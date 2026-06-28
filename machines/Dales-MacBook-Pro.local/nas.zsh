#!/usr/bin/env zsh

alias nas='ssh nas.home.dmdavis.net'
alias nuc='ssh nuc10.home.dmdavis.net'
alias pihole='ssh pi-hole.home.dmdavis.net'
alias pi-hole='ssh pi-hole.home.dmdavis.net'

# TODO: Review nas.zsh functions; improve or remove

# Copy a local file to a remote directory on the NAS
# Ex: cpnas ~/foo ~/
cpnas() {
    scp "$1" "nas.home.dmdavis.net:$2"
}

# Copy a file on the NAS to a local directory
# Ex: nascp ~/.gitignore ~/
nascp() {
    scp "nas.home.dmdavis.net:$1" "$2"
}

# Upload a movie or TV show to a subfolder of the `/volume1/video` NAS share.
# Usage: upvid [--dry-run] <local-file-or-folder> <nas-video-sub-path>
# Ex:    upvid some-movie.mkv Comedy
# Ex:    upvid some-show/ "Prime/The Boys/Season 05"
upvid() {
    local dry_run=false
    local -a positional

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run) dry_run=true; shift ;;
            -h|--help)
                echo "USAGE: upvid [--dry-run] <local-file-or-folder> <nas-video-sub-path>"
                echo ""
                echo "OPTIONS:"
                echo "  --dry-run   Show what would be transferred without copying or trashing"
                echo "  -h, --help  Show this help message"
                echo ""
                echo "EXAMPLES:"
                echo "  upvid some-movie.mkv Comedy"
                echo "  upvid some-show/ \"Prime/The Boys/Season 05\""
                echo "  upvid --dry-run some-movie.mkv \"Science Fiction\""
                return 0
                ;;
            --) shift; positional+=("$@"); break ;;
            *) positional+=("$1"); shift ;;
        esac
    done

    if [[ ${#positional[@]} -lt 2 ]]; then
        echo "USAGE: upvid [--dry-run] <local-file-or-folder> <nas-video-sub-path>"
        return 1
    fi

    local source="${positional[1]}"
    local dest="${positional[2]}"
    local remote_path="/volume1/video/$dest"
    local remote="nas.home.dmdavis.net"

    # Check if remote directory exists; prompt to create if not
    if ! ssh -q "$remote" "test -d '$remote_path'" 2>/dev/null; then
        echo "Remote directory does not exist: $remote_path"
        if $dry_run; then
            echo "[dry-run] Would prompt to create '$remote_path'"
        else
            echo -n "Create it? [y/N] "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                ssh "$remote" "mkdir -p '$remote_path'"
            else
                echo "Aborting."
                return 1
            fi
        fi
    fi

    local -a rsync_opts=(-azvhP --protect-args -e ssh)
    $dry_run && rsync_opts+=(--dry-run)

    echo "Copying '$source' → $remote:$remote_path"
    if rsync "${rsync_opts[@]}" "$source" "$remote:$remote_path"; then
        if ! $dry_run; then
            echo -n "Move '$source' to Trash? [y/N] "
            read -r response
            [[ "$response" =~ ^[Yy]$ ]] && trash "$source"
        fi
    else
        echo "rsync failed for '$source'"
        return 1
    fi
}