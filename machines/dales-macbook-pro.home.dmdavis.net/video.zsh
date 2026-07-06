#!/usr/bin/env zsh

# Convert an FCP timecode to a 0-based frame number. ';' before the frames
# field means drop-frame (29.97/59.94) and gets SMPTE drop-frame correction.
# Leading fields may be omitted: "11;23" == "00;00;11;23".
_tc_to_frame() {
    local tc="$1" fps="$2"
    local drop=0
    [[ "$tc" == *\;* ]] && drop=1

    local -a parts
    parts=("${(@s/:/)${tc//;/:}}")
    local n=${#parts[@]} h=0 m=0 s=0 f=0
    case $n in
        4) h=${parts[1]} m=${parts[2]} s=${parts[3]} f=${parts[4]} ;;
        3) m=${parts[1]} s=${parts[2]} f=${parts[3]} ;;
        2) s=${parts[1]} f=${parts[2]} ;;
        *) echo "Bad timecode: $tc" >&2; return 1 ;;
    esac

    local frame=$(( (h*3600 + m*60 + s) * fps + f ))
    if [[ $drop -eq 1 ]]; then
        local total_min=$(( h*60 + m ))
        local df=$(( fps / 15 ))   # dropped labels/min: 2 @30fps nominal, 4 @60fps
        frame=$(( frame - df * (total_min - total_min / 10) ))
    fi
    echo $frame
}

# Nominal (rounded) integer frame rate of a clip, e.g. 60000/1001 -> 60.
_nominal_fps() {
    local rate num den
    rate=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 "$1") || return 1
    num=${rate%/*} den=${rate#*/}
    echo $(( (num + den / 2) / den ))
}

