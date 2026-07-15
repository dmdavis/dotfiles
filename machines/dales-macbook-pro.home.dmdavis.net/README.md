# dales-macbook-pro.home.dmdavis.net

Machine-specific shell configuration for the MacBook Pro. Loaded automatically
by `.zshrc` at startup.

| File | Purpose |
|------|---------|
| `Brewfile` | Homebrew packages and casks for this machine. |
| `env.zsh` | `PATH` additions (Rancher Desktop, toolbox, local bin). |
| `nas.zsh` | SSH aliases and file-transfer helpers for the home NAS. |
| `video.zsh` | Video inspection and metadata-restoration utilities. |

## Tools

### NAS / home network (`nas.zsh`)

| Tool | Description |
|------|-------------|
| [rsync](https://rsync.samba.org) | Used by `upvid` to transfer video files to the NAS over SSH. |
| [trash](https://github.com/ali-rantakari/trash) | Moves the local source to Trash after a successful `upvid` upload. |

`ssh` and `scp` are used by the NAS aliases and `cpnas`/`nascp` helpers; both
ship with macOS.

### Video (`video.zsh`)

| Tool | Description |
|------|-------------|
| [ffmpeg](https://ffmpeg.org) | Runs luma signal-stats and renders histogram frames in `hlcheck`. |
| [ffprobe](https://ffmpeg.org) | Reads clip duration and frame rate; bundled with ffmpeg. |
| [ExifTool](https://exiftool.org) | Reads recording dates from `.MTS` streams and writes them onto transcoded clips in `avchd_restore_dates`. |
