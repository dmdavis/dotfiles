#!/usr/bin/env zsh

# Load actual credentials from untracked files
# shellcheck source=./local/nas-secrets.zsh
[[ -f "$DOTFILES/machines/$HOSTNAME/local/nas-secrets.zsh" ]] && source "$DOTFILES/machines/$HOSTNAME/local/nas-secrets.zsh"

alias nas='ssh -p $NAS_SSH_PORT $NAS_USER@$NAS_IP'
alias nuc='ssh -p $NUC_SSH_PORT $NUC_USER@$NUC_IP'
alias pihole='ssh -p $PI_HOLE_SSH_PORT $PI_HOLE_USER@$PI_HOLE_IP'
alias pi-hole='ssh -p $PI_HOLE_SSH_PORT $PI_HOLE_USER@$PI_HOLE_IP'

# TODO: Review nas.zsh functions; improve or remove

# Copy a local file to a remote directory on the NAS
# Ex: cpnas ~/foo ~/
cpnas() {
    scp -P "$NAS_SSH_PORT" "$1" "$NAS_USER@$NAS_IP:$2"
}

# Copy a file on the NAS to a local directory
# Ex: nascp ~/.gitignore ~/
nascp() {
    scp -P "$NAS_SSH_PORT" "$NAS_USER@$NAS_IP:$1" "$2"
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
    local remote="$NAS_USER@$NAS_IP"

    # Check if remote directory exists; prompt to create if not
    if ! ssh -q -p "$NAS_SSH_PORT" "$remote" "test -d '$remote_path'" 2>/dev/null; then
        echo "Remote directory does not exist: $remote_path"
        if $dry_run; then
            echo "[dry-run] Would prompt to create '$remote_path'"
        else
            echo -n "Create it? [y/N] "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                ssh -p "$NAS_SSH_PORT" "$remote" "mkdir -p '$remote_path'"
            else
                echo "Aborting."
                return 1
            fi
        fi
    fi

    local -a rsync_opts=(-azvhP -e "ssh -p $NAS_SSH_PORT")
    $dry_run && rsync_opts+=(--dry-run)

    echo "Copying '$source' → $NAS_IP:$remote_path"
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