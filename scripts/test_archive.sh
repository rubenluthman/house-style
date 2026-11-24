#!/usr/bin/env bash
# Loads dist/HouseStyle.zip the way a consuming repository does (vale sync with a
# local Packages path), then checks that two rules alert. Needs vale.
# Vale names the package after the zip file, so the file must stay HouseStyle.zip.
set -euo pipefail
cd "$(dirname "$0")/.."
zip="$PWD/dist/HouseStyle.zip"
[ -f "$zip" ] || { echo "FAIL: $zip is missing; run scripts/build_release.sh first"; exit 1; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work"
cat > .vale.ini <<INI
StylesPath = styles
MinAlertLevel = error

Packages = $zip

[*.md]
BasedOnStyles = HouseStyle
INI
printf '# Title Case Heading\n\nA seamless result.\n' > sample.md

vale sync >/dev/null
# Vale exits 1 when it finds alerts, which is the expected result here.
out=$(vale --output=JSON sample.md || true)
for rule in HouseStyle.Headings HouseStyle.Promotional; do
  if ! printf '%s' "$out" | jq -e --arg r "$rule" '[.[][] | select(.Check == $r)] | length > 0' >/dev/null; then
    echo "FAIL: $rule did not alert when loaded from dist/HouseStyle.zip"
    exit 1
  fi
done
echo "OK: dist/HouseStyle.zip loads and both rules alert"
