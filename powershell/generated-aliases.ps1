# generated-aliases.ps1 — DO NOT EDIT.
#
# Regenerate with tools/Build-Aliases.ps1. Source of truth is the alias dump
# plus unixmap.psd1; edits here are lost on the next run.
#
# Source dump SHA256: 5F0620E48BE0
#
# No timestamp on purpose: identical inputs must produce an identical file, so
# that a diff means something changed upstream rather than that it was rebuilt.

# git log formats, copied verbatim from the Zim git module.
$script:GitLogFuller = '%C(bold yellow)commit %H%C(auto)%d%n%C(bold)Author: %C(blue)%an <%ae> %C(cyan)%ai (%ar)%n%C(bold)Commit: %C(blue)%cn <%ce> %C(cyan)%ci (%cr)%C(reset)%n%+B'
$script:GitLogOneline = '%C(bold yellow)%h%C(reset) %s%C(auto)%d%C(reset)'
$script:GitLogOnelineMedium = '%C(bold yellow)%h%C(reset) %<(50,trunc)%s %C(bold blue)%an %C(cyan)%as (%ar)%C(auto)%d%C(reset)'

# Built-in aliases displaced by the definitions below. Resolution order is
# Alias -> Function -> Cmdlet, so these must go or the functions are
# unreachable. The cmdlets themselves are untouched — only the short forms.
Remove-Alias -Name 'Gc' -Force -ErrorAction SilentlyContinue  # was Get-Content
Remove-Alias -Name 'Gcm' -Force -ErrorAction SilentlyContinue  # was Get-Command
Remove-Alias -Name 'GcS' -Force -ErrorAction SilentlyContinue  # was Get-PSCallStack
Remove-Alias -Name 'Gcs' -Force -ErrorAction SilentlyContinue  # was Get-PSCallStack
Remove-Alias -Name 'Gl' -Force -ErrorAction SilentlyContinue  # was Get-Location
Remove-Alias -Name 'Gm' -Force -ErrorAction SilentlyContinue  # was Get-Member
Remove-Alias -Name 'Gp' -Force -ErrorAction SilentlyContinue  # was Get-ItemProperty

