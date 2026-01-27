import BaseProvider from './BaseProvider.js';

export default class UnixProvider extends BaseProvider {
  /**
   * Run a Bash/Shell script.
   */
  async runScript(taskName, scriptPath, args = []) {
    this.logInfo(`(PREVIEW) Launching Unix command (Linux/macOS): ${scriptPath}...`);
    
    // In the future, this will map to .sh scripts or python scripts
    this.logError(`Unix implementation for ${scriptPath} is coming soon in Phase 2.`);
    return false;
  }

  getName() {
    return 'Unix (Linux/macOS)';
  }
}
