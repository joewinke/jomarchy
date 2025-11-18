#!/usr/bin/env node
// Shared library for Agent Mail tools

import { spawn } from 'child_process';
import { homedir } from 'os';
import { existsSync } from 'fs';
import { join } from 'path';

export const AGENT_MAIL_URL = process.env.AGENT_MAIL_URL || 'http://localhost:8765';
export const AGENT_MAIL_TOKEN = process.env.AGENT_MAIL_TOKEN || '';
export const PROJECT_KEY = process.env.PROJECT_KEY || process.cwd();

let serverStartAttempted = false;

// Check if Agent Mail server is running
async function isServerRunning() {
  try {
    const response = await fetch(`${AGENT_MAIL_URL}/health`, {
      method: 'GET',
      signal: AbortSignal.timeout(2000)
    });
    return response.ok;
  } catch {
    return false;
  }
}

// Auto-start Agent Mail server if not running
async function ensureServerRunning() {
  if (serverStartAttempted) return;
  serverStartAttempted = true;

  const isRunning = await isServerRunning();
  if (isRunning) return;

  // Try to find and start the server
  const possiblePaths = [
    join(homedir(), 'code', 'jomarchy-agent-tools', 'mcp_agent_mail'),
    join(homedir(), 'code', 'jomarchy', 'mcp_agent_mail'),
    join(homedir(), 'mcp_agent_mail')
  ];

  let serverPath = null;
  for (const path of possiblePaths) {
    const runScript = join(path, 'scripts', 'run_server_with_token.sh');
    if (existsSync(runScript)) {
      serverPath = runScript;
      break;
    }
  }

  if (!serverPath) {
    console.error('⚠ Agent Mail server not running and installation not found');
    console.error('  Run: bash ~/code/jomarchy-agent-tools/install.sh');
    process.exit(1);
  }

  console.log('⚙ Starting Agent Mail server...');

  // Start server in background
  const server = spawn('bash', [serverPath], {
    detached: true,
    stdio: 'ignore'
  });
  server.unref();

  // Wait for server to be ready
  for (let i = 0; i < 10; i++) {
    await new Promise(resolve => setTimeout(resolve, 1000));
    if (await isServerRunning()) {
      console.log('✓ Agent Mail server started');
      return;
    }
  }

  console.error('✗ Failed to start Agent Mail server');
  process.exit(1);
}

export async function amFetch(endpoint, options = {}) {
  await ensureServerRunning();

  const url = `${AGENT_MAIL_URL}${endpoint}`;
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers
  };

  if (AGENT_MAIL_TOKEN) {
    headers['Authorization'] = `Bearer ${AGENT_MAIL_TOKEN}`;
  }

  const response = await fetch(url, {
    ...options,
    headers
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Agent Mail API error: ${response.status} ${error}`);
  }

  return response.json();
}

export function formatJson(obj, indent = 2) {
  return JSON.stringify(obj, null, indent);
}

export function formatTable(rows, columns) {
  if (!rows || rows.length === 0) return 'No results';

  // Calculate column widths
  const widths = {};
  columns.forEach(col => {
    widths[col] = Math.max(
      col.length,
      ...rows.map(row => String(row[col] || '').length)
    );
  });

  // Header
  let table = columns.map(col => col.padEnd(widths[col])).join('  ') + '\n';
  table += columns.map(col => '-'.repeat(widths[col])).join('  ') + '\n';

  // Rows
  rows.forEach(row => {
    table += columns.map(col => String(row[col] || '').padEnd(widths[col])).join('  ') + '\n';
  });

  return table;
}

export function parseArgs(argv) {
  const args = { _: [], flags: {} };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg.startsWith('--')) {
      const key = arg.slice(2);
      const next = argv[i + 1];
      if (next && !next.startsWith('--')) {
        args.flags[key] = next;
        i++;
      } else {
        args.flags[key] = true;
      }
    } else if (arg.startsWith('-')) {
      args.flags[arg.slice(1)] = true;
    } else {
      args._.push(arg);
    }
  }
  return args;
}

export function showHelp(usage, options) {
  console.log('Usage: ' + usage);
  console.log('\nOptions:');
  Object.entries(options).forEach(([flag, desc]) => {
    console.log(`  ${flag.padEnd(25)} ${desc}`);
  });
}
