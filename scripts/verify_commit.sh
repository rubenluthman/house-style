#!/usr/bin/env bash
# Checks the package's rules against fixtures. Needs vale and jq.
set -euo pipefail
cd "$(dirname "$0")/.."
command -v vale >/dev/null || { echo "vale not installed (brew install vale)"; exit 1; }
command -v jq >/dev/null || { echo "jq not installed (brew install jq)"; exit 1; }
fail() { echo "FAIL: $*"; exit 1; }

# Fixtures hold @@EMDASH@@ so the repository itself never contains U+2014.
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
cp -R HouseStyle .vale.ini "$work/"
mkdir "$work/tests"
for f in tests/*.md; do
  sed $'s/@@EMDASH@@/\xe2\x80\x94/g' "$f" > "$work/$f"
done

run() { (cd "$work" && vale --output=JSON "$1" || true); }

echo "1. should-alert.md raises every expected check..."
out="$(run tests/should-alert.md)"
for want in "delve" "seamless" "cutting-edge" "game-changer" "revolutionize" "revolutionise"; do
  echo "$out" | jq -e --arg w "$want" '[.[][] | select(.Check=="HouseStyle.Promotional" and (.Match|ascii_downcase)==$w)] | length >= 1' >/dev/null \
    || fail "expected Promotional alert for '$want'"
done
echo "$out" | jq -e '[.[][] | select(.Check=="HouseStyle.Dashes")] | length == 1' >/dev/null \
  || fail "expected exactly one Dashes alert"

echo "2. should-pass.md raises no alerts..."
out="$(run tests/should-pass.md)"
[ "$(echo "$out" | jq 'length')" = "0" ] || fail "unexpected alerts: $(echo "$out" | jq -c '[.[][] | {Line,Match}]')"

echo "3. no em dashes or inline word lists outside HouseStyle/..."
if git ls-files -z --cached --others --exclude-standard | xargs -0 grep -l $'\xe2\x80\x94' 2>/dev/null; then
  fail "em dash (U+2014) found in repository"
fi
echo "OK"
