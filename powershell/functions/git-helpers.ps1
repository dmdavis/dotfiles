# git-helpers.ps1
#
# The two Zim helper scripts that generated-aliases.ps1 actually depends on.
# Without these, G.. / Gpc / Gpp are broken — they were emitted referencing
# helpers that did not exist, which is exactly what happened on first deploy.
#
# The other ten Zim git helpers are interactive pickers and are deliberately
# NOT ported; see the Exclude section of unixmap.psd1.

function git-root {
    # Named for the Zim script it replaces, because generated-aliases.ps1 calls
    # it by that exact name. An approved Verb-Noun name would be more idiomatic
    # and would break the port, so the rule is suppressed here rather than in
    # the settings file — it is right everywhere else.
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '',
        Justification = 'Name is fixed by the Zim alias set this replaces.')]
    param()

    # zsh original: `git-root || print .`. The fallback is part of the
    # contract — G.. does Set-Location (git-root), which would throw on a
    # bare directory if this returned nothing.
    $root = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0 -and $root) { $root } else { '.' }
}

function git-branch-current {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '',
        Justification = 'Name is fixed by the Zim alias set this replaces.')]
    param()

    # Swallows its own error, which is why the generator drops the
    # `2>/dev/null` the zsh aliases wrapped this in.
    $branch = git branch --show-current 2>$null
    if ($LASTEXITCODE -eq 0) { $branch } else { '' }
}
