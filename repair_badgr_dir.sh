#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -z "$REPO_ROOT" ] && { echo "cd into your repo root (~/for-git) first."; exit 1; }
cd "$REPO_ROOT"

BRANCH_NAME="${BRANCH_NAME:-badgr-bot}"
BOT_DIR="${BOT_DIR:-badgr_bot}"
LOG_DIR="$BOT_DIR/outputs/logs"
LOG_FILE="$LOG_DIR/setup.log"
mkdir -p "$LOG_DIR"; : > "$LOG_FILE" || true

ts(){ date -u +"%Y-%m-%dT%H:%M:%SZ"; }
say(){ echo "[$(ts)] $*"; }
note(){ echo "[$(ts)] $*" | tee -a "$LOG_FILE"; }

git fetch --all -p >>"$LOG_FILE" 2>&1 || true
git checkout -B "$BRANCH_NAME" | tee -a "$LOG_FILE"

mkdir -p "$BOT_DIR"/{configs,scripts,src/crew/tools,src/schemas,outputs/{logs,csv,lighthouse}}

# seeds (only if missing)
seed(){ local p="$1"; shift; [ -f "$p" ] && note "keep $p" || { printf "%s\n" "$*" > "$p"; note "write $p"; }; }

seed "$BOT_DIR/requirements.txt" "crewai==0.58.0
pydantic==2.7.4
httpx==0.27.0
playwright==1.48.0
rich==13.9.2
ujson==5.10.0
python-json-logger==2.0.7
pyyaml==6.0.2"

seed "$BOT_DIR/package.json" '{"name":"badgr_bot","private":true,"version":"0.1.0","description":"Local token-free CI-MAS","scripts":{"lh":"lighthouse --quiet --output=json --output-path=stdout","prepare":"playwright install --with-deps || true"},"devDependencies":{"lighthouse":"^12.0.0"}}'

seed "$BOT_DIR/configs/bot.config.yaml" "keywords_source:
  type: github
  repo: \"Ch405-L9/for-git\"
  path: \"data/keywords.txt\"
  ref: \"main\"
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
  throttling: \"desktopDense4G\"
  runs_per_url: 1
  categories: [\"performance\",\"seo\",\"best-practices\",\"accessibility\"]
quota:
  scans_per_day: 20
  concurrency: 2
retry_backoff:
  initial_ms: 1000
  max_ms: 15000
  factor: 2"

# minimal precheck + setup
cat > "$BOT_DIR/scripts/precheck.py" <<'PY'
import json, sys, shutil, os, urllib.request, hashlib, yaml, time
REQUIRED_CMDS = ["node", "npm", "python", "npx"]
def which(c): return shutil.which(c) is not None
def fetch_raw(repo, path, ref="main"):
    url = f"https://raw.githubusercontent.com/{repo}/{ref}/{path}"
    with urllib.request.urlopen(url, timeout=10) as r:
        return r.read().decode("utf-8")
def sha256_text(t): import hashlib; return hashlib.sha256(t.encode()).hexdigest()
def main():
    out={"ok":True,"ts":int(time.time()),"checks":[]}
    miss=[c for c in REQUIRED_CMDS if not which(c)]
    out["checks"].append({"cmds_missing":miss})
    if miss: out["ok"]=False
    try: import crewai, pydantic, playwright, yaml  # noqa
    except Exception as e: out["ok"]=False; out["py_deps_error"]=str(e)
    if not os.path.exists("./configs/bot.config.yaml"):
        out["ok"]=False; out["config"]="bot.config.yaml missing"; print(json.dumps(out)); sys.exit(1)
    with open("./configs/bot.config.yaml","r",encoding="utf-8") as f:
        cfg=yaml.safe_load(f)
    ks=cfg.get("keywords_source",{})
    if ks.get("type")=="github":
        try:
            txt=fetch_raw(ks["repo"], ks["path"], ks.get("ref","main"))
            lines=[l for l in txt.splitlines() if l.strip()]
            out["keyword_lines"]=len(lines)
            if len(lines)<3: out["ok"]=False; out["keywords_source_error"]="Too few keywords"
            out["keywords_sha256"]=sha256_text(txt)
        except Exception as e:
            out["ok"]=False; out["keywords_source_error"]=str(e)
    os.makedirs("./outputs/logs", exist_ok=True)
    with open("./outputs/logs/precheck.touch","w") as _:
        pass
    print(json.dumps(out)); sys.exit(0 if out["ok"] else 1)
if __name__=="__main__": main()
PY

cat > "$BOT_DIR/scripts/setup.sh" <<'BASH'
#!/usr/bin/env bash
set -Eeuo pipefail
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
npm install
python -m playwright install --with-deps
echo "Setup complete."
BASH
chmod +x "$BOT_DIR/scripts/setup.sh"

cat > "$BOT_DIR/scripts/run.sh" <<'BASH'
#!/usr/bin/env bash
set -Eeuo pipefail
. .venv/bin/activate
python scripts/precheck.py
python src/main.py "$@"
echo "Run complete. See outputs/."
BASH
chmod +x "$BOT_DIR/scripts/run.sh"

echo "[setup] installing deps…" | tee -a "$LOG_FILE"
( cd "$BOT_DIR" && bash scripts/setup.sh ) | tee -a "$LOG_FILE" || true

git add .
git commit -m "badgr_bot: safe scaffold + precheck" || true
git status --short
echo "[setup] done → $BOT_DIR"
