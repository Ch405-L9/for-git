#!/usr/bin/env python3
# postmortem.py – final version (env key only, EOF-marked)
import argparse, base64, csv, json, os, re, shutil, sys, time
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any, Optional

# OpenAI SDK (env: OPENAI_API_KEY)
try:
    from openai import OpenAI
except Exception:
    print("pip install openai", file=sys.stderr)
    raise

TEXT_MODEL = os.getenv("OPENAI_TEXT_MODEL", "gpt-4o")
TRANSCRIBE_MODEL = os.getenv("OPENAI_STT_MODEL", "gpt-4o-transcribe")
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# Config
MAX_CORPUS_SLICE = int(os.getenv("POSTMORTEM_MAX_SLICE", "40000"))
MAX_TOTAL_CHARS = int(os.getenv("POSTMORTEM_MAX_TOTAL", "800000"))
RETRY_MAX = 5
RETRY_BASE = 1.4

IMG_EXT = {".png", ".jpg", ".jpeg", ".webp"}
AUDIO_EXT = {".wav", ".mp3", ".m4a", ".ogg"}
TEXT_EXT = {".txt", ".md", ".log", ".json"}

SUCCESS_DIR = "successes"

SCHEMA_DEF = {
    "type": "object",
    "properties": {
        "project_title": {"type": "string"},
        "continuation_recommendation": {"type": "string", "enum": ["continue", "pivot", "archive"]},
        "estimated_monetary_value_usd": {"type": "number"},
        "rationale": {"type": "string"},
        "prompt_engineering_findings": {"type": "array", "items": {"type": "string"}},
        "improved_prompts": {"type": "array", "items": {"type": "string"}},
        "success_flag": {"type": "boolean"},
        "reproducible_schema": {
            "type": "object",
            "properties": {
                "goals": {"type": "array", "items": {"type": "string"}},
                "inputs_required": {"type": "array", "items": {"type": "string"}},
                "tools_apis": {"type": "array", "items": {"type": "string"}},
                "pipeline_steps": {"type": "array", "items": {"type": "string"}},
                "artifacts": {"type": "array", "items": {"type": "string"}},
                "acceptance_criteria": {"type": "array", "items": {"type": "string"}}
            },
            "required": ["goals", "inputs_required", "pipeline_steps", "artifacts", "acceptance_criteria"]
        }
    },
    "required": [
        "project_title", "continuation_recommendation", "estimated_monetary_value_usd",
        "rationale", "prompt_engineering_findings", "improved_prompts", "success_flag", "reproducible_schema"
    ]
}

ANALYSIS_SYSTEM = (
    "Task: Review chats and transcripts. Improve prompt engineering with specific, testable suggestions. "
    "Rate real-world value (USD) and decide continue/pivot/archive. "
    "If success_flag true, output a concise reproducible schema."
)

def ensure_dirs(root: Path):
    (root / "inputs" / "conversations").mkdir(parents=True, exist_ok=True)
    (root / "inputs" / "media").mkdir(parents=True, exist_ok=True)
    (root / "outputs" / "transcripts").mkdir(parents=True, exist_ok=True)
    (root / "outputs" / "images").mkdir(parents=True, exist_ok=True)
    (root / "outputs" / "analysis").mkdir(parents=True, exist_ok=True)
    (root / SUCCESS_DIR).mkdir(parents=True, exist_ok=True)

def safe_acronym(name: str) -> str:
    base = re.sub(r"[^A-Za-z0-9]+", "_", name).strip("_")
    return (base[:16] or "PROJECT").upper()

def limited_read(p: Path) -> str:
    try:
        if p.suffix.lower() == ".json":
            return json.dumps(json.loads(p.read_text(errors="ignore")), indent=2)
        return p.read_text(errors="ignore")
    except Exception as e:
        return f"READ_ERROR {p.name}: {e}"

def collect_inputs(src: Path, root: Path):
    conv_ext = {".txt", ".md", ".json", ".log"}
    media_ext = {".wav", ".mp3", ".m4a", ".ogg"}
    tree_like = {"tree.txt", "project_tree.txt"}

    for p in src.rglob("*"):
        if not p.is_file():
            continue
        # skip internal dirs
        if any(part in {"inputs", "outputs", "successes"} for part in p.parts):
            continue

        if p.name in tree_like or p.suffix.lower() == ".tree":
            dst = root / "inputs" / "tree" / p.name
        elif p.suffix.lower() in media_ext:
            dst = root / "inputs" / "media" / p.name
        elif p.suffix.lower() in conv_ext:
            dst = root / "inputs" / "conversations" / p.name
        else:
            continue

        if not dst.exists() or p.resolve() != dst.resolve():
            try:
                shutil.copy2(p, dst)
            except shutil.SameFileError:
                pass

