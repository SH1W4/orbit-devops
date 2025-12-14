import os
import subprocess
import sys
import logging
from typing import Any, List, Optional
from mcp.server.fastmcp import FastMCP

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("windiagkit-mcp")

# Initialize FastMCP Server
mcp = FastMCP("WinDiagKit")

# Constants
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCRIPTS_DIR = os.path.join(BASE_DIR, "scripts")

def run_powershell(script_rel_path: str, args: List[str] = None) -> str:
    """Helper to run PowerShell scripts located in the scripts directory."""
    script_path = os.path.join(SCRIPTS_DIR, script_rel_path)
    if not os.path.exists(script_path):
        return f"Error: Script not found at {script_path}"

    command = ["powershell", "-ExecutionPolicy", "Bypass", "-File", script_path]
    if args:
        command.extend(args)

    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=False  # Don't throw exception on non-zero exit, capture stderr
        )
        if result.returncode != 0:
            return f"Command Failed (Exit Code {result.returncode}):\n{result.stderr}\n\nOutput:\n{result.stdout}"
        return result.stdout
    except Exception as e:
        return f"Execution Error: {str(e)}"

@mcp.tool()
def get_system_health() -> str:
    """
    Performs a quick system health check (CPU, Disk, Memory).
    Returns a textual report.
    """
    return run_powershell("diagnostic/SystemDiagnosticUser.ps1")

@mcp.tool()
def analyze_storage() -> str:
    """
    Analyzes disk usage to find large folders and potential cleanup targets.
    Returns a list of space hogs.
    """
    return run_powershell("analysis/ScanStorage.ps1")

@mcp.tool()
def check_docker_usage() -> str:
    """
    Checks Docker disk usage (images, containers, volumes).
    """
    return run_powershell("analysis/ScanTargets.ps1")

@mcp.tool()
def run_safe_cleanup(dry_run: bool = True) -> str:
    """
    Runs safe cleanup tasks (Browser cache, Downloads, Temp).
    
    Args:
        dry_run: If True, only lists what would be deleted. (Note: Current script might run immediately, so use with caution)
    """
    # Note: AdditionalCleanup.ps1 is designed to run safely. 
    # For a true dry_run, we would need to pass a flag to the PS script.
    # Currently assuming immediate execution as per existing script design.
    if dry_run:
        return "Dry run not fully supported by underlying script yet. It would clean Browsers, Downloads, and Temp."
    
    return run_powershell("cleanup/AdditionalCleanup.ps1")

@mcp.tool()
def read_architecture() -> str:
    """
    Returns the Enterprise Architecture of WinDiagKit.
    """
    arch_path = os.path.join(BASE_DIR, "ARCHITECTURE.json")
    if os.path.exists(arch_path):
        with open(arch_path, "r", encoding="utf-8") as f:
            return f.read()
    return "Architecture file not found."

if __name__ == "__main__":
    mcp.run()
