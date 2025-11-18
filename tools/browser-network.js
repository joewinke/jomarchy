#!/usr/bin/env node

import puppeteer from "puppeteer-core";

// Parse command line arguments
function parseArgs() {
	const args = process.argv.slice(2);
	const options = {
		filter: null, // null = all, 'fetch', 'xhr', 'failed'
		urlPattern: null,
		stream: false,
		limit: 50,
		json: false,
		showTiming: false,
	};

	if (args.includes("--help") || args.includes("-h")) {
		showHelp();
		process.exit(0);
	}

	for (let i = 0; i < args.length; i++) {
		const arg = args[i];

		if (arg === "--filter") {
			const filter = args[++i];
			const validFilters = ["fetch", "xhr", "failed", "all"];
			if (!validFilters.includes(filter)) {
				console.error(`✗ Error: Invalid filter "${filter}"`);
				console.error(`  Valid filters: ${validFilters.join(", ")}`);
				process.exit(1);
			}
			options.filter = filter === "all" ? null : filter;
		} else if (arg === "--url") {
			options.urlPattern = args[++i];
		} else if (arg === "--stream") {
			options.stream = true;
		} else if (arg === "--limit") {
			options.limit = parseInt(args[++i], 10);
		} else if (arg === "--json") {
			options.json = true;
		} else if (arg === "--timing") {
			options.showTiming = true;
		}
	}

	return options;
}

function showHelp() {
	console.log(`browser-network.js - Network request monitoring

USAGE:
  browser-network.js [options]

OPTIONS:
  --filter <type>      Filter by request type: fetch, xhr, failed, all
  --url <pattern>      Filter by URL pattern (substring match)
  --stream             Real-time streaming mode (press Ctrl+C to stop)
  --limit <n>          Number of recent requests to show (default: 50)
  --timing             Show detailed timing information
  --json               Output in JSON format
  -h, --help           Show this help message

FILTERS:
  fetch    - Only fetch() API requests
  xhr      - Only XMLHttpRequest requests
  failed   - Only failed requests (4xx, 5xx, network errors)
  all      - All requests (default)

OUTPUT MODES:

  SNAPSHOT MODE (default):
  - Shows recent network requests
  - Formatted for readability
  - Includes method, status, URL, timing
  - Exits after displaying requests

  STREAMING MODE (--stream):
  - Real-time network monitoring
  - Shows new requests as they happen
  - Useful for API testing and debugging
  - Press Ctrl+C to stop

EXAMPLES:
  # Show last 50 network requests
  browser-network.js

  # Show only failed requests
  browser-network.js --filter failed

  # Monitor API requests in real-time
  browser-network.js --stream --url "/api/"

  # Show timing details for all requests
  browser-network.js --timing

  # Get JSON output for analysis
  browser-network.js --json --limit 100

  # Monitor fetch requests to specific endpoint
  browser-network.js --stream --filter fetch --url "/graphql"

USE CASES:
  - API testing and debugging
  - Performance analysis
  - Network error tracking
  - Request/response verification
  - Load time optimization

TECHNICAL DETAILS:
  - Uses CDP Network.requestWillBeSent event
  - Uses CDP Network.responseReceived event
  - Uses CDP Network.loadingFinished event
  - Uses CDP Network.loadingFailed event
  - Connects to Chrome DevTools at localhost:9222
  - Captures full request/response lifecycle

TIMING INFORMATION (--timing):
  - DNS lookup time
  - Connection time
  - TLS handshake time
  - Request send time
  - Waiting time (TTFB)
  - Content download time
  - Total time

NOTES:
  - Monitors active tab's network activity
  - Streaming mode continues until interrupted
  - JSON format useful for automated analysis
  - Essential for API integration testing
`);
}

