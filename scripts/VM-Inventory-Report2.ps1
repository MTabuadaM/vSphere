<#
.SYNOPSIS
    Generates a VM inventory report with resource usage stats.
.DESCRIPTION
    Combines Get-VM, Get-VMGuest, and Get-Stat for detailed auditing.
.PARAMETER vCenterServer
    vCenter FQDN or IP.
.PARAMETER ClusterName
    Optional cluster filter.
.EXAMPLE
    .\VM-Inventory-With-Stats.ps1 -vCenterServer "vcsa01.domain.local" -ClusterName "ProdCluster"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,
    [string]$ClusterName = $null
)

Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue

try {
    Connect-VIServer -Server $vCenterServer -ErrorAction Stop | Out-Null

    $vms = if ($ClusterName) { Get-Cluster $ClusterName | Get-VM } else { Get-VM }

    $report = $vms | ForEach-Object {
        $vm = $_
        $guest = Get-VMGuest -VM $vm
        $cpuStat = Get-Stat -Entity $vm -Stat cpu.usage.average -MaxSamples 1 -Realtime
        $memStat = Get-Stat -Entity $vm -Stat mem.usage.average -MaxSamples 1 -Realtime

        [PSCustomObject]@{
            VMName      = $vm.Name
            PowerState  = $vm.PowerState
            NumCpu      = $vm.NumCpu
            MemoryGB    = $vm.MemoryGB
            GuestOS     = $guest.OSFullName
            IPAddress   = ($guest.IPAddress -join ', ')
            CpuUsagePct = if ($cpuStat) { [math]::Round($cpuStat.Value, 2) } else { "N/A" }
            MemUsagePct = if ($memStat) { [math]::Round($memStat.Value, 2) } else { "N/A" }
        }
    }

    $report | Export-Csv -Path "VM_Inventory_Stats.csv" -NoTypeInformation
    Write-Output "Report exported to VM_Inventory_Stats.csv"
}
catch {
    Write-Error "Error: $($_.Exception.Message)"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
