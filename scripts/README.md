# Scripts - VMware Virtualization Optimization Toolkit

This folder contains PowerCLI automation scripts designed to optimize VMware vSphere environments.  
Each script includes parameters for flexibility and can be adapted to different infrastructures.

---

## 🧹 Cleanup-Snapshots.ps1

**Purpose:**  
Removes old snapshots to free storage space and prevent datastore bloat.

**Usage Example:**
```powershell
.\Cleanup-Snapshots.ps1 -vCenter "vcenter.local" -User "admin" -Password "password" -DaysOld 7

Case of Use:
Scheduled maintenance to clean up snapshots older than 7 days.
Prevents performance degradation caused by excessive snapshot accumulation.

## ⚖️ Balance-Workloads.ps1
Purpose:  
Balances workloads across ESXi hosts using vMotion, migrating VMs with high CPU usage to less loaded hosts.

Usage Example:
.\Balance-Workloads.ps1 -vCenter "vcenter.local" -User "admin" -Password "password" -CpuThreshold 2000

Case of Use:
Automatically redistributes VMs when CPU usage exceeds 2000 MHz.
Ensures optimal resource utilization across the cluster.

## 🚀 Optimize-VMResources.ps1
Purpose:  
Adjusts CPU and memory allocation for a specific VM to optimize performance.

Usage Example:
.\Optimize-VMResources.ps1 -vCenter "vcenter.local" -User "admin" -Password "password" -VMName "AppServer01" -CPUCount 4 -MemoryGB 8

Case of Use:
Increase resources for an application server experiencing high demand.
Standardize VM configurations across environments.

## 📖 Notes
Always test scripts in a non-production environment before applying to production.

Credentials should be managed securely (avoid hardcoding passwords).

Scripts are licensed under GNU GPL v3 (see [Looks like the result wasn't safe to show. Let's switch things up and try something else!]).

# Maintainer: Mario Tabuada Mussio
Cloud Solution Architect | IT Technical Manager

---
