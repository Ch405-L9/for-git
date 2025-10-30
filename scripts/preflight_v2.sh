#!/usr/bin/env bash
set -Eeuo pipefail

ok(){ echo "OK: $*"; }
warn(){ echo "WARN: $*"; }
fail(){ echo "FAIL: $*"; exit 1; }

# 0) env
[ -n "${VIRTUAL_ENV:-}" ] && ok "venv active ($VIRTUAL_ENV)" || warn "venv not active"

# 1) versions
PYV=$(python3 -c 'import sys;print(sys.version.split()[0])' 2>/dev/null || true)
[[ "$PYV" =~ ^3\.(10|11|12)$ ]] && ok "Python $PYV" || warn "Python not in 3.10–3.12 ($PYV)"

NODEV=$(node -v 2>/dev/null || true)
[[ "$NODEV" =~ ^v(2[0-9]|3[0-9])\. ]] && ok "Node $NODEV" || warn "Node >=20 required ($NODEV)"

NPMV=$(npm -v 2>/dev/null || true)
[[ -n "$NPMV" ]] && ok "npm $NPMV" || warn "npm missing"

LHV=$(npx lighthouse --version 2>/dev/null || true)
[[ "$LHV" =~ ^1[2-9]\. ]] && ok "Lighthouse $LHV" || warn "Lighthouse >=12 required ($LHV)"

# 2) chrome availability (any of these is fine)
CHROME_BIN="${CHROME_BIN:-$(command -v google-chrome-stable || command -v chromium || command -v chromium-browser || true)}"
[ -n "$CHROME_BIN" ] && ok "Chrome binary found ($CHROME_BIN)" || warn "Chrome not found; Lighthouse may auto-install; consider installing Chromium"

# 3) python deps
python - <<'PY'
from importlib import metadata as m
need = ["requests","beautifulsoup4","lxml","tldextract","jsonschema"]
miss = [p for p in need if not __import__(p)]
print("OK: python deps present:", ", ".join(need))
PY

# 4) dirs + permissions
mkdir -p outputs/{lighthouse,logs,contacts} data || true
for d in outputs outputs/lighthouse outputs/logs outputs/contacts; do
  [ -w "$d" ] && ok "writable: $d" || fail "not writable: $d"
done

# 5) network probes
getent hosts example.com >/dev/null && ok "DNS" || fail "DNS lookup failed"
curl -sSfI https://www.google.com >/dev/null && ok "Outbound HTTPS" || fail "Outbound HTTPS failed"

# 6) analyzer schema validate (if refs exist)
if [ -f data/cwv_reference.schema.json ] && [ -f data/cwv_reference.json ]; then
  python - <<'PY'
import json,sys
from jsonschema import validate, Draft202012Validator
sch=json.load(open("data/cwv_reference.schema.json"))
doc=json.load(open("data/cwv_reference.json"))
Draft202012Validator.check_schema(sch); validate(doc, sch)
print("OK: cwv_reference.json validates against schema")
PY
else
  warn "Schema or reference missing; skip validation"
fi

# 7) freshness checks (LH → analyzer/contacts newer)
LATEST_LH=$(ls -1t outputs/lighthouse/*.json 2>/dev/null | head -n1 || true)
echo "Latest LH JSON: ${LATEST_LH:-none}"
check_fresh(){ local f="$1"; if [ -f "$f" ] && [ -n "$LATEST_LH" ]; then
  if [ "$f" -nt "$LATEST_LH" ]; then ok "Fresh $f"; else warn "Stale $f → re-run generator"; fi
else echo "Missing → $f"; fi; }
check_fresh outputs/cwv_summary.csv
check_fresh outputs/cwv_summary.md
check_fresh outputs/cwv_summary.html
check_fresh outputs/contacts/contacts.json
check_fresh outputs/contacts/contacts.csv

# 8) robots UA for collector
UA=${UA:-"BADGRTech-IntelBot/1.0 (+https://badgrtech.com)"}
ok "Collector UA: $UA"

ok "Preflight_v2 complete"
