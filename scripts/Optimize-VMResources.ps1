<#
.SYNOPSIS
    Optimize VM resources (CPU and Memory) in VMware vSphere.

.DESCRIPTION
    This script connects to a vCenter Server, retrieves a specified VM,
    and adjusts its CPU and Memory allocation based on input parameters.
    Useful for performance tuning and resource optimization.

.PARAMETER vCenter
    The vCenter Server FQDN or IP address.

.PARAMETER User
    vCenter username.

.PARAMETER Password
    vCenter password.

.PARAMETER VMName
    Name of the Virtual Machine to optimize.

.PARAMETER CPUCount
    Desired number of vCPUs.

.PARAMETER MemoryGB
    Desired amount of memory (GB).

.EXAMPLE
    .\Optimize-VMResources.ps1 -vCenter "vcenter.local" -User "admin" -Password "password" -VMName "AppServer01" -CPUCount 4 -MemoryGB 8
#>

param(
    [string]$vCenter = "vcenter.local",
    [string]$User = "admin",
    [string]$Password = "password",
    [string]$VMName,
    [int]$CPUCount = 4,
    [int]$MemoryGB = 8
)

Write-Host "Connecting to vCenter $vCenter..."
Connect-VIServer -Server $vCenter -User $User -Password $Password

Write-Host "Retrieving VM: $VMName..."
$vm = Get-VM -Name $VMName

if ($vm) {
    Write-Host "Optimizing VM $VMName..."
    Set-VM -VM $vm -NumCpu $CPUCount -MemoryGB $MemoryGB -Confirm:$false
    Write-Host "Optimization applied: $CPUCount CPUs, $MemoryGB GB RAM"
} else {
    Write-Host "VM $VMName not found in vCenter $vCenter."
}

Disconnect-VIServer -Confirm:$false
