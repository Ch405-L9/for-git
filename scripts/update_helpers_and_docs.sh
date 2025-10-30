#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

echo "[+] Generating helper scripts, README, and BUILD instructions..."

# -----------------------------
# 1) scripts/enrich.sh helper
# -----------------------------
mkdir -p scripts
cat <<"ENRICH_SCRIPT" > scripts/enrich.sh
#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

# activate venv if present
if [[ -f .venv/bin/activate ]]; then
  # shellcheck disable=SC1091
  source .venv/bin/activate
fi

INPUT="${1:-outputs/contacts/contacts.csv}"
OUTPUT="${2:-outputs/enriched/enriched.csv}"
PROVIDER="${3:-upgini}"
KEYS="${4:-EMAIL}"

python scripts/enrich_contacts.py \
  --input_path "$INPUT" \
  --output_path "$OUTPUT" \
  --provider "$PROVIDER" \
  --search_keys "$KEYS"

./scripts/postcheck_enrichment.sh "$OUTPUT"
ENRICH_SCRIPT
chmod +x scripts/enrich.sh

# -----------------------------
# 2) .env.example
# -----------------------------
cat <<"ENV_EXAMPLE" > .env.example
# Copy to .env and replace with your actual Upgini API key (keep out of Git)
UPGINI_API_KEY=replace_me
ENV_EXAMPLE

# -----------------------------
# 3) Makefile
# -----------------------------
cat <<"MAKEFILE_CONTENT" > Makefile
.PHONY: venv upgini enrich clean

venv:
	python3 -m venv .venv && . .venv/bin/activate && pip install --upgrade pip

upgini:
	. .venv/bin/activate && pip install pandas upgini

enrich:
	./scripts/enrich.sh outputs/contacts/contacts.csv outputs/enriched/enriched.csv upgini EMAIL

clean:
	rm -rf outputs/enriched/enriched.csv
MAKEFILE_CONTENT

# -----------------------------
# 4) README.md (auto-doc for GitHub)
# -----------------------------
cat <<"README_CONTENT" > README.md
# BADGR_BOT – R9 Enrichment Phase (Automated Report)

## Overview
This build finalizes the R9 phase of BADGR_BOT, focusing on **lead enrichment** using the Upgini API and local automation helpers.
All modules and dependencies were validated under **Python 3.12.3** inside a clean \`.venv\`.

## Key Fixes & Milestones
| Step | Description | Result |
|------|-------------|--------|
| 1 | Fixed missing \`pandas\` in isolated venv | Successful import |
| 2 | Installed Cairo and build deps for Upgini's PDF chain | Upgini installed cleanly |
| 3 | Corrected \`FeaturesEnricher\` call (expects dict of column→SearchKey) | No constructor errors |
| 4 | Added non-constant synthetic target \`y\` (from email hash) | Passed Upgini validation |
| 5 | Validated with 2 unique test emails | Enrichment executed |
| 6 | Added helper scripts, Makefile, and auto-documentation | Automation in place |

## Commands

### Setup Environment
\`\`\`bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas upgini
export UPGINI_API_KEY="your_key_here"
\`\`\`

### Run Enrichment
\`\`\`bash
make enrich
\`\`\`

### Validate
\`\`\`bash
./scripts/postcheck_enrichment.sh outputs/enriched/enriched.csv
\`\`\`

### Full Automation
\`\`\`bash
./scripts/update_helpers_and_docs.sh
git add .
git commit -m "auto: refresh helpers + docs"
git push
\`\`\`

## Files Created
| File | Purpose |
|------|---------|
| scripts/enrich.sh | CLI wrapper for enrichment |
| .env.example | API key template |
| Makefile | Simplified task runner |
| README.md | Build log for GitHub |
| BUILD_INSTRUCTIONS.txt | Local offline reference |

## Validation Summary
- Python 3.12.3 ✓
- Upgini 1.2.x integrated ✓
- CSV → Enriched CSV pipeline verified ✓
- Robust fallback on missing/insufficient data ✓
- Reproducible with one command (\`make enrich\`) ✓
README_CONTENT

# -----------------------------
# 5) BUILD_INSTRUCTIONS.txt (local reference)
# -----------------------------
cat <<"BUILD_INSTRUCTIONS" > BUILD_INSTRUCTIONS.txt
BADGR_BOT – LOCAL BUILD INSTRUCTIONS
Environment: Python 3.12.3 + .venv
Provider: Upgini API

Quick setup:
  python3 -m venv .venv
  source .venv/bin/activate
  pip install pandas upgini
  export UPGINI_API_KEY="your_key_here"

Run enrichment:
  make enrich

Validate:
  ./scripts/postcheck_enrichment.sh outputs/enriched/enriched.csv

Commit results:
  git switch -c r9-enrichment-final || git switch r9-enrichment-final
  git add .
  git commit -m "R9: enrichment final + helpers"
  git push -u origin r9-enrichment-final
BUILD_INSTRUCTIONS

echo "[+] Helpers, README, and BUILD_INSTRUCTIONS updated."
