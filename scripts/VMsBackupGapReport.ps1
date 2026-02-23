<#
.SYNOPSIS
    Reports VMs with potential backup gaps (no recent snapshots or disk changes).
.DESCRIPTION
    Combines Get-VM, Get-Snapshot, Get-HardDisk, Get-Stat for backup readiness check.
.PARAMETER vCenterServer
    vCenter FQDN or IP.
.PARAMETER DaysThreshold
    Days without activity to flag (default: 7).
.EXAMPLE
    .\VM-Backup-Gap-Report.ps1 -vCenterServer "vcsa01.domain.local" -DaysThreshold 14
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,
    [int]$DaysThreshold = 7
)

Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue

try {
    Connect-VIServer -Server $vCenterServer -ErrorAction Stop | Out-Null

    $thresholdDate = (Get-Date).AddDays(-$DaysThreshold)

    $report = Get-VM | Where-Object { $_.PowerState -eq "PoweredOn" } | ForEach-Object {
        $vm = $_
        $lastSnapshot = Get-Snapshot -VM $vm | Sort-Object Created -Descending | Select-Object -First 1
        $lastDiskChange = Get-Stat -Entity $vm -Stat disk.used.latest -Start $thresholdDate -Finish (Get-Date) -ErrorAction SilentlyContinue

        $gapDaysSnapshot = if ($lastSnapshot) { (Get-Date) - $lastSnapshot.Created | Select-Object -ExpandProperty Days } else { "No snapshots ever" }
        $hasRecentActivity = if ($lastDiskChange) { $lastDiskChange.Count -gt 0 } else { $false }

        [PSCustomObject]@{
            VMName            = $vm.Name
            PowerState        = $vm.PowerState
            LastSnapshotDays  = $gapDaysSnapshot
            RecentDiskActivity = if ($hasRecentActivity) { "Yes" } else { "No activity in last $DaysThreshold days" }
            RiskLevel         = if ($gapDaysSnapshot -is [int] -and $gapDaysSnapshot -gt $DaysThreshold) { "High" } elseif ($gapDaysSnapshot -eq "No snapshots ever") { "Critical" } else { "Low" }
        }
    }

    $report | Sort-Object RiskLevel -Descending | Export-Csv -Path "VM_Backup_Gap_Report.csv" -NoTypeInformation -Encoding UTF8
    Write-Output "Backup gap report generated: VM_Backup_Gap_Report.csv"
}
catch {
    Write-Error "Error generating backup gap report: $($_.Exception.Message)"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
