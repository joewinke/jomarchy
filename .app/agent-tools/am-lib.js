#!/usr/bin/env node
// Shared library for Agent Mail tools

export const AGENT_MAIL_URL = process.env.AGENT_MAIL_URL || 'http://localhost:8765';
export const AGENT_MAIL_TOKEN = process.env.AGENT_MAIL_TOKEN || '';
export const PROJECT_KEY = process.env.PROJECT_KEY || process.cwd();

export async function amFetch(endpoint, options = {}) {
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
