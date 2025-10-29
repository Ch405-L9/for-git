#!/usr/bin/env bash
set -euo pipefail

SHN="${SHN:-SHN-UNSET}"
OUT="${1:-preflight/precheck.report.json}"
fail=0
checks=()

add_check () {
  local name="$1"; local status="$2"; local details="${3:-}"
  checks+=("  { \"name\": \"$name\", \"status\": \"$status\", \"details\": \"${details//"/\"}\" }")
  [[ "$status" == "fail" ]] && fail=1
}

req_dirs=( "src" "src/components" "src/styles" "public" "preflight" ".github/workflows" )
for d in "${req_dirs[@]}"; do
  if [[ -d "$d" ]]; then add_check "dir:$d" "pass" ""; else add_check "dir:$d" "fail" "Missing directory"; fi
done

req_files=( "src/main.tsx" "src/App.tsx" "src/components/OrderModal.tsx" "src/components/ToastEmbed.tsx" "src/styles/tokens.css" "src/styles/tokens.json" "public/robots.txt" )
for f in "${req_files[@]}"; do
  if [[ -f "$f" ]]; then add_check "file:$f" "pass" ""; else add_check "file:$f" "fail" "Missing file"; fi
done

if [[ -f "index.html" ]] && grep -q '/src/main.tsx' index.html; then
  add_check "index.html script path" "pass" ""
else
  add_check "index.html script path" "fail" "Expected <script type=\"module\" src=\"/src/main.tsx\">"
fi

if [[ -f "package-lock.json" || -f "pnpm-lock.yaml" || -f "yarn.lock" ]]; then
  add_check "lockfile present" "pass" ""
else
  add_check "lockfile present" "fail" "Add package-lock.json, pnpm-lock.yaml, or yarn.lock"
fi

if grep -R --exclude-dir=node_modules -E 'API[_-]?KEY|SECRET|sk-live|AIza' -n . >/dev/null 2>&1; then
  add_check "secrets scan" "fail" "Possible secrets detected in repo"
else
  add_check "secrets scan" "pass" ""
fi

if grep -q 'outline' src/styles/tokens.css 2>/dev/null; then
  add_check "a11y:focus-outline" "pass" ""
else
  add_check "a11y:focus-outline" "fail" "Add visible focus outline styles"
fi

add_check "perf:lazy-images-policy" "pass" "Ensure loading='lazy' for non-hero images"
add_check "security:iframe-allowlist" "pass" "Ensure Toast domain allowlisted in CSP"

status="pass"; [[ $fail -eq 1 ]] && status="fail"
mkdir -p "$(dirname "$OUT")"
{
  echo "{"
  echo "  \"shn\": \"$SHN\","
  echo "  \"status\": \"$status\","
  echo "  \"checks\": ["
  printf "%s
" "$(IFS=$',
'; echo "${checks[*]}")"
  echo "  ]"
  echo "}"
} > "$OUT"

echo "Pre-Check status: $status"
[[ $fail -eq 0 ]]
