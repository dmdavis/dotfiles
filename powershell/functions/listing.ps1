# listing.ps1 — the lsd family.
#
# In zsh these chain: ls -> lsd, ll -> `ls -lh`, l -> `ll -A`. PowerShell
# aliases do NOT chain, so each is spelled out against lsd directly.
#
# `ls` is a built-in alias for Get-ChildItem on Windows and must be removed
# before the function can be reached at all — resolution order is
# Alias -> Function -> Cmdlet.

if (-not (Get-Command lsd -ErrorAction SilentlyContinue)) { return }

Remove-Alias -Name ls -Force -ErrorAction SilentlyContinue
Remove-Alias -Name ll -Force -ErrorAction SilentlyContinue

function ls  { lsd @args }
function ll  { lsd -lh @args }
function l   { lsd -lhA @args }
function lo  { lsd -lhA --permission octal @args }
function llo { lsd -lh  --permission octal @args }
# Tree views default to --depth 2 on Windows. `lt` in the home directory
# otherwise runs effectively forever: ~ holds 13 reparse points, including the
# legacy junctions Application Data -> AppData\Roaming and My Documents ->
# Documents, which are infinite loops, plus OneDrive, iCloudDrive and
# SynologyDrive. macOS has no equivalent, which is why the zsh original needs
# no depth limit. An explicit --depth still wins.
function lt  { if ($args -contains '--depth') { lsd -lh --tree @args } else { lsd -lh --tree --depth 2 @args } }
function lr  { if ($args -contains '--depth') { lsd -lh --tree @args } else { lsd -lh --tree --depth 2 @args } }
function lk  { lsd -lh -Sr @args }
function lx  { lsd -lh -X @args }
function lm  { lsd -lhA @args | Out-Host -Paging }
function o   { lsd -lhA --permission octal @args }
function ot  { if ($args -contains '--depth') { lsd -lhA --permission octal --tree @args } else { lsd -lhA --permission octal --tree --depth 2 @args } }

# Dotfiles only / dot-directories only. Colour is dropped for these two: the
# trailing-slash test has to look at the raw text, and ANSI reset codes sit
# between the name and the `/`.
function ldf { lsd -AF --ignore-glob '[!.]*' @args | Where-Object { $_ -notmatch '/\s*$' } }
function ldd { lsd -AF --ignore-glob '[!.]*' @args | Where-Object { $_ -match  '/\s*$' } }
