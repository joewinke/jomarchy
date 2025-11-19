#!/usr/bin/env node

import { spawn, execSync } from "node:child_process";
import { platform } from "node:os";
import puppeteer from "puppeteer-core";

const useProfile = process.argv[2] === "--profile";

if (process.argv[2] && process.argv[2] !== "--profile") {
	console.log("Usage: browser-start.js [--profile]");
	console.log("\nOptions:");
	console.log("  --profile  Copy your default Chrome profile (cookies, logins)");
	console.log("\nExamples:");
	console.log("  browser-start.js            # Start with fresh profile");
	console.log("  browser-start.js --profile  # Start with your Chrome profile");
	process.exit(1);
}

// Platform-specific configuration
const isMac = platform() === "darwin";
const isLinux = platform() === "linux";

// Chrome executable paths
const chromePaths = isMac
	? ["/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"]
	: [
		"/usr/bin/google-chrome-stable",
		"/usr/bin/google-chrome",
		"/usr/bin/chromium-browser",
		"/usr/bin/chromium",
	];

// Chrome profile paths
const profilePaths = isMac
	? [`${process.env.HOME}/Library/Application Support/Google/Chrome/Default`]
	: [
		`${process.env.HOME}/.config/google-chrome/Default`,
		`${process.env.HOME}/.config/chromium/Default`,
	];

// Chrome process names for killall
const processNames = isMac
	? ["Google Chrome"]
	: ["chrome", "chromium", "google-chrome", "chromium-browser"];

// Find Chrome executable
let chromeExec = null;
for (const path of chromePaths) {
	try {
		execSync(`test -x "${path}"`, { stdio: "ignore" });
		chromeExec = path;
		break;
	} catch {}
}

if (!chromeExec) {
	console.error("✗ Chrome not found. Install via:");
	if (isLinux) {
		console.error("  Arch/Manjaro: sudo pacman -S chromium");
		console.error("  Ubuntu/Debian: sudo apt install chromium-browser");
	} else if (isMac) {
		console.error("  brew install --cask google-chrome");
	}
	process.exit(1);
}

// Kill existing Chrome instances
for (const name of processNames) {
	try {
		execSync(`killall '${name}'`, { stdio: "ignore" });
	} catch {}
}

// Wait a bit for processes to fully die
await new Promise((r) => setTimeout(r, 1000));

// Setup profile directory
execSync("mkdir -p ~/.cache/scraping", { stdio: "ignore" });

if (useProfile) {
	// Find user's Chrome profile
	let sourceProfile = null;
	for (const path of profilePaths) {
		try {
			execSync(`test -d "${path}"`, { stdio: "ignore" });
			sourceProfile = path;
			break;
		} catch {}
	}

	if (sourceProfile) {
		// Sync profile with rsync (much faster on subsequent runs)
		execSync(
			`rsync -a --delete "${sourceProfile}/" ~/.cache/scraping/Default/`,
			{ stdio: "pipe" },
		);
	} else {
		console.warn("⚠ Chrome profile not found, starting with fresh profile");
	}
}

// Start Chrome in background (detached so Node can exit)
spawn(
	chromeExec,
	["--remote-debugging-port=9222", `--user-data-dir=${process.env.HOME}/.cache/scraping`],
	{ detached: true, stdio: "ignore" },
).unref();

// Wait for Chrome to be ready by attempting to connect
let connected = false;
for (let i = 0; i < 30; i++) {
	try {
		const browser = await puppeteer.connect({
			browserURL: "http://localhost:9222",
			defaultViewport: null,
		});
		await browser.disconnect();
		connected = true;
		break;
	} catch {
		await new Promise((r) => setTimeout(r, 500));
	}
}

if (!connected) {
	console.error("✗ Failed to connect to Chrome");
	process.exit(1);
}

console.log(`✓ Chrome started on :9222${useProfile ? " with your profile" : ""}`);
