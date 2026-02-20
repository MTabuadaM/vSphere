<#
.SYNOPSIS
    Balance VMware workloads across ESXi hosts using vMotion.

.DESCRIPTION
    This script connects to a vCenter Server, identifies VMs with high CPU usage,
    and automatically migrates them to the least loaded ESXi host using vMotion.
    Helps optimize resource utilization and maintain performance balance.

.PARAMETER vCenter
    The vCenter Server FQDN or IP address.

.PARAMETER User
    vCenter username.

.PARAMETER Password
    vCenter password.

.PARAMETER CpuThreshold
    CPU usage threshold (MHz) above which VMs are considered overloaded.

.EXAMPLE
    .\Balance-Workloads.ps1 -vCenter "vcenter.local" -User "admin" -Password "password" -CpuThreshold 2000
#>

param(
    [string]$vCenter = "vcenter.local",
    [string]$User = "admin",
    [string]$Password = "password",
    [int]$CpuThreshold = 2000
)

Write-Host "Connecting to vCenter $vCenter..."
Connect-VIServer -Server $vCenter -User $User -Password $Password

Write-Host "Searching for VMs with CPU usage above $CpuThreshold MHz..."
