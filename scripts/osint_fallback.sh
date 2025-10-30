#!/usr/bin/env bash
set -Eeuo pipefail
in="${1:-outputs/contacts/contacts.csv}"
out="${2:-outputs/enriched/enriched.csv}"

mkdir -p "$(dirname "$out")"
tmp="$(mktemp)"

awk 'BEGIN{FS=OFS=","}
NR==1 { print $0,"company_guess","title_guess"; next }
{ print $0,"","" }' "$in" > "$tmp"

mv "$tmp" "$out"
echo "[OSINT-FALLBACK] Wrote: $out"
