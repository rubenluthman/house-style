#!/usr/bin/env bash
# Runs the rule tests, then the shared commit checks. Needs vale, jq and gitleaks.
set -euo pipefail
cd "$(dirname "$0")/.."

scripts/test_rules.sh

echo "6. shared commit checks (secrets, home paths, emails, private names, secret files, hooks)..."
scripts/commit-checks verify || { echo "FAIL: commit-checks failed"; exit 1; }
echo "OK"
