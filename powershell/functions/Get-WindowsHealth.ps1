# Get-WindowsHealth.ps1 — machine health as objects. Alias: winhealth
#
# Named Get-WindowsHealth rather than the Get-BeastHealth the plan called for:
# this repo is public and cross-machine, so it should not carry one host's
# name, and MSI Laptop gets it for free.
#
# The point is STRUCTURED output. Everything returns objects, so
# `winhealth | ConvertTo-Json -Depth 6` produces something diffable against a
# later run — the same habit the hardening project already uses with
# STATE.json, and the reason a scriptable shell on this box was worth building.
#
# Findings are computed, not hard-coded, so a fixed problem stops being
# reported instead of lingering in a document nobody re-reads.

function Get-WindowsHealth {
    <#
    .SYNOPSIS
        Disk, Defender, update and backup posture for a Windows machine.

    .DESCRIPTION
        Returns one object with sections plus a Findings array. Nothing here
        changes the machine; it is all read-only.

    .PARAMETER Quick
        Skip the checks that hit the network or take seconds — currently the
        winget upgrade query.

    .PARAMETER SkipSmart
        Skip smartctl. Use when it is not installed, or to keep the run fast.

    .EXAMPLE
        winhealth | ConvertTo-Json -Depth 6 > health.json
        Snapshot for diffing against a later run.

    .EXAMPLE
        (winhealth).Findings
        Just what is wrong.
    #>
    [CmdletBinding()]
    param(
        [switch]$Quick,
        [switch]$SkipSmart
    )

    $ErrorActionPreference = 'SilentlyContinue'
    $findings = [System.Collections.Generic.List[string]]::new()

    # --- host -------------------------------------------------------------
    $os = Get-CimInstance Win32_OperatingSystem
    $host_ = [ordered]@{
        Name      = $env:COMPUTERNAME
        OS        = $os.Caption
        Build     = $os.BuildNumber
        BootedUtc = $os.LastBootUpTime.ToUniversalTime().ToString('s')
        UptimeHrs = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalHours, 1)
    }

    # --- pending reboot ---------------------------------------------------
    # Three independent signals; any one means a reboot is owed. The rename
    # queue is the one that catches package installs.
    $reboot = [ordered]@{
        ComponentServicing = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
        WindowsUpdate      = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
        PendingFileRename  = [bool](Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations)
    }
    $reboot.Pending = [bool]($reboot.Values -contains $true)
    if ($reboot.Pending) { $findings.Add('Reboot pending.') }

    # --- disks ------------------------------------------------------------
    $disks = @(Get-PhysicalDisk | Sort-Object DeviceId | ForEach-Object {
        [ordered]@{
            Id     = $_.DeviceId
            Model  = $_.FriendlyName
            Media  = $_.MediaType.ToString()
            Bus    = $_.BusType.ToString()
            SizeGB = [math]::Round($_.Size / 1GB)
            Health = $_.HealthStatus.ToString()
        }
    })
    foreach ($d in $disks) {
        if ($d.Health -ne 'Healthy') { $findings.Add("Disk $($d.Id) ($($d.Model)) reports health '$($d.Health)'.") }
    }

    $raid0 = @($disks | Where-Object { $_.Model -match 'Raid 0' })
    if ($raid0) {
        $findings.Add("$($raid0.Count) RAID 0 volume(s) present - striped, no redundancy. One member failing loses the whole array.")
    }

    # --- SMART ------------------------------------------------------------
    # Windows' own storage APIs are useless here: Get-StorageReliabilityCounter
    # returns Available=true and then zeros/nulls for every Intel RST member,
    # and the WMI failure-prediction classes enumerate only directly-attached
    # disks. smartctl reaches RST members through the CSMI interface.
    $smart = [ordered]@{ Available = $false; Devices = @(); Note = $null }
    if (-not $SkipSmart) {
        $sc = (Get-Command smartctl -ErrorAction SilentlyContinue).Source
        if (-not $sc -and (Test-Path 'C:\Program Files\smartmontools\bin\smartctl.exe')) {
            $sc = 'C:\Program Files\smartmontools\bin\smartctl.exe'
        }
        if (-not $sc) {
            $smart.Note = 'smartctl not installed; run bootstrap.ps1.'
            $findings.Add('No SMART data: smartctl is not installed.')
        } else {
            $smart.Available = $true
            $scanned = & $sc --scan 2>$null
            $devs = foreach ($line in $scanned) {
                if ($line -notmatch '^(\S+)') { continue }
                $dev  = $Matches[1]
                $info = & $sc -i $dev 2>$null | Out-String
                if ($info -notmatch '(?m)^(?:Device Model|Model Number):\s*(.+)$') { continue }
                $model  = $Matches[1].Trim()
                # Serial is what identifies a PHYSICAL disk. smartctl --scan
                # lists the same drive under more than one path — here every
                # SATA disk appears as both /dev/sdN and /dev/csmiN,P — and
                # reporting it twice would make every diff of this output noisy.
                $serial = if ($info -match '(?m)^Serial Number:\s*(.+)$') { $Matches[1].Trim() } else { $dev }
                $health = (& $sc -H $dev 2>$null | Select-String 'result:|SMART Health Status:' | Select-Object -First 1)
                $verdict = if ($health) { ($health.ToString() -replace '.*?:\s*', '').Trim() } else { 'unknown' }
                [ordered]@{ Device = $dev; Model = $model; Serial = $serial; Health = $verdict }
            }
            # Prefer the CSMI path when a disk has both: it is the one that
            # keeps working when the disk is an Intel RST array member.
            $smart.Devices = @($devs |
                Group-Object Serial |
                ForEach-Object {
                    @($_.Group | Sort-Object { $_.Device -notmatch 'csmi' })[0]
                } |
                Sort-Object Device)
            foreach ($dv in $smart.Devices) {
                if ($dv.Health -notmatch 'PASSED|OK') { $findings.Add("SMART on $($dv.Device) ($($dv.Model)): $($dv.Health)") }
            }

            # The gap that matters. NVMe behind Intel RST is invisible to
            # smartctl as well, so the array holding C: has no early warning
            # at all — which is the opposite of what its risk profile wants.
            $nvmeDisks    = @($disks | Where-Object { $_.Media -eq 'SSD' -and $_.Model -match 'Raid 0' })
            $smartModels  = ($smart.Devices.Model -join ' ')
            if ($nvmeDisks -and $smartModels -notmatch '970 EVO') {
                $smart.Note = 'NVMe members behind Intel RST are not reachable by smartctl; only SATA/CSMI members are covered.'
                $findings.Add('SMART is unavailable for the NVMe RAID 0 array (the boot array) - Intel RST hides it from every Windows tool.')
            }
        }
    }

    # --- volumes ----------------------------------------------------------
    $bl = @{}
    foreach ($v in (Get-BitLockerVolume)) { $bl[$v.MountPoint] = $v.ProtectionStatus.ToString() }
    $volumes = @(Get-Volume | Where-Object { $_.DriveLetter } | Sort-Object DriveLetter | ForEach-Object {
        $mount = "$($_.DriveLetter):"
        $pct   = if ($_.Size) { [math]::Round(100 * $_.SizeRemaining / $_.Size, 1) } else { $null }
        [ordered]@{
            Mount      = $mount
            Label      = $_.FileSystemLabel
            FreeGB     = [math]::Round($_.SizeRemaining / 1GB, 1)
            SizeGB     = [math]::Round($_.Size / 1GB, 1)
            FreePct    = $pct
            BitLocker  = $bl[$mount]
        }
    })
    foreach ($v in $volumes) {
        if ($null -ne $v.FreePct -and $v.FreePct -lt 10) { $findings.Add("Volume $($v.Mount) is $($v.FreePct)% free.") }
    }
    $unencrypted = @($volumes | Where-Object { $_.BitLocker -eq 'Off' })
    if ($unencrypted) { $findings.Add("BitLocker off on: $(($unencrypted.Mount) -join ', ').") }

    # --- Defender ---------------------------------------------------------
    # Via CIM, not Get-MpComputerStatus: the module writes a progress record
    # that ignores $ProgressPreference over SSH and prepends a CLIXML blob to
    # otherwise-valid JSON.
    $mp = Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpComputerStatus
    $defender = if ($mp) {
        [ordered]@{
            RealTimeProtection = $mp.RealTimeProtectionEnabled
            TamperProtection   = $mp.IsTamperProtected
            SignatureAgeDays   = $mp.AntivirusSignatureAge
            LastQuickScan      = $mp.QuickScanEndTime
        }
    } else { $null }
    if ($defender) {
        if (-not $defender.RealTimeProtection) { $findings.Add('Defender real-time protection is OFF.') }
        if ($defender.SignatureAgeDays -gt 3)  { $findings.Add("Defender signatures are $($defender.SignatureAgeDays) days old.") }
    }

    # --- backup -----------------------------------------------------------
    # There is no real backup on this machine, so report what actually exists
    # rather than implying coverage. Restore points and shadow copies live on
    # the same disks they would be needed to recover.
    $rp = @(Get-ComputerRestorePoint | Sort-Object SequenceNumber | Select-Object -Last 1)
    $backup = [ordered]@{
        LatestRestorePoint = if ($rp) { [ordered]@{ Sequence = $rp.SequenceNumber; Description = $rp.Description } } else { $null }
        ShadowStorage      = @(vssadmin list shadowstorage 2>$null | Select-String 'Used Shadow Copy Storage space' |
                                ForEach-Object { ($_ -replace '.*space:\s*', '').Trim() })
        Note               = 'Restore points and shadow copies are NOT a backup: they live on the disks they would recover.'
    }
    $findings.Add('No off-machine backup is verified by this check - see the RAID 0 finding.')

    # --- updates ----------------------------------------------------------
    $updates = [ordered]@{ WingetPending = $null; Note = $null }
    if ($Quick) {
        $updates.Note = 'skipped (-Quick)'
    } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
        $raw = winget upgrade --disable-interactivity 2>&1 | Out-String
        if ($raw -match '(?m)^(\d+)\s+upgrades? available') { $updates.WingetPending = [int]$Matches[1] }
        else {
            # Fall back to counting table rows past the separator line.
            $rows = ($raw -split "`n") | Where-Object { $_ -match '^\S.*\s+\S+\s+\S+\s+winget\s*$' }
            $updates.WingetPending = @($rows).Count
        }
        if ($updates.WingetPending -gt 0) { $findings.Add("$($updates.WingetPending) winget package(s) have updates available.") }
    } else {
        $updates.Note = 'winget not on PATH'
    }

    [pscustomobject]@{
        Host          = [pscustomobject]$host_
        PendingReboot = [pscustomobject]$reboot
        Disks         = $disks
        Smart         = [pscustomobject]$smart
        Volumes       = $volumes
        Defender      = if ($defender) { [pscustomobject]$defender } else { $null }
        Backup        = [pscustomobject]$backup
        Updates       = [pscustomobject]$updates
        Findings      = @($findings)
    }
}

Set-Alias -Name winhealth -Value Get-WindowsHealth -Force
