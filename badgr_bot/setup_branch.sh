#!/usr/bin/env bash
set -Eeuo pipefail

# ===== Config =====
REPO_URL="${REPO_URL:-https://github.com/Ch405-L9/for-git.git}"
BRANCH_NAME="${BRANCH_NAME:-badgr-bot}"
BOT_DIR="${BOT_DIR:-badgr_bot}"
LOG_DIR="${LOG_DIR:-${BOT_DIR}/outputs/logs}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/setup.log}"
VERBOSE="${VERBOSE:-1}"   # 1=on, 0=off
DRY_RUN="${DRY_RUN:-0}"   # 1=print only, no actions

# ===== Utils =====
ts(){ date -u +"%Y-%m-%dT%H:%M:%SZ"; }
say(){ echo "[$(ts)] $*"; }
run(){ if [[ "$DRY_RUN" == "1" ]]; then say "DRY: $*"; else eval "$@"; fi }
vexec(){ if [[ "$VERBOSE" == "1" ]]; then say "$*"; run "$@" 2>&1 | tee -a "$LOG_FILE"; else run "$@" >>"$LOG_FILE" 2>&1; fi }
abort(){ say "ERROR: $*"; exit 1; }

mkdir -p "$(dirname "$LOG_FILE")"; : > "$LOG_FILE" || true
say "Begin: setup_branch.sh (repo=$REPO_URL branch=$BRANCH_NAME bot_dir=$BOT_DIR)" | tee -a "$LOG_FILE"

command -v git >/dev/null || abort "git not found"
command -v python3 >/dev/null || abort "python3 not found"
command -v node >/dev/null || abort "node not found"
command -v npm >/dev/null || abort "npm not found"

# 1) clone or enter
if [[ ! -d "for-git/.git" ]]; then
  vexec git clone "$REPO_URL" for-git
fi
cd for-git

# 2) clean tree
if [[ -n "$(git status --porcelain)" ]]; then
  abort "Working tree not clean. Commit/stash first."
fi

# 3) branch
if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
  vexec git checkout "$BRANCH_NAME"
else
  vexec git checkout -b "$BRANCH_NAME"
fi

# 4) scaffold
mkdir -p "$BOT_DIR"/{configs,scripts,src/crew/tools,src/schemas,outputs/{logs,csv,lighthouse}}

# ---- Files (create if missing) ----
make_file(){ local p="$1"; shift; if [[ -f "$p" ]]; then say "Skip existing $p" | tee -a "$LOG_FILE"; else say "Create $p" | tee -a "$LOG_FILE"; cat > "$p" <<'EOF'
$CONTENT
EOF
fi }

# README.md
CONTENT='# badgr_bot (branch: badgr-bot)

Local, token-free CI-MAS bot:
- Phase 1: discover domains from GitHub keywords, run Lighthouse, export CSV with CWV + scores
- Phase 2: discover public B2B contacts, enrich CSV, prepare a short email draft for approval

Quick start:
- scripts/setup.sh
- scripts/run.sh (single pass)
- scripts/run_loop.sh (continuous, with backoff and logs)
'
make_file "$BOT_DIR/README.md"

# .gitignore
CONTENT='.venv/
__pycache__/
node_modules/
outputs/
.env
.DS_Store
'
make_file "$BOT_DIR/.gitignore"

# LICENSE (MIT minimal)
CONTENT='MIT License

Copyright (c)
Permission is hereby granted, free of charge, to any person obtaining a copy...
'
make_file "$BOT_DIR/LICENSE"

# requirements.txt (pinned for determinism)
CONTENT='crewai==0.58.0
pydantic==2.7.4
httpx==0.27.0
playwright==1.48.0
rich==13.9.2
ujson==5.10.0
python-json-logger==2.0.7
pyyaml==6.0.2
'
make_file "$BOT_DIR/requirements.txt"

