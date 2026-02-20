# Monitoring - VMware Virtualization Optimization Toolkit

This folder contains guides and scripts for **monitoring VMware environments** and setting up custom alerts.  
The goal is to proactively detect performance issues and ensure optimal resource utilization.

---

## 📊 Monitoring-Alerts.md

**Purpose:**  
Provides instructions for creating custom alerts in VMware vSphere and integrating with external monitoring tools.

**Contents:**  
- PowerCLI queries for CPU, memory, and datastore usage.  
- Examples of alert thresholds (e.g., CPU > 80%, datastore free space < 20%).  
- Steps to configure alerts in vSphere Client.  
- Integration with Aria Operations dashboards.  
- Example SolarWinds alert configuration for VMware metrics.

---

## 🛠️ Example PowerCLI Queries

**Check CPU usage across VMs:**
```powershell
Get-VM | Select Name, CpuUsageMhz

**Check datastore free space:**
Get-Datastore | Select Name, FreeSpaceGB, CapacityGB

**Check memory usage across hosts:**
Get-VMHost | Select Name, MemoryUsageGB, MemoryTotalGB

##🚨 Use Cases
Capacity Planning:  
Monitor datastore growth and plan expansions before reaching critical thresholds.

Performance Optimization:  
Detect VMs with high CPU/memory usage and trigger workload balancing.

Proactive Alerts:  
Configure notifications when thresholds are exceeded, reducing downtime risk.

📖 Notes
Alerts should be tested in a non-production environment before deployment.

Combine monitoring with scripts in /scripts for automated remediation.

Use dashboards in Aria Operations or SolarWinds for centralized visibility.

Maintainer: Mario Tabuada Mussio
Cloud Solution Architect | IT Technical Manager
---
