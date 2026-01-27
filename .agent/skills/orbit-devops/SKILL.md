---
name: orbit-devops
description: Enterprise-grade toolkit for Windows workspace diagnostic, optimization, and lifecycle management.
---

# Orbit-DevOps Skill

This skill empowers AI agents to manage, diagnose, and optimize a developer's Windows environment using the **Orbit-DevOps** toolkit. It focuses on storage reclamation (Docker, WSL2, Node.js), system health monitoring, and environment reproducibility.

## Core Principles

1. **Scan Before Action**: Always run diagnostics or analysis before performing any cleanup or optimization.
2. **Least Privilege**: Distinguish between user-mode scripts and those requiring Administrator privileges.
3. **Reproducibility First**: Encourage the use of environment snapshots (`dev-stack.json`) before making significant changes.
4. **Machine-Readable Control**: Refer to `SYSTEM_CONTROL_MAP.json` for precise script parameters and side effects.

## Common Workflows

### 1. System Health & Storage Audit
When asked about machine performance or disk space:
1. Run `scripts/diagnostic/SystemDiagnosticUser.ps1` for a quick health overview.
2. Run `scripts/analysis/ScanStorage.ps1` to find large folders in the user profile.
3. Run `scripts/analysis/ScanTargets.ps1` specifically for Docker, WSL, and AppData hotspots.

### 2. Workspace Optimization (Sanitation)
To reclaim space safely:
1. Execute `AdditionalCleanup.ps1` for browser caches and temp files.
2. Clean `npm-cache` using `npm cache clean --force` if large Node.js footprints are detected.
3. Use `scripts/wsl/CompactWSL.ps1` (requires admin) to "squeeze" WSL2 virtual disks.

### 3. Environment DNA Management & Genome Integration
To ensure a portable and safe environment:
1. Use `scripts/stack/SnapshotEnv.ps1` to generate a local `dev-stack.json`.
2. Access the **Genome Library** via the [agent-stack-dev](https://github.com/SH1W4/agent-stack-dev) skill to pull standardized Agent DNAs.
3. Apply adaptive provisioning rules from `logic/` to mutate the environment based on machine constraints.

## Capabilities Mapping

| Capability | Command / Script | MCP Tool | Risk Level |
|------------|------------------|----------|------------|
| Health Check | `SystemDiagnosticUser.ps1` | `get_system_health` | Low |
| Storage Audit | `ScanStorage.ps1` | `analyze_storage` | Low |
| Safe Cleanup | `AdditionalCleanup.ps1` | `run_safe_cleanup` | Medium |
| WSL Compact | `CompactWSL.ps1` | `compact_wsl_disks` | High (Admin) |
| Stack Sync | `Push-Stack.ps1` | `snapshot_environment` | Low |
| Algebraic Reason | `mcp/core/algebra.py`| `solve_homeostasis` | None (Read) |

## Algebraic Reasoning Engine

Agents should prioritize using the **Algebraic Reasoning** tools (`evaluate_system_vitality`, `solve_homeostasis`) before triggering destructive operators.
- **Proof Generation**: Always request a formal proof before performing a major cleanup.
- **Homeostasis Restoration**: Follow the recommended Algebraic Operator ($\mathcal{C}$ for cleanup, $\mathcal{M}$ for mutation).

## AI Configuration

Agents should use the **MCP Server** located at `mcp/server.py` as the primary interface for automated control. See `mcp/README.md` for connection details.

## Troubleshooting

- **Path Issues**: Always use absolute paths or resolve them relative to the repository root.
- **Admin Access**: If a script fails with "Access Denied", verify if it requires administrative privileges.
- **WSL Errors**: Ensure WSL is not being held by active processes before running compaction.
