
Commands
Create and activate venv
python3 -m venv .venv && . .venv/bin/activate && pip install --upgrade pip

Install deps
pip install -r requirements.txt
pip install upgini pandas

Keys
export UPGINI_API_KEY="YOUR_KEY"
echo 'UPGINI_API_KEY=YOUR_KEY' >> .env

Collect
bash scripts/run_collect.sh

or:
python tools/collect_contacts.py --out outputs/contacts/contacts.csv --keywords configs/keywords.us.nationwide.json

Enrich + Autodoc
make one_shot

SHN stamp
ts="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
jq --arg ts "$ts" '
.shn_id |= (. + $ts) |
.timeline_utc.start |= $ts |
.timeline_utc.end |= $ts
' shn/BADGR_BOT-R9-Enrichment_Autodoc-SHN.json | sponge shn/BADGR_BOT-R9-Enrichment_Autodoc-SHN.json
