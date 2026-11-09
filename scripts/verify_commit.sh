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
for f in tests/*.md tests/*.swift; do
  sed $'s/@@EMDASH@@/\xe2\x80\x94/g' "$f" > "$work/$f"
done

run() { (cd "$work" && vale --output=JSON "$1" || true); }
count() { echo "$1" | jq --arg c "$2" '[.[][] | select(.Check==$c)] | length'; }
has() { echo "$1" | jq -e --arg w "$2" '[.[][] | select(.Check=="HouseStyle.Promotional" and (.Match|ascii_downcase)==$w)] | length >= 1' >/dev/null; }

echo "1. should-alert.md raises every expected check..."
out="$(run tests/should-alert.md)"
for want in seamless cutting-edge game-changer revolutionize revolutionise; do
  has "$out" "$want" || fail "expected Promotional alert for '$want'"
done
[ "$(count "$out" HouseStyle.Dashes)" = "2" ] || fail "expected two Dashes alerts (prose and code span)"

echo "1b. Filler tokens raise HouseStyle.Filler..."
for want in "delve" "testament to" "rich tapestry" "beacon of" "nestled"; do
  echo "$out" | jq -e --arg w "$want" '[.[][] | select(.Check=="HouseStyle.Filler" and (.Match|ascii_downcase)==$w)] | length >= 1' >/dev/null \
    || fail "expected Filler alert for '$want'"
done

echo "2. should-pass.md raises no alerts..."
out="$(run tests/should-pass.md)"
[ "$(echo "$out" | jq 'length')" = "0" ] || fail "unexpected alerts: $(echo "$out" | jq -c '[.[][] | {Line,Match}]')"

echo "3. ShouldAlert.swift flags the dash in a string and in a comment, promo only in comments..."
out="$(run tests/ShouldAlert.swift)"
[ "$(count "$out" HouseStyle.Dashes)" = "2" ] || fail "expected two Dashes alerts in Swift (string and comment)"
has "$out" seamless || fail "expected Promotional alert for 'seamless' in a comment"

echo "4. ShouldPass.swift raises no alerts..."
out="$(run tests/ShouldPass.swift)"
[ "$(echo "$out" | jq 'length')" = "0" ] || fail "unexpected alerts: $(echo "$out" | jq -c '[.[][] | {Line,Match}]')"

echo "5. no em dashes in the repository..."
if git ls-files -z --cached --others --exclude-standard | xargs -0 grep -l $'\xe2\x80\x94' 2>/dev/null; then
  fail "em dash (U+2014) found in repository"
fi
echo "OK"
