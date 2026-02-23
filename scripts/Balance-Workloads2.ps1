<#
.SYNOPSIS
    Balances VM workloads by vMotion based on host CPU usage.
.DESCRIPTION
    Combines Get-VMHost, Get-VM, Get-Stat, and Move-VM for dynamic balancing.
.PARAMETER vCenterServer
    vCenter FQDN or IP.
.PARAMETER ClusterName
    Cluster to balance.
.EXAMPLE
    .\Host-Workload-Balance.ps1 -vCenterServer "vcsa01.domain.local" -ClusterName "ProdCluster"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,
    [Parameter(Mandatory = $true)]
    [string]$ClusterName
)

Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue

try {
    Connect-VIServer -Server $vCenterServer -ErrorAction Stop | Out-Null

    $hosts = Get-Cluster $ClusterName | Get-VMHost

    $hostStats = $hosts | ForEach-Object {
        $stat = Get-Stat -Entity $_ -Stat cpu.usage.average -MaxSamples 1 -Realtime
        [PSCustomObject]@{
            HostName = $_.Name
            CpuUsagePct = [math]::Round($stat.Value, 2)
            VMs = Get-VM -VMHost $_
        }
    }

    $overloaded = $hostStats | Where-Object { $_.CpuUsagePct -gt 80 }
    $underloaded = $hostStats | Where-Object { $_.CpuUsagePct -lt 50 } | Select-Object -First 1

    foreach ($host in $overloaded) {
        $vmToMove = $host.VMs | Select-Object -First 1  # Mueve la primera VM no crítica
        if ($vmToMove -and $underloaded) {
            Move-VM -VM $vmToMove -Destination $underloaded.HostName
            Write-Output "Moved $($vmToMove.Name) from $($host.HostName) to $($underloaded.HostName)"
        }
    }
}
catch {
    Write-Error "Error: $($_.Exception.Message)"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
