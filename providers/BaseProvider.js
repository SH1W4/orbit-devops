import chalk from 'chalk';

export default class BaseProvider {
  constructor(projectRoot) {
    this.projectRoot = projectRoot;
  }

  /**
   * Run a platform-specific command or script.
   * @param {string} taskName Name of the task
   * @param {string} scriptPath Relative path to the script
   * @param {Array} args Arguments for the script
   */
  async runScript(taskName, scriptPath, args = []) {
    throw new Error('runScript() must be implemented by the provider');
  }

  logInfo(message) {
    console.log(chalk.blue(`\n🚀 Orbit [${this.getName()}]: ${message}`));
  }

  logSuccess(message) {
    console.log(chalk.green(`\n✅ ${message}`));
  }

  logError(message) {
    console.error(chalk.red(`\n❌ Error [${this.getName()}]: ${message}`));
  }

  getName() {
    return 'Base';
  }
}
