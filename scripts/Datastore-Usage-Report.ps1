<#
.SYNOPSIS
    Generates a usage report for all datastores in vSphere.
.DESCRIPTION
    Reports capacity, free space, used space, provisioned space, and number of VMs per datastore.
.PARAMETER vCenterServer
    The FQDN or IP address of the vCenter Server.
.PARAMETER OutputFormat
    Output format: CSV (default), XML, or TXT.
.EXAMPLE
    .\Datastore-Usage-Report.ps1 -vCenterServer "vcsa01.domain.local" -OutputFormat XML
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
    $report = Get-Datastore | Select-Object @{
        Name = 'Name'; Expression = { $_.Name }
    }, @{
        Name = 'Type'; Expression = { $_.Type }
    }, @{
        Name = 'CapacityGB'; Expression = { [math]::Round($_.CapacityGB, 2) }
    }, @{
        Name = 'FreeSpaceGB'; Expression = { [math]::Round($_.FreeSpaceGB, 2) }
    }, @{
        Name = 'UsedGB'; Expression = { [math]::Round($_.CapacityGB - $_.FreeSpaceGB, 2) }
    }, @{
        Name = 'UsedPercent'; Expression = { [math]::Round((($_.CapacityGB - $_.FreeSpaceGB) / $_.CapacityGB) * 100, 1) }
    }, @{
        Name = 'VMsCount'; Expression = { (Get-VM -Datastore $_).Count }
    }, @{
        Name = 'ProvisionedGB'; Expression = { 
            [math]::Round(((Get-VM -Datastore $_ | Measure-Object -Property ProvisionedSpaceGB -Sum).Sum), 2) 
        }
    }

    $outputFile = "Datastore_Usage_$((Get-Date).ToString('yyyyMMdd_HHmm')).$($OutputFormat.ToLower())"

    switch ($OutputFormat) {
        "CSV" { $report | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8 }
        "XML" { $report | Export-Clixml -Path $outputFile }
        "TXT" { $report | Format-Table -AutoSize | Out-File -FilePath $outputFile -Encoding UTF8 }
    }

    Write-Output "Datastore usage report generated: $outputFile"
}
catch {
    Write-Error "Error generating datastore report: $($_.Exception.Message)"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
