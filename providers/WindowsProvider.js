import spawn from 'cross-spawn';
import path from 'path';
import fs from 'fs';
import BaseProvider from './BaseProvider.js';

export default class WindowsProvider extends BaseProvider {
  /**
   * Run a PowerShell script.
   */
  async runScript(taskName, scriptPath, args = []) {
    const fullPath = path.normalize(path.resolve(this.projectRoot, scriptPath));
    
    if (!fs.existsSync(fullPath)) {
      this.logError(`Script not found at: ${fullPath}`);
      return;
    }

    this.logInfo(`Launching: ${path.basename(fullPath)}...`);

    return new Promise((resolve) => {
      const child = spawn('powershell.exe', [
        '-ExecutionPolicy', 'Bypass', 
        '-File', fullPath, 
        ...args
      ], {
        stdio: 'inherit'
      });

      child.on('close', (code) => {
        if (code === 0) {
          this.logSuccess(`Mission Complete (Exit Code: ${code})`);
          resolve(true);
        } else {
          this.logError(`Mission Failed (Exit Code: ${code})`);
          resolve(false);
        }
      });
    });
  }

  getName() {
    return 'Windows';
  }
}
