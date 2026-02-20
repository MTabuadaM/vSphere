<#
.SYNOPSIS
    Cleanup old VMware snapshots to free storage space.

.DESCRIPTION
    This script connects to a vCenter Server, finds snapshots older than a defined threshold,
    and removes them automatically. Helps maintain performance and prevent datastore bloat.

.PARAMETER vCenter
    The vCenter Server FQDN or IP address.

.PARAMETER User
    vCenter username.

.PARAMETER Password
    vCenter password.

.PARAMETER DaysOld
    Number of days after which snapshots are considered old and should be deleted.

.EXAMPLE
    .\Cleanup-Snapshots.ps1 -vCenter "vcenter.local" -User "admin" -Password "password" -DaysOld 7
#>

param(
    [string]$vCenter = "vcenter.local",
    [string]$User = "admin",
    [string]$Password = "password",
    [int]$DaysOld = 7
)

Write-Host "Connecting to vCenter $vCenter..."
Connect-VIServer -Server $vCenter -User $User -Password $Password

Write-Host "Searching for snapshots older than $DaysOld days..."
$oldSnapshots = Get-VM | Get-Snapshot | Where-Object { $_.Created -lt (Get-Date).AddDays(-$DaysOld) }

if ($oldSnapshots) {
    foreach ($snap in $oldSnapshots) {
        Write-Host "Removing snapshot '$($snap.Name)' from VM '$($snap.VM.Name)' created on $($snap.Created)..."
        Remove-Snapshot -Snapshot $snap -Confirm:$false
    }
    Write-Host "Cleanup completed successfully."
} else {
    Write-Host "No snapshots older than $DaysOld days found."
}

Disconnect-VIServer -Confirm:$false
