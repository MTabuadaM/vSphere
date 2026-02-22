# PowerCLI Quick Reference Guide

This document provides a categorized overview of the most commonly used **PowerCLI cmdlets** (from VMware.PowerCLI / VCF.PowerCLI modules) for vSphere administration.  
Use it as a cheat sheet for scripting, automation, and troubleshooting.

All examples assume you have connected to vCenter with `Connect-VIServer`.

## Connection & Configuration

| Cmdlet                        | Description                                      | Example Usage                                      |
|-------------------------------|--------------------------------------------------|----------------------------------------------------|
| Connect-VIServer              | Connect to vCenter/ESXi                          | `Connect-VIServer vcsa01.domain.local`             |
| Disconnect-VIServer           | Close session                                    | `Disconnect-VIServer * -Confirm:$false`            |
| Set-PowerCLIConfiguration     | Configure global settings (e.g., ignore certs)   | `Set-PowerCLIConfiguration -InvalidCertificateAction Ignore` |

## Virtual Machines

| Cmdlet                        | Description                                      | Example Usage                                      |
|-------------------------------|--------------------------------------------------|----------------------------------------------------|
| Get-VM                        | List VMs                                         | `Get-VM -Name prod-*`                              |
| New-VM                        | Create new VM                                    | `New-VM -Name TestVM -VMHost esxi01`               |
| Start-VM / Stop-VM            | Power on/off                                     | `Get-VM dev* | Start-VM`                         |
| Move-VM                       | vMotion (compute/storage)                        | `Move-VM -VM App01 -Destination esxi02`            |
| Get-Snapshot / New-Snapshot   | Manage snapshots                                 | `Get-Snapshot -VM ProdSQL`                         |
| Get-VMGuest                   | Guest OS info (IP, tools status)                 | `Get-VM | Get-VMGuest`                             |

## Compute Resources

| Cmdlet                        | Description                                      | Example Usage                                      |
|-------------------------------|--------------------------------------------------|----------------------------------------------------|
| Get-Stat                      | Performance metrics (CPU, memory, etc.)          | `Get-Stat -Entity $vm -Stat cpu.usage.average`     |
| Set-VMResourceConfiguration   | Set limits/reservations                          | `Set-VMResourceConfiguration -VM SQL01 -CpuSharesLevel High` |

## Networking

| Cmdlet                        | Description                                      | Example Usage                                      |
|-------------------------------|--------------------------------------------------|----------------------------------------------------|
| Get-NetworkAdapter            | VM network adapters                              | `Get-VM | Get-NetworkAdapter`                      |
| Get-VirtualPortGroup          | Standard port groups                             | `Get-VirtualPortGroup -VMHost esxi01`              |
| Get-VDPortgroup               | Distributed port groups                          | `Get-VDPortgroup -Name "VLAN-100"`                 |
| Set-NetworkAdapter            | Change VLAN/port group                           | `Set-NetworkAdapter -Portgroup VLAN-200`           |

## Storage / Datastores

| Cmdlet                        | Description                                      | Example Usage                                      |
|-------------------------------|--------------------------------------------------|----------------------------------------------------|
| Get-Datastore                 | List datastores & usage                          | `Get-Datastore | Sort FreeSpaceGB -Descending`   |
| Get-HardDisk                  | VM disks                                         | `Get-VM SQL01 | Get-HardDisk`                    |
| Move-VM (Storage vMotion)     | Migrate storage                                  | `Move-VM -VM DB01 -Datastore NewDS`                |

## Tags, Alarms & Events

| Cmdlet                        | Description                                      | Example Usage                                      |
|-------------------------------|--------------------------------------------------|----------------------------------------------------|
| Get-Tag / Set-Tag             | Manage tags                                      | `Get-TagAssignment -Entity $vm`                    |
| Get-AlarmDefinition           | View defined alarms                              | `Get-AlarmDefinition -Name "High CPU"`             |
| Get-Event / Get-Task          | Recent events & tasks                            | `Get-Event -After (Get-Date).AddDays(-7)`          |

## Real-World Script Examples

See the `/scripts/` folder for full implementations. Here are key patterns:

1. **Inventory + Stats Report**  
   ```powershell
   $vms = Get-VM
   $report = $vms | Select Name, PowerState, @{N="CpuUsage%";E={(Get-Stat -Entity $_ -Stat cpu.usage.average -MaxSamples 1).Value}}
   $report | Export-Csv "VM-Stats.csv" -NoTypeInformation

2. **Old Snapshots Cleanup**
   Get-VM | Get-Snapshot | Where {$_.Created -lt (Get-Date).AddDays(-30)} | Remove-Snapshot -Confirm:$false

3. **Host Overload Detection**
  Get-VMHost | Get-Stat -Stat cpu.usage.average -MaxSamples 1 | Where {$_.Value -gt 80}

# Always test scripts in a lab environment first.
Note: This reference is not exhaustive. Use Get-Command -Module VMware* to explore all available cmdlets.
For full documentation: VMware PowerCLI Reference
Last updated: February 2026.





  
