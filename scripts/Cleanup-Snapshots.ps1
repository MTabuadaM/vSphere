# Cleanup-Snapshots.ps1
# Removes old snapshots to free storage

Connect-VIServer -Server "vcenter.local" -User "admin" -Password "password"

Get-VM | Get-Snapshot | Where-Object {$_.Created -lt (Get-Date).AddDays(-7)} | Remove-Snapshot -Confirm:$false

Write-Host "Old snapshots cleaned successfully."
Disconnect-VIServer -Confirm:$false
