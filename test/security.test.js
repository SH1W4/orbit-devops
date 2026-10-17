import { describe, it, expect } from 'vitest';
import { readFileSync } from 'node:fs';
import path from 'node:path';

const read = (relativePath) => readFileSync(path.resolve(process.cwd(), relativePath), 'utf8');

describe('Orbit-DevOps security guardrails', () => {
  it('keeps package and lockfile root versions aligned', () => {
    const pkg = JSON.parse(read('package.json'));
    const lock = JSON.parse(read('package-lock.json'));
    expect(lock.version).toBe(pkg.version);
    expect(lock.packages[''].version).toBe(pkg.version);
  });

  it('keeps cleanup preview-only unless explicitly executed', () => {
    const script = read('scripts/cleanup/AdditionalCleanup.ps1');
    expect(script).toContain('[switch]$Execute');
    expect(script).toContain('if (-not $Execute)');
    expect(script).toContain('Type DELETE');
    expect(script).not.toContain('$env:USERPROFILE\\Downloads');
    expect(script).not.toContain('$env:USERPROFILE\\.cache');
  });

  it('does not allow MCP to execute cleanup', () => {
    const server = read('mcp/server.py');
    expect(server).toContain('Execution is disabled through MCP for safety.');
    expect(server).toContain('return run_script("cleanup/AdditionalCleanup.ps1")');
  });

  it('does not automatically publish the local software inventory', () => {
    const script = read('scripts/stack/Push-Stack.ps1');
    expect(script).not.toContain('git add $');
    expect(script).not.toContain('git commit $');
    expect(script).not.toContain('git push $');
  });

  it('uses supervised agent defaults and disables automatic side effects', () => {
    const stack = JSON.parse(read('templates/agent-stack-dev.json'));
    expect(stack.requirements.env_vars.AGENT_MODE).toBe('supervised');
    expect(stack.provisioning.cleanup_on_exit).toBe(false);
    expect(stack.provisioning.sync_stack_on_change).toBe(false);
    expect(stack.permissions.network).toBe(false);
  });

  it('keeps local node_modules out of version control', () => {
    expect(read('.gitignore')).toContain('node_modules/');
  });

  it('does not expose a GitHub token through the legacy push helper', () => {
    const script = read('scripts/legacy/ForcePush.ps1');
    expect(script).toContain('No Git operation was performed.');
    expect(script).not.toContain('gh auth token');
    expect(script).not.toContain('git -c credential.helper= push');
  });

  it('keeps Downloads organization scripts disabled', () => {
    for (const file of ['scripts/utils/OrganizeDownloads.ps1', 'scripts/utils/DeepOrganizeDownloads.ps1']) {
      const script = read(file);
      expect(script).toContain('No files were moved.');
      expect(script).not.toContain('Move-Item');
    }
  });

  it('makes WSL compaction a preview unless explicitly executed', () => {
    const script = read('scripts/wsl/CompactWSL.ps1');
    expect(script).toContain('[switch]$Execute');
    expect(script).toContain('if (-not $Execute)');
  });
});