// Format network request for display
function formatRequest(req) {
	const method = req.method.padEnd(6);
	const status = req.status ? String(req.status).padEnd(3) : "...";
	const statusIcon = {
		pending: "⏳",
		success: "✓",
		failed: "✗",
	};

	const icon = statusIcon[req.state] || "  ";
	const url = req.url.length > 80 ? req.url.substring(0, 77) + "..." : req.url;

	let output = `${icon} ${method} ${status} ${url}`;

	if (req.timing) {
		output += ` (${req.timing.total}ms)`;
	}

	output += "\n";

	if (req.showTiming && req.timing && req.timing.breakdown) {
		const t = req.timing.breakdown;
		output += `  Timing: DNS ${t.dns}ms | Connect ${t.connect}ms | TLS ${t.tls}ms | Send ${t.send}ms | Wait ${t.wait}ms | Receive ${t.receive}ms\n`;
	}

	if (req.error) {
		output += `  Error: ${req.error}\n`;
	}

	return output;
}

// Calculate timing breakdown
function calculateTiming(timing) {
	if (!timing) return null;

	const total = Math.round((timing.receiveHeadersEnd || timing.sendEnd || 0) * 1000);

	const breakdown = {
		dns: Math.round((timing.dnsEnd - timing.dnsStart) * 1000),
		connect: Math.round((timing.connectEnd - timing.connectStart) * 1000),
		tls: Math.round((timing.sslEnd - timing.sslStart) * 1000),
		send: Math.round((timing.sendEnd - timing.sendStart) * 1000),
		wait: Math.round((timing.receiveHeadersEnd - timing.sendEnd) * 1000),
		receive: Math.round((timing.receiveHeadersEnd - timing.sendEnd) * 1000),
	};

	return { total, breakdown };
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

		// Enable network domain
		await client.send("Network.enable");

		const requests = new Map();

		// Request started
		client.on("Network.requestWillBeSent", (event) => {
			const req = {
				id: event.requestId,
				method: event.request.method,
				url: event.request.url,
				type: event.type,
				state: "pending",
				timestamp: event.timestamp,
				timing: null,
				status: null,
				error: null,
				showTiming: options.showTiming,
			};

			// Apply filters
			if (options.filter === "fetch" && event.type !== "Fetch") return;
			if (options.filter === "xhr" && event.type !== "XHR") return;
			if (options.urlPattern && !req.url.includes(options.urlPattern)) return;

			requests.set(req.id, req);
		});

		// Response received
		client.on("Network.responseReceived", (event) => {
			const req = requests.get(event.requestId);
			if (!req) return;

			req.status = event.response.status;
			req.state = event.response.status >= 400 ? "failed" : "success";
			req.timing = calculateTiming(event.response.timing);

			// Apply failed filter
			if (options.filter === "failed" && req.state !== "failed") {
				requests.delete(req.id);
				return;
			}

			// In streaming mode, output when response received
			if (options.stream) {
				if (options.json) {
					console.log(JSON.stringify(req));
				} else {
					process.stdout.write(formatRequest(req));
				}
			}
		});

		// Request finished
		client.on("Network.loadingFinished", (event) => {
			const req = requests.get(event.requestId);
			if (!req) return;

			// Update timing if not set
			if (!req.timing && event.timestamp) {
				const duration = (event.timestamp - req.timestamp) * 1000;
				req.timing = { total: Math.round(duration) };
			}
		});

		// Request failed
		client.on("Network.loadingFailed", (event) => {
			const req = requests.get(event.requestId);
			if (!req) return;

			req.state = "failed";
			req.error = event.errorText;

			// In streaming mode, output when failure detected
			if (options.stream) {
				if (options.json) {
					console.log(JSON.stringify(req));
				} else {
					process.stdout.write(formatRequest(req));
				}
			}
		});

		if (options.stream) {
			// Streaming mode - wait indefinitely
			console.error("🔴 Streaming network requests (Ctrl+C to stop)...\n");

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
			// Snapshot mode - wait a bit to collect requests, then output
			await new Promise((resolve) => setTimeout(resolve, 1000));

			// Get recent requests
			const recentRequests = Array.from(requests.values()).slice(-options.limit);

			if (recentRequests.length === 0) {
				console.log("ℹ️  No network requests found");
			} else {
				if (options.json) {
					console.log(JSON.stringify(recentRequests, null, 2));
				} else {
					console.log(`Network Requests (${recentRequests.length}):`);
					console.log("=".repeat(80));
					for (const req of recentRequests) {
						process.stdout.write(formatRequest(req));
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
