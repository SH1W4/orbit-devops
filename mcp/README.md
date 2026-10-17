# 🤖 Orbit-DevOps MCP Agent

This directory contains the **Model Context Protocol (MCP)** implementation for Orbit-DevOps. It turns the toolkit into an intelligent agent that AI coding assistants (like Claude Desktop, Cursor, etc.) can communicate with to diagnose and optimize your system directly.

## 🌟 Capabilities

The MCP agent enables your AI assistant to:

- 🏥 **Check System Health:** Query CPU, RAM, and Disk status in real-time.
- 🧹 **Preview Cleanup:** Inspect a dry-run plan via chat; destructive cleanup execution is disabled through MCP.
- 🕵️ **Analyze Storage:** Ask "Where is my disk space going?" and get an analysis.
- 🐳 **Inspect Docker:** Check for wasted Docker resources.

## 🛠️ Installation

### Prerequisites

- Python 3.10+
- Orbit-DevOps (Root repository)

### Setup

1. Navigate to the `mcp` directory:
   ```powershell
   cd mcp
   ```

2. Install dependencies:
   ```powershell
   pip install mcp[cli]
   ```

## 🔌 Integration

### Using with Claude Desktop

Add the following to your `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "Orbit-DevOps": {
      "command": "python",
      "args": [
        "C:/Path/To/Orbit-DevOps/mcp/server.py"
      ]
    }
  }
}
```

### Using with Cursor

(Support for MCP in Cursor is evolving, check Cursor documentation for local MCP server configuration).

## 🛡️ Security

The MCP server can execute diagnostic PowerShell scripts on your host machine.
- Cleanup through MCP is preview-only; it cannot execute deletions.
- PowerShell is launched without an execution-policy bypass.
- Diagnostic reports may contain local machine details. Review them before sharing.
- Review every proposed action before authorizing it.
