# BADGR_BOT v9 — R9/R10 Enrichment + Autodoc (Beta)

Automation for lead discovery → contacts CSV → enrichment (Upgini or fallback) → autodoc.
Hardened for heredocs, Makefile TAB safety, and auto-venv activation.

## Features
- Lead capture via keyword configs in `configs/`
- Enrichment with Upgini (skips provider if rows < 100 or no key)
- Autodoc helper regenerates README and BUILD instructions
- Scripts auto-activate `.venv` when present
- Structured outputs under `outputs/`

## Setup
```bash
cd ~/badgr_bot
python3 -m venv .venv && . .venv/bin/activate && pip install --upgrade pip
pip install -r requirements.txt
pip install upgini pandas
Keys
bash
Copy code
export UPGINI_API_KEY="YOUR_KEY"
# or persist:
echo 'UPGINI_API_KEY=YOUR_KEY' >> .env
Run
bash
Copy code
make one_shot             # enrich + autodoc
bash scripts/enrich.sh    # enrich only
bash scripts/update_helpers_and_docs.sh  # autodoc only
Notes
Upgini requires ≥ 100 labeled rows after validation

Fallback preserves schema and passes postcheck

Do not commit .env or keys (see .gitignore)
