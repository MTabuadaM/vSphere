<#
.SYNOPSIS
    Monitors and reports resource usage on ESXi hosts.
.DESCRIPTION
    Collects CPU, memory usage percentages, uptime, and VM count per host.
.PARAMETER vCenterServer
    The FQDN or IP address of the vCenter Server.
.PARAMETER OutputFormat
    Output format: CSV (default), XML, or TXT.
.EXAMPLE
    .\Host-Resource-Monitor.ps1 -vCenterServer "vcsa01.domain.local"
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
    $report = Get-VMHost | Select-Object @{
        Name = 'Name'; Expression = { $_.Name }
    }, @{
        Name = 'ConnectionState'; Expression = { $_.ConnectionState }
    }, @{
        Name = 'CpuUsagePercent'; Expression = { 
            if ($_.CpuTotalMhz -gt 0) { [math]::Round(($_.CpuUsageMhz / $_.CpuTotalMhz) * 100, 1) } else { "N/A" }
        }
    }, @{
        Name = 'MemoryUsagePercent'; Expression = { 
            if ($_.MemoryTotalGB -gt 0) { [math]::Round(($_.MemoryUsageGB / $_.MemoryTotalGB) * 100, 1) } else { "N/A" }
        }
    }, @{
        Name = 'UptimeDays'; Expression = { [math]::Round($_.ExtensionData.Summary.QuickStats.Uptime / 86400, 1) }
    }, @{
        Name = 'VMsCount'; Expression = { (Get-VM -VMHost $_).Count }
    }

    $outputFile = "Host_Resources_$((Get-Date).ToString('yyyyMMdd_HHmm')).$($OutputFormat.ToLower())"

    switch ($OutputFormat) {
        "CSV" { $report | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8 }
        "XML" { $report | Export-Clixml -Path $outputFile }
        "TXT" { $report | Format-Table -AutoSize | Out-File -FilePath $outputFile -Encoding UTF8 }
    }

    Write-Output "Host resource report generated: $outputFile"
}
catch {
    Write-Error "Error generating host report: $($_.Exception.Message)"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
