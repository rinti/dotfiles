#!/usr/bin/env node

import { SENTRY_API_BASE, getAuthToken, fetchJson, resolveProjectId } from "../lib/auth.js";

const HELP = `Usage: web-vitals.js [options]

Web vitals metrics per transaction via Sentry Discover.

Options:
  --org, -o <org>          Organization slug (required)
  --project, -p <project>  Project slug or ID
  --transaction <name>     Filter to specific transaction/page
  --period, -t <period>    Time period (default: 24h, e.g., 1h, 7d, 14d)
  --percentile <pN>        Percentile to use (default: p75, options: p50, p75, p95, p99)
  --limit, -n <n>          Max results (default: 25, max: 100)
  --json                   Output raw JSON
  -h, --help               Show this help

Metrics:
  LCP   Largest Contentful Paint   good <2500ms, poor >4000ms
  FCP   First Contentful Paint     good <1800ms, poor >3000ms
  CLS   Cumulative Layout Shift    good <0.1, poor >0.25
  TTFB  Time to First Byte        good <800ms, poor >1800ms
  INP   Interaction to Next Paint  good <200ms, poor >500ms

Examples:
  # Web vitals for all pages in last 7 days
  web-vitals.js --org myorg --period 7d

  # Specific page at p95
  web-vitals.js --org myorg --transaction "GET /home" --percentile p95

  # Single project
  web-vitals.js --org myorg --project frontend --period 24h
`;

// Core Web Vitals thresholds: [good_threshold, poor_threshold]
// Values below good = Good, above poor = Poor, between = Meh
const VITALS_THRESHOLDS = {
  lcp: { good: 2500, poor: 4000, unit: "ms" },
  fcp: { good: 1800, poor: 3000, unit: "ms" },
  cls: { good: 0.1, poor: 0.25, unit: "" },
  ttfb: { good: 800, poor: 1800, unit: "ms" },
  inp: { good: 200, poor: 500, unit: "ms" },
};

function parseArgs(args) {
  const options = {
    org: null,
    project: null,
    transaction: null,
    period: "24h",
    percentile: "p75",
    limit: 25,
    json: false,
    help: false,
  };

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];

    switch (arg) {
      case "--help":
      case "-h":
        options.help = true;
        break;
      case "--json":
        options.json = true;
        break;
      case "--org":
      case "-o":
        options.org = args[++i];
        break;
      case "--project":
      case "-p":
        options.project = args[++i];
        break;
      case "--transaction":
        options.transaction = args[++i];
        break;
      case "--period":
      case "-t":
        options.period = args[++i];
        break;
      case "--percentile":
        options.percentile = args[++i];
        break;
      case "--limit":
      case "-n":
        options.limit = parseInt(args[++i], 10);
        break;
    }
  }

  return options;
}

function rateValue(value, vital) {
  const t = VITALS_THRESHOLDS[vital];
  if (!t || value === null || value === undefined) return "?";
  if (value <= t.good) return "Good";
  if (value >= t.poor) return "Poor";
  return "Meh";
}

function formatVital(value, vital) {
  if (value === null || value === undefined) return "N/A";
  const t = VITALS_THRESHOLDS[vital];
  if (!t) return String(value);

  let display;
  if (vital === "cls") {
    display = value.toFixed(3);
  } else if (value < 1) {
    display = `${(value * 1000).toFixed(0)}µs`;
  } else if (value < 1000) {
    display = `${value.toFixed(0)}ms`;
  } else {
    display = `${(value / 1000).toFixed(2)}s`;
  }

  const rating = rateValue(value, vital);
  return `${display} (${rating})`;
}

function formatOutput(data, percentile) {
  if (!data.data || data.data.length === 0) {
    return "No web vitals data found. Ensure pages have LCP measurements.";
  }

  const lines = [];
  lines.push(`Found ${data.data.length} transactions (${percentile}):\n`);

  for (const row of data.data) {
    const txn = row.transaction || "(unknown)";
    const count = row["count()"] || 0;

    const lcp = row[`${percentile}(measurements.lcp)`];
    const fcp = row[`${percentile}(measurements.fcp)`];
    const cls = row[`${percentile}(measurements.cls)`];
    const ttfb = row[`${percentile}(measurements.ttfb)`];
    const inp = row[`${percentile}(measurements.inp)`];

    lines.push(`${txn} (${count} events)`);
    lines.push(`  LCP:  ${formatVital(lcp, "lcp")}`);
    lines.push(`  FCP:  ${formatVital(fcp, "fcp")}`);
    lines.push(`  CLS:  ${formatVital(cls, "cls")}`);
    lines.push(`  TTFB: ${formatVital(ttfb, "ttfb")}`);
    lines.push(`  INP:  ${formatVital(inp, "inp")}`);
    lines.push("");
  }

  return lines.join("\n").trimEnd();
}

async function main() {
  const args = process.argv.slice(2);
  const options = parseArgs(args);

  if (options.help) {
    console.log(HELP);
    process.exit(0);
  }

  if (!options.org) {
    console.error("Error: --org is required");
    console.error("Run with --help for usage information");
    process.exit(1);
  }

  const token = getAuthToken();
  const pct = options.percentile;

  const params = new URLSearchParams();
  params.set("dataset", "discover");
  params.set("statsPeriod", options.period);
  params.set("per_page", Math.min(options.limit, 100).toString());

  // Fields
  const fields = [
    "transaction",
    `${pct}(measurements.lcp)`,
    `${pct}(measurements.fcp)`,
    `${pct}(measurements.cls)`,
    `${pct}(measurements.ttfb)`,
    `${pct}(measurements.inp)`,
    "count()",
  ];
  for (const field of fields) {
    params.append("field", field);
  }

  // Only page loads with LCP data
  const queryParts = ["event.type:transaction", "has:measurements.lcp"];

  if (options.project) {
    const projectId = await resolveProjectId(options.org, options.project, token);
    params.set("project", projectId);
  }

  if (options.transaction) {
    queryParts.push(`transaction:${options.transaction}`);
  }

  params.set("query", queryParts.join(" "));
  params.set("sort", `-${pct}(measurements.lcp)`);

  const url = `${SENTRY_API_BASE}/organizations/${encodeURIComponent(options.org)}/events/?${params.toString()}`;

  try {
    const data = await fetchJson(url, token);

    if (options.json) {
      console.log(JSON.stringify(data, null, 2));
    } else {
      console.log(formatOutput(data, pct));
    }
  } catch (err) {
    console.error("Error:", err.message);
    process.exit(1);
  }
}

main();
