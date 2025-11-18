#!/usr/bin/env node

import puppeteer from "puppeteer-core";

// Parse command line arguments
function parseArgs() {
	const args = process.argv.slice(2);
	const options = {
		type: null,
		value: null,
		timeout: 30000, // Default 30 seconds
		interval: 100, // Poll every 100ms
	};

	if (args.length === 0 || args.includes("--help") || args.includes("-h")) {
		showHelp();
		process.exit(0);
	}

	// Parse flags
	for (let i = 0; i < args.length; i++) {
		const arg = args[i];

		if (arg === "--text") {
			options.type = "text";
			options.value = args[++i];
		} else if (arg === "--selector") {
			options.type = "selector";
			options.value = args[++i];
		} else if (arg === "--url") {
			options.type = "url";
			options.value = args[++i];
		} else if (arg === "--eval") {
			options.type = "eval";
			options.value = args[++i];
		} else if (arg === "--timeout") {
			options.timeout = parseInt(args[++i], 10);
		} else if (arg === "--interval") {
			options.interval = parseInt(args[++i], 10);
		}
	}

	if (!options.type || !options.value) {
		console.error("✗ Error: Must specify a wait condition");
		console.error("  Use --help for usage information");
		process.exit(1);
	}

	return options;
}

function showHelp() {
	console.log(`browser-wait.js - Smart waiting for browser automation

USAGE:
  browser-wait.js --text "expected text" [options]
  browser-wait.js --selector "css selector" [options]
  browser-wait.js --url "partial url" [options]
  browser-wait.js --eval "JavaScript condition" [options]

WAIT CONDITIONS:
  --text <string>      Wait for text to appear anywhere on the page
  --selector <string>  Wait for CSS selector to exist in DOM
  --url <string>       Wait for URL to contain the specified string
  --eval <string>      Wait for custom JavaScript expression to return true

OPTIONS:
  --timeout <ms>       Maximum wait time in milliseconds (default: 30000)
  --interval <ms>      Polling interval in milliseconds (default: 100)
  -h, --help           Show this help message

EXAMPLES:
  # Wait for specific text to appear
  browser-wait.js --text "Login successful"

  # Wait for element to be present
  browser-wait.js --selector ".loading-spinner" --timeout 5000

  # Wait for navigation to complete
  browser-wait.js --url "/dashboard"

  # Wait for custom condition
  browser-wait.js --eval "document.querySelectorAll('img').length > 0"

  # Wait with custom timeout and interval
  browser-wait.js --text "Results" --timeout 60000 --interval 200

RETURNS:
  Exit code 0 on success, 1 on timeout or error

NOTES:
  - Connects to Chrome DevTools Protocol at localhost:9222
  - Uses active tab (most recently opened/focused)
  - Non-blocking polling with configurable intervals
  - Eliminates race conditions from fixed sleep delays
`);
}

async function waitForCondition(page, options) {
	const startTime = Date.now();

	while (true) {
		const elapsed = Date.now() - startTime;

		if (elapsed > options.timeout) {
			return { success: false, reason: "timeout" };
		}

		try {
			let conditionMet = false;

			switch (options.type) {
				case "text": {
					const text = await page.evaluate(() => document.body.innerText);
					conditionMet = text.includes(options.value);
					break;
				}

				case "selector": {
					const element = await page.$(options.value);
					conditionMet = element !== null;
					break;
				}

				case "url": {
					const currentUrl = page.url();
					conditionMet = currentUrl.includes(options.value);
					break;
				}

				case "eval": {
					conditionMet = await page.evaluate((code) => {
						const AsyncFunction = (async () => {}).constructor;
						return new AsyncFunction(`return (${code})`)();
					}, options.value);
					break;
				}
			}

			if (conditionMet) {
				return { success: true, elapsed };
			}
		} catch (error) {
			// Continue polling even if evaluation fails
			// This handles cases where elements don't exist yet
		}

		// Wait before next poll
		await new Promise((resolve) => setTimeout(resolve, options.interval));
	}
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

		// Show what we're waiting for
		const conditionDesc = {
			text: `text containing "${options.value}"`,
			selector: `selector "${options.value}"`,
			url: `URL containing "${options.value}"`,
			eval: `condition: ${options.value}`,
		};

		process.stdout.write(
			`⏳ Waiting for ${conditionDesc[options.type]} (timeout: ${options.timeout}ms)...`
		);

		const result = await waitForCondition(page, options);

		if (result.success) {
			console.log(` ✓ Found in ${result.elapsed}ms`);
			await browser.disconnect();
			process.exit(0);
		} else {
			console.log(` ✗ Timeout after ${options.timeout}ms`);
			await browser.disconnect();
			process.exit(1);
		}
	} catch (error) {
		console.error("✗ Error:", error.message);
		process.exit(1);
	}
})();
