# VMware Virtualization Optimization Toolkit

A professional toolkit showcasing optimization strategies for VMware vSphere, VCF, and Aria Cloud Suite environments.  
Includes automation scripts, performance tuning guides, and disaster recovery implementations designed to maximize efficiency, resilience, and scalability in enterprise virtualization.

## Overview

This repository showcases practical implementations of **virtualization optimization** using VMware technologies.

It includes **automation scripts, performance tuning guides, monitoring dashboards, and disaster recovery procedures** designed to maximize efficiency, resilience, and scalability in enterprise environments.

> **Note**: This repository is documented entirely in English for consistency with official VMware/PowerCLI documentation and broader community reach. Issues and discussions in Spanish are welcome — we'll respond accordingly!

## Repository Structure

### Scripts & Automation

This repository provides a collection of PowerShell scripts using VMware PowerCLI to automate common vSphere administration tasks. All scripts are designed for efficiency in enterprise, lab, or educational environments and include proper error handling, parameter validation, and export options (CSV, XML, TXT).

Scripts are located in the `/scripts/` directory.

#### Core Optimization & Operations Scripts

| Script Name                  | Description                                                                 | Primary Use Case                          |
|------------------------------|-----------------------------------------------------------------------------|-------------------------------------------|
| Optimize-VMResources.ps1     | Dynamically adjusts CPU and Memory allocation based on historical usage patterns | Resource optimization & rightsizing       |
| Cleanup-Snapshots.ps1        | Identifies and removes old or unnecessary snapshots to reclaim storage     | Storage cleanup & performance improvement |
| Balance-Workloads.ps1        | Uses vMotion to automatically balance VM workloads across hosts            | Load balancing & DRS enhancement          |
| Custom-Alerts.ps1            | Creates or monitors custom alerts for CPU Ready Time, Memory Ballooning, etc. | Proactive alerting without Aria Ops       |
| Failover-Test.ps1            | Simulates Site Recovery Manager (SRM) failover for DR plan validation       | Disaster recovery testing                 |

#### Reporting, Health & Management Scripts

These additional scripts focus on inventory, health checks, reporting, and cleanup — ideal for auditing, troubleshooting, and daily operations.

| Script Name                     | Description                                                                 | Primary Use Case                          |
|---------------------------------|-----------------------------------------------------------------------------|-------------------------------------------|
| VM-Inventory-Report.ps1         | Generates a comprehensive inventory of all VMs (name, power state, CPU/RAM, OS, IP, datastores, tags) | Auditing, compliance & capacity planning  |
| VM-Health-Check.ps1             | Scans VMs for common issues (VMware Tools status, old snapshots, high CPU ready) with optional auto-fix | Proactive health monitoring & remediation |
| VM-Clone-Automate.ps1           | Automates cloning from templates/existing VMs with custom naming, host, and datastore placement | Rapid provisioning & lab/test environments|
| Datastore-Usage-Report.ps1      | Reports datastore capacity, used/free space, provisioned vs consumed, and VM count | Storage monitoring & planning             |
| Host-Resource-Monitor.ps1       | Monitors ESXi host resources (CPU/memory usage %, uptime, VM count)        | Host performance overview & bottleneck detection |
| Network-Config-Report.ps1       | Collects network adapter details (port groups, MAC, IPs, connection state) for all VMs | Network troubleshooting & audits          |
| VM-Backup-Status.ps1            | Checks backup status (integrates with Veeam if available; shows last backup time & result) | Backup compliance & DR readiness          |
| Orphaned-VM-Cleanup.ps1         | Detects and optionally removes orphaned, disconnected, or inaccessible VMs (dry-run by default) | Cleanup of ghost VMs & resource reclamation |

### Performance Tuning

- VDI-Latency-Benchmark.md → Benchmarks comparing default vs optimized VM configurations.

### Monitoring & Reporting

- Custom-Alerts.ps1 → Alerts for CPU Ready Time & Memory Ballooning.

### Disaster Recovery & High Availability

- Failover-Test.ps1 → Simulates SRM failover for DRP validation.

### Documentation

- Runbook-VMOptimization.md → Step-by-step guide for optimization workflows.

### Diagrams (Visual Architecture)

- VMware Optimized Architecture: ![VMware Architecture](diagrams/VMware-Architecture.puml)
- vMotion Workflow: ![vMotion Workflow](diagrams/vMotion-Workflow.puml)
- SRM Failover Process: ![SRM Failover](diagrams/SRM-Failover.puml)

## Usage Examples

### Optimize VM Resources

```powershell
.\scripts\Optimize-VMResources.ps1 -VMName "AppServer01" -CPUCount 4 -MemoryGB 8

### Generate VM Inventory Report (new)

.\scripts\VM-Inventory-Report.ps1 -vCenterServer "vcsa01.yourdomain.local" -OutputFormat CSV

### Notes:

All scripts require VMware PowerCLI (install via Install-Module -Name VMware.PowerCLI). Always test in a non-production environment first.
Important Disclaimer
These scripts are community-contributed and not officially supported by VMware/Omnissa/Broadcom.
Use at your own risk. Always back up configurations, test thoroughly in a lab, and verify compatibility with your vSphere version. No warranties expressed or implied.
For more details on each script, refer to the inline help (e.g., Get-Help .\scripts\VM-Health-Check.ps1 -Full).

# Author
Mario Tabuada Mussio
Cloud Solution Architect | IT Technical Manager
📧 mario.tabuada@outlook.com
🌐 LinkedIn: Mario Tabuada Mussio
🎥 YouTube: Virtualization & Digital Transformation

Contributing
See CONTRIBUTING.md for guidelines on how to contribute.

License
This project is licensed under the GNU General Public License v3.0 - see the License file for details.

Code of Conduct
We follow the Contributor Covenant Code of Conduct.

Security
Report security issues via SECURITY.md.
#
