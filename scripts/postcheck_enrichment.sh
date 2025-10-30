#!/usr/bin/env bash

# --- auto-venv guard (inserted by patch_venv_guard.sh) ---
cd "$(dirname "$0")/.." >/dev/null 2>&1 || true
if [ -f ".venv/bin/activate" ]; then
  # shellcheck disable=SC1091
  . ".venv/bin/activate"
fi
# ---------------------------------------------------------

set -Eeuo pipefail

CSV="${1:-outputs/enriched/enriched.csv}"
req_cols=(email role linkedin_url company_name industry source_provider enrichment_timestamp)

if [[ ! -f "$CSV" ]]; then
  echo "[postcheck] Missing file: $CSV" >&2
  exit 2
fi

header="$(head -n1 "$CSV")"
ok=1
for col in "${req_cols[@]}"; do
  if ! echo "$header" | tr ',' '\n' | grep -qx "$col"; then
    echo "[postcheck] Missing header column: $col" >&2
    ok=0
  fi
done

rows="$(wc -l < "$CSV" | awk '{print $1}')"
if [[ "$rows" -lt 2 ]]; then
  echo "[postcheck] CSV has header only (no rows)." >&2
  ok=0
fi

if [[ "$ok" -eq 1 ]]; then
  echo "[postcheck] OK → $CSV ($((rows-1)) rows)"
  exit 0
else
  exit 3
fi
