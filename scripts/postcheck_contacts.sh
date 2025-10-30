#!/usr/bin/env bash
set -Eeuo pipefail
. ./.venv/bin/activate 2>/dev/null || true

echo "== Post-check: Contact Outputs =="

ok=true
OUT_DIR="outputs/contacts"
JSON="$OUT_DIR/contacts.json"
CSV="$OUT_DIR/contacts.csv"

# 1) File presence
for f in "$JSON" "$CSV"; do
  if [ -s "$f" ]; then
    echo "OK: Found $f"
  else
    echo "FAIL: Missing or empty $f"; ok=false
  fi
done

# 2) JSON validity + structure
python - <<'PY' || ok=false
import json, sys
from pathlib import Path
f=Path("outputs/contacts/contacts.json")
try:
    data=json.loads(f.read_text())
    if not isinstance(data,list) or not data:
        print("FAIL: JSON empty or invalid type")
        sys.exit(1)
    required={"url","domain","emails","phones","organizations"}
    missing=[i for i,x in enumerate(data) if not required.issubset(x)]
    if missing:
        print(f"WARN: {len(missing)} entries missing required keys")
    else:
        print("OK: JSON structure valid")
except Exception as e:
    print("FAIL:",e)
    sys.exit(1)
PY

# 3) CSV header sanity
head -n1 "$CSV" | grep -q 'url,domain,organization' && echo "OK: CSV header valid" || { echo "FAIL: CSV header mismatch"; ok=false; }

# 4) Row count > 0
rows=$(wc -l < "$CSV")
if (( rows > 1 )); then
  echo "OK: CSV contains $((rows-1)) record(s)"
else
  echo "FAIL: CSV empty"; ok=false
fi

$ok && echo "Post-check PASSED" || { echo "Post-check FAILED"; exit 1; }
