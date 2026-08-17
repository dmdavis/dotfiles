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
function lt  { lsd -lh --tree @args }
function lr  { lsd -lh --tree @args }
function lk  { lsd -lh -Sr @args }
function lx  { lsd -lh -X @args }
function lm  { lsd -lhA @args | Out-Host -Paging }
function o   { lsd -lhA --permission octal @args }
function ot  { lsd -lhA --permission octal --tree @args }

# Dotfiles only / dot-directories only. Colour is dropped for these two: the
# trailing-slash test has to look at the raw text, and ANSI reset codes sit
# between the name and the `/`.
function ldf { lsd -AF --ignore-glob '[!.]*' @args | Where-Object { $_ -notmatch '/\s*$' } }
function ldd { lsd -AF --ignore-glob '[!.]*' @args | Where-Object { $_ -match  '/\s*$' } }
