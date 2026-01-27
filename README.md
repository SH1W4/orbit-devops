# 🪐 Orbit-DevOps

<div align="center">
  <h3>The Developer's Workspace Command Center</h3>
  <p>
    Diagnose. Optimize. Compact. Control.
  </p>
  
  <p>
    <a href="LICENSE">
      <img src="https://img.shields.io/badge/license-MIT-blue?style=flat-square" alt="License" />
    </a>
    <img src="https://img.shields.io/badge/platform-Windows_10%2F11%2BWSL2-0078D6?style=flat-square&logo=windows&logoColor=white" alt="Platform" />
    <img src="https://img.shields.io/badge/PowerShell-7.0%2B-5391FE?style=flat-square&logo=powershell&logoColor=white" alt="PowerShell" />
    <img src="https://img.shields.io/badge/AI-MCP_Ready-purple?style=flat-square&logo=openai&logoColor=white" alt="MCP Ready" />
  </p>
</div>

---

**Orbit-DevOps** is a comprehensive toolkit designed to keep a developer's Windows environment efficient, clean, and reproducible. It goes beyond simple cleanup to manage the complex footprint of modern development stacks (Docker, WSL2, Anaconda, Node.js).

## 🚀 Why Orbit-DevOps?

- **🛡️ Intelligent Maintenance:** Safely reclaims storage from dev tools without breaking projects.
- **� WSL2 Optimization:** Advanced tools to compact Linux virtual disks (vhdx) that Windows ignores.
- **💾 Environment Snapshots:** Export and restore your installed tools stack using Winget.
- **🤖 AI-Powered:** Built-in MCP (Model Context Protocol) server allows AI agents to manage your machine.

## ✨ Core Modules

### 1. 🔍 Deep Diagnostics
- **Storage CSI:** Forensically analyze where every GB is going (User root, AppData, Docker layers).
- **Health Checks:** Monitor system vital signs critical for performance.

### 2. 🧹 Smart Sanitation
- **Dev Stack Cleaning:**
  - **Docker:** Prunes dangling images/volumes while respecting active containers.
  - **Node/Python:** Cleans global caches and unused environments.
  - **IDE:** Optimizes Cursor/VSCode caches.
- **System:** Cleans browser caches and temp files safely.

### 3. 🐧 WSL2 Management
- **Compact:** Shrimp your `ext4.vhdx` files to reclaim "ghost" space deleted inside Linux.
- **Analyze:** See which WSL distros are eating your drive.

### 4. 📦 Stack Control
- **Snapshot:** `winget export` wrapper to backup your toolchain.
- **Sync:** Automatically push your environment DNA to GitHub (`SH1W4/stack`).
- **Restore:** One-click reinstallation of your dev environment.

## 🤖 AI Integration (MCP Agent)

Orbit-DevOps includes a native **Model Context Protocol (MCP)** server.
- **Connect:** Link Claude/Cursor to your local machine.
- **SKILL:** Pre-defined `.agent/skills/orbit-devops` for autonomous AI operation.
- **Documentation:** See [mcp/README.md](mcp/README.md) and [SKILL.md](.agent/skills/orbit-devops/SKILL.md).

## 🚀 Quick Start

### Interactive Menu (The "Orbit" Command)
Run `Orbit.ps1` to access the full control panel:
```powershell
.\Orbit.ps1
```

### Manual Execution

**Diagnostic Scan:**
```powershell
.\scripts\diagnostic\SystemDiagnosticUser.ps1
```

**Storage Analysis:**
```powershell
.\scripts\analysis\ScanStorage.ps1
```

**Safe Cleanup:**
```powershell
.\scripts\cleanup\AdditionalCleanup.ps1
```

## 🏗️ Architecture

Orbit-DevOps follows a modular layer pattern (Presentation -> Logic -> Execution).
See [ARCHITECTURE.json](ARCHITECTURE.json) for details.

## 📊 Benchmarks

Typical recovery on a Senior Dev workstation:

| Component | Before Orbit | After Orbit | Optimization |
|-----------|--------------|-------------|-----------|
| **WSL2 Disk** | 64.0 GB | 12.0 GB | **81% Compacted** |
| **Docker** | 25.0 GB | 0.3 GB | **98% Reduction** |
| **IDE Caches** | 13.0 GB | 6.5 GB | **50% Reduction** |
| **Total** | **Critical** | **Healthy** | **Massive Gain** |

## 🤝 Contributing

We welcome contributions! Please check [CONTRIBUTING.md](CONTRIBUTING.md).

## 📝 License

Licensed under the [MIT License](LICENSE).

---
<div align="center">
  <sub>Made with ❤️ by <a href="https://github.com/SH1W4">SH1W4</a></sub>
</div>
