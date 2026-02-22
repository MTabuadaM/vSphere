<#
.SYNOPSIS
    Detects and optionally removes orphaned / disconnected / inaccessible VMs.
.DESCRIPTION
    Finds VMs in states: orphaned, disconnected, inaccessible.
    Default is dry-run (simulation only).
.PARAMETER vCenterServer
    The FQDN or IP address of the vCenter Server.
.PARAMETER DryRun
    Simulate cleanup without actual deletion (default: $true).
.PARAMETER OutputFormat
    Log format: CSV (default), XML, or TXT.
.EXAMPLE
    .\Orphaned-VM-Cleanup.ps1 -vCenterServer "vcsa01.domain.local" -DryRun $false
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,

    [bool]$DryRun = $true,

    [ValidateSet("CSV", "XML", "TXT")]
    [string]$OutputFormat = "CSV"
)

Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue

try { Connect-VIServer -Server $vCenterServer -ErrorAction Stop | Out-Null }
catch { Write-Error "Connection failed: $($_.Exception.Message)"; exit 1 }

try {
    $badStates = @("orphaned", "disconnected", "inaccessible")
    $vms = Get-View -ViewType VirtualMachine -Filter @{ "Runtime.ConnectionState" = $badStates -join "|" }

    $log = @()

    foreach ($vmView in $vms) {
        $vmName = $vmView.Name
        $state = $vmView.Runtime.ConnectionState

        $action = if ($DryRun) { "Dry-run: Would remove $vmName ($state)" } else { "Removing $vmName ($state)" }

        if (-not $DryRun -and $PSCmdlet.ShouldProcess($vmName, "Remove orphaned VM")) {
            try {
                $task = $vmView.Destroy_Task()
                $logEntry = [PSCustomObject]@{
                    Timestamp = Get-Date
                    VMName    = $vmName
                    State     = $state
                    Action    = "Removed successfully"
                    Result    = "Task submitted"
                }
            }
            catch {
                $logEntry = [PSCustomObject]@{
                    Timestamp = Get-Date
                    VMName    = $vmName
                    State     = $state
                    Action    = "Failed"
                    Result    = $_.Exception.Message
                }
            }
        } else {
            $logEntry = [PSCustomObject]@{
                Timestamp = Get-Date
                VMName    = $vmName
                State     = $state
                Action    = $action
                Result    = "No change (dry-run)"
            }
        }

        $log += $logEntry
    }

    $outputFile = "Orphaned_Cleanup_$((Get-Date).ToString('yyyyMMdd_HHmm')).$($OutputFormat.ToLower())"

    switch ($OutputFormat) {
        "CSV" { $log | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8 }
        "XML" { $log | Export-Clixml -Path $outputFile }
        "TXT" { $log | Format-Table -AutoSize | Out-File -FilePath $outputFile -Encoding UTF8 }
    }

    Write-Output "Orphaned VMs check completed. Log: $outputFile (Dry-run: $DryRun)"
}
catch {
    Write-Error "Error during orphaned cleanup: $($_.Exception.Message)"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