# --- ported aliases ---
Set-Alias -Name 'G' -Value 'git' -Force
function G.. { Set-Location (git-root) }
function Gb { git branch @args }
function Gbc { git checkout -b @args }
function Gbd { git checkout --detach @args }
function Gbl {
    if ($MyInvocation.InvocationName -cne 'Gbl') {
        Write-Error 'Gbl is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git branch --list -vv. Shadowed: GbL = git branch --list -vv --all. Run the git command directly if you wanted one of those.'; return
    }
    git branch --list -vv @args
}
function Gbm {
    if ($MyInvocation.InvocationName -cne 'Gbm') {
        Write-Error 'Gbm is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git branch --move. Shadowed: GbM = git branch --move --force. Run the git command directly if you wanted one of those.'; return
    }
    git branch --move @args
}
function Gbn { git branch --no-contains @args }
function GbR { git branch --force @args }
function Gbs {
    if ($MyInvocation.InvocationName -cne 'Gbs') {
        Write-Error 'Gbs is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git show-branch. Shadowed: GbS = git show-branch --all. Run the git command directly if you wanted one of those.'; return
    }
    git show-branch @args
}
function Gbu { git branch --unset-upstream @args }
function Gc { git commit --verbose @args }
function Gca {
    if ($MyInvocation.InvocationName -cne 'Gca') {
        Write-Error 'Gca is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git commit --verbose --all. Shadowed: GCa = git add @(GCl); GcA = git commit --verbose --patch. Run the git command directly if you wanted one of those.'; return
    }
    git commit --verbose --all @args
}
function GCe { git mergetool @(GCl) @args }
function Gcf {
    if ($MyInvocation.InvocationName -cne 'Gcf') {
        Write-Error 'Gcf is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git commit --amend --reuse-message HEAD. Shadowed: GcF = git commit --verbose --amend. Run the git command directly if you wanted one of those.'; return
    }
    git commit --amend --reuse-message HEAD @args
}
function GCl { git --no-pager diff --name-only --diff-filter=U @args }
function Gcm { git commit --message @args }
function Gco {
    if ($MyInvocation.InvocationName -cne 'Gco') {
        Write-Error 'Gco is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git checkout. Shadowed: GCO = GCo @(GCl); GCo = git checkout --ours --; GcO = git checkout --patch. Run the git command directly if you wanted one of those.'; return
    }
    git checkout @args
}
function Gcp {
    if ($MyInvocation.InvocationName -cne 'Gcp') {
        Write-Error 'Gcp is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git cherry-pick. Shadowed: GcP = git cherry-pick --no-commit. Run the git command directly if you wanted one of those.'; return
    }
    git cherry-pick @args
}
function Gcr {
    if ($MyInvocation.InvocationName -cne 'Gcr') {
        Write-Error 'Gcr is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git revert. Shadowed: GcR = git reset "HEAD^". Run the git command directly if you wanted one of those.'; return
    }
    git revert @args
}
function Gcs {
    if ($MyInvocation.InvocationName -cne 'Gcs') {
        Write-Error 'Gcs is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git show "--pretty=format:$GitLogFuller". Shadowed: GcS = git commit --verbose -S. Run the git command directly if you wanted one of those.'; return
    }
    git show "--pretty=format:$GitLogFuller" @args
}
function GCt {
    if ($MyInvocation.InvocationName -cne 'GCt') {
        Write-Error 'GCt is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git checkout --theirs --. Shadowed: GCT = GCt @(GCl). Run the git command directly if you wanted one of those.'; return
    }
    git checkout --theirs -- @args
}
function Gcu {
    if ($MyInvocation.InvocationName -cne 'Gcu') {
        Write-Error 'Gcu is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git commit --fixup. Shadowed: GcU = git commit --squash. Run the git command directly if you wanted one of those.'; return
    }
    git commit --fixup @args
}
function Gcv { git verify-commit @args }
function Gd { git ls-files @args }
function Gdc { git ls-files --cached @args }
function GdI { git ls-files --ignored --exclude-per-directory=.gitignore --cached @args }
function Gdk { git ls-files --killed @args }
function Gdm { git ls-files --modified @args }
function Gdu { git ls-files --other --exclude-standard @args }
function Gdx { git ls-files --deleted @args }
function Gf { git fetch @args }
function Gfa { git fetch --all @args }
function Gfc { git clone @args }
function Gfm { git pull --no-rebase @args }
function Gfp { git fetch --all --prune @args }
function Gfr { git pull --rebase @args }
function Gfu { git pull --ff-only --all --prune @args }
function Gg { git grep @args }
function Ggi { git grep --ignore-case @args }
function Ggl {
    if ($MyInvocation.InvocationName -cne 'Ggl') {
        Write-Error 'Ggl is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git grep --files-with-matches. Shadowed: GgL = git grep --files-without-match. Run the git command directly if you wanted one of those.'; return
    }
    git grep --files-with-matches @args
}
function Ggv { git grep --invert-match @args }
function Ggw { git grep --word-regexp @args }
function Gh { git help @args }
function Ghw { git help --web @args }
function Gia {
    if ($MyInvocation.InvocationName -cne 'Gia') {
        Write-Error 'Gia is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git add --verbose. Shadowed: GiA = git add --patch. Run the git command directly if you wanted one of those.'; return
    }
    git add --verbose @args
}
function Gid {
    if ($MyInvocation.InvocationName -cne 'Gid') {
        Write-Error 'Gid is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git diff --no-ext-diff --cached. Shadowed: GiD = git diff --no-ext-diff --cached --word-diff. Run the git command directly if you wanted one of those.'; return
    }
    git diff --no-ext-diff --cached @args
}
function Gir {
    if ($MyInvocation.InvocationName -cne 'Gir') {
        Write-Error 'Gir is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git reset. Shadowed: GiR = git reset --patch. Run the git command directly if you wanted one of those.'; return
    }
    git reset @args
}
function Giu {
    if ($MyInvocation.InvocationName -cne 'Giu') {
        Write-Error 'Giu is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git add --verbose --update. Shadowed: GiU = git add --verbose --all. Run the git command directly if you wanted one of those.'; return
    }
    git add --verbose --update @args
}
function Gix {
    if ($MyInvocation.InvocationName -cne 'Gix') {
        Write-Error 'Gix is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git rm --cached -r. Shadowed: GiX = git rm --cached -rf. Run the git command directly if you wanted one of those.'; return
    }
    git rm --cached -r @args
}
function Gl { git log --date-order "--pretty=format:$GitLogFuller" @args }
function Glc { git shortlog --summary --numbered @args }
function Gld { git log --date-order --stat --patch "--pretty=format:$GitLogFuller" @args }
function Glf { git log --date-order --stat --patch --follow "--pretty=format:$GitLogFuller" @args }
function Glg {
    if ($MyInvocation.InvocationName -cne 'Glg') {
        Write-Error 'Glg is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git log --date-order --graph "--pretty=format:$GitLogOneline". Shadowed: GlG = git log --date-order --graph "--pretty=format:$GitLogOnelineMedium". Run the git command directly if you wanted one of those.'; return
    }
    git log --date-order --graph "--pretty=format:$GitLogOneline" @args
}
function Glo {
    if ($MyInvocation.InvocationName -cne 'Glo') {
        Write-Error 'Glo is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git log --date-order "--pretty=format:$GitLogOneline". Shadowed: GlO = git log --date-order "--pretty=format:$GitLogOnelineMedium". Run the git command directly if you wanted one of those.'; return
    }
    git log --date-order "--pretty=format:$GitLogOneline" @args
}
function Glr { git reflog @args }
function Gls { git log --date-order --stat "--pretty=format:$GitLogFuller" @args }
function Glv { git log --date-order --show-signature "--pretty=format:$GitLogFuller" @args }
function Gm { git merge @args }
function Gma { git merge --abort @args }
function Gmc {
    if ($MyInvocation.InvocationName -cne 'Gmc') {
        Write-Error 'Gmc is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git merge --continue. Shadowed: GmC = git merge --no-commit. Run the git command directly if you wanted one of those.'; return
    }
    git merge --continue @args
}
function GmF { git merge --no-ff @args }
function Gms {
    if ($MyInvocation.InvocationName -cne 'Gms') {
        Write-Error 'Gms is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git merge --squash. Shadowed: GmS = git merge -S. Run the git command directly if you wanted one of those.'; return
    }
    git merge --squash @args
}
function Gmt { git mergetool @args }
function Gmv { git merge --verify-signatures @args }
function Gp { git push @args }
function Gpa {
    if ($MyInvocation.InvocationName -cne 'Gpa') {
        Write-Error 'Gpa is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git push --all. Shadowed: GpA = git push --all && git push --tags --no-verify. Run the git command directly if you wanted one of those.'; return
    }
    git push --all @args
}
function Gpc { git push --set-upstream origin (git-branch-current) @args }
function Gpf {
    if ($MyInvocation.InvocationName -cne 'Gpf') {
        Write-Error 'Gpf is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git push --force-with-lease. Shadowed: GpF = git push --force. Run the git command directly if you wanted one of those.'; return
    }
    git push --force-with-lease @args
}
function Gpp { git pull origin (git-branch-current) && git push origin (git-branch-current) }
function Gpt { git push --tags @args }
function Gr {
    if ($MyInvocation.InvocationName -cne 'Gr') {
        Write-Error 'Gr is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git rebase. Shadowed: GR = git remote. Run the git command directly if you wanted one of those.'; return
    }
    git rebase @args
}
function Gra {
    if ($MyInvocation.InvocationName -cne 'Gra') {
        Write-Error 'Gra is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git rebase --abort. Shadowed: GRa = git remote add. Run the git command directly if you wanted one of those.'; return
    }
    git rebase --abort @args
}
function Grc { git rebase --continue @args }
function Gri { git rebase --interactive --autosquash @args }
function GRl { git remote --verbose @args }
function GRm { git remote rename @args }
function GRp { git remote prune @args }
function Grs {
    if ($MyInvocation.InvocationName -cne 'Grs') {
        Write-Error 'Grs is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git rebase --skip. Shadowed: GRS = git remote set-url; GRs = git remote show; GrS = git rebase --exec "git commit --amend --no-edit --no-verify -S". Run the git command directly if you wanted one of those.'; return
    }
    git rebase --skip @args
}
function GRu { git remote update @args }
function GRx { git remote rm @args }
function Gs {
    if ($MyInvocation.InvocationName -cne 'Gs') {
        Write-Error 'Gs is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git stash. Shadowed: GS = git submodule. Run the git command directly if you wanted one of those.'; return
    }
    git stash @args
}
function Gsa {
    if ($MyInvocation.InvocationName -cne 'Gsa') {
        Write-Error 'Gsa is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git stash apply. Shadowed: GSa = git submodule add. Run the git command directly if you wanted one of those.'; return
    }
    git stash apply @args
}
function Gsd { git stash show --patch --stat @args }
function GSf { git submodule foreach @args }
function Gsi {
    if ($MyInvocation.InvocationName -cne 'Gsi') {
        Write-Error 'Gsi is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git stash push --staged. Shadowed: GSI = git submodule update --init --recursive; GSi = git submodule init. Run the git command directly if you wanted one of those.'; return
    }
    git stash push --staged @args
}
function Gsl {
    if ($MyInvocation.InvocationName -cne 'Gsl') {
        Write-Error 'Gsl is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git stash list. Shadowed: GSl = git submodule status. Run the git command directly if you wanted one of those.'; return
    }
    git stash list @args
}
function Gsp { git stash pop @args }
function Gss {
    if ($MyInvocation.InvocationName -cne 'Gss') {
        Write-Error 'Gss is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git stash save --include-untracked. Shadowed: GSs = git submodule sync; GsS = git stash save --patch --no-keep-index. Run the git command directly if you wanted one of those.'; return
    }
    git stash save --include-untracked @args
}
function Gsu {
    if ($MyInvocation.InvocationName -cne 'Gsu') {
        Write-Error 'Gsu is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git stash show --patch | git apply --reverse. Shadowed: GSu = git submodule update --remote. Run the git command directly if you wanted one of those.'; return
    }
    git stash show --patch | git apply --reverse
}
function Gsw { git stash save --include-untracked --keep-index @args }
function Gsx { git stash drop @args }
function Gt { git tag @args }
function Gtl { git tag --list --sort=-committerdate @args }
function Gts { git tag --sign @args }
function Gtv { git verify-tag @args }
function Gtx { git tag --delete @args }
function GW { git worktree @args }
function GWa { git worktree add @args }
function Gwc {
    if ($MyInvocation.InvocationName -cne 'Gwc') {
        Write-Error 'Gwc is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git clean --dry-run. Shadowed: GwC = git clean -d --force. Run the git command directly if you wanted one of those.'; return
    }
    git clean --dry-run @args
}
function Gwd {
    if ($MyInvocation.InvocationName -cne 'Gwd') {
        Write-Error 'Gwd is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git diff --no-ext-diff. Shadowed: GwD = git diff --no-ext-diff --word-diff. Run the git command directly if you wanted one of those.'; return
    }
    git diff --no-ext-diff @args
}
function GWl { git worktree list @args }
function Gwm {
    if ($MyInvocation.InvocationName -cne 'Gwm') {
        Write-Error 'Gwm is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git mv. Shadowed: GWm = git worktree move; GwM = git mv -f. Run the git command directly if you wanted one of those.'; return
    }
    git mv @args
}
function GWp { git worktree prune @args }
function Gwr {
    if ($MyInvocation.InvocationName -cne 'Gwr') {
        Write-Error 'Gwr is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git reset --soft. Shadowed: GwR = git reset --hard. Run the git command directly if you wanted one of those.'; return
    }
    git reset --soft @args
}
function Gws {
    if ($MyInvocation.InvocationName -cne 'Gws') {
        Write-Error 'Gws is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git status --short --branch. Shadowed: GwS = git status. Run the git command directly if you wanted one of those.'; return
    }
    git status --short --branch @args
}
function Gwx {
    if ($MyInvocation.InvocationName -cne 'Gwx') {
        Write-Error 'Gwx is the only reachable casing here - PowerShell command names are case-insensitive. It runs: git rm -r. Shadowed: GWX = git worktree remove --force; GWx = git worktree remove; GwX = git rm -rf. Run the git command directly if you wanted one of those.'; return
    }
    git rm -r @args
}
function Gy { git switch @args }
function Gyc { git switch --create @args }
function Gyd { git switch --detach @args }
