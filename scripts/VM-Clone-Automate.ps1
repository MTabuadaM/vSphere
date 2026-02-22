<#
.SYNOPSIS
    Automates the cloning of a virtual machine from a template or existing VM.
.DESCRIPTION
    Creates a new VM clone with specified name, target host, and datastore.
    Starts the new VM and logs the operation.
.PARAMETER vCenterServer
    The FQDN or IP address of the vCenter Server.
.PARAMETER SourceVM
    Name of the source VM or template to clone from.
.PARAMETER NewVMName
    Name for the new cloned VM.
.PARAMETER TargetHost
    Name of the target ESXi host (optional - will use default if omitted).
.PARAMETER TargetDatastore
    Name of the target datastore (optional).
.PARAMETER OutputFormat
    Log format: CSV (default), XML, or TXT.
.EXAMPLE
    .\VM-Clone-Automate.ps1 -vCenterServer "vcsa01.domain.local" -SourceVM "WinTemplate" -NewVMName "TestVM-01" -TargetDatastore "datastore1"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,

    [Parameter(Mandatory = $true)]
    [string]$SourceVM,

    [Parameter(Mandatory = $true)]
    [string]$NewVMName,

    [string]$TargetHost,

    [string]$TargetDatastore,

    [ValidateSet("CSV", "XML", "TXT")]
    [string]$OutputFormat = "CSV"
)

Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue

try { Connect-VIServer -Server $vCenterServer -ErrorAction Stop | Out-Null }
catch { Write-Error "Connection failed: $($_.Exception.Message)"; exit 1 }

try {
    $source = Get-VM -Name $SourceVM -ErrorAction Stop

    $cloneParams = @{
        VM          = $source
        Name        = $NewVMName
        VMHost      = if ($TargetHost) { Get-VMHost -Name $TargetHost } else { $null }
        Datastore   = if ($TargetDatastore) { Get-Datastore -Name $TargetDatastore } else { $null }
        Location    = $source.VMHost.Parent  # Same folder/cluster as source by default
    }

    $newVM = New-VM @cloneParams -ErrorAction Stop

    Start-VM -VM $newVM -ErrorAction Stop | Out-Null

    $logEntry = [PSCustomObject]@{
        Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        SourceVM    = $SourceVM
        NewVMName   = $NewVMName
        TargetHost  = if ($TargetHost) { $TargetHost } else { $newVM.VMHost.Name }
        Datastore   = if ($TargetDatastore) { $TargetDatastore } else { $newVM.Datastore.Name }
        Status      = "Success - VM started"
    }
}
catch {
    $logEntry = [PSCustomObject]@{
        Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        SourceVM    = $SourceVM
        NewVMName   = $NewVMName
        Status      = "Failed: $($_.Exception.Message)"
    }
    Write-Error $logEntry.Status
}

$outputFile = "Clone_Operation_$((Get-Date).ToString('yyyyMMdd_HHmm')).$($OutputFormat.ToLower())"

switch ($OutputFormat) {
    "CSV" { $logEntry | Export-Csv -Path $outputFile -NoTypeInformation -Append -Encoding UTF8 }
    "XML" { $logEntry | Export-Clixml -Path $outputFile -Append }
    "TXT" { $logEntry | Format-List | Out-File -FilePath $outputFile -Append -Encoding UTF8 }
}

Write-Output "Clone operation logged to: $outputFile"

finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
