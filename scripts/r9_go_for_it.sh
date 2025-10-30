#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SHN_FILE="shn/BADGR_BOT-R9-Enrichment_Autodoc-SHN.json"
SCHEMA_FILE="schemas/enriched.schema.json"
OSINT_SCRIPT="scripts/osint_fallback.sh"
MAKEFILE="Makefile"

require() { command -v "$1" >/dev/null 2>&1 || { echo "[ERR] '$1' is required. Please install it and re-run." >&2; exit 1; }; }

echo "[+] Pre-flight checks"
require jq
require git

test -f "$SHN_FILE" || { echo "[ERR] Missing $SHN_FILE" >&2; exit 1; }

echo "[+] Stamp SHN with current UTC timestamp"
TS="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
TMP="$(mktemp)"
jq --arg ts "$TS" '
  .shn_id |= (. + $ts)
  | .timeline_utc.start |= $ts
  | .timeline_utc.end   |= $ts
' "$SHN_FILE" > "$TMP"
mv "$TMP" "$SHN_FILE"

echo "[+] Validate SHN JSON"
jq -e type "$SHN_FILE" >/dev/null
echo "    -> JSON OK"

echo "[+] Create or switch to branch: r9-shn-drop"
git switch -C r9-shn-drop

echo "[+] Stage and commit SHN update"
git add "$SHN_FILE"
git commit -m "SHN: R9 Enrichment + Autodoc snapshot ($TS)" || echo "    -> No changes to commit (already up to date)"

echo "[+] Wire Makefile one_shot target (idempotent)"
touch "$MAKEFILE"
if ! grep -q '^one_shot:' "$MAKEFILE"; then
  {
    printf '\n.PHONY: enrich autodoc one_shot\n'
    printf 'enrich:\n\t@bash scripts/enrich.sh\n\n'
    printf 'autodoc:\n\t@bash scripts/update_helpers_and_docs.sh\n\n'
    printf 'one_shot: enrich autodoc\n\t@echo "[DONE] Enrichment + Autodoc complete"\n'
  } >> "$MAKEFILE"
  echo "    -> one_shot appended"
else
  echo "    -> one_shot already present; skipping append"
fi

echo "[+] Write R10 scoring schema → $SCHEMA_FILE"
mkdir -p "$(dirname "$SCHEMA_FILE")"
cat > "$SCHEMA_FILE" <<'JSON'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "EnrichedContact",
  "type": "object",
  "properties": {
    "email": { "type": "string", "format": "email" },
    "email_confidence": { "type": "number", "minimum": 0, "maximum": 1 },
    "full_name": { "type": "string" },
    "role": { "type": "string" },
    "linkedin_url": { "type": "string" },
    "company_name": { "type": "string" },
    "company_size": { "type": "string" },
    "industry": { "type": "string" },
    "tech_stack": { "type": "array", "items": { "type": "string" } },
    "phone": { "type": "string" },
    "hq_country": { "type": "string" },
    "hq_region": { "type": "string" },
    "hq_city": { "type": "string" },
    "source_provider": { "type": "string" },
    "enrichment_timestamp": { "type": "string", "format": "date-time" }
  },
  "required": ["email", "source_provider", "enrichment_timestamp"],
  "additionalProperties": true
}
JSON

echo "[+] Create zero-cost OSINT fallback stub → $OSINT_SCRIPT"
cat > "$OSINT_SCRIPT" <<'BASH'
#!/usr/bin/env bash
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
BASH
chmod +x "$OSINT_SCRIPT"

echo "[+] Git add, commit, push supplemental changes"
git add "$MAKEFILE" "$SCHEMA_FILE" "$OSINT_SCRIPT"
git commit -m "R9→R10 prep: Makefile one_shot, enriched.schema.json, OSINT fallback stub" || echo "    -> No changes to commit (already up to date)"
git push -u origin r9-shn-drop

echo "[✓] All done."
echo "    Next: run 'make one_shot' to execute enrich + autodoc with new gates."
