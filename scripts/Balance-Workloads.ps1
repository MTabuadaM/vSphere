# Balance-Workloads.ps1
# Uses vMotion to balance workloads across hosts

Connect-VIServer -Server "vcenter.local" -User "admin" -Password "password"

$highLoadVMs = Get-VM | Where-Object {$_.CpuUsageMhz -gt 2000}
foreach ($vm in $highLoadVMs) {
    $targetHost = Get-VMHost | Sort-Object @{Expression={$_.CpuUsageMhz}} | Select-Object -First 1
    Move-VM -VM $vm -Destination $targetHost -Confirm:$false
    Write-Host "Moved $($vm.Name) to $($targetHost.Name)"
}

Disconnect-VIServer -Confirm:$false
