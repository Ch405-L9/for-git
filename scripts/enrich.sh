#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

# activate venv if present
if [[ -f .venv/bin/activate ]]; then
  # shellcheck disable=SC1091
  source .venv/bin/activate
fi

INPUT="${1:-outputs/contacts/contacts.csv}"
OUTPUT="${2:-outputs/enriched/enriched.csv}"
PROVIDER="${3:-upgini}"
KEYS="${4:-EMAIL}"

python scripts/enrich_contacts.py \
  --input_path "$INPUT" \
  --output_path "$OUTPUT" \
  --provider "$PROVIDER" \
  --search_keys "$KEYS"

./scripts/postcheck_enrichment.sh "$OUTPUT"
