#!/usr/bin/env bash

# --- auto-venv guard (inserted by patch_venv_guard.sh) ---
cd "$(dirname "$0")/.." >/dev/null 2>&1 || true
if [ -f ".venv/bin/activate" ]; then
  # shellcheck disable=SC1091
  . ".venv/bin/activate"
fi
# ---------------------------------------------------------

set -Eeuo pipefail
in="${1:-outputs/contacts/contacts.csv}"
out="${2:-outputs/enriched/enriched.csv}"

mkdir -p "$(dirname "$out")"
tmp="$(mktemp)"

# Pass-through with placeholder columns when no provider data is available.
# Adds: company_guess, title_guess (to be improved by later OSINT probes).
awk 'BEGIN{FS=OFS=","}
NR==1 { print $0,"company_guess","title_guess"; next }
{ print $0,"","" }' "$in" > "$tmp"

mv "$tmp" "$out"
echo "[OSINT-FALLBACK] Wrote: $out"
