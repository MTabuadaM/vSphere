<#
.SYNOPSIS
    Performs a health check on virtual machines and generates a report.
.DESCRIPTION
    Checks for common issues: VMware Tools status, old snapshots (>30 days), high CPU ready time.
    Optional remediation for tools upgrade.
.PARAMETER vCenterServer
    The FQDN or IP address of the vCenter Server.
.PARAMETER OutputFormat
    Output format: CSV (default), XML, or TXT.
.PARAMETER FixTools
    Attempt to update VMware Tools on VMs where status is not OK.
.EXAMPLE
    .\VM-Health-Check.ps1 -vCenterServer "vcsa01.domain.local" -FixTools
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,

    [ValidateSet("CSV", "XML", "TXT")]
    [string]$OutputFormat = "CSV",

    [switch]$FixTools
)

Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue

try { Connect-VIServer -Server $vCenterServer -ErrorAction Stop | Out-Null }
catch { Write-Error "Connection failed: $($_.Exception.Message)"; exit 1 }

try {
    $health = Get-VM | ForEach-Object {
        $vm = $_
        $toolsStatus = $vm.ExtensionData.Guest.ToolsStatus
        $oldSnapshots = (Get-Snapshot -VM $vm | Where-Object { $_.Created -lt (Get-Date).AddDays(-30) }).Count
        $cpuReadySample = Get-Stat -Entity $vm -Stat cpu.ready.summation -MaxSamples 1 -Realtime:$true -ErrorAction SilentlyContinue
        $cpuReadyPct = if ($cpuReadySample) { [math]::Round(($cpuReadySample.Value / 20000), 2) } else { "N/A" }

        $issues = @()
        if ($toolsStatus -ne "toolsOk") { $issues += "Tools not OK ($toolsStatus)" }
        if ($oldSnapshots -gt 0) { $issues += "$oldSnapshots old snapshots" }
        if ($cpuReadyPct -is [double] -and $cpuReadyPct -gt 10) { $issues += "High CPU ready ($cpuReadyPct%)" }

        $obj = [PSCustomObject]@{
            VMName       = $vm.Name
            ToolsStatus  = $toolsStatus
            OldSnapshots = $oldSnapshots
            CpuReadyPct  = $cpuReadyPct
            Issues       = if ($issues) { $issues -join '; ' } else { "Healthy" }
        }

        if ($FixTools -and $toolsStatus -ne "toolsOk") {
            try {
                Update-Tools -VM $vm -NoReboot -ErrorAction Stop
                $obj.Issues += "; Tools update attempted"
            }
            catch {
                $obj.Issues += "; Tools update failed"
            }
        }

        $obj
    }

    $outputFile = "VM_Health_$((Get-Date).ToString('yyyyMMdd_HHmm')).$($OutputFormat.ToLower())"

    switch ($OutputFormat) {
        "CSV" { $health | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8 }
        "XML" { $health | Export-Clixml -Path $outputFile }
        "TXT" { $health | Format-Table -AutoSize | Out-File -FilePath $outputFile -Encoding UTF8 }
    }

    Write-Output "Health check report generated: $outputFile"
}
catch {
    Write-Error "Health check error: $($_.Exception.Message)"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
