#!/usr/bin/env bash
set -Eeuo pipefail
. ./.venv/bin/activate 2>/dev/null || true

echo "== Contact Collector Preflight =="

ok=true

check_group() {
  local label="$1"; shift
  echo "-- Checking: $label --"
  for m in "$@"; do
    python - <<PY || { echo "MISS: $m"; ok=false; }
import importlib
importlib.import_module("${m}")
print("OK:", "${m}")
PY
  done
}

# 1) Core libs
check_group "Core" requests bs4 lxml

# 2) Extended
check_group "Extended" extruct w3lib tldextract

# 3) Validation
check_group "Validation" email_validator phonenumbers

# 4) Optional (spaCy + model)
echo "-- Checking: Optional (spaCy) --"
python - <<'PY' || true
try:
    import spacy
    spacy.load("en_core_web_sm")
    print("OK: spacy + en_core_web_sm")
except Exception as e:
    print("WARN: spaCy model not ready:", e)
PY

# Directory check
mkdir -p outputs/contacts
if [ -w outputs/contacts ]; then
  echo "OK: outputs/contacts writable"
else
  echo "FAIL: outputs/contacts not writable"; ok=false
fi

$ok || { echo "Preflight FAILED"; exit 1; }
echo "-- Checking: Optional (Playwright) --"; 
python - <<'PY' || true
try:
    import playwright
    print("OK: playwright (python)")
except Exception as e:
    print("WARN: Playwright not installed:", e)
PY

echo "Preflight PASSED"