def chunk_text(text: str, size: int) -> List[str]:
    return [text[i:i + size] for i in range(0, len(text), size)]

def backoff_try(fn, *args, **kwargs):
    delay = RETRY_BASE
    for i in range(RETRY_MAX):
        try:
            return fn(*args, **kwargs)
        except Exception:
            if i == RETRY_MAX - 1:
                raise
            time.sleep(delay)
            delay *= 1.8

def b64_data_url(img_path: Path) -> str:
    mime = "image/png" if img_path.suffix.lower() == ".png" else "image/jpeg"
    data = base64.b64encode(img_path.read_bytes()).decode("utf-8")
    return f"data:{mime};base64,{data}"

def cmd_prepare(path: Path):
    ensure_dirs(path)
    collect_inputs(path, path)
    print(f"[ok] Prepared under {path}")

def cmd_transcribe(path: Path):
    ensure_dirs(path)
    media_dir = path / "inputs" / "media"
    out_dir = path / "outputs" / "transcripts"
    count = 0
    for audio in sorted(media_dir.glob("*")):
        if audio.suffix.lower() not in AUDIO_EXT:
            continue
        with audio.open("rb") as f:
            resp = backoff_try(
                client.audio.transcriptions.create,
                model=TRANSCRIBE_MODEL,
                file=f,
                response_format="json"  # valid for gpt-4o-transcribe
            )
        data = resp.to_dict() if hasattr(resp, "to_dict") else json.loads(resp.model_dump_json())
        (out_dir / f"{audio.stem}.json").write_text(json.dumps(data, indent=2), encoding="utf-8")
        text = data.get("text") or data.get("transcript") or ""
        (out_dir / f"{audio.stem}.txt").write_text(text, encoding="utf-8")
        count += 1
    print(f"[ok] Transcribed {count} file(s) → {out_dir}")

def cmd_images(path: Path):
    ensure_dirs(path)
    out_img = path / "outputs" / "images"
    out_meta = out_img / "_descriptions.jsonl"
    moved = 0
    with out_meta.open("w", encoding="utf-8") as meta:
        for img in sorted(path.rglob("*")):
            if img.is_file() and img.suffix.lower() in IMG_EXT:
                dst = out_img / img.name
                if not dst.exists() or img.resolve() != dst.resolve():
                    try:
                        shutil.copy2(img, dst)
                    except shutil.SameFileError:
                        pass
                try:
                    vis = backoff_try(
                        client.responses.create,
                        model=TEXT_MODEL,
                        input=[{
                            "role": "user",
                            "content": [
                                {"type": "input_text",
                                 "text": "Describe this image in 1-2 neutral sentences for evidence logging; include visible text and timestamps if any."},
                                {"type": "input_image", "image_url": b64_data_url(dst)}
                            ]
                        }]
                    )
                    desc = getattr(vis, "output_text", "") or ""
                except Exception:
                    desc = "Description unavailable."
                meta.write(json.dumps({"file": dst.name, "description": desc}, ensure_ascii=False) + "\n")
                moved += 1
    print(f"[ok] Collected and described {moved} image(s) → {out_img}")

def analyze_chunk(chunk: str, topic: str) -> Dict[str, Any]:
    try:
        resp = backoff_try(
            client.responses.create,
            model=TEXT_MODEL,
            input=[
                {"role": "system", "content": ANALYSIS_SYSTEM},
                {"role": "user", "content": f"Project: {topic}\n\n{chunk}"}
            ],
            response_format={
                "type": "json_schema",
                "json_schema": {"name": "postmortem_schema", "schema": SCHEMA_DEF, "strict": True}
            }
        )
        return json.loads(resp.output_text)
    except Exception:
        resp = backoff_try(
            client.responses.create,
            model=TEXT_MODEL,
            input=[{"role": "user", "content": f"Return ONLY JSON matching this schema:\n{json.dumps(SCHEMA_DEF)}\n\n{chunk}"}]
        )
        return json.loads(resp.output_text)

