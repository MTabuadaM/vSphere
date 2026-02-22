<#
.SYNOPSIS
    Checks backup status of VMs (Veeam integration - basic example).
.DESCRIPTION
    Attempts to retrieve last backup information using Veeam PowerShell module.
    Note: Requires Veeam Backup & Replication PowerShell module installed.
.PARAMETER vCenterServer
    The FQDN or IP address of the vCenter Server.
.PARAMETER OutputFormat
    Output format: CSV (default), XML, or TXT.
.EXAMPLE
    .\VM-Backup-Status.ps1 -vCenterServer "vcsa01.domain.local"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,

    [ValidateSet("CSV", "XML", "TXT")]
    [string]$OutputFormat = "CSV"
)

Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue

# Attempt to load Veeam module (comment out or adapt if not using Veeam)
if (Get-Module -ListAvailable -Name VeeamPSSnapin) {
    Add-PSSnapin VeeamPSSnapin -ErrorAction SilentlyContinue
} else {
    Write-Warning "Veeam PowerShell module not found. Report will show 'N/A' for backup info."
}

try { Connect-VIServer -Server $vCenterServer -ErrorAction Stop | Out-Null }
catch { Write-Error "Connection failed: $($_.Exception.Message)"; exit 1 }

try {
    $report = Get-VM | ForEach-Object {
        $vm = $_
        $backupInfo = $null

        if (Get-Command Get-VBRBackup -ErrorAction SilentlyContinue) {
            $backup = Get-VBRBackup | Where-Object { $_.Name -like "*$($vm.Name)*" } | Sort-Object CreationTime -Descending | Select-Object -First 1
            if ($backup) {
                $session = Get-VBRBackupSession -Backup $backup | Sort-Object EndTime -Descending | Select-Object -First 1
                $backupInfo = $session.Result
                $lastTime = $session.EndTime
            }
        }

        [PSCustomObject]@{
            VMName      = $vm.Name
            PowerState  = $vm.PowerState
            LastBackup  = if ($lastTime) { $lastTime } else { "N/A" }
            BackupStatus = if ($backupInfo) { $backupInfo } else { "No backup found or Veeam not available" }
        }
    }

    $outputFile = "VM_Backup_Status_$((Get-Date).ToString('yyyyMMdd_HHmm')).$($OutputFormat.ToLower())"

    switch ($OutputFormat) {
        "CSV" { $report | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8 }
        "XML" { $report | Export-Clixml -Path $outputFile }
        "TXT" { $report | Format-Table -AutoSize | Out-File -FilePath $outputFile -Encoding UTF8 }
    }

    Write-Output "Backup status report generated: $outputFile"
}
catch {
    Write-Error "Error generating backup report: $($_.Exception.Message)"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
