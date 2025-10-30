#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

# Auto-venv
if [ -f .venv/bin/activate ]; then . .venv/bin/activate; fi

# Config
KEYWORDS_JSON="${1:-configs/keywords.us.nationwide.json}"
RAW_CSV="outputs/contacts/contacts.raw.csv"
CLEAN_CSV="outputs/contacts/contacts.clean.csv"
FINAL_CSV="outputs/contacts/contacts.csv"
ENRICHED="outputs/enriched/enriched.csv"
DAILY_CAP="${DAILY_CAP:-200}"          # cap leads per run
MIN_ROWS_FOR_PROVIDER="${MIN_ROWS_FOR_PROVIDER:-100}"  # Upgini needs >=100 labeled rows

echo "[beta] collecting… from $KEYWORDS_JSON"
if [ -x scripts/run_collect.sh ]; then
  bash scripts/run_collect.sh || true
fi

# Fallback collector if run_collect.sh didn’t write output
if [ ! -s "$FINAL_CSV" ] && [ -f tools/collect_contacts.py ]; then
  python tools/collect_contacts.py --out "$RAW_CSV" --keywords "$KEYWORDS_JSON" || true
else
  cp -f "$FINAL_CSV" "$RAW_CSV" || true
fi

[ -s "$RAW_CSV" ] || { echo "[beta] no raw contacts found"; exit 0; }

echo "[beta] cleaning & capping → $CLEAN_CSV"
# Keep header, then:
# - drop no-reply/info/support helpdesk style mailboxes
# - lowercase emails
# - dedupe by email
# - cap to DAILY_CAP
awk -F',' 'NR==1{hdr=$0; next}
{
  # naive email column detection (fallback to any field containing @)
  e=""
  for(i=1;i<=NF;i++) if($i ~ /@/) { e=$i; break }
  if(e=="") next
  le=tolower(e)
  if(le ~ /(no-?reply|info|support|help|service|admin|contact|sales)@/) next
  if(!seen[le]++){ rows[++n]=$0; emails[n]=le }
}
END{
  print hdr
  cap='${DAILY_CAP}'
  if(n>cap) n=cap
  for(i=1;i<=n;i++) print rows[i]
}' "$RAW_CSV" > "$CLEAN_CSV"

mv -f "$CLEAN_CSV" "$FINAL_CSV"
rows=$(awk 'END{print NR-1}' "$FINAL_CSV")
echo "[beta] final contacts rows=$rows → $FINAL_CSV"

# Enrich + autodoc
if [ "$rows" -lt "$MIN_ROWS_FOR_PROVIDER" ] || [ -z "$UPGINI_API_KEY" ]; then
  echo "[beta] provider off (rows<$MIN_ROWS_FOR_PROVIDER or no key). Using fallback."
fi
make one_shot

# Stamp SHN
ts="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
if command -v jq >/dev/null; then
  jq --arg ts "$ts" '
    .shn_id |= (. + $ts) |
    .timeline_utc.start |= $ts |
    .timeline_utc.end   |= $ts
  ' shn/BADGR_BOT-R9-Enrichment_Autodoc-SHN.json | sponge shn/BADGR_BOT-R9-Enrichment_Autodoc-SHN.json || true
fi

echo "[beta] done → $ENRICHED"
