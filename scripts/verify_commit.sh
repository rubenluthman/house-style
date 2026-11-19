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
for want in seamless cutting-edge game-changer game-changers revolutionize revolutionizes revolutionise revolutionised unleashes unleashed "robust solutions"; do
  has "$out" "$want" || fail "expected Promotional alert for '$want'"
done
[ "$(count "$out" HouseStyle.Dashes)" = "2" ] || fail "expected two Dashes alerts (prose and code span)"

echo "1b. Filler tokens raise HouseStyle.Filler..."
for want in "delve" "delves" "delved" "delving" "testament to" "testaments to" "rich tapestry" "beacon of" "beacons of" "nestled"; do
  echo "$out" | jq -e --arg w "$want" '[.[][] | select(.Check=="HouseStyle.Filler" and (.Match|ascii_downcase)==$w)] | length >= 1' >/dev/null \
    || fail "expected Filler alert for '$want'"
done

echo "1c. Title Case headings raise HouseStyle.Headings..."
[ "$(count "$out" HouseStyle.Headings)" = "4" ] || fail "expected four Headings alerts"

echo "2. should-pass.md raises no alerts..."
out="$(run tests/should-pass.md)"
[ "$(echo "$out" | jq 'length')" = "0" ] || fail "unexpected alerts: $(echo "$out" | jq -c '[.[][] | {Line,Match}]')"

echo "3. ShouldAlert.swift flags the dash in a string and in a comment, promo only in comments..."
out="$(run tests/ShouldAlert.swift)"
[ "$(count "$out" HouseStyle.Dashes)" = "2" ] || fail "expected two Dashes alerts in Swift (string and comment)"
has "$out" seamless || fail "expected Promotional alert for 'seamless' in a comment"
echo "$out" | jq -e '[.[][] | select(.Check=="HouseStyle.Filler" and (.Match|ascii_downcase)=="delve")] | length == 1' >/dev/null \
  || fail "expected one Filler alert for 'delve' in a Swift comment only"

echo "4. ShouldPass.swift raises no alerts..."
out="$(run tests/ShouldPass.swift)"
[ "$(echo "$out" | jq 'length')" = "0" ] || fail "unexpected alerts: $(echo "$out" | jq -c '[.[][] | {Line,Match}]')"

echo "4b. the repository's own docs raise no alerts (tests/ is excluded: its fixtures are meant to alert)..."
out="$(vale --output=JSON README.md CHANGELOG.md AGENTS.md HouseStyle/README.md || true)"
[ "$(echo "$out" | jq 'length')" = "0" ] || fail "alerts in own docs: $(echo "$out" | jq -c '[to_entries[] | .key as $f | .value[] | {File:$f,Line,Match}]')"

echo "4c. relative Markdown links resolve..."
for f in README.md CHANGELOG.md AGENTS.md HouseStyle/README.md; do
  while IFS= read -r link; do
    target="${link#\]\(}"; target="${target%\)}"; target="${target%%#*}"
    case "$target" in ""|http*|mailto:*) continue ;; esac
    [ -e "$(dirname "$f")/$target" ] || fail "broken link in $f: $target"
  done < <(grep -o '\]([^)]*)' "$f" || true)
done

echo "5. no em dashes in the repository..."
if git ls-files -z --cached --others --exclude-standard | xargs -0 grep -l $'\xe2\x80\x94' 2>/dev/null; then
  fail "em dash (U+2014) found in repository"
fi

echo "6. shared commit checks (secrets, home paths, emails, private names, secret files, hooks)..."
scripts/commit-checks verify || fail "commit-checks failed"
echo "OK"
