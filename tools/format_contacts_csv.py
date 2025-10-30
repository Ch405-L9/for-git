#!/usr/bin/env python3
import json, csv, sys
from pathlib import Path

IN = Path("outputs/contacts/contacts.json")
OUT = Path("outputs/contacts/contacts.csv")

def fmt_addr(a):
    if not a: return ""
    if isinstance(a, str): return a.strip()
    street = (a.get("streetAddress") or "").strip()
    city   = (a.get("addressLocality") or "").strip()
    region = (a.get("addressRegion") or "").strip()
    postal = (a.get("postalCode") or "").strip()
    country= (a.get("addressCountry") or "").strip()
    parts  = []
    if street: parts.append(street)
    city_line = ", ".join(p for p in [city] if p)
    tail = " ".join(p for p in [region, postal] if p).strip()
    tail = ", ".join(p for p in [city_line, tail] if p).strip().strip(", ")
    if tail: parts.append(tail)
    if country: parts.append(country)
    return ", ".join(p for p in parts if p)

def fmt_list(xs, sep=","):
    if not xs: return ""
    return sep.join(str(x).strip() for x in xs if str(x).strip())

def fmt_socials(d):
    if not d: return ""
    # Keep only URLs; order by host for deterministic output
    items = [d[k] for k in sorted(d)]
    seen, out = set(), []
    for u in items:
        if u and u not in seen:
            out.append(u)
            seen.add(u)
    return ", ".join(out)

def first_or_join(xs):
    if not xs: return ""
    # Use the first as primary org; if you prefer all, replace with fmt_list(xs)
    return str(xs[0]).strip()

def main():
    if not IN.exists():
        print("contacts.json not found at", IN, file=sys.stderr)
        sys.exit(1)
    rows = json.loads(IN.read_text(encoding="utf-8"))

    fields = [
        "url",
        "domain",
        "organization",
        "names",
        "emails",
        "phones",
        "address",
        "socials",
        "timestamp",
    ]

    with OUT.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        for r in rows:
            w.writerow({
                "url": r.get("url",""),
                "domain": r.get("domain",""),
                "organization": first_or_join(r.get("organizations",[])),
                "names": fmt_list(r.get("names",[]), sep=","),
                "emails": fmt_list([e.lower() for e in r.get("emails",[])], sep=","),
                "phones": fmt_list(r.get("phones",[]), sep=","),
                "address": fmt_addr(r.get("address")),
                "socials": fmt_socials(r.get("socials",{})),
                "timestamp": r.get("timestamp",""),
            })

    print(f"✓ Reformatted CSV → {OUT}")

if __name__ == "__main__":
    main()
