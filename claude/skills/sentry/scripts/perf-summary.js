#!/usr/bin/env node

import { SENTRY_API_BASE, getAuthToken, fetchJson, resolveProjectId } from "../lib/auth.js";

const HELP = `Usage: perf-summary.js [options]

Aggregate performance metrics for transactions via Sentry Discover.

Options:
  --org, -o <org>          Organization slug (required)
  --project, -p <project>  Project slug or ID
  --transaction <name>     Filter to specific transaction
  --period, -t <period>    Time period (default: 24h, e.g., 1h, 7d, 14d)
  --limit, -n <n>          Max results (default: 25, max: 100)
  --sort <sort>            Sort field (default: -p95, options: -p95, -tpm, -failure_rate)
  --json                   Output raw JSON
  -h, --help               Show this help

Sort Options:
  -p95            p95(transaction.duration) descending (default)
  -tpm            tpm() descending
  -failure_rate   failure_rate() descending

Examples:
  # Slowest transactions in last 7 days
  perf-summary.js --org myorg --period 7d

  # Specific project, sorted by failure rate
  perf-summary.js --org myorg --project backend --sort "-failure_rate"

  # Single transaction details
  perf-summary.js --org myorg --transaction "GET /api/users"
`;

const SORT_MAP = {
  "-p95": "-p95(transaction.duration)",
  "-tpm": "-tpm()",
  "-failure_rate": "-failure_rate()",
};

function parseArgs(args) {
  const options = {
    org: null,
    project: null,
    transaction: null,
    period: "24h",
    limit: 25,
    sort: "-p95",
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
      case "--limit":
      case "-n":
        options.limit = parseInt(args[++i], 10);
        break;
      case "--sort":
        options.sort = args[++i];
        break;
    }
  }

  return options;
}

function formatDuration(ms) {
  if (ms === null || ms === undefined) return "N/A";
  if (ms < 1) return `${(ms * 1000).toFixed(0)}µs`;
  if (ms < 1000) return `${ms.toFixed(0)}ms`;
  return `${(ms / 1000).toFixed(2)}s`;
}

function formatPercent(rate) {
  if (rate === null || rate === undefined) return "N/A";
  return `${(rate * 100).toFixed(1)}%`;
}

function formatTpm(tpm) {
  if (tpm === null || tpm === undefined) return "N/A";
  if (tpm < 1) return `${tpm.toFixed(2)}/min`;
  return `${tpm.toFixed(1)}/min`;
}

function formatOutput(data) {
  if (!data.data || data.data.length === 0) {
    return "No transaction data found.";
  }

  const lines = [];
  lines.push(`Found ${data.data.length} transactions:\n`);

  for (const row of data.data) {
    const txn = row.transaction || "(unknown)";
    const count = row["count()"] || 0;
    const p50 = formatDuration(row["p50(transaction.duration)"]);
    const p75 = formatDuration(row["p75(transaction.duration)"]);
    const p95 = formatDuration(row["p95(transaction.duration)"]);
    const p99 = formatDuration(row["p99(transaction.duration)"]);
    const tpm = formatTpm(row["tpm()"]);
    const failRate = formatPercent(row["failure_rate()"]);

    lines.push(`${txn}`);
    lines.push(`  p50: ${p50} | p75: ${p75} | p95: ${p95} | p99: ${p99}`);
    lines.push(`  tpm: ${tpm} | failure_rate: ${failRate} | count: ${count}`);
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

  const params = new URLSearchParams();
  params.set("dataset", "discover");
  params.set("statsPeriod", options.period);
  params.set("per_page", Math.min(options.limit, 100).toString());

  // Fields
  const fields = [
    "transaction",
    "p50(transaction.duration)",
    "p75(transaction.duration)",
    "p95(transaction.duration)",
    "p99(transaction.duration)",
    "tpm()",
    "failure_rate()",
    "count()",
  ];
  for (const field of fields) {
    params.append("field", field);
  }

  // Query: only transactions
  const queryParts = ["event.type:transaction"];

  if (options.project) {
    const projectId = await resolveProjectId(options.org, options.project, token);
    params.set("project", projectId);
  }

  if (options.transaction) {
    queryParts.push(`transaction:${options.transaction}`);
  }

  params.set("query", queryParts.join(" "));

  // Sort
  const sortField = SORT_MAP[options.sort] || SORT_MAP["-p95"];
  params.set("sort", sortField);

  const url = `${SENTRY_API_BASE}/organizations/${encodeURIComponent(options.org)}/events/?${params.toString()}`;

  try {
    const data = await fetchJson(url, token);

    if (options.json) {
      console.log(JSON.stringify(data, null, 2));
    } else {
      console.log(formatOutput(data));
    }
  } catch (err) {
    console.error("Error:", err.message);
    process.exit(1);
  }
}

main();
