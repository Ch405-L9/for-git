
#!/usr/bin/env python3
"""
Build search queries for the collector.
Reads data/keywords_master_next.csv (fallback: keywords_seed.csv)
Writes outputs/queries_next.csv with: query, region, bucket, priority
"""
import os, csv
from pathlib import Path

MASTER = "data/keywords_master_next.csv"
SEED = "data/keywords_seed.csv"
OUT = "outputs/queries_next.csv"

def read_rows(path):
    with open(path, newline="", encoding="utf-8") as f:
        r = csv.DictReader(f)
        return list(r)

def main():
    src = MASTER if os.path.exists(MASTER) else SEED
    rows = read_rows(src)
    Path("outputs").mkdir(parents=True, exist_ok=True)
    with open(OUT, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["query","region","bucket","priority"])
        for r in rows:
            kw = (r.get("keyword") or "").strip()
            filters = (r.get("recommended_filters") or "").strip()
            query = kw if not filters else f"{kw} {filters}"
            w.writerow([query, r.get("region",""), r.get("bucket",""), r.get("priority","")])
    print(f"✅ Queries written → {OUT} (rows={len(rows)})")

if __name__ == "__main__":
    main()
