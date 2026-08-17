#
# unixmap.psd1 — the single source of truth for the zsh-to-PowerShell mapping.
#
# Three consumers read this file and nothing else:
#   1. tools/Build-Aliases.ps1  — emits generated-aliases.ps1 from a live
#                                 `zsh -ic alias` dump plus the Rules below.
#   2. Get-UnixMap / unixhelp   — the discovery command.
#   3. The vault note           — Projects/PowerShell Parity on Windows.md
#
# It deliberately contains NO CODE. Shims are real .ps1 files under functions/
# so they get syntax highlighting and are parse-checked at load; this file only
# describes and classifies them. Anything in the alias dump that no rule
# matches is reported as UNCLASSIFIED rather than silently dropped — that
# report is the mechanism that keeps this file honest as the Mac side drifts.
#
# Tiers:
#   A  ported mechanically from the dump; the underlying tool exists on Windows
#   B  needs a hand-written PowerShell shim
#   C  does not apply on Windows — kept, with the reason, because "why isn't
#      this here" is the question a discovery command should answer
#
@{
    SchemaVersion = 1

    # ---------------------------------------------------------------------
    # READ THIS BEFORE WRITING ANY CODE THAT CONSUMES THIS FILE.
    # ---------------------------------------------------------------------
    Matching = @{
        CaseSensitive = $true
        Why = @'
Zim's git grammar is case-significant and reuses letters at both cases with
DIFFERENT meanings. GSx is git-submodule-remove; Gsx is git stash drop. GbX
force-deletes a branch; Gbx picks one interactively.

PowerShell compares case-INSENSITIVELY by default — -contains, -match, -eq,
-in, hashtable keys and Sort-Object all ignore case. Using any of them here
silently conflates the two halves of the grammar. This was not hypothetical:
the first run of the classifier excluded `git stash drop` because the exclude
list contains `GSx`.

Consumers MUST use -ccontains, -cmatch, -ceq, -cin, and
[System.StringComparer]::Ordinal for any dictionary keyed by alias name.

It goes further than comparisons: VARIABLE NAMES are case-insensitive too.
$gsx and $GSx are the same variable. A test written to prove Gsx and GSx stay
distinct did exactly that, assigned both to one variable, and reported a
false failure. Do not name variables after the aliases they hold.
'@
    }

    Source = @{
        Command = 'zsh -ic alias'
        Why     = @'
Only ~58 of 225 live aliases are authored in this repo. Zim's git and homebrew
modules synthesise the other 167 at shell start, so the files are not the
inventory — the running shell is.
'@
    }

    # ---------------------------------------------------------------------
    # Classification rules, applied to each dump entry in array order.
    # First match wins.
    # ---------------------------------------------------------------------
    Rules = @(
        @{
            Match    = '^G'
            Tier     = 'A'
            Group    = 'git'
            Requires = 'git'
            Note     = 'Zim git-module grammar: verb letter, then object letter, capital = more destructive or more thorough.'
        }
        @{
            Match = '^(brew|cask)'
            Tier  = 'C'
            Group = 'packages'
            Note  = 'Homebrew is macOS-only. See the Packages section for the small winget set that replaces it.'
        }
        @{
            Match    = '^(l|ll|lo|llo|lt|lr|lk|lx|lm|ldf|ldd|ls|o|ot)$'
            Tier     = 'B'
            Group    = 'listing'
            Requires = 'lsd'
            Note     = 'The zsh versions chain alias-to-alias (ll -> ls -> lsd). PowerShell aliases do not chain, so each becomes a function.'
        }
        @{
            Match = '^(lc|llc)$'
            Tier  = 'C'
            Group = 'listing'
            Note  = 'lolcat has no maintained Windows build. Not worth a shim.'
        }
        @{
            Match    = '^(nas|nuc|pihole|pi-hole)$'
            Tier     = 'C'
            Group    = 'hosts'
            Note     = 'SSH host shortcuts are machine-scoped, and this repo is public. Define them per-machine, not here.'
        }
    )

    # ---------------------------------------------------------------------
    # Dump entries the generator must NOT emit, with the reason. These are the
    # Zim git aliases that call helper SCRIPTS shipped with the module rather
    # than plain git — porting them means porting an interactive TUI, which is
    # not worth it for aliases that get used a few times a year.
    # ---------------------------------------------------------------------
    Exclude = @(
        @{ Name = 'G?';   Reason = 'Calls git-alias-lookup against a Zim module path that does not exist here. unixhelp supersedes it.' }
        @{ Name = 'Gbx';  Reason = 'git-branch-delete-interactive — an fzf-style picker, not a git invocation.' }
        @{ Name = 'GbX';  Reason = 'As Gbx, with --force.' }
        @{ Name = 'GsX';  Reason = 'git-stash-clear-interactive — interactive picker.' }
        @{ Name = 'Gsr';  Reason = 'git-stash-recover — recovers dangling stashes; non-trivial script.' }
        @{ Name = 'GSm';  Reason = 'git-submodule-move — non-trivial script.' }
        @{ Name = 'GSx';  Reason = 'git-submodule-remove — non-trivial script.' }
        @{ Name = 'GbG';  Reason = 'Needs git-branch-remote-tracking plus xargs -r, which has no direct PowerShell equivalent.' }
    )

    # ---------------------------------------------------------------------
    # Variables the git log aliases interpolate. Copied verbatim from Zim's
    # git module so `Gl`, `Glo`, `Glg` and the other seven render identically
    # to the Mac. Emitting these is what unblocks 10 of the 24 aliases that
    # would otherwise be dropped.
    # ---------------------------------------------------------------------
    GitLogFormats = @{
        Fuller        = '%C(bold yellow)commit %H%C(auto)%d%n%C(bold)Author: %C(blue)%an <%ae> %C(cyan)%ai (%ar)%n%C(bold)Commit: %C(blue)%cn <%ce> %C(cyan)%ci (%cr)%C(reset)%n%+B'
        Oneline       = '%C(bold yellow)%h%C(reset) %s%C(auto)%d%C(reset)'
        OnelineMedium = '%C(bold yellow)%h%C(reset) %<(50,trunc)%s %C(bold blue)%an %C(cyan)%as (%ar)%C(auto)%d%C(reset)'
    }

    # ---------------------------------------------------------------------
    # Built-in PowerShell aliases that shadow a name we define. The generator
    # emits `Remove-Alias -Force` for each before defining the function.
    #
    # This is not optional. Resolution order is
    #   Alias -> Function -> Cmdlet -> ExternalScript -> Application
    # so a function named `ls` is unreachable while the built-in alias exists,
    # and the failure is silent.
    # ---------------------------------------------------------------------
    Collisions = @('ls', 'll', 'cat', 'cp', 'mv', 'rm', 'man', 'ps', 'sort', 'echo', 'pwd', 'type', 'diff', 'where', 'select', 'history', 'tee', 'sleep')

    # ---------------------------------------------------------------------
    # Built-ins that mean something DIFFERENT and are left alone. These are
    # not overridden — they are listed so unixhelp can warn about them, which
    # is the more useful thing for someone arriving from zsh.
    # ---------------------------------------------------------------------
    Traps = @(
        @{ Name = 'diff';  Is = 'Compare-Object'; Note = 'Takes -ReferenceObject/-DifferenceObject, not two paths. `diff a b` does not do what you mean.' }
        @{ Name = 'sort';  Is = 'Sort-Object';    Note = 'Sorts objects by property, not lines of text.' }
        @{ Name = 'ps';    Is = 'Get-Process';    Note = 'No BSD/SysV flags. `ps aux` is an error.' }
        @{ Name = 'where'; Is = 'Where-Object';   Note = 'Not the path lookup. Use `which` (shimmed) or Get-Command.' }
        @{ Name = 'cat';   Is = 'Get-Content';    Note = 'Returns an array of lines, not a byte stream. -Raw gives you one string.' }
        @{ Name = 'echo';  Is = 'Write-Output';   Note = 'Emits objects into the pipeline; it is not a printf.' }
        @{ Name = 'ft';    Is = 'Format-Table';   Note = 'DISPLAY ONLY. Anything piped past it is formatting records, not data. The single most common way to break a script.' }
        @{ Name = 'fl';    Is = 'Format-List';    Note = 'As ft.' }
    )

    # ---------------------------------------------------------------------
    # Tier B — hand-written shims. Metadata only; the code is in functions/.
    # ---------------------------------------------------------------------
    Shims = @(
        @{ Name = 'ls';       File = 'listing.ps1';      Group = 'listing';   Requires = 'lsd'; Removes = 'ls'; Note = 'Plain lsd. The built-in ls alias must be removed first or this is unreachable.' }
        @{ Name = 'll';       File = 'listing.ps1';      Group = 'listing';   Requires = 'lsd'; Removes = 'll'; Note = 'lsd -lh. The zsh original chained through two aliases; PowerShell aliases do not chain.' }
        @{ Name = 'l';        File = 'listing.ps1';      Group = 'listing';   Requires = 'lsd'; Note = 'lsd -lhA' }
        @{ Name = 'lt';       File = 'listing.ps1';      Group = 'listing';   Requires = 'lsd'; Note = 'Tree view.' }
        @{ Name = 'lr';       File = 'listing.ps1';      Group = 'listing';   Requires = 'lsd'; Note = 'Tree view; same as lt in the zsh set.' }
        @{ Name = 'lo';       File = 'listing.ps1';      Group = 'listing';   Requires = 'lsd'; Note = 'Octal permissions.' }
        @{ Name = 'llo';      File = 'listing.ps1';      Group = 'listing';   Requires = 'lsd'; Note = 'Octal permissions, without -A.' }
        @{ Name = 'o';        File = 'listing.ps1';      Group = 'listing';   Requires = 'lsd'; Note = 'Same as lo.' }
        @{ Name = 'ot';       File = 'listing.ps1';      Group = 'listing';   Requires = 'lsd'; Note = 'Octal permissions, tree.' }
        @{ Name = 'lk';       File = 'listing.ps1';      Group = 'listing';   Requires = 'lsd'; Note = 'Sorted by size, ascending.' }
        @{ Name = 'lx';       File = 'listing.ps1';      Group = 'listing';   Requires = 'lsd'; Note = 'Sorted by extension.' }
        @{ Name = 'lm';       File = 'listing.ps1';      Group = 'listing';   Requires = 'lsd'; Note = 'Paged, via Out-Host -Paging rather than piping to less.' }
        @{ Name = 'ldf';      File = 'listing.ps1';      Group = 'listing';   Requires = 'lsd'; Note = 'Dotfiles only. Colour is dropped: the trailing-slash test reads raw text and ANSI reset codes sit between the name and the slash.' }
        @{ Name = 'ldd';      File = 'listing.ps1';      Group = 'listing';   Requires = 'lsd'; Note = 'Dot-directories only. Same colour caveat as ldf.' }
        @{ Name = 'which';    File = 'legacy-shims.ps1'; Group = 'files';     Note = 'Currently shells out to where.exe, so it misses functions, aliases and cmdlets. Get-Command is the better answer; see Idioms.' }
        @{ Name = 'touch';    File = 'legacy-shims.ps1'; Group = 'files';     Note = 'Creates the file or bumps LastWriteTime.' }
        @{ Name = 'printenv'; File = 'legacy-shims.ps1'; Group = 'env';       Note = 'Get-ChildItem env:' }
        @{ Name = 'mkcd';     File = 'nav.ps1';          Group = 'navigation'; Note = 'mkdir then cd, as in zsh.' }
        @{ Name = 'df';       File = 'system.ps1';       Group = 'system';    Note = 'Human-readable free space per volume.' }
        @{ Name = 'du';       File = 'system.ps1';       Group = 'system';    Note = 'Recursive size of a path. Slower than the GNU original; PowerShell has no stat cache.' }
        @{ Name = 'alg';      File = 'discovery.ps1';    Group = 'discovery'; Note = 'Was `alias | rg`. Now searches aliases AND functions, which is what you actually want here.' }
        @{ Name = 'grep';     File = 'discovery.ps1';    Group = 'discovery'; Requires = 'rg'; Note = 'Routed to ripgrep. Windows has no grep; findstr is not a substitute.' }
        @{ Name = 'get';      File = 'net.ps1';          Group = 'net';       Note = 'Resumable download keeping the remote name and timestamp. curl.exe ships with Windows, so this is a flag wrapper, not a reimplementation — but it must call curl.exe explicitly, since PowerShell 5.1 aliased `curl` to Invoke-WebRequest and the muscle memory is dangerous.' }
        @{ Name = 'git-root'; File = 'git-helpers.ps1';  Group = 'git';       Requires = 'git'; Note = 'git rev-parse --show-toplevel. Unblocks G..' }
        @{ Name = 'git-branch-current'; File = 'git-helpers.ps1'; Group = 'git'; Requires = 'git'; Note = 'git branch --show-current. Unblocks Gpc and Gpp.' }
    )

    # ---------------------------------------------------------------------
    # Tier C — not ported, and why. This section is the point of the whole
    # exercise: the answer to "where did my alias go" should be a sentence,
    # not silence.
    # ---------------------------------------------------------------------
    # `Names` is what the classifier matches on; `Name` is the display label.
    NotPorted = @(
        @{ Name = 'brew* / cask*'; Names = @(); Count = 28; Reason = 'Homebrew is macOS-only. Matched by Rule, not by name.'; Instead = 'The Packages set below — deliberately small, not a 28-alias mirror.' }
        @{ Name = 'n';             Names = @('n');  Reason = 'nnn has no Windows build.'; Instead = 'Out-ConsoleGridView, or yazi if it ever lands here.' }
        @{ Name = 'lc / llc';      Names = @('lc','llc'); Reason = 'lolcat has no maintained Windows build.' }
        @{ Name = 'ff';            Names = @('ff'); Reason = 'fastfetch exists on Windows, but the shim selects a macOS terminal-image protocol (iTerm/kitty).'; Instead = 'Plain fastfetch.' }
        @{ Name = 'y';             Names = @('y');  Reason = 'yazi wrapper; the cwd-file dance is shell-specific.' }
        @{ Name = 'sync_brewfile'; Names = @('sync_brewfile'); Reason = 'Homebrew.'; Instead = 'winget export, once bootstrap.ps1 exists.' }
        @{ Name = 't';             Names = @('t');  Reason = 'The live alias is t=task, which shadows the tmux function of the same name in .zshrc. Neither ports: task is not installed here and tmux does not exist on Windows.'; Instead = 'Windows Terminal panes.' }
        @{ Name = 'tg';            Names = @('tg'); Reason = 'terragrunt is not installed on Windows. It has a Windows build if it is ever wanted.' }
        @{ Name = 'which-command'; Names = @('which-command'); Reason = 'zsh `whence` has no direct equivalent.'; Instead = 'Get-Command, which resolves aliases, functions and cmdlets as well as files — see the `which` idiom.' }
        @{ Name = 'nas / nuc / pihole'; Names = @('nas','nuc','pihole','pi-hole'); Reason = 'Machine-scoped SSH shortcuts, and this repo is public.' }
    )

    # ---------------------------------------------------------------------
    # The small winget set. NOT a mirror of the 28 brew aliases — the aim is
    # the handful of verbs worth having at the prompt when the habit so far
    # has been GUI updaters.
    # ---------------------------------------------------------------------
    Packages = @(
        @{ Name = 'wgo'; Runs = 'winget upgrade';                    Note = 'What has updates pending. The one to run first.' }
        @{ Name = 'wgU'; Runs = 'winget upgrade --all';              Note = 'Upgrade everything. Capital = the sweeping one, as in the brew grammar.' }
        @{ Name = 'wgi'; Runs = 'winget install --exact --id';       Note = '--exact --id avoids the interactive disambiguation prompt.' }
        @{ Name = 'wgs'; Runs = 'winget search';                     Note = 'Find a package id.' }
        @{ Name = 'wgl'; Runs = 'winget list';                       Note = 'What is installed, including things winget did not install.' }
        @{ Name = 'wgx'; Runs = 'winget uninstall --exact --id';     Note = 'Uninstall.' }
    )

    # ---------------------------------------------------------------------
    # Tools the shims depend on, with verified winget ids. Checked against
    # `winget show --exact --id` on 2026-08-16 rather than guessed.
    # ---------------------------------------------------------------------
    Tools = @(
        @{ Name = 'rg';        WingetId = 'BurntSushi.ripgrep.MSVC'; Install = $true;  Provides = @('grep') }
        @{ Name = 'fd';        WingetId = 'sharkdp.fd';              Install = $true;  Provides = @('find') }
        @{ Name = 'lsd';       WingetId = 'lsd-rs.lsd';              Install = $true;  Provides = @('ls', 'll', 'l', 'lt', 'lo') }
        @{ Name = 'bat';       WingetId = 'sharkdp.bat';             Install = $false; Provides = @('cat'); Note = 'Already present on BEAST via Chocolatey under UniGetUI. Installing again through winget would give the box two copies from two package managers.' }
        @{ Name = 'fzf';       WingetId = 'junegunn.fzf';            Install = $true;  Provides = @('Ctrl+R', 'Ctrl+T') }
        @{ Name = 'jq';        WingetId = 'jqlang.jq';               Install = $true }
        @{ Name = 'yq';        WingetId = 'MikeFarah.yq';            Install = $true }
        @{ Name = 'delta';     WingetId = 'dandavison.delta';        Install = $true;  Note = 'git pager.' }
        @{ Name = 'starship';  WingetId = 'Starship.Starship';       Install = $true;  Note = 'Chosen over oh-my-posh: cross-shell, and the Mac already runs asciiship, Zim''s starship-alike.' }
        @{ Name = 'zoxide';    WingetId = 'ajeetdsouza.zoxide';      Install = $true;  Provides = @('j') }
        @{ Name = 'gsudo';     WingetId = 'gerardog.gsudo';          Install = $true;  Provides = @('sudo') }
        @{ Name = 'eza';       WingetId = 'eza-community.eza';       Install = $false; Note = 'Alternative to lsd. Listed so the choice is recorded, not installed.' }
        @{ Name = 'oh-my-posh'; WingetId = 'JanDeDobbeleer.OhMyPosh'; Install = $false; Note = 'Deferred. Worth trying in a subshell alongside starship rather than swapping the prompt outright.' }
    )

    # ---------------------------------------------------------------------
    # PowerShell modules. Installed from the PSGallery by bootstrap.ps1, not by
    # winget — different ecosystem, different installer.
    # ---------------------------------------------------------------------
    Modules = @(
        @{ Name = 'PSReadLine';                           Install = $true;  Note = 'Already present at 2.4.5 on BEAST; listed so a fresh machine gets a version new enough for ListView prediction.' }
        @{ Name = 'PSFzf';                                Install = $true;  Requires = 'fzf'; Note = 'Ctrl+R and Ctrl+T bindings.' }
        @{ Name = 'Terminal-Icons';                       Install = $true;  Note = 'Needs a Nerd Font in the terminal or it renders as boxes.' }
        @{ Name = 'CompletionPredictor';                  Install = $true;  Note = 'Feeds ListView prediction from completions as well as history.' }
        @{ Name = 'Microsoft.PowerShell.ConsoleGuiTools'; Install = $true;  Note = 'Out-ConsoleGridView - an fzf-for-objects picker.' }
        @{ Name = 'posh-git';                             Install = $false; Note = 'Not needed: starship renders git status itself, and posh-git would duplicate it at a cost to prompt latency.' }
    )

    # ---------------------------------------------------------------------
    # What a zsh user actually needs to know about PowerShell, as opposed to
    # which alias maps to what. Surfaced by `unixhelp -Idioms`.
    # ---------------------------------------------------------------------
    Idioms = @(
        @{
            Topic   = 'objects'
            Summary = 'The pipeline carries objects, not text.'
            Detail  = 'No awk, no cut, no field numbers. `Get-Process | Where-Object CPU -gt 10 | Select-Object Name, CPU`. If you find yourself parsing a string, look for a property first.'
        }
        @{
            Topic   = 'shorthand'
            Summary = '? is Where-Object and % is ForEach-Object.'
            Detail  = 'The two workhorses have single-character aliases, which is what makes one-liners bearable: `ls | ? Length -gt 1MB | % Name`. Note ? is NOT a glob here - PowerShell wildcards are * and ?, but ? at the START of a command position is Where-Object.'
        }
        @{
            Topic   = 'formatting'
            Summary = 'Format-Table and Format-List are terminal output, not data.'
            Detail  = 'Anything piped past ft/fl receives formatting records. Use Select-Object to shape data, and put ft LAST if at all. This is the single most common way to break a working script.'
        }
        @{
            Topic   = 'exit-codes'
            Summary = '$? and $LASTEXITCODE are not the same thing.'
            Detail  = '$LASTEXITCODE is the exit code of the last EXTERNAL program. $? is a boolean for the last PowerShell operation. Native commands do not set $? usefully in older versions, and cmdlets do not set $LASTEXITCODE at all.'
        }
        @{
            Topic   = 'errors'
            Summary = 'Most errors are non-terminating by default.'
            Detail  = 'A cmdlet that fails often keeps going and writes to the error stream. Use -ErrorAction Stop, or $ErrorActionPreference = ''Stop'', to get set -e behaviour. try/catch only catches TERMINATING errors.'
        }
        @{
            Topic   = 'quoting'
            Summary = 'Single quotes are literal, double quotes interpolate.'
            Detail  = 'Same as zsh. The difference is the escape character: backtick, not backslash. Backslash is just a path separator and needs no escaping.'
        }
        @{
            Topic   = 'which'
            Summary = 'Get-Command beats which.'
            Detail  = 'The `which` shim calls where.exe, which only sees files on PATH. Get-Command also resolves aliases, functions and cmdlets, and tells you which of those it found — the thing you actually want given the resolution-order trap.'
        }
        @{
            Topic   = 'resolution-order'
            Summary = 'Alias beats Function beats Cmdlet beats Application.'
            Detail  = 'A function named `ls` is unreachable while the built-in `ls` alias exists, and nothing warns you. Remove-Alias first. This is why generated-aliases.ps1 emits Remove-Alias lines.'
        }
        @{
            Topic   = 'arguments'
            Summary = 'Set-Alias cannot carry arguments.'
            Detail  = 'An alias is a name-to-name mapping only. `alias gs="git status"` has no direct equivalent — anything with arguments must be a function. That is why most of the port is functions rather than aliases.'
        }
    )
}
