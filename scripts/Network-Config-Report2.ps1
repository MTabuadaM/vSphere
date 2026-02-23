<#
.SYNOPSIS
    Audits VM network and storage configurations.
.DESCRIPTION
    Combines Get-VM, Get-NetworkAdapter, Get-HardDisk, and Get-Datastore for compliance reports.
.PARAMETER vCenterServer
    vCenter FQDN or IP.
.EXAMPLE
    .\VM-Network-Storage-Audit.ps1 -vCenterServer "vcsa01.domain.local"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer
)

Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue

try {
    Connect-VIServer -Server $vCenterServer -ErrorAction Stop | Out-Null

    $report = Get-VM | ForEach-Object {
        $vm = $_
        $nics = Get-NetworkAdapter -VM $vm
        $disks = Get-HardDisk -VM $vm
        $datastores = $vm.DatastoreIdList | ForEach-Object { Get-Datastore -Id $_ }

        [PSCustomObject]@{
            VMName        = $vm.Name
            NetworkAdapters = ($nics.NetworkName -join ', ')
            MacAddresses   = ($nics.MacAddress -join ', ')
            DisksGB        = ($disks.CapacityGB -join ', ')
            Datastores     = ($datastores.Name -join ', ')
            TotalStorageGB = [math]::Round(($disks | Measure-Object -Property CapacityGB -Sum).Sum, 2)
        }
    }

    $report | Export-Csv -Path "VM_Network_Storage_Audit.csv" -NoTypeInformation
    Write-Output "Audit report exported to VM_Network_Storage_Audit.csv"
}
catch {
    Write-Error "Error: $($_.Exception.Message)"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
