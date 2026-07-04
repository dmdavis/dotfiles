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
