import os
import subprocess
import sys
import logging
from typing import Any, List, Optional
from mcp.server.fastmcp import FastMCP
from core.algebra import OrbitAlgebra

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("windiagkit-mcp")

# Initialize FastMCP Server
mcp = FastMCP("Orbit-DevOps")

import platform

# Constants
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCRIPTS_DIR = os.path.join(BASE_DIR, "scripts")
IS_WINDOWS = platform.system() == "Windows"

def run_script(script_rel_path: str, mac_script_path: str = None, args: List[str] = None) -> str:
    """
    Helper to run scripts based on OS.
    If Windows, runs the PowerShell script_rel_path.
    If Mac/Linux, runs the mac_script_path (if provided).
    """
    if IS_WINDOWS:
        script_path = os.path.join(SCRIPTS_DIR, script_rel_path)
        interpreter = "powershell"
        exec_args = ["-ExecutionPolicy", "Bypass", "-File", script_path]
    else:
        # macOS / Linux logic
        if not mac_script_path:
            return "Error: This tool is not yet available for macOS/Linux."
        
        script_path = os.path.join(SCRIPTS_DIR, mac_script_path)
        interpreter = "bash"
        exec_args = [script_path]

    if not os.path.exists(script_path):
        return f"Error: Script not found at {script_path}"

    command = [interpreter] + exec_args
    if args and IS_WINDOWS: # Pass args only to PS for now
        command.extend(args)

    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=False
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
    Works on Windows and Mac.
    """
    return run_script("diagnostic/SystemDiagnosticUser.ps1", "mac/diagnostic.sh")

@mcp.tool()
def analyze_storage() -> str:
    """
    Analyzes disk usage to find large folders and potential cleanup targets.
    Returns a list of space hogs.
    """
    return run_script("analysis/ScanStorage.ps1")

@mcp.tool()
def check_docker_usage() -> str:
    """
    Checks Docker disk usage (images, containers, volumes).
    """
    return run_script("analysis/ScanTargets.ps1")

@mcp.tool()
def run_safe_cleanup(dry_run: bool = True) -> str:
    """
    Runs safe cleanup tasks (Browser cache, Downloads, Temp).
    
    Args:
        dry_run: If True, only lists what would be deleted.
    """
    if dry_run:
        return "Dry run not fully supported by underlying script yet. It would clean Browsers, Downloads, and Temp."
    
    return run_script("cleanup/AdditionalCleanup.ps1")

@mcp.tool()
def read_architecture() -> str:
    """
    Returns the Enterprise Architecture of Orbit-DevOps.
    """
    arch_path = os.path.join(BASE_DIR, "ARCHITECTURE.json")
    if os.path.exists(arch_path):
        with open(arch_path, "r", encoding="utf-8") as f:
            return f.read()
    return "Architecture file not found."

@mcp.tool()
def evaluate_system_vitality(omega: float, phi: float, sigma: float) -> dict:
    """
    Calculates the system vitality using the Orbit Symbiotic Algebra.
    
    Args:
        omega: Entropy (0-1)
        phi: Vitality (0-1)
        sigma: Symbiosis (0-1)
    """
    return OrbitAlgebra.reason_state(omega, phi, sigma)

@mcp.tool()
def solve_homeostasis(current_omega: float, current_phi: float, current_sigma: float) -> str:
    """
    Provides a formal logical proof for the best course of action to restore homeostasis.
    """
    result = OrbitAlgebra.reason_state(current_omega, current_phi, current_sigma)
    return f"Formal Proof Found:\n{result['proof']}\nRecommended Operator: {result['recommendation']}\nFinal Vitality Prediction: {result['vitality_score']}"

if __name__ == "__main__":
    mcp.run()
