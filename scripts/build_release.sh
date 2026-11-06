#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
rm -rf dist && mkdir dist
zip -qr dist/HouseStyle.zip HouseStyle -x '*.DS_Store'
unzip -l dist/HouseStyle.zip
