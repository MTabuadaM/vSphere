<#
.SYNOPSIS
    Checks VM health and optionally cleans old snapshots.
.DESCRIPTION
    Combines Get-VM, Get-Snapshot, Get-VMGuest, and Get-TagAssignment for proactive maintenance.
.PARAMETER vCenterServer
    vCenter FQDN or IP.
.PARAMETER Cleanup
    Remove old snapshots if true.
.EXAMPLE
    .\VM-Health-And-Snapshot-Cleanup.ps1 -vCenterServer "vcsa01.domain.local" -Cleanup
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,
    [switch]$Cleanup
)

Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue

try {
    Connect-VIServer -Server $vCenterServer -ErrorAction Stop | Out-Null

    $vms = Get-VM

    $report = $vms | ForEach-Object {
        $vm = $_
        $snapshots = Get-Snapshot -VM $vm | Where-Object { $_.Created -lt (Get-Date).AddDays(-7) }
        $guest = Get-VMGuest -VM $vm
        $tags = Get-TagAssignment -Entity $vm

        $issues = @()
        if ($snapshots.Count -gt 0) { $issues += "$($snapshots.Count) old snapshots" }
        if ($guest.ToolsStatus -ne "toolsOk") { $issues += "Tools outdated" }

        if ($Cleanup -and $snapshots) {
            $snapshots | Remove-Snapshot -Confirm:$false
            $issues += "; Snapshots cleaned"
        }

        [PSCustomObject]@{
            VMName     = $vm.Name
            Tags       = ($tags.Tag -join ', ')
            ToolsStatus= $guest.ToolsStatus
            Issues     = if ($issues) { $issues -join '; ' } else { "Healthy" }
        }
    }

    $report | Export-Csv -Path "VM_Health_Report.csv" -NoTypeInformation
    Write-Output "Health report exported to VM_Health_Report.csv"
}
catch {
    Write-Error "Error: $($_.Exception.Message)"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
