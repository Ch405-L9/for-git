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
        except Exception as e):
            out["ok"]=False; out["keywords_source_error"]=str(e)
    os.makedirs("./outputs/logs", exist_ok=True)
    with open("./outputs/logs/precheck.touch","w") as _:
        pass
    print(json.dumps(out)); sys.exit(0 if out["ok"] else 1)
if __name__=="__main__": main()
