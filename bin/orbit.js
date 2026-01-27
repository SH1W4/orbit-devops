import { Command } from 'commander';
import chalk from 'chalk';
import path from 'path';
import { fileURLToPath } from 'url';
import os from 'os';

// Providers
import WindowsProvider from '../providers/WindowsProvider.js';
import UnixProvider from '../providers/UnixProvider.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.join(__dirname, '..');

// Platform Detection & Provider Initialization
let provider;
const platform = os.platform();

if (platform === 'win32') {
  provider = new WindowsProvider(PROJECT_ROOT);
} else if (platform === 'linux' || platform === 'darwin') {
  provider = new UnixProvider(PROJECT_ROOT);
} else {
  console.error(chalk.red(`\n❌ Error: Unsupported platform: ${platform}`));
  process.exit(1);
}

const program = new Command();

program
  .name('orbit')
  .description('Orbit-DevOps: The Developer\'s Workspace Command Center')
  .version('1.4.0');

// --- Commands ---

program
  .command('doctor')
  .description('Run a full system diagnostic health check')
  .action(async () => {
    await provider.runScript('Diagnostic', 'scripts/diagnostic/SystemDiagnosticUser_v2.ps1');
  });

program
  .command('space')
  .description('Analyze disk usage and find hotspots')
  .action(async () => {
    await provider.runScript('Storage Analysis', 'scripts/diagnostic/ScanStorage.ps1');
  });

program
  .command('clean')
  .description('Perform safe system and dev-tool cleanup')
  .action(async () => {
    await provider.runScript('Cleanup', 'scripts/cleanup/AdditionalCleanup.ps1');
  });

program
  .command('compact')
  .description('Compact WSL2 virtual disks manually (requires Admin)')
  .action(async () => {
    if (platform !== 'win32') {
      console.error(chalk.yellow('\n⚠️  Note: WSL2 compaction is only available on Windows.'));
      return;
    }
    await provider.runScript('WSL Compaction', 'scripts/wsl/CompactWSL.ps1');
  });

program
  .command('sync')
  .description('Sync environment stack to GitHub')
  .action(async () => {
    await provider.runScript('Stack Sync', 'scripts/stack/Push-Stack.ps1');
  });

program
  .command('menu')
  .description('Launch the interactive PowerShell menu (Legacy)')
  .action(async () => {
    if (platform !== 'win32') {
      console.error(chalk.yellow('\n⚠️  Note: The interactive menu is currently Windows-only.'));
      return;
    }
    await provider.runScript('Legacy Menu', 'scripts/core/Orbit.ps1');
  });

program.parse(process.argv);

if (!process.argv.slice(2).length) {
  program.outputHelp();
}