# Diagnose blown-out highlights in a video file.
# Runs per-frame luma stats and renders a one-frame histogram PNG.
# Usage: hlcheck <file> [frame-number | fcp-timecode]
# Ex:    hlcheck clip.mov
# Ex:    hlcheck clip.mov 120
# Ex:    hlcheck clip.mov 11;23
# Ex:    hlcheck clip.mov 00;01;11;23
hlcheck() {
    if [[ $# -lt 1 ]]; then
        echo "USAGE: hlcheck <file> [frame-number | fcp-timecode]"
        echo ""
        echo "OPTIONS:"
        echo "  frame-number  Frame to use for histogram, 1-based (default: 1)"
        echo "  fcp-timecode  FCP source timecode, e.g. 11;23 or 00;01;11;23 —"
        echo "                ';' before the frames field means drop-frame"
        echo ""
        echo "EXAMPLES:"
        echo "  hlcheck clip.mov"
        echo "  hlcheck clip.mov 120"
        echo "  hlcheck clip.mov 11;23"
        return 1
    fi

    local input="$1"
    local arg="${2:-1}"
    local histogram="${input:r}_histogram.png"

    if [[ ! -f "$input" ]]; then
        echo "File not found: $input"
        return 1
    fi

    local n0
    if [[ "$arg" == *[:\;]* ]]; then
        local fps
        fps=$(_nominal_fps "$input") || return 1
        n0=$(_tc_to_frame "$arg" "$fps") || return 1
        echo "=== $arg @ ${fps}fps nominal → frame $((n0 + 1)) ==="
    else
        n0=$((arg - 1))
    fi

    echo "=== Luma stats (signalstats) ==="
    ffmpeg -i "$input" -vf "signalstats,metadata=print" -f null - 2>&1 \
        | grep -E "^\[Parsed_metadata.*(frame:|YMIN|YMAX|YAVG)"

    echo ""
    echo "=== Histogram: frame $((n0 + 1)) → $histogram ==="
    ffmpeg -i "$input" -vf "select=eq(n\,$n0),histogram" -frames:v 1 -y "$histogram" \
        && [[ -s "$histogram" ]] && echo "Saved: $histogram" \
        || { echo "Histogram render failed (frame $((n0 + 1)) out of range?)"; return 1; }
}

# Restore real recording dates on transcoded AVCHD clips. Transcoders (e.g.
# EditReady) discard the per-clip date stored in BDMV/CLIPINF/*.CPI and the
# H264:DateTimeOriginal embedded in the .MTS stream, stamping the transcode
# time instead. Filenames don't line up after export renames clips, so this
# matches source .MTS to converted files by clip duration instead.
# Usage: avchd_restore_dates <avchd-dir> <converted-dir> [tolerance-seconds]
# Ex:    avchd_restore_dates "Video 1/AVCHD" "Video 1/ProRes"
# Ex:    avchd_restore_dates "Video 1/AVCHD" "Video 1/ProRes" 1.0
avchd_restore_dates() {
    if [[ $# -lt 2 ]]; then
        echo "USAGE: avchd_restore_dates <avchd-dir> <converted-dir> [tolerance-seconds]"
        echo ""
        echo "  <avchd-dir>        Folder containing BDMV/STREAM/*.MTS (the AVCHD root)"
        echo "  <converted-dir>    Folder of transcoded files (e.g. ProRes .mov) to date-stamp"
        echo "  tolerance-seconds  Max duration difference to call a match (default: 0.5)"
        echo ""
        echo "Copies the source clip's real recording date onto the matched converted"
        echo "file's QuickTime CreateDate and filesystem dates. Ambiguous duration"
        echo "matches (more than one converted file within tolerance) are skipped, not"
        echo "guessed."
        echo ""
        echo "EXAMPLES:"
        echo "  avchd_restore_dates \"Video 1/AVCHD\" \"Video 1/ProRes\""
        return 1
    fi

    setopt local_options null_glob

    local avchd_dir="$1" dst_dir="$2"
    local tolerance="${3:-0.5}"
    local stream_dir="$avchd_dir/BDMV/STREAM"

    if [[ ! -d "$stream_dir" ]]; then
        echo "No BDMV/STREAM found under: $avchd_dir"
        return 1
    fi
    if [[ ! -d "$dst_dir" ]]; then
        echo "Converted-dir not found: $dst_dir"
        return 1
    fi

    local -a src_files dst_files all_dst
    local f
    src_files=("$stream_dir"/*.MTS)
    all_dst=("$dst_dir"/*)
    for f in "${all_dst[@]}"; do
        [[ -f "$f" ]] && dst_files+=("$f")
    done

    if [[ ${#src_files[@]} -eq 0 ]]; then
        echo "No .MTS files in $stream_dir"
        return 1
    fi
    if [[ ${#dst_files[@]} -eq 0 ]]; then
        echo "No files in $dst_dir"
        return 1
    fi

    # One ffprobe call per converted file up front instead of per-comparison.
    local -A dst_duration dst_used
    local dur
    for f in "${dst_files[@]}"; do
        dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f" 2>/dev/null)
        [[ -n "$dur" ]] && dst_duration[$f]=$dur
    done

    local matched=0 unmatched=0 ambiguous=0
    for f in "${src_files[@]}"; do
        local src_dur
        src_dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f" 2>/dev/null)
        if [[ -z "$src_dur" ]]; then
            echo "SKIP      : $f:t — no readable duration"
            ((unmatched++))
            continue
        fi

        local best="" best_diff="" diff candidate
        local -a ties=()
        for candidate in "${dst_files[@]}"; do
            [[ -n "${dst_used[$candidate]}" ]] && continue
            [[ -z "${dst_duration[$candidate]}" ]] && continue
            diff=$(awk -v a="$src_dur" -v b="${dst_duration[$candidate]}" 'BEGIN{d=a-b; if(d<0)d=-d; print d}')
            if awk -v d="$diff" -v t="$tolerance" 'BEGIN{exit !(d<=t)}'; then
                ties+=("$candidate")
                if [[ -z "$best_diff" ]] || awk -v d="$diff" -v bd="$best_diff" 'BEGIN{exit !(d<bd)}'; then
                    best="$candidate"
                    best_diff="$diff"
                fi
            fi
        done

        if [[ ${#ties[@]} -eq 0 ]]; then
            echo "NO MATCH  : $f:t (${src_dur}s)"
            ((unmatched++))
            continue
        fi
        if [[ ${#ties[@]} -gt 1 ]]; then
            # Duration alone is ambiguous — break the tie if exactly one
            # candidate shares the source clip's numeric filename stem
            # (e.g. 00012.MTS -> 00012.mov), which some transcoders preserve.
            local src_num="${f:t:r}"
            local -a same_num=()
            for candidate in "${ties[@]}"; do
                [[ "${candidate:t:r}" == "$src_num" ]] && same_num+=("$candidate")
            done
            if [[ ${#same_num[@]} -eq 1 ]]; then
                best="${same_num[1]}"
                echo "TIEBREAK  : $f:t (${src_dur}s) — ${#ties[@]} duration matches, resolved by matching filename number"
            else
                echo "AMBIGUOUS : $f:t (${src_dur}s) matches ${#ties[@]} converted files within ${tolerance}s — skipping, fix manually"
                ((ambiguous++))
                continue
            fi
        fi

        dst_used[$best]=1
        local src_date
        src_date=$(exiftool -H264:DateTimeOriginal -s3 "$f" 2>/dev/null)
        [[ -z "$src_date" ]] && src_date=$(exiftool -FileModifyDate -s3 "$f" 2>/dev/null)
        if [[ -z "$src_date" ]]; then
            echo "NO DATE   : $f:t — source has no readable date"
            ((unmatched++))
            continue
        fi

        exiftool -q -overwrite_original \
            "-QuickTime:CreateDate=$src_date" \
            "-FileCreateDate=$src_date" \
            "-FileModifyDate=$src_date" \
            "$best" >/dev/null

        echo "MATCHED   : $f:t -> $best:t  ($src_date)"
        ((matched++))
    done

    echo ""
    echo "Done: $matched matched, $ambiguous ambiguous, $unmatched unmatched (of ${#src_files[@]} source clips)"
}
