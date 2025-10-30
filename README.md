# BADGR_BOT · Phase R8→R9 — Lead Capture (Collector → Formatter → Postcheck)

Operational status: **Stable**. This repo extracts first-party contacts from target domains and emits both structured JSON and a tidy CSV suitable for CRM import.

## What’s included
- **Collector**: HTTP-first discovery of org/name/email/phone/address/socials (JSON-LD + mailto/tel + deobfuscation + NER + anchor scan).
- **Formatter**: Normalizes address into one line; aggregates socials as comma-separated.
- **Postcheck**: Verifies presence, headers, row counts, and JSON shape before downstream use.

## Requirements
- Linux Mint/Ubuntu x86_64
- Python 3.12 (venv)
- Node ≥ 20.x (only needed if JS rendering via Playwright)
- Chrome stable on PATH
- Repo root: `/home/t0n34781/badgr_bot`

## Usage
```bash
# 1) Seed your targets
echo "https://example.com" > urls.txt

# 2) Run collector → formatter
./scripts/run_collect.sh urls.txt

# 3) Verify artifacts
./scripts/postcheck_contacts.sh
Outputs
outputs/contacts/contacts.json — structured capture

outputs/contacts/contacts.csv — spreadsheet-ready (single address block, socials CSV)

Flags
CONTACT_DEFAULT_REGION=US (override per run)

RENDER_JS=1 enables Playwright fallback (default 0)

Performance & Integrity
Default run is HTTP-first for speed; JS render only when required.

Backoff delay ~0.4s for polite crawling.

CSV column order and formatting are deterministic.

Known limits
Icon-only socials that render via JS may require RENDER_JS=1.

Roadmap (R9)
Evaluate open alternatives to Apollo/Clearbit for enrichment.

Optional hashing of outputs for CI traceability.

— SHN: BADGR_BOT-R8-LeadCapture_vFinal-2025-10-30T06:00:00Z
