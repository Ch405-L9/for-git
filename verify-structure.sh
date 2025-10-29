#!/usr/bin/env bash
set -euo pipefail
missing=0
for p in src src/components src/styles src/main.tsx src/App.tsx src/components/OrderModal.tsx src/components/ToastEmbed.tsx src/styles/tokens.css; do
  if [[ ! -e "$p" ]]; then echo "Missing: $p"; missing=1; fi
done
grep -q '/src/main.tsx' index.html || { echo "index.html not pointing to /src/main.tsx"; missing=1; }
exit $missing
