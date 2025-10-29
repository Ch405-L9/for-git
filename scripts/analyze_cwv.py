#!/usr/bin/env python3
import json, csv, glob, os, sys, datetime, html
from pathlib import Path

REPORTS_GLOB = "outputs/lighthouse/*.report.json"
REF_PATH      = "data/cwv_reference.json"
REF_SCHEMA    = "data/cwv_reference.schema.json"
OUT_CSV       = "outputs/cwv_summary.csv"
OUT_MD        = "outputs/cwv_summary.md"
OUT_HTML      = "outputs/cwv_summary.html"
LOG_DIR       = "outputs/logs"
WARN_LOG      = os.path.join(LOG_DIR, "audit-warnings.log")

ALIASES  = {"experimental-interaction-to-next-paint": "interaction-to-next-paint"}
SEVERITY = {"red": 2, "yellow": 1, "green": 0}

def color_for_score(score):
    try:
        s = float(score)
    except Exception:
        return "red"
    if s >= 0.9: return "green"
    if s >= 0.5: return "yellow"
    return "red"

def ensure_dirs():
    Path("outputs/lighthouse").mkdir(parents=True, exist_ok=True)
    Path(LOG_DIR).mkdir(parents=True, exist_ok=True)

def jload(p):
    with open(p, "r", encoding="utf-8") as f:
        return json.load(f)

def write_warn(line):
    Path(LOG_DIR).mkdir(parents=True, exist_ok=True)
    with open(WARN_LOG, "a", encoding="utf-8") as w:
        ts = datetime.datetime.now(datetime.timezone.utc).isoformat()
        w.write(f"{ts} {line}\n")

def validate_reference():
    try:
        ref = jload(REF_PATH)
        schema = jload(REF_SCHEMA)
        try:
            from jsonschema import validate, Draft202012Validator
            Draft202012Validator.check_schema(schema)
            validate(instance=ref, schema=schema)
            return ref, None
        except Exception as e:
            return ref, f"SCHEMA_FAIL {e}"
    except Exception as e:
        return {}, f"REF_READ_FAIL {e}"

def build_html(by_url):
    def badge(color, txt): return f'<span class="badge {color}">{html.escape(txt)}</span>'
    head = """<!doctype html><meta charset="utf-8"><title>CWV/Lighthouse Summary</title>
<style>
body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif;margin:24px}
h1{margin:0 0 12px} h2{margin:16px 0 8px}
.badge{display:inline-block;padding:2px 8px;border-radius:999px;font-size:12px;border:1px solid #ddd}
.red{background:#ffe6e6} .yellow{background:#fff7e0} .green{background:#e7ffe7}
.item{margin:6px 0}.meta{color:#555;font-size:12px}
</style><h1>CWV and Lighthouse Fail Summary</h1>"""
    parts=[head]
    for url, items in by_url.items():
        parts.append(f"<h2>{html.escape(url)}</h2>")
        for r in items:
            parts.append(
                f'<div class="item">{badge(r["color"], r["color"].upper())} '
                f'{html.escape(r["metric"])} — score {r["score"]}'
                f'{" — " + html.escape(str(r["display_value"])) if r.get("display_value") else ""}'
                f'<div class="meta">{html.escape(r.get("description",""))} | Pain: {html.escape(r.get("pain_point",""))}</div></div>'
            )
    return "\n".join(parts)

def main():
    ensure_dirs()
    ref, ref_err = validate_reference()
    if ref_err: write_warn(ref_err)

    include_greens = os.getenv("INCLUDE_GREENS", "0") == "1"
    rows=[]; now = datetime.datetime.now(datetime.timezone.utc).isoformat()
    report_paths = sorted(glob.glob(REPORTS_GLOB))
    if not report_paths:
        print("No Lighthouse reports found. Expected at outputs/lighthouse/*.report.json"); sys.exit(0)

    for path in report_paths:
        try:
            data = jload(path)
        except Exception as e:
            write_warn(f"READ_FAIL {path} {e}"); continue

        url = data.get("finalUrl") or data.get("requestedUrl") or "unknown"
        audits = data.get("audits", {})
        for key, audit in audits.items():
            score = audit.get("score")
            if not isinstance(score, (int,float)): continue
            canon_key = ALIASES.get(key, key)
            color = color_for_score(score)
            if not include_greens and color == "green": continue

            rows.append({
                "url": url,
                "metric": audit.get("title", canon_key),
                "audit_key": canon_key,
                "score": float(score),
                "color": color,
                "numeric_value": audit.get("numericValue"),
                "display_value": audit.get("displayValue"),
                "description": ref.get(canon_key, {}).get("description","N/A"),
                "pain_point": ref.get(canon_key, {}).get("pain_point","N/A"),
                "timestamp": now
            })

    rows.sort(key=lambda r: (SEVERITY[r["color"]], r["score"]))

    with open(OUT_CSV,"w",newline="",encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=[
            "url","metric","audit_key","score","color",
            "numeric_value","display_value","description","pain_point","timestamp"
        ])
        w.writeheader(); [w.writerow(r) for r in rows]

    with open(OUT_MD,"w",encoding="utf-8") as f:
        f.write("# CWV and Lighthouse Fail Summary\n\n")
        if not rows: f.write("All scored audits passed green.\n")
        else:
            by_url={}
            for r in rows: by_url.setdefault(r["url"],[]).append(r)
            for url, items in by_url.items():
                f.write(f"## {url}\n")
                for r in items:
                    dv = f" — {r['display_value']}" if r.get("display_value") else ""
                    f.write(f"- [{r['color'].upper()}] {r['metric']} — score {r['score']}{dv}\n")
                f.write("\n")

    by_url={}
    for r in rows: by_url.setdefault(r["url"],[]).append(r)
    with open(OUT_HTML,"w",encoding="utf-8") as f: f.write(build_html(by_url))

    print(f"CWV summary written → {OUT_CSV}")
    print(f"Markdown summary   → {OUT_MD}")
    print(f"HTML summary       → {OUT_HTML}")

if __name__ == "__main__":
    main()