# package.json
CONTENT='{
  "name": "badgr_bot",
  "private": true,
  "version": "0.1.0",
  "description": "Local, token-free CI-MAS for B2B audits and CSV export",
  "scripts": {
    "lh": "lighthouse --quiet --output=json --output-path=stdout",
    "prepare": "playwright install --with-deps || true"
  },
  "devDependencies": {
    "lighthouse": "^12.0.0"
  }
}
'
make_file "$BOT_DIR/package.json"

# Makefile
CONTENT='
.PHONY: setup run loop clean

setup:
\tpython3 -m venv .venv
\t. .venv/bin/activate && pip install -r requirements.txt
\tnpm install
\tpython -m playwright install --with-deps

run:
\t. .venv/bin/activate && python scripts/precheck.py && python src/main.py

loop:
\t. .venv/bin/activate && bash scripts/run_loop.sh

clean:
\trm -rf .venv node_modules outputs
'
make_file "$BOT_DIR/Makefile"

# configs/bot.config.yaml
CONTENT='keywords_source:
  type: github
  repo: "Ch405-L9/for-git"
  path: "data/keywords.txt"   # adjust if your path differs
  ref: "main"
targets:
  domains_file: ./configs/domains.txt
outputs:
  dir: ./outputs
  csv: ./outputs/csv/results.csv
  logs: ./outputs/logs/run.jsonl
  lh_dir: ./outputs/lighthouse
engine:
  model: llama3:8b-instruct-q4_K_M
  temperature: 0.1
  max_tokens: 2048
crawl:
  respect_robots: true
  max_depth: 2
  timeout_ms: 20000
lighthouse:
  throttling: "desktopDense4G"
  runs_per_url: 1
  categories: ["performance", "seo", "best-practices", "accessibility"]
quota:
  scans_per_day: 20
  concurrency: 2
retry_backoff:
  initial_ms: 1000
  max_ms: 15000
  factor: 2
'
make_file "$BOT_DIR/configs/bot.config.yaml"

# scripts/setup.sh
CONTENT='#!/usr/bin/env bash
set -Eeuo pipefail
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
npm install
python -m playwright install --with-deps
echo "Setup complete."
'
make_file "$BOT_DIR/scripts/setup.sh"; chmod +x "$BOT_DIR/scripts/setup.sh"

# scripts/run.sh
CONTENT='#!/usr/bin/env bash
set -Eeuo pipefail
. .venv/bin/activate
python scripts/precheck.py
python src/main.py "$@"
echo "Run complete. See outputs/."
'
make_file "$BOT_DIR/scripts/run.sh"; chmod +x "$BOT_DIR/scripts/run.sh"

# scripts/run_loop.sh
CONTENT='#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
BOT_DIR="${BOT_DIR:-$ROOT}"
LOG_DIR="${LOG_DIR:-$BOT_DIR/outputs/logs}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/loop.log}"
SLEEP_SEC="${SLEEP_SEC:-1800}"     # 30m default
MAX_ROUNDS="${MAX_ROUNDS:-0}"      # 0=infinite
VERBOSE="${VERBOSE:-1}"

ts(){ date -u +"%Y-%m-%dT%H:%M:%SZ"; }
loop_log(){ mkdir -p "$LOG_DIR"; echo "[$(ts)] $*" | tee -a "$LOG_FILE"; }

round=0
while :; do
  round=$((round+1))
  loop_log "Round ${round} start"

  if [[ -f "$BOT_DIR/scripts/run.sh" ]]; then
    if [[ "$VERBOSE" == "1" ]]; then
      bash "$BOT_DIR/scripts/run.sh" 2>&1 | tee -a "$LOG_FILE" || loop_log "Run failed"
    else
      bash "$BOT_DIR/scripts/run.sh" >>"$LOG_FILE" 2>&1 || loop_log "Run failed"
    fi
  else
    loop_log "Missing scripts/run.sh"
    exit 1
  fi

  loop_log "Round ${round} done."
  if [[ "$MAX_ROUNDS" -gt 0 && "$round" -ge "$MAX_ROUNDS" ]]; then
    loop_log "Reached MAX_ROUNDS=$MAX_ROUNDS. Exit."
    exit 0
  fi
  sleep "$SLEEP_SEC"
