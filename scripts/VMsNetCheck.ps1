<#
.SYNOPSIS
    Checks network compliance for VMs (approved port groups, connected adapters).
.DESCRIPTION
    Combines Get-VM, Get-NetworkAdapter, Get-TagAssignment.
.PARAMETER vCenterServer
    vCenter FQDN or IP.
.PARAMETER ApprovedPortGroups
    Comma-separated list of allowed port groups (e.g., "VLAN-100, VLAN-200").
.EXAMPLE
    .\Network-Compliance-Check.ps1 -vCenterServer "vcsa01.domain.local" -ApprovedPortGroups "Production, DMZ"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,
    [Parameter(Mandatory = $true)]
    [string[]]$ApprovedPortGroups
)

Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue

try {
    Connect-VIServer -Server $vCenterServer -ErrorAction Stop | Out-Null

    $report = Get-VM | Where-Object { (Get-TagAssignment -Entity $_).Tag.Name -contains "Critical" } | ForEach-Object {
        $vm = $_
        $adapters = Get-NetworkAdapter -VM $vm

        $nonCompliant = $adapters | Where-Object {
            $_.NetworkName -notin $ApprovedPortGroups -or -not $_.ConnectionState.Connected
        }

        [PSCustomObject]@{
            VMName           = $vm.Name
            Compliant        = if ($nonCompliant) { "No" } else { "Yes" }
            NonCompliantAdapters = ($nonCompliant | ForEach-Object { "$($_.Name): $($_.NetworkName) (Connected: $($_.ConnectionState.Connected))" }) -join '; '
        }
    }

    $report | Export-Csv -Path "Network_Compliance_Report.csv" -NoTypeInformation -Encoding UTF8
    Write-Output "Network compliance report generated: Network_Compliance_Report.csv"
}
catch {
    Write-Error "Error generating compliance report: $($_.Exception.Message)"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
