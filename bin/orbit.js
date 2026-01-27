#!/usr/bin/env node

import { Command } from 'commander';
import chalk from 'chalk';
import spawn from 'cross-spawn';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.join(__dirname, '..');

const program = new Command();

program
  .name('orbit')
  .description('Orbit-DevOps: The Developer\'s Workspace Command Center')
  .version('1.1.0');

import fs from 'fs';

// ... (previous imports)

// Helper to run PowerShell scripts
function runScript(scriptPath, args = []) {
  // Safe path resolution for Windows
  const fullPath = path.normalize(path.resolve(PROJECT_ROOT, scriptPath));
  
  if (!fs.existsSync(fullPath)) {
    console.error(chalk.red(`\n❌ Error: Script not found at: ${fullPath}`));
    process.exit(1);
  }

  console.log(chalk.blue(`\n🚀 Orbit Launching: ${path.basename(fullPath)}...`));

  // Don't manually quote the path; spawn handles it if we don't use windowsVerbatimArgumentsor specific shell options
  const child = spawn('powershell.exe', ['-ExecutionPolicy', 'Bypass', '-File', fullPath, ...args], {
    stdio: 'inherit'
  });

  child.on('close', (code) => {
    if (code === 0) {
      console.log(chalk.green(`\n✅ Mission Complete (Exit Code: ${code})`));
    } else {
      console.log(chalk.red(`\n❌ Mission Failed (Exit Code: ${code})`));
    }
  });
}

// --- Commands ---

program
  .command('doctor')
  .description('Run a full system diagnostic health check')
  .action(() => {
    runScript('scripts/diagnostic/SystemDiagnosticUser_v2.ps1');
  });

program
  .command('space')
  .description('Analyze disk usage and find hotspots')
  .action(() => {
    runScript('scripts/diagnostic/ScanStorage.ps1');
  });

program
  .command('clean')
  .description('Perform safe system and dev-tool cleanup')
  .action(() => {
    runScript('scripts/cleanup/AdditionalCleanup.ps1');
  });

program
  .command('compact')
  .description('Compact WSL2 virtual disks manually (requires Admin)')
  .action(() => {
    console.log(chalk.yellow('⚠️  Note: Compaction might require Administrator privileges.'));
    runScript('scripts/wsl/CompactWSL.ps1');
  });

program
  .command('sync')
  .description('Sync environment stack to GitHub (sh1w4/stack)')
  .action(() => {
    runScript('scripts/stack/Push-Stack.ps1');
  });

program
  .command('menu')
  .description('Launch the interactive PowerShell menu (Legacy)')
  .action(() => {
    runScript('scripts/core/Orbit.ps1');
  });

program.parse(process.argv);

if (!process.argv.slice(2).length) {
  program.outputHelp();
}