done
'
make_file "$BOT_DIR/scripts/run_loop.sh"; chmod +x "$BOT_DIR/scripts/run_loop.sh"

# scripts/precheck.py (hardened)
CONTENT='import json, sys, shutil, os, urllib.request, hashlib, yaml, time

REQUIRED_CMDS = ["node", "npm", "python", "npx"]
REQUIRED_PY = ["crewai", "pydantic", "playwright", "yaml"]

def which(cmd): return shutil.which(cmd) is not None
def fetch_github_raw(repo: str, path: str, ref: str="main") -> str:
    url = f"https://raw.githubusercontent.com/{repo}/{ref}/{path}"
    with urllib.request.urlopen(url, timeout=10) as r:
        return r.read().decode("utf-8")

def sha256_text(t: str) -> str:
    return hashlib.sha256(t.encode()).hexdigest()

def main():
    out = {"ok": True, "ts": int(time.time()), "checks": []}

    missing = [c for c in REQUIRED_CMDS if not which(c)]
    out["checks"].append({"name": "cmds", "missing": missing})
    if missing:
        out["ok"] = False

    try:
        import crewai, pydantic, playwright, yaml  # noqa
    except Exception as e:
        out["ok"] = False
        out["py_deps_error"] = str(e)

    if not os.path.exists("./configs/bot.config.yaml"):
        out["ok"] = False
        out["config"] = "bot.config.yaml missing"
        print(json.dumps(out))
        sys.exit(1)

    with open("./configs/bot.config.yaml","r",encoding="utf-8") as f:
        cfg = yaml.safe_load(f)
    ks = cfg.get("keywords_source", {})
    if ks.get("type") == "github":
        try:
            txt = fetch_github_raw(ks["repo"], ks["path"], ks.get("ref","main"))
            lines = [l for l in (txt.splitlines()) if l.strip()]
            out["keyword_lines"] = len(lines)
            if len(lines) < 3:
                out["ok"] = False
                out["keywords_source_error"] = "Too few keywords"
            out["keywords_sha256"] = sha256_text(txt)
        except Exception as e:
            out["ok"] = False
            out["keywords_source_error"] = str(e)

    # outputs writable?
    try:
        os.makedirs("./outputs/logs", exist_ok=True)
        with open("./outputs/logs/precheck.touch","w") as _:
            pass
    except Exception as e:
        out["ok"] = False
        out["outputs_writable"] = str(e)

    print(json.dumps(out))
    sys.exit(0 if out["ok"] else 1)

if __name__ == "__main__":
    main()
'
make_file "$BOT_DIR/scripts/precheck.py"

# src/schemas/records.py
CONTENT='from pydantic import BaseModel, HttpUrl, Field, EmailStr
from typing import Optional

class CWV(BaseModel):
    lcp_ms: int = Field(ge=0)
    cls: float = Field(ge=0)
    inp_ms: int = Field(ge=0)

class LighthouseScores(BaseModel):
    performance: float = Field(ge=0, le=100)
    seo: float = Field(ge=0, le=100)
    best_practices: float = Field(ge=0, le=100)
    accessibility: float = Field(ge=0, le=100)
    cwv: CWV

class Contact(BaseModel):
    name: Optional[str] = None
    role: Optional[str] = None
    email: Optional[EmailStr] = None
    source_url: Optional[HttpUrl] = None

class AuditRow(BaseModel):
    run_id: str
    domain: str
    page_url: HttpUrl
    lighthouse: LighthouseScores
    contact_primary: Optional[Contact] = None
    contact_secondary: Optional[Contact] = None
    b2b_owner_flag: Optional[bool] = None
    email_draft: Optional[str] = None
'
make_file "$BOT_DIR/src/schemas/records.py"

# src/crew/tools/audit_logger.py (JSONL with config/code hashes)
CONTENT='import json, hashlib, time, os
from typing import Any, Dict

