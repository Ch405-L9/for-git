#!/usr/bin/env bash
set -Eeuo pipefail
. ./.venv/bin/activate 2>/dev/null || true

REGION="${CONTACT_DEFAULT_REGION:-US}"
INPUT="${1:-urls.txt}"

if [ ! -f "$INPUT" ]; then
  echo "No $INPUT found. Create one URL per line." >&2
  exit 1
fi

mkdir -p outputs/contacts

# De-dupe + trim
mapfile -t URLS < <(sed 's/[[:space:]]\+//g' "$INPUT" | awk 'length>0' | sort -u)

# Collect (HTTP-first; enable JS fallback per-run with: RENDER_JS=1)
printf '%s\n' "${URLS[@]}" | python tools/collect_contacts.py "$REGION"

# Reformat -> tidy CSV for spreadsheets
python tools/format_contacts_csv.py

echo "Done. See:"
echo " - outputs/contacts/contacts.json"
echo " - outputs/contacts/contacts.csv"
