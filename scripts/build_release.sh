#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
rm -rf dist && mkdir dist
git archive --format=zip -o dist/HouseStyle.zip HEAD HouseStyle
unzip -l dist/HouseStyle.zip
