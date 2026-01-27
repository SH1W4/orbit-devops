import { describe, it, expect } from 'vitest';
import { execSync } from 'child_process';
import path from 'path';

const CLI_PATH = path.resolve(process.cwd(), 'bin/orbit.js');

describe('Orbit-DevOps CLI', () => {
  it('should display help information', () => {
    const output = execSync(`node ${CLI_PATH} --help`).toString();
    expect(output).toContain('Usage: orbit');
    expect(output).toContain('Options:');
  });

  it('should have the doctor command', () => {
    const output = execSync(`node ${CLI_PATH} --help`).toString();
    expect(output).toContain('doctor');
  });

  it('should have the sync command', () => {
    const output = execSync(`node ${CLI_PATH} --help`).toString();
    expect(output).toContain('sync');
  });
});
