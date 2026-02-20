# Runbook: VM Optimization

## Step 1: Connect to vCenter
Use PowerCLI to connect:
Connect-VIServer -Server vcenter.local -User admin -Password password

## Step 2: Apply Optimization
Run `Optimize-VMResources.ps1` with parameters:
.\Optimize-VMResources.ps1 -VMName "AppServer01" -CPUCount 4 -MemoryGB 8

## Step 3: Validate Performance
Check metrics in vRealize/Aria Operations dashboard.
