# Optimize-VMResources.ps1
# Script to adjust CPU and Memory allocation for VMs in vSphere

param(
    [string]$VMName,
    [int]$CPUCount = 4,
    [int]$MemoryGB = 8
)

Write-Host "Connecting to vCenter..."
Connect-VIServer -Server "vcenter.local" -User "admin" -Password "password"

$vm = Get-VM -Name $VMName
Set-VM -VM $vm -NumCpu $CPUCount -MemoryGB $MemoryGB -Confirm:$false

Write-Host "Optimization applied to $VMName: $CPUCount CPUs, $MemoryGB GB RAM"
Disconnect-VIServer -Confirm:$false
