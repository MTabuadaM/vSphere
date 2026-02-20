# Disaster Recovery (DR) - VMware Virtualization Optimization Toolkit

This folder contains documentation and scripts related to **Disaster Recovery Planning (DRP)** and testing workflows in VMware environments.  
It demonstrates how to simulate failover scenarios using VMware Site Recovery Manager (SRM) and complementary automation.

---

## 🌐 SRM-Failover Simulation

**Purpose:**  
Simulate a failover from the primary site to the recovery site using VMware SRM.

**Contents:**  
- Step-by-step instructions for initiating failover.  
- Validation of VM recovery and service availability.  
- Integration with `SRM-Failover.puml` diagram for visualization.  

**Usage Example:**  
- Trigger SRM failover in vSphere Client.  
- Validate that VMs are powered on and accessible in the recovery site.  
- Document results in `/docs/Runbook-DRPTesting.md`.

---

## 🛠️ Scripts Integration

Although most DR workflows are orchestrated by SRM, scripts can support:
- **Pre-checks**: Verify replication status and datastore health.  
- **Post-checks**: Confirm VM IP addresses, DNS registration, and application availability.  
- **Logging**: Record failover events for audit purposes.  

---

## 📊 Diagrams

- **SRM-Failover.puml**: Visual representation of the failover process.  
  - Primary site and recovery site with replicated datastores.  
  - SRM orchestration steps (detection, failover initiation, VM recovery).  
  - Helps visualize dependencies and sequence of events.  

---

## 📖 Notes
- These scenarios are **educational exercises** and may not reflect production best practices.  
- Always test DR workflows in a **controlled environment** before applying to production.  
- Combine with `/docs/Runbook-DRPTesting.md` for a complete DRP simulation.  

---

**Maintainer:** Mario Tabuada Mussio  
Cloud Solution Architect | IT Technical Manager  
LinkedIn: [Mario Tabuada Mussio](https://www.linkedin.com/in/mario-tabuada-mussio-2830412/)  
YouTube: [Virtualization & Digital Transformation](https://www.youtube.com/@MarioTabuadaMussio)
---
