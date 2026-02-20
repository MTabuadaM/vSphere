# Documentation - VMware Virtualization Optimization Toolkit

This folder contains **runbooks, guides, and step-by-step documentation** that complement the PowerCLI scripts and diagrams.  
They provide practical instructions for applying optimization, monitoring, and disaster recovery strategies in VMware environments.

---

## 📘 Runbook-VMOptimization.md

**Purpose:**  
Step-by-step guide to optimize VM resources using PowerCLI scripts.  

**Contents:**  
- How to run `Optimize-VMResources.ps1` for CPU/Memory adjustments.  
- Best practices for testing changes in non-production environments.  
- Examples of scaling application servers and standardizing VM configurations.  

---

## 📗 Runbook-SnapshotCleanup.md

**Purpose:**  
Guide for cleaning up old snapshots to free datastore space.  

**Contents:**  
- How to run `Cleanup-Snapshots.ps1`.  
- Scheduling cleanup tasks with Windows Task Scheduler or vSphere.  
- Verification steps to ensure snapshots were removed successfully.  

---

## 📙 Runbook-WorkloadBalancing.md

**Purpose:**  
Instructions for balancing workloads across ESXi hosts using vMotion.  

**Contents:**  
- How to run `Balance-Workloads.ps1`.  
- Identifying overloaded VMs with CPU usage thresholds.  
- Validating migrations with vSphere Client and PowerCLI logs.  

---

## 📕 Runbook-DRPTesting.md

**Purpose:**  
Disaster Recovery Plan (DRP) testing workflow using VMware Site Recovery Manager (SRM).  

**Contents:**  
- Simulating failover from primary to recovery site.  
- Validating VM recovery and service availability.  
- Using `SRM-Failover.puml` diagram for visualization.  

---

## 📒 Monitoring-Alerts.md

**Purpose:**  
Custom monitoring and alerting guide for VMware environments.  

**Contents:**  
- Setting up alerts for CPU, memory, and datastore usage.  
- Integrating with Aria Operations or SolarWinds dashboards.  
- Example PowerCLI queries for proactive monitoring.  

---

## 📖 Notes
- Documentation is modular: each runbook focuses on a specific process.  
- Designed for **educational and professional use**.  
- Use alongside `/scripts` and `/diagrams` for a complete toolkit.  

---

**Maintainer:** Mario Tabuada Mussio  
Cloud Solution Architect | IT Technical Manager  
LinkedIn: [Mario Tabuada Mussio](https://www.linkedin.com/in/mario-tabuada-mussio-2830412/)  
YouTube: [Virtualization & Digital Transformation](https://www.youtube.com/@MarioTabuadaMussio)
---
