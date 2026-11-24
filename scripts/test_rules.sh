#!/usr/bin/env bash
# Checks the package's rules against fixtures and its own docs. Needs vale and jq.
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

run() { (cd "$work" && vale --minAlertLevel=error --output=JSON "$1" || true); }
count() { echo "$1" | jq --arg c "$2" '[.[][] | select(.Check==$c)] | length'; }
has() { echo "$1" | jq -e --arg w "$2" '[.[][] | select(.Check=="HouseStyle.Promotional" and (.Match|ascii_downcase)==$w)] | length >= 1' >/dev/null; }

echo "0. every rule has a message, meta.json is valid..."
for f in HouseStyle/*.yml; do
  grep -q '^message:' "$f" || fail "$f has no message: line"
done
jq -e 'has("feed") and has("vale_version")' HouseStyle/meta.json >/dev/null || fail "HouseStyle/meta.json must parse and have feed and vale_version"

echo "1. should-alert.md raises every expected check..."
out="$(run tests/should-alert.md)"
for want in seamless seamlessly cutting-edge "cutting edge" game-changer game-changers "game changer" "game changers" game-changing \
  revolutionary revolutionize revolutionizes revolutionise revolutionised revolutionizing groundbreaking ground-breaking \
  unleash unleashes unleashed unleashing world-class "world class" state-of-the-art "state of the art" blazing blazingly \
  "robust solution" "robust solutions" best-in-class "best in class"; do
  has "$out" "$want" || fail "expected Promotional alert for '$want'"
done
[ "$(count "$out" HouseStyle.Dashes)" = "2" ] || fail "expected two Dashes alerts (prose and code span)"

echo "1b. Filler tokens raise HouseStyle.Filler..."
for want in "delve" "delves" "delved" "delving" "testament to" "testaments to" "rich tapestry" "beacon of" "beacons of" "nestled"; do
  echo "$out" | jq -e --arg w "$want" '[.[][] | select(.Check=="HouseStyle.Filler" and (.Match|ascii_downcase)==$w)] | length >= 1' >/dev/null \
    || fail "expected Filler alert for '$want'"
done

echo "1c. Title Case headings raise HouseStyle.Headings..."
lines="$(echo "$out" | jq -c '[.[][] | select(.Check=="HouseStyle.Headings") | .Line]')"
[ "$lines" = "[16,18,20,22,24,26,28,30,32,34,36,38,40,42]" ] || fail "Headings alerts on wrong lines: $lines"

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
docs=()
while IFS= read -r f; do
  case "$f" in tests/*|docs/private/*) ;; *) [ -f "$f" ] && docs+=("$f") ;; esac
done < <(git ls-files '*.md')
out="$(vale --minAlertLevel=error --output=JSON "${docs[@]}" || true)"
[ "$(echo "$out" | jq 'length')" = "0" ] || fail "alerts in own docs: $(echo "$out" | jq -c '[to_entries[] | .key as $f | .value[] | {File:$f,Line,Match}]')"

echo "5. no em dashes in the repository..."
status=0
hits="$(git grep --untracked -lI $'\xe2\x80\x94')" || status=$?
case "$status" in
  0) fail "em dash (U+2014) found in: $hits" ;;
  1) ;;
  *) fail "git grep failed with status $status" ;;
esac

echo "OK"
