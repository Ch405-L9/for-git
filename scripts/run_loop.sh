# --- build next-run query set ---
. .venv/bin/activate 2>/dev/null || true
python scripts/manage_keywords.py
python scripts/build_queries.py

# --- summarize CWV/LH (greens optional) ---
INCLUDE_GREENS=${INCLUDE_GREENS:-0} python scripts/analyze_cwv.py || echo "[warn] analyze_cwv.py failed"

# quick surface
[ -f outputs/queries_next.csv ] && echo "queries_next ready: $(wc -l < outputs/queries_next.csv) rows"
[ -f data/keywords_master_next.csv ] && echo "master_next ready: $(wc -l < data/keywords_master_next.csv) rows"

###############################################################################
# R9 ADDITIONS: Keyword Engine + CWV Analyzer + Retry/Backoff
###############################################################################

# --- venv (safe) ---
if [ -f ".venv/bin/activate" ]; then
  . .venv/bin/activate
fi

# --- helper: retry/backoff for missing/empty Lighthouse JSON report ---
retry_json() {
  # usage: retry_json <url> <json_path> <lighthouse_args...>
  URL="$1"; shift
  TARGET="$1"; shift
  MAX=3; TRY=0; SLEEP_S=2

  while :; do
    if [ -s "$TARGET" ]; then
      echo "[ok] report exists: $TARGET"
      return 0
    fi

    TRY=$((TRY+1))
    if [ "$TRY" -gt "$MAX" ]; then
      echo "[fail] report missing after $MAX tries: $TARGET"
      mkdir -p outputs/logs
      echo "$(date -u +%FT%TZ) FAIL $TARGET $URL" >> outputs/logs/audit-failures.log
      return 1
    fi

    echo "[warn] missing report: $TARGET (retry $TRY/$MAX); sleeping ${SLEEP_S}s"
    sleep "$SLEEP_S"
    SLEEP_S=$((SLEEP_S*2))

    # Re-run Lighthouse with the same args (adjust the binary/flags as needed)
    # Example expected args (passed in ...):
    #   --output=json --output-path="$TARGET" --chrome-flags="--headless=new"
    lighthouse "$URL" "$@" || echo "[warn] lighthouse re-run exited non-zero"
  done
}

# --- keyword engine: merge, dedupe, rank; then build ready-to-run queries ---
python scripts/manage_keywords.py || { echo "[warn] manage_keywords.py failed"; }
python scripts/build_queries.py   || { echo "[warn] build_queries.py failed"; }

# --- CWV/Lighthouse summarizer (greens optional via env) ---
INCLUDE_GREENS=${INCLUDE_GREENS:-0} \
python scripts/analyze_cwv.py || echo "[warn] analyze_cwv.py failed"

# --- quick surface counts so CI logs stay readable ---
[ -f outputs/queries_next.csv ] && echo "[info] queries_next rows: $(wc -l < outputs/queries_next.csv)"
[ -f data/keywords_master_next.csv ] && echo "[info] master_next rows: $(wc -l < data/keywords_master_next.csv)"
[ -f outputs/cwv_summary.csv ] && echo "[info] cwv_summary rows: $(wc -l < outputs/cwv_summary.csv)"

###############################################################################
# END R9 ADDITIONS
###############################################################################
