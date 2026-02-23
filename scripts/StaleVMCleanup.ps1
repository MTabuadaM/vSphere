<#
.SYNOPSIS
    Identifies and optionally removes stale (powered off) VMs.
.DESCRIPTION
    Uses Get-VM, Get-View (for last powered off time), Remove-VM.
    Find VMs that have been turned off for more than 90 days and remove them (with confirmation or dry-run),
    ideal for labs or development environments.
.PARAMETER vCenterServer
    vCenter FQDN or IP.
.PARAMETER DaysInactive
    Days powered off to consider stale (default: 90).
.PARAMETER DryRun
    Simulate without deletion (default: true).
.EXAMPLE
    .\Stale-VM-Cleanup.ps1 -vCenterServer "vcsa01.domain.local" -DaysInactive 120 -DryRun $false
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,
    [int]$DaysInactive = 90,
    [bool]$DryRun = $true
)

Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue

try {
    Connect-VIServer -Server $vCenterServer -ErrorAction Stop | Out-Null

    $threshold = (Get-Date).AddDays(-$DaysInactive)

    $staleVMs = Get-VM | Where-Object {
        $_.PowerState -eq "PoweredOff" -and
        $_.ExtensionData.Runtime.PowerOffDate -and
        $_.ExtensionData.Runtime.PowerOffDate -lt $threshold
    }

    Write-Output "Found $($staleVMs.Count) stale VMs (powered off > $DaysInactive days)"

    foreach ($vm in $staleVMs) {
        $lastOff = $vm.ExtensionData.Runtime.PowerOffDate.ToLocalTime().ToString("yyyy-MM-dd")
        if ($DryRun) {
            Write-Output "[DRY-RUN] Would remove $($vm.Name) (last powered off: $lastOff)"
        }
        elseif ($PSCmdlet.ShouldProcess($vm.Name, "Delete stale VM")) {
            Remove-VM -VM $vm -DeletePermanently -Confirm:$false
            Write-Output "Removed $($vm.Name)"
        }
    }
}
catch {
    Write-Error "Error during stale VM cleanup: $($_.Exception.Message)"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