def dedupe(items: List[str]) -> List[str]:
    seen, out = set(), []
    for it in items:
        k = it.strip().lower()
        if k and k not in seen:
            seen.add(k)
            out.append(it.strip())
    return out

def aggregate(parts: List[Dict[str, Any]], topic: str) -> Dict[str, Any]:
    votes = {"continue": 0, "pivot": 0, "archive": 0}
    vals, findings, prompts, rationales = [], [], [], []
    schema = None
    success = False
    for p in parts:
        rec = p.get("continuation_recommendation", "pivot")
        if rec in votes:
            votes[rec] += 1
        v = p.get("estimated_monetary_value_usd")
        if isinstance(v, (int, float)):
            vals.append(v)
        findings += p.get("prompt_engineering_findings", [])
        prompts += p.get("improved_prompts", [])
        if p.get("rationale"):
            rationales.append(p["rationale"])
        if p.get("success_flag") and isinstance(p.get("reproducible_schema"), dict):
            schema = p["reproducible_schema"]
            success = True
    final_rec = max(votes, key=votes.get)
    avg_val = round(sum(vals) / len(vals), 2) if vals else 0.0
    return {
        "project_title": topic,
        "continuation_recommendation": final_rec,
        "estimated_monetary_value_usd": avg_val,
        "rationale": "\n\n".join(rationales)[:20000],
        "prompt_engineering_findings": dedupe(findings),
        "improved_prompts": dedupe(prompts),
        "success_flag": success,
        "reproducible_schema": schema or {}
    }

def cmd_analyze(path: Path, topic: str):
    ensure_dirs(path)
    convs = sorted((path / "inputs" / "conversations").glob("*"))
    transcripts = sorted((path / "outputs" / "transcripts").glob("*.txt"))
    corpus = ""
    for p in convs + transcripts:
        corpus += f"\n\n=== {p.name} ===\n" + limited_read(p)
        if len(corpus) > MAX_TOTAL_CHARS:
            break
    chunks = chunk_text(corpus, MAX_CORPUS_SLICE) or ["No data"]
    results = []
    for i, ch in enumerate(chunks, 1):
        print(f"[..] Analyzing chunk {i}/{len(chunks)}")
        results.append(analyze_chunk(ch, topic))
    combined = aggregate(results, topic)
    out_dir = path / "outputs" / "analysis"
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "project_analysis.json").write_text(json.dumps(combined, indent=2, ensure_ascii=False), encoding="utf-8")
    with (out_dir / "summary.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["project_title", "recommendation", "value_usd", "success_flag"])
        w.writerow([
            combined["project_title"],
            combined["continuation_recommendation"],
            combined["estimated_monetary_value_usd"],
            combined["success_flag"]
        ])
    if combined.get("success_flag"):
        acr = safe_acronym(topic)
        sdir = path / SUCCESS_DIR / acr
        sdir.mkdir(parents=True, exist_ok=True)
        (sdir / f"{acr}_schema.json").write_text(json.dumps(combined["reproducible_schema"], indent=2, ensure_ascii=False), encoding="utf-8")
        (sdir / "README.md").write_text(f"{acr} schema generated {datetime.now().date()}.\n", encoding="utf-8")
    print(f"[ok] Analysis complete → {out_dir}")

def cmd_run(path: Path, topic: str):
    cmd_prepare(path)
    cmd_transcribe(path)
    cmd_images(path)
    cmd_analyze(path, topic)

def main():
    ap = argparse.ArgumentParser(prog="postmortem")
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("prepare");    p.add_argument("path")
    t = sub.add_parser("transcribe"); t.add_argument("path")
    i = sub.add_parser("images");     i.add_argument("path")
    a = sub.add_parser("analyze");    a.add_argument("path"); a.add_argument("--topic", required=True)
    r = sub.add_parser("run");        r.add_argument("path"); r.add_argument("--topic", required=True)
    args = ap.parse_args()
    root = Path(args.path).expanduser().resolve()
    if args.cmd == "prepare":
        cmd_prepare(root)
    elif args.cmd == "transcribe":
        cmd_transcribe(root)
    elif args.cmd == "images":
        cmd_images(root)
    elif args.cmd == "analyze":
        cmd_analyze(root, args.topic)
    elif args.cmd == "run":
        cmd_run(root, args.topic)

if __name__ == "__main__":
    main()
# EOF
