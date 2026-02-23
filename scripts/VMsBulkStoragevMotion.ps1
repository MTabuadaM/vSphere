<#
.SYNOPSIS
    Performs bulk storage vMotion to a new datastore, excluding critical VMs.
.DESCRIPTION
    Uses Get-Datastore, Get-VM, Get-TagAssignment, Move-VM.
.PARAMETER vCenterServer
    vCenter FQDN or IP.
.PARAMETER SourceDatastore
    Datastore to evacuate.
.PARAMETER TargetDatastore
    Destination datastore.
.PARAMETER CriticalTag
    Tag to exclude (e.g., "DoNotMigrate").
.EXAMPLE
    .\Bulk-Storage-vMotion.ps1 -vCenterServer "vcsa01.domain.local" -SourceDatastore "OldDS" -TargetDatastore "NewFastDS" -CriticalTag "Production-Critical"
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,
    [Parameter(Mandatory = $true)]
    [string]$SourceDatastore,
    [Parameter(Mandatory = $true)]
    [string]$TargetDatastore,
    [string]$CriticalTag = "DoNotMigrate"
)

Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue

try {
    Connect-VIServer -Server $vCenterServer -ErrorAction Stop | Out-Null

    $sourceDS = Get-Datastore -Name $SourceDatastore -ErrorAction Stop
    $targetDS = Get-Datastore -Name $TargetDatastore -ErrorAction Stop

    $vmsToMove = Get-VM -Datastore $sourceDS |
        Where-Object {
            $tags = (Get-TagAssignment -Entity $_).Tag.Name
            -not ($tags -contains $CriticalTag)
        }

    Write-Output "Found $($vmsToMove.Count) VMs eligible for migration from $SourceDatastore to $TargetDatastore"

    foreach ($vm in $vmsToMove) {
        if ($PSCmdlet.ShouldProcess($vm.Name, "Storage vMotion to $TargetDatastore")) {
            try {
                Move-VM -VM $vm -Datastore $targetDS -ErrorAction Stop
                Write-Output "Successfully moved $($vm.Name)"
            }
            catch {
                Write-Warning "Failed to move $($vm.Name): $($_.Exception.Message)"
            }
        }
    }
}
catch {
    Write-Error "Error during bulk migration: $($_.Exception.Message)"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
