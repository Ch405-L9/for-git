#!/usr/bin/env bash
set -Eeuo pipefail
. .venv/bin/activate
python scripts/precheck.py
python src/main.py "$@"
echo "Run complete. See outputs/."
