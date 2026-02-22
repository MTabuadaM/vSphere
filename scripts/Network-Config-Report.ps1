<#
.SYNOPSIS
    Generates a report of network adapter configurations for all VMs.
.DESCRIPTION
    Collects VM name, adapter name, port group/network, MAC, IP addresses, and connection state.
.PARAMETER vCenterServer
    The FQDN or IP address of the vCenter Server.
.PARAMETER OutputFormat
    Output format: CSV (default), XML, or TXT.
.EXAMPLE
    .\Network-Config-Report.ps1 -vCenterServer "vcsa01.domain.local" -OutputFormat TXT
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,

    [ValidateSet("CSV", "XML", "TXT")]
    [string]$OutputFormat = "CSV"
)

Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue

try { Connect-VIServer -Server $vCenterServer -ErrorAction Stop | Out-Null }
catch { Write-Error "Connection failed: $($_.Exception.Message)"; exit 1 }

try {
    $report = Get-VM | Get-NetworkAdapter | Select-Object @{
        Name = 'VMName'; Expression = { $_.Parent.Name }
    }, @{
        Name = 'AdapterName'; Expression = { $_.Name }
    }, @{
        Name = 'NetworkName'; Expression = { $_.NetworkName }
    }, @{
        Name = 'MacAddress'; Expression = { $_.MacAddress }
    }, @{
        Name = 'IPAddress'; Expression = { ($_.Parent.Guest.IPAddress -join ', ') }
    }, @{
        Name = 'Connected'; Expression = { $_.ConnectionState.Connected }
    }, @{
        Name = 'StartConnected'; Expression = { $_.ConnectionState.StartConnected }
    }

    $outputFile = "Network_Config_$((Get-Date).ToString('yyyyMMdd_HHmm')).$($OutputFormat.ToLower())"

    switch ($OutputFormat) {
        "CSV" { $report | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8 }
        "XML" { $report | Export-Clixml -Path $outputFile }
        "TXT" { $report | Format-Table -AutoSize | Out-File -FilePath $outputFile -Encoding UTF8 }
    }

    Write-Output "Network configuration report generated: $outputFile"
}
catch {
    Write-Error "Error generating network report: $($_.Exception.Message)"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
