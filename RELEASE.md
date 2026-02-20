# Release Notes - VMware Virtualization Optimization Toolkit

This file provides human-friendly release notes for each version of the project.  
For detailed technical changes, see [CHANGELOG.md](CHANGELOG.md).

---

## 🚀 v1.0.0 - Initial Stable Release (2026-02-19)

### 🎉 Highlights
- First official release of the toolkit, consolidating scripts, documentation, and diagrams.
- Provides a complete set of PowerCLI automation scripts for VMware optimization.

### 🛠️ Features
- **Scripts**
  - `Optimize-VMResources.ps1`: Adjust CPU & Memory allocation for VMs.
  - `Cleanup-Snapshots.ps1`: Remove old snapshots to free storage.
  - `Balance-Workloads.ps1`: Use vMotion to balance workloads across hosts.
- **Documentation**
  - `README.md` with badges, usage examples, and architecture overview.
  - `Runbook-VMOptimization.md` with step-by-step optimization workflows.
- **Diagrams**
  - PlantUML diagrams for VMware architecture, vMotion workflow, and SRM failover.
- **Governance**
  - Added LICENSE (GNU GPL v3), NOTICE.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md, ROADMAP.md, ISSUE_TEMPLATE.md, PULL_REQUEST_TEMPLATE.md.

### 📖 How to Update
- Clone or pull the latest repository version:
git pull origin main

- Review updated documentation in `/docs`.
- Test scripts in a non-production environment before applying to production.

---

## 🔮 Upcoming (see [ROADMAP.md](ROADMAP.md))
- Logging enhancements for workload balancing and snapshot cleanup.
- Adaptive optimization based on real-time performance metrics.
- Lightweight diagrams in Mermaid.js for direct GitHub rendering.
- Release v1.1 planned with incremental improvements.

---

**Maintainer:** Mario Tabuada Mussio  
Cloud Solution Architect | IT Technical Manager  
LinkedIn: [Mario Tabuada Mussio](https://www.linkedin.com/in/mario-tabuada-mussio-2830412/)  
YouTube: [Virtualization & Digital Transformation](https://www.youtube.com/@MarioTabuadaMussio)
