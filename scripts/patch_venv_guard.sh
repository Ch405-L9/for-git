#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

BLOCK='
# --- auto-venv guard (inserted by patch_venv_guard.sh) ---
cd "$(dirname "$0")/.." >/dev/null 2>&1 || true
if [ -f ".venv/bin/activate" ]; then
  # shellcheck disable=SC1091
  . ".venv/bin/activate"
fi
# ---------------------------------------------------------
'

# Target scripts to patch (add any others you want)
TARGETS=(
  scripts/enrich.sh
  scripts/update_helpers_and_docs.sh
  scripts/run.sh
  scripts/run_loop.sh
  scripts/preflight_contacts.sh
  scripts/preflight_v2.sh
  scripts/postcheck_enrichment.sh
  scripts/postcheck_contacts.sh
  scripts/osint_fallback.sh
  scripts/setup.sh
)

patch_one() {
  local f="$1"
  [ -f "$f" ] || return 0
  # Skip if already patched
  if grep -q 'auto-venv guard' "$f" || grep -q '\.venv/bin/activate' "$f"; then
    echo "[=] Already has venv guard: $f"
    return 0
  fi
  # Ensure executable shebang exists
  read -r first < "$f" || true
  if [[ "$first" =~ ^#!/ ]]; then
    awk -v blk="$BLOCK" 'NR==1{print; print blk; next} {print}' "$f" > "$f.tmp"
  else
    { echo '#!/usr/bin/env bash'; echo 'set -Eeuo pipefail'; echo "$BLOCK"; cat "$f"; } > "$f.tmp"
    chmod +x "$f.tmp"
  fi
  mv "$f.tmp" "$f"
  chmod +x "$f"
  echo "[+] Patched venv guard: $f"
}

for s in "${TARGETS[@]}"; do
  patch_one "$s"
done

echo "[✓] Done. Scripts will auto-activate .venv when present."
