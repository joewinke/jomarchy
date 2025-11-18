#!/usr/bin/env node

import puppeteer from "puppeteer-core";

// Parse command line arguments
function parseArgs() {
	const args = process.argv.slice(2);
	const options = {
		level: null, // null means all levels
		stream: false,
		limit: 50, // Default to last 50 messages
		json: false,
	};

	if (args.includes("--help") || args.includes("-h")) {
		showHelp();
		process.exit(0);
	}

	for (let i = 0; i < args.length; i++) {
		const arg = args[i];

		if (arg === "--level") {
			const level = args[++i];
			const validLevels = ["log", "info", "warn", "error", "debug"];
			if (!validLevels.includes(level)) {
				console.error(`✗ Error: Invalid level "${level}"`);
				console.error(`  Valid levels: ${validLevels.join(", ")}`);
				process.exit(1);
			}
			options.level = level;
		} else if (arg === "--stream") {
			options.stream = true;
		} else if (arg === "--limit") {
			options.limit = parseInt(args[++i], 10);
		} else if (arg === "--json") {
			options.json = true;
		}
	}

	return options;
}

function showHelp() {
	console.log(`browser-console.js - Structured console access for debugging

USAGE:
  browser-console.js [options]

OPTIONS:
  --level <type>       Filter by log level: log, info, warn, error, debug
  --stream             Real-time streaming mode (press Ctrl+C to stop)
  --limit <n>          Number of recent messages to show (default: 50)
  --json               Output in JSON format
  -h, --help           Show this help message

OUTPUT MODES:

  SNAPSHOT MODE (default):
  - Shows recent console messages
  - Formatted for readability
  - Includes timestamps and sources
  - Exits after displaying messages

  STREAMING MODE (--stream):
  - Real-time console monitoring
  - Shows new messages as they appear
  - Useful for debugging and testing
  - Press Ctrl+C to stop

LOG LEVELS:
  log      - Regular console.log() calls
  info     - console.info() calls
  warn     - console.warn() calls (yellow in browser)
  error    - console.error() calls (red in browser)
  debug    - console.debug() calls

EXAMPLES:
  # Show last 50 console messages
  browser-console.js

  # Show only errors
  browser-console.js --level error

  # Stream console in real-time
  browser-console.js --stream

  # Show last 100 warnings
  browser-console.js --level warn --limit 100

  # Get JSON output for processing
  browser-console.js --json --limit 10

USE CASES:
  - Debugging JavaScript errors
  - Monitoring application logs
  - Verifying console output in tests
  - Tracking warnings and deprecations

TECHNICAL DETAILS:
  - Uses CDP Runtime.consoleAPICalled for console messages
  - Uses CDP Log.entryAdded for browser logs
  - Connects to Chrome DevTools at localhost:9222
  - Captures stack traces for errors
  - Includes source file and line numbers

NOTES:
  - Console messages are captured from active tab
  - Streaming mode continues until interrupted
  - JSON format useful for automated analysis
  - More reliable than manual browser inspection
`);
}

// Format console message for display
function formatMessage(msg) {
	const timestamp = new Date(msg.timestamp).toISOString();
	const level = msg.level.toUpperCase().padEnd(5);
	const levelIcon = {
		log: "📝",
		info: "ℹ️",
		warn: "⚠️",
		error: "❌",
		debug: "🐛",
	};

	const icon = levelIcon[msg.level] || "  ";
	let output = `${icon} ${level} [${timestamp}]`;

	// Add source location if available
	if (msg.source) {
		output += ` ${msg.source}`;
	}

	output += `\n  ${msg.text}\n`;

	// Add stack trace for errors
	if (msg.stack && msg.level === "error") {
		output += `  Stack:\n${msg.stack
			.split("\n")
			.map((line) => `    ${line}`)
			.join("\n")}\n`;
	}

	return output;
}

// Main execution
(async () => {
	try {
		const options = parseArgs();

		const browser = await puppeteer.connect({
			browserURL: "http://localhost:9222",
			defaultViewport: null,
		});

		const page = (await browser.pages()).at(-1);

		if (!page) {
			console.error("✗ No active tab found");
			process.exit(1);
		}

		// Get CDP client
		const client = await page.target().createCDPSession();

		// Enable console and log domains
		await client.send("Runtime.enable");
		await client.send("Log.enable");

		const messages = [];

		// Handle console API calls (console.log, console.error, etc.)
		client.on("Runtime.consoleAPICalled", (event) => {
			const msg = {
				timestamp: event.timestamp || Date.now(),
				level: event.type,
				text: event.args.map((arg) => arg.value || arg.description || "").join(" "),
				source: event.stackTrace?.callFrames?.[0]
					? `${event.stackTrace.callFrames[0].url}:${event.stackTrace.callFrames[0].lineNumber}`
					: null,
				stack: event.stackTrace
					? event.stackTrace.callFrames
							.map((frame) => `  at ${frame.functionName || "<anonymous>"} (${frame.url}:${frame.lineNumber}:${frame.columnNumber})`)
							.join("\n")
					: null,
			};

			// Apply level filter
			if (options.level && msg.level !== options.level) {
				return;
			}

			messages.push(msg);

			// In streaming mode, output immediately
			if (options.stream) {
				if (options.json) {
					console.log(JSON.stringify(msg));
				} else {
					process.stdout.write(formatMessage(msg));
				}
			}
		});

		// Handle log entries (browser-generated logs)
		client.on("Log.entryAdded", (event) => {
			const entry = event.entry;
			const msg = {
				timestamp: entry.timestamp || Date.now(),
				level: entry.level,
				text: entry.text,
				source: entry.url ? `${entry.url}:${entry.lineNumber}` : null,
				stack: entry.stackTrace
					? entry.stackTrace.callFrames
							.map((frame) => `  at ${frame.functionName || "<anonymous>"} (${frame.url}:${frame.lineNumber}:${frame.columnNumber})`)
							.join("\n")
					: null,
			};

			// Apply level filter
			if (options.level && msg.level !== options.level) {
				return;
			}

			messages.push(msg);

			// In streaming mode, output immediately
			if (options.stream) {
				if (options.json) {
					console.log(JSON.stringify(msg));
				} else {
					process.stdout.write(formatMessage(msg));
				}
			}
		});

		if (options.stream) {
			// Streaming mode - wait indefinitely
			console.error("🔴 Streaming console messages (Ctrl+C to stop)...\n");

			// Handle Ctrl+C gracefully
			process.on("SIGINT", async () => {
				console.error("\n✓ Stopped streaming");
				await client.detach();
				await browser.disconnect();
				process.exit(0);
			});

			// Keep the process running
			await new Promise(() => {});
		} else {
			// Snapshot mode - wait a bit to collect messages, then output
			await new Promise((resolve) => setTimeout(resolve, 1000));

			// Get recent messages (up to limit)
			const recentMessages = messages.slice(-options.limit);

			if (recentMessages.length === 0) {
				console.log("ℹ️  No console messages found");
			} else {
				if (options.json) {
					console.log(JSON.stringify(recentMessages, null, 2));
				} else {
					console.log(`Console Messages (${recentMessages.length}):`);
					console.log("=".repeat(80));
					for (const msg of recentMessages) {
						process.stdout.write(formatMessage(msg));
					}
				}
			}

			await client.detach();
			await browser.disconnect();
		}
	} catch (error) {
		console.error("✗ Error:", error.message);
		process.exit(1);
	}
})();
