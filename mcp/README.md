# 🤖 WinDiagKit MCP Agent

This directory contains the **Model Context Protocol (MCP)** implementation for WinDiagKit. It turns the toolkit into an intelligent agent that AI coding assistants (like Claude Desktop, Cursor, etc.) can communicate with to diagnose and optimize your system directly.

## 🌟 Capabilities

The MCP agent enables your AI assistant to:

- 🏥 **Check System Health:** Query CPU, RAM, and Disk status in real-time.
- 🧹 **Perform Cleanup:** Trigger safe cleanup routines via chat commands.
- 🕵️ **Analyze Storage:** Ask "Where is my disk space going?" and get an analysis.
- 🐳 **Inspect Docker:** Check for wasted Docker resources.

## 🛠️ Installation

### Prerequisites

- Python 3.10+
- WinDiagKit (Root repository)

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
    "WinDiagKit": {
      "command": "python",
      "args": [
        "C:/Path/To/WinDiagKit/mcp/server.py"
      ]
    }
  }
}
```

### Using with Cursor

(Support for MCP in Cursor is evolving, check Cursor documentation for local MCP server configuration).

## 🛡️ Security

The MCP server executes PowerShell scripts on your host machine.
- It is designed to run **inspection** and **safe cleanup** scripts.
- It respects the same safety execution policies as the scripts themselves.
- Always review what the AI intends to do before authorizing actions.
