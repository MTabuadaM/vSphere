# Diagrams - VMware Virtualization Optimization Toolkit

This folder contains **PlantUML diagrams** that visually represent key processes and architectures in VMware environments.  
They complement the scripts and documentation, providing a clear view of workflows and system design.

---

## 🏗️ VMware-Architecture.puml

**Purpose:**  
Shows the overall architecture of the VMware cluster, including ESXi hosts, vCenter, datastores, and VMs.

**How to interpret:**  
- ESXi hosts are grouped under clusters.  
- vCenter is represented as the central management node.  
- Datastores and networks are linked to hosts and VMs.  
- Useful for understanding resource distribution and management hierarchy.

---

## 🔄 vMotion-Workflow.puml

**Purpose:**  
Illustrates the process of **vMotion migration**, where a VM is moved from one ESXi host to another without downtime.

**How to interpret:**  
- VM state is transferred across hosts.  
- Memory and CPU context are migrated live.  
- Storage remains accessible via shared datastore.  
- Helps visualize how workload balancing scripts (`Balance-Workloads.ps1`) operate.

---

## 🌐 SRM-Failover.puml

**Purpose:**  
Depicts the **Disaster Recovery (DR) failover process** using VMware Site Recovery Manager (SRM).

**How to interpret:**  
- Primary site and recovery site are shown with replicated datastores.  
- SRM orchestrates failover of VMs to the recovery site.  
- Sequence highlights detection, failover initiation, and VM recovery.  
- Supports documentation in `/dr` for DRP testing workflows.

---

## 📖 Notes
- Diagrams are written in **PlantUML** and can be rendered directly in GitHub or external tools.  
- They are designed to be **modular**: each diagram focuses on a specific aspect (architecture, migration, recovery).  
- Use them alongside scripts and docs for a complete understanding of optimization and resilience strategies.

---

**Maintainer:** Mario Tabuada Mussio  
Cloud Solution Architect | IT Technical Manager  
LinkedIn: [Mario Tabuada Mussio](https://www.linkedin.com/in/mario-tabuada-mussio-2830412/)  
YouTube: [Virtualization & Digital Transformation](https://www.youtube.com/@MarioTabuadaMussio)