def _hash(payload: Dict[str, Any]) -> str:
    return hashlib.sha256(json.dumps(payload, sort_keys=True, ensure_ascii=False).encode()).hexdigest()

def log_event(out_path: str, run_id: str, step: str, tool: str, data: Dict[str, Any], extra: Dict[str, Any] | None=None) -> None:
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    entry = {
        "ts": int(time.time() * 1000),
        "run_id": run_id,
        "step": step,
        "tool": tool,
        "hash": _hash(data),
        "data": data,
    }
    if extra:
        entry.update(extra)
    with open(out_path, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")
'
make_file "$BOT_DIR/src/crew/tools/audit_logger.py"

# src/crew/tools/robots_guard.py
CONTENT='import urllib.request, urllib.parse, time

def robots_allows(url: str, user_agent: str = "Mozilla/5.0") -> bool:
    try:
        parts = urllib.parse.urlparse(url if url.startswith("http") else "https://" + url)
        base = f"{parts.scheme}://{parts.netloc}"
        robots_url = urllib.parse.urljoin(base, "/robots.txt")
        req = urllib.request.Request(robots_url, headers={"User-Agent": user_agent})
        with urllib.request.urlopen(req, timeout=6) as resp:
            txt = resp.read().decode("utf-8", errors="ignore").lower()
        # naive allow (we respect robots by avoiding disallowed paths; homepages are typically allowed)
        # if robots explicitly blocks all, skip.
        if "user-agent: *" in txt and "disallow: /" in txt:
            return False
        return True
    except Exception:
        # if robots not reachable, err on the side of allow for homepage only
        return True
'
make_file "$BOT_DIR/src/crew/tools/robots_guard.py"

# src/crew/tools/domain_finder.py (GH keywords, dedupe, backoff)
CONTENT='from playwright.sync_api import sync_playwright
from urllib.parse import urlparse, quote_plus
import time, os, re, urllib.request, yaml, random, json, hashlib

DDG = "https://duckduckgo.com/?q={q}&kl=us-en"

def extract_domain(u: str) -> str:
    try: return urlparse(u).netloc.replace("www.","")
    except: return ""

def _fetch_keywords_from_github(repo: str, path: str, ref: str="main") -> list[str]:
    url = f"https://raw.githubusercontent.com/{repo}/{ref}/{path}"
    with urllib.request.urlopen(url, timeout=15) as r:
        text = r.read().decode("utf-8")
    return [k.strip() for k in text.splitlines() if k.strip()]

def _seen_path()->str: return "./outputs/seen_domains.txt"

def _load_seen()->set[str]:
    p = _seen_path()
    if os.path.exists(p):
        with open(p,"r",encoding="utf-8") as f:
            return set(l.strip() for l in f if l.strip())
    return set()

def _save_seen(seen:set[str])->None:
    with open(_seen_path(),"w",encoding="utf-8") as f:
        for d in sorted(seen):
            f.write(d+"\n")

def load_keywords_from_config(config_path: str="./configs/bot.config.yaml") -> list[str]:
    with open(config_path,"r",encoding="utf-8") as f:
        cfg = yaml.safe_load(f)
    ks = cfg.get("keywords_source", {})
    if ks.get("type") == "github":
        return _fetch_keywords_from_github(ks["repo"], ks["path"], ks.get("ref","main"))
    local_path = "./configs/keywords.txt"
    if os.path.exists(local_path):
        with open(local_path,"r",encoding="utf-8") as f:
            return [k.strip() for k in f if k.strip()]
    return []

def find_domains_from_keywords(config_path: str, out_domains_file: str, max_per_kw: int = 10):
    os.makedirs(os.path.dirname(out_domains_file), exist_ok=True)
    seen = _load_seen()
    # preload existing domains list
    if os.path.exists(out_domains_file):
        with open(out_domains_file, "r", encoding="utf-8") as f:
            seen.update([l.strip() for l in f if l.strip()])

    keywords = load_keywords_from_config(config_path)
    if not keywords:
        return []

    results = []
    backoff_ms = 1000
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        for kw in keywords:
            try:
                page.goto(DDG.format(q=quote_plus(kw)), wait_until="domcontentloaded", timeout=20000)
                links = page.locator("a.result__a, a[data-testid=\'result-title-a\']")
                n = links.count()
                count = min(n, max_per_kw)
                for i in range(count):
                    href = links.nth(i).get_attribute("href") or ""
                    d = extract_domain(href)
                    if d and d not in seen and not re.search(r"(facebook|twitter|linkedin|youtube|pinterest)", d):
                        results.append(d)
                        seen.add(d)
                time.sleep(0.6)
                backoff_ms = max(1000, int(backoff_ms/2))  # cool down if success
            except Exception:
                time.sleep(backoff_ms/1000.0)
                backoff_ms = min(15000, backoff_ms * 2)
                continue
        browser.close()

    if results:
        with open(out_domains_file, "a", encoding="utf-8") as f:
            for d in results:
                f.write(d + "\n")
        _save_seen(seen)
    return results
'
make_file "$BOT_DIR/src/crew/tools/domain_finder.py"

# src/crew/tools/lighthouse_tool.py
CONTENT='import json, subprocess, tempfile, os
from typing import Dict, Any
from src.crew.tools.audit_logger import log_event

def run_lighthouse(url: str, out_dir: str, run_id: str, npx_bin: str = "npx") -> Dict[str, Any]:
    os.makedirs(out_dir, exist_ok=True)
    with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as tmp:
        cmd = [npx_bin, "lighthouse", url, "--quiet", "--output=json", f"--output-path={tmp.name}"]
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if res.returncode != 0:
            raise RuntimeError(f"Lighthouse failed: {res.stderr[:200]}")
        with open(tmp.name, "r", encoding="utf-8") as f:
            report = json.load(f)
    log_event(os.path.join(out_dir, "..", "logs", "run.jsonl"), run_id, "scan", "lighthouse", {"url": url})
    return report
'
make_file "$BOT_DIR/src/crew/tools/lighthouse_tool.py"

# src/crew/tools/scraper_tool.py
CONTENT='from playwright.sync_api import sync_playwright
from src.crew.tools.audit_logger import log_event
import os

def snapshot(url: str, out_dir: str, run_id: str, user_agent: str | None = None) -> str:
    os.makedirs(out_dir, exist_ok=True)
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(user_agent=user_agent)
        page.goto(url, wait_until="domcontentloaded", timeout=20000)
        path = os.path.join(out_dir, "snapshot.html")
        with open(path, "w", encoding="utf-8") as f:
            f.write(page.content())
        browser.close()
    log_event(os.path.join(out_dir, "..", "logs", "run.jsonl"), run_id, "crawl", "playwright", {"url": url})
    return path
'
make_file "$BOT_DIR/src/crew/tools/scraper_tool.py"

# src/crew/tools/contact_finder.py
CONTENT='from playwright.sync_api import sync_playwright
from urllib.parse import urljoin
import re

EMAIL_RE = re.compile(r"[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}", re.I)
ROLE_HINTS = ["marketing", "growth", "business development", "sales", "partnership", "operations", "owner", "founder", "ceo"]
CANDIDATE_PATHS = ["", "contact", "about", "team", "leadership", "company"]

def fetch_contacts(base_url: str, max_pages: int = 4):
    contacts = []
    visited = set()
    with sync_playwright() as p:
        b = p.chromium.launch(headless=True)
        page = b.new_page()
        base = base_url if base_url.startswith("http") else f"https://{base_url}"
        for path in CANDIDATE_PATHS[:max_pages]:
            u = urljoin(base if base.endswith("/") else base + "/", path)
            if u in visited: continue
            visited.add(u)
            try:
                page.goto(u, wait_until="domcontentloaded", timeout=20000)
                html = page.content()
            except:
                continue
            emails = set(m.group(0) for m in EMAIL_RE.finditer(html))
            text = page.inner_text("body")
            chunks = re.split(r"[\\n\\r]+", text)
            for e in emails:
                role = None
                name = None
                for c in chunks:
                    if e in c and not name:
                        nm = re.search(r"([A-Z][a-z]+ [A-Z][a-z]+)", c)
                        if nm: name = nm.group(1)
                    if any(h in c.lower() for h in ROLE_HINTS) and not role:
                        role = c.strip()[:120]
                contacts.append({"email": e, "name": name, "role": role, "source_url": u})
        b.close()
    uniq = {}
    for c in contacts:
        uniq[c["email"].lower()] = c
    return list(uniq.values())
'
make_file "$BOT_DIR/src/crew/tools/contact_finder.py"

# src/crew/tools/email_drafter.py
CONTENT='def draft_b2b_email(company: str, domain: str, issues: dict) -> str:
    lines = []
    lines.append(f"Subject: Quick win ideas for {company} website performance")
    lines.append("")
    lines.append(f"Hi team at {company},")
    lines.append("")
    lines.append("Quick findings from a non-intrusive audit:")
    bullets = []
    bullets.append(f"- Performance score: {issues.get(\'performance\',\'?\')}")
    bullets.append(f"- SEO score: {issues.get(\'seo\',\'?\')}")
    bullets.append(f"- Accessibility: {issues.get(\'accessibility\',\'?\')}")
    bullets.append(f"- Best Practices: {issues.get(\'best_practices\',\'?\')}")
    if issues.get("notes"):
        bullets.append(f"- Notes: {issues[\'notes\'][:140]}...")
    lines += bullets
    lines.append("")
    lines.append("If helpful, I can share a 15-minute walk-through with fixes prioritized by impact and effort, with one-time or monthly options.")
    lines.append("")
    lines.append(f"Would you like a quick demo using {domain}?")
    lines.append("")
    lines.append("Regards,")
    lines.append("A. D. Grant")
    return "\\n".join(lines)
'
make_file "$BOT_DIR/src/crew/tools/email_drafter.py"

# src/crew/agents.py
CONTENT='from src.schemas.records import AuditRow, LighthouseScores, CWV
from src.crew.tools.lighthouse_tool import run_lighthouse

def audit_domain(url: str, out_dir: str, run_id: str) -> AuditRow:
    lh = run_lighthouse(url, out_dir, run_id)
    scores = LighthouseScores(
        performance=lh["categories"]["performance"]["score"]*100,
        seo=lh["categories"]["seo"]["score"]*100,
        best_practices=lh["categories"]["best-practices"]["score"]*100,
        accessibility=lh["categories"]["accessibility"]["score"]*100,
        cwv=CWV(
            lcp_ms=int(lh["audits"]["largest-contentful-paint"]["numericValue"]),
            cls=float(lh["audits"]["cumulative-layout-shift"]["numericValue"]),
            inp_ms=int(lh["audits"]["interaction-to-next-paint"]["numericValue"])
        )
    )
    return AuditRow(run_id=run_id, domain=url.split("/")[2], page_url=url, lighthouse=scores)
'
make_file "$BOT_DIR/src/crew/agents.py"

# src/main.py (run_id, robots, backoff)
CONTENT='import os, sys, time, uuid
from src.crew.agents import audit_domain
from src.crew.tools.csv_writer import write_csv
from src.schemas.records import AuditRow, Contact
from src.crew.tools.domain_finder import find_domains_from_keywords
from src.crew.tools.contact_finder import fetch_contacts
from src.crew.tools.email_drafter import draft_b2b_email
from src.crew.tools.robots_guard import robots_allows
from src.crew.tools.audit_logger import log_event

OUT_CSV = "./outputs/csv/results.csv"
DOMAINS_FILE = "./configs/domains.txt"
LH_DIR = "./outputs/lighthouse"
LOGS = "./outputs/logs/run.jsonl"

def run_phase1(run_id: str):
    find_domains_from_keywords("./configs/bot.config.yaml", DOMAINS_FILE)
    urls = []
    if os.path.exists(DOMAINS_FILE):
        with open(DOMAINS_FILE, "r", encoding="utf-8") as f:
            urls = [("https://" + d.strip()) if not d.startswith("http") else d.strip() for d in f if d.strip()]
    rows = []
    for u in urls:
        dom = u.split("/")[2]
        if not robots_allows(dom):
            log_event(LOGS, run_id, "guard", "robots", {"domain": dom}, {"decision": "skip"})
            continue
        try:
            row = audit_domain(u, LH_DIR, run_id)
            rows.append(row)
            log_event(LOGS, run_id, "audit", "lighthouse", {"url": u})
        except Exception as e:
            log_event(LOGS, run_id, "error", "lighthouse", {"url": u, "error": str(e)})
    return rows

def run_phase2(run_id: str, rows: list[AuditRow]) -> list[AuditRow]:
    enriched = []
    for r in rows:
        domain = r.domain
        base_url = f"https://{domain}"
        try:
            contacts = fetch_contacts(base_url)
        except Exception as e:
            log_event(LOGS, run_id, "error", "contacts", {"domain": domain, "error": str(e)})
            contacts = []
        c1 = contacts[0] if contacts else None
        c2 = contacts[1] if len(contacts) > 1 else None
        if c1:
            r.contact_primary = Contact(**{k: c1.get(k) for k in ["name","role","email","source_url"]})
        if c2:
            r.contact_secondary = Contact(**{k: c2.get(k) for k in ["name","role","email","source_url"]})
        r.b2b_owner_flag = any(
            (c.get("role") or "").lower().find("partnership") >= 0 or
            (c.get("role") or "").lower().find("business") >= 0 or
            (c.get("role") or "").lower().find("marketing") >= 0
            for c in contacts
        )
        scores = r.lighthouse.model_dump()
        issues = {
            "performance": scores["performance"],
            "seo": scores["seo"],
            "accessibility": scores["accessibility"],
            "best_practices": scores["best_practices"],
        }
        r.email_draft = draft_b2b_email(domain.split(".")[0].title(), domain, issues)
        enriched.append(r)
        log_event(LOGS, run_id, "enrich", "contacts+email", {"domain": domain, "contacts_found": len(contacts)})
    return enriched

def main():
    os.makedirs("./outputs/csv", exist_ok=True)
    run_id = uuid.uuid4().hex[:12]
    log_event(LOGS, run_id, "start", "badgr_bot", {"argv": sys.argv})
    p1_rows = run_phase1(run_id)
    p2_rows = run_phase2(run_id, p1_rows)
    write_csv(p2_rows, OUT_CSV)
    log_event(LOGS, run_id, "finish", "badgr_bot", {"rows": len(p2_rows)})
    print(f"Complete. CSV at {OUT_CSV}")

if __name__ == "__main__":
    main()
'
make_file "$BOT_DIR/src/main.py"

# src/crew/tools/csv_writer.py (unchanged)
CONTENT='import csv, os
from typing import Iterable
from src.schemas.records import AuditRow

def write_csv(rows: Iterable[AuditRow], path: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    rows = list(rows)
    if not rows: return
    header = rows[0].model_dump().keys()
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=header)
        w.writeheader()
        for r in rows:
            w.writerow(r.model_dump())
'
make_file "$BOT_DIR/src/crew/tools/csv_writer.py"

# 5) install deps once (optional here, you can run later)
( cd "$BOT_DIR" && vexec bash scripts/setup.sh )

# 6) commit & push
vexec git add .
vexec git commit -m "badgr_bot: scaffold with GH keywords, robots guard, backoff, JSONL logs, run loop"
vexec git push -u origin "$BRANCH_NAME"

say "Done: branch '$BRANCH_NAME' pushed with scaffold at $BOT_DIR" | tee -a "$LOG_FILE"
