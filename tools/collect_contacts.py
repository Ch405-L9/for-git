#!/usr/bin/env python3
# BADGR_BOT Intel Collector (v1.6)
# - HTTP-first parse (BeautifulSoup)
# - JSON-LD/microdata (extruct) for org/email/phone/address + sameAs (socials)
# - <a rel="me"> and anchors, plus plain-text social mentions
# - Optional JS render via Playwright when RENDER_JS=1 (Chromium headless)
# - mailto:/tel: + deobfuscation; phone validation (phonenumbers -> E.164)
# - spaCy NER (optional) for PERSON/ORG
# - CSV now also flattens address fields for spreadsheets

import os, sys, re, json, csv, time, html
from pathlib import Path
from urllib.parse import urljoin, urlparse
import requests
from bs4 import BeautifulSoup
import tldextract
import phonenumbers
from email_validator import validate_email, EmailNotValidError
import extruct
from w3lib.html import get_base_url

# Optional spaCy NER
try:
    import spacy
    NER = spacy.load("en_core_web_sm")
except Exception:
    NER = None

RENDER_JS = os.getenv("RENDER_JS", "0") == "1"

# Optional Playwright (only if RENDER_JS=1)
if RENDER_JS:
    try:
        from playwright.sync_api import sync_playwright
    except Exception:
        sync_playwright = None

OUT_DIR = Path("outputs/contacts")
OUT_DIR.mkdir(parents=True, exist_ok=True)

DEFAULT_REGION = (sys.argv[1] if len(sys.argv) > 1 and len(sys.argv[1]) == 2 else "US").upper()

SOCIAL_DOMAINS = {
    "twitter.com","x.com","facebook.com","instagram.com","linkedin.com",
    "youtube.com","tiktok.com","github.com","discord.gg","discord.com",
    "reddit.com","threads.net","pinterest.com","bluesky.social"
}
SOCIAL_TEXT_RE = re.compile(
    r'\b(?:https?://)?(?:www\.)?('
    r'twitter\.com|x\.com|facebook\.com|instagram\.com|linkedin\.com|'
    r'youtube\.com|tiktok\.com|github\.com|discord\.gg|discord\.com|'
    r'reddit\.com|threads\.net|pinterest\.com|bluesky\.social'
    r')(/[^\s"\'<>]*)?', re.IGNORECASE)

CONTACT_PATH_HINTS = [
    "contact","contact-us","about","about-us","team","company","support","help"
]

HEADERS = {"User-Agent": "BADGRBot/1.0 (+https://badgrtech.com) Python-requests"}

EMAIL_RE = re.compile(r"""
    (?:
      mailto:|
      (?<![\w@])
    )
    ([A-Z0-9._%+\-]+
      (?:\s*(?:\[at\]|\(at\)|\{at\}|@|\s+at\s+)\s*)
      [A-Z0-9.\-]+
      (?:\s*(?:\[dot\]|\(dot\)|\{dot\}|\.|\s+dot\s+)\s*)
      [A-Z]{2,})
""", re.IGNORECASE | re.VERBOSE)
TEL_LINK_RE = re.compile(r'^tel:\s*([+\d][\d()\s\-.]+)$', re.I)
PHONE_TEXT_RE = re.compile(r'[+]*[(]{0,1}\d{1,4}[)]{0,1}[-\s\.0-9]{6,}', re.I)

def norm_domain(u:str)->str:
    ex = tldextract.extract(u)
    return ".".join([p for p in [ex.domain, ex.suffix] if p])

def fetch(url:str, timeout=15)->requests.Response|None:
    try:
        r = requests.get(url, headers=HEADERS, timeout=timeout)
        r.raise_for_status()
        return r
    except Exception:
        return None

def render_js(url:str, timeout_ms:int=10000)->str|None:
    if not RENDER_JS or sync_playwright is None:
        return None
    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=True, args=["--disable-dev-shm-usage"])
            ctx = browser.new_context()
            page = ctx.new_page()
            page.goto(url, timeout=timeout_ms, wait_until="load")
            # let client JS finish minor hydration
            page.wait_for_timeout(800)
            html_content = page.content()
            browser.close()
            return html_content
    except Exception:
        return None

def safe_text(soup:BeautifulSoup)->str:
    for t in soup(["script","style","noscript","template"]):
        t.extract()
    return " ".join(soup.get_text(separator=" ", strip=True).split())

def decode_email(candidate:str)->str:
    c = html.unescape(candidate)
    c = c.replace("(at)","@").replace("[at]","@").replace("{at}","@")
    c = re.sub(r'\s+at\s+','@', c, flags=re.I)
    c = c.replace("(dot)",".").replace("[dot]",".").replace("{dot}",".")
    c = re.sub(r'\s+dot\s+','.', c, flags=re.I)
    c = c.replace(" ","")
    c = re.sub(r'^mailto:','', c, flags=re.I)
    return c

def valid_email(e:str)->str|None:
    try:
        return validate_email(e, check_deliverability=False).email
    except EmailNotValidError:
        return None

def extract_emails(soup:BeautifulSoup, html_text:str)->set[str]:
    emails=set()
    for a in soup.select('a[href^="mailto:"]'):
        m = re.search(EMAIL_RE, a.get("href",""))
        if m: emails.add(decode_email(m.group(1)))
    for m in EMAIL_RE.finditer(html_text):
        emails.add(decode_email(m.group(1)))
    return {e for e in (valid_email(e) for e in emails) if e}

def extract_phones(soup:BeautifulSoup, text:str)->set[str]:
    raw=set()
    for a in soup.select('a[href^="tel:"]'):
        h = a.get("href","")
        m = TEL_LINK_RE.match(h)
        if m: raw.add(m.group(1))
    for m in PHONE_TEXT_RE.finditer(text):
        raw.add(m.group(0))
    out=set()
    for cand in raw:
        cand = re.sub(r'[^\d+()]','', cand)
        try:
            num = phonenumbers.parse(cand, DEFAULT_REGION)
            if phonenumbers.is_possible_number(num) and phonenumbers.is_valid_number(num):
                out.add(phonenumbers.format_number(num, phonenumbers.PhoneNumberFormat.E164))
        except Exception:
            continue
    return out

def add_social(socials:dict, href:str):
    try:
        host = urlparse(href).netloc.lower().split(":")[0]
    except Exception:
        return
    if any(host.endswith(d) for d in SOCIAL_DOMAINS):
        socials.setdefault(host, href)

def extract_socials(soup:BeautifulSoup, text:str, structured_sameas:list[str]|None=None)->dict:
    socials={}
    # 0) from structured data sameAs
    if structured_sameas:
        for url in structured_sameas:
            add_social(socials, url)

    # 1) Anchor tags (incl rel=me)
    for a in soup.select('a[href]'):
        href = a["href"].strip()
        add_social(socials, href)

    # 2) rel="me" links are strong signals
    for a in soup.select('a[rel*="me"]'):
        href = a.get("href","").strip()
        add_social(socials, href)

    # 3) Plain-text mentions
    for m in SOCIAL_TEXT_RE.finditer(text):
        host = m.group(1).lower()
        path = m.group(2) or ""
        url = f"https://{host}{path}"
        add_social(socials, url)

    return socials

def extract_meta_org(soup:BeautifulSoup)->str|None:
    og = soup.find("meta", attrs={"property":"og:site_name"})
    if og and og.get("content"): return og["content"].strip()
    title = soup.find("title")
    if title and title.text.strip(): return title.text.strip()
    h1 = soup.find("h1")
    if h1 and h1.text.strip(): return h1.text.strip()
    return None

def extract_structured(html_str:str, base:str)->dict:
    data={}
    try:
        metadata = extruct.extract(html_str, base_url=get_base_url(html_str, base),
                                   syntaxes=["json-ld","microdata","opengraph","microformat"])
        same_as = []
        for syntax in ("json-ld","microdata"):
            for item in metadata.get(syntax, []):
                # normalize item iteration
                nodes = []
                if isinstance(item, dict) and "@graph" in item:
                    nodes = item["@graph"]
                else:
                    nodes = [item]
                for node in (nodes if isinstance(nodes, list) else [nodes]):
                    if not isinstance(node, dict): continue
                    types = node.get("@type") or node.get("type")
                    types = [types] if isinstance(types, str) else (types or [])
                    # collect sameAs globally
                    sa = node.get("sameAs")
                    if isinstance(sa, list): same_as.extend([str(u) for u in sa if isinstance(u, (str, bytes))])
                    elif isinstance(sa, str): same_as.append(sa)
                    # capture org/person
                    if any(t in ("Organization","LocalBusiness","Corporation","Person") for t in types):
                        name = node.get("name")
                        email = node.get("email")
                        if not email:
                            cp = node.get("contactPoint")
                            if isinstance(cp, list):
                                for c in cp:
                                    if isinstance(c, dict) and c.get("email"):
                                        email = c["email"]; break
                        tel = node.get("telephone") or node.get("tel")
                        address = node.get("address")
                        if name: data.setdefault("org_names", set()).add(str(name))
                        if email: data.setdefault("emails", set()).add(str(email))
                        if tel: data.setdefault("phones_raw", set()).add(str(tel))
                        if address and "address_structured" not in data:
                            data["address_structured"]=address
        if same_as:
            data["sameAs"] = list(dict.fromkeys(same_as))  # dedupe/preserve order
    except Exception:
        pass
    # normalize phones
    if "phones_raw" in data:
        phones=set()
        for cand in data["phones_raw"]:
            try:
                num = phonenumbers.parse(str(cand), DEFAULT_REGION)
                if phonenumbers.is_possible_number(num) and phonenumbers.is_valid_number(num):
                    phones.add(phonenumbers.format_number(num, phonenumbers.PhoneNumberFormat.E164))
            except Exception:
                continue
        data["phones"]=phones
        del data["phones_raw"]
    return data

def ner_people_orgs(text:str)->tuple[set[str],set[str]]:
    if not NER or not text: return set(), set()
    doc = NER(text[:800000])
    persons=set(); orgs=set()
    for ent in doc.ents:
        if ent.label_ == "PERSON":
            persons.add(ent.text.strip())
        elif ent.label_ == "ORG":
            orgs.add(ent.text.strip())
    return persons, orgs

def candidate_urls(root:str, soup:BeautifulSoup)->list[str]:
    urls=set([root])
    parsed=urlparse(root)
    base=f"{parsed.scheme}://{parsed.netloc}"
    for hint in CONTACT_PATH_HINTS:
        urls.add(urljoin(base, f"/{hint}"))
        urls.add(urljoin(base, f"/{hint}/"))
    for loc in ["/sitemap.xml","/sitemap_index.xml","/sitemap"]:
        r = fetch(urljoin(base, loc), timeout=10)
        if r and "xml" in r.headers.get("Content-Type","").lower():
            try:
                sx = BeautifulSoup(r.text, "xml")
                for u in sx.find_all("loc"):
                    href=u.text.strip()
                    if any(h in href.lower() for h in CONTACT_PATH_HINTS):
                        urls.add(href)
            except Exception:
                pass
            break
    for a in soup.select("a[href]"):
        href=a["href"].strip()
        if href.startswith("#"): continue
        full=urljoin(root, href)
        if any(f"/{k}" in full.lower() for k in CONTACT_PATH_HINTS):
            urls.add(full)
    return list(urls)

def collect_page(url:str)->tuple[BeautifulSoup,str,str]:
    # returns (soup, text, raw_html)
    r = fetch(url)
    raw = r.text if r else ""
    # if JS render requested and little content, try render
    if RENDER_JS and (not raw or len(raw) < 5000) and sync_playwright:
        rendered = render_js(url)
        if rendered: raw = rendered
    soup = BeautifulSoup(raw or "", "lxml")
    text = safe_text(soup)
    return soup, text, raw

def collect_one(url:str)->dict:
    root = url if url.startswith("http") else f"https://{url}"

    soup0, text0, raw0 = collect_page(root)
    if not raw0:
        return {"url": root, "error":"fetch_failed"}

    urls = candidate_urls(root, soup0)
    pages = [(root, soup0, text0, raw0)]
    seen={root}
    for u in urls:
        if u in seen: continue
        seen.add(u)
        s, t, raw = collect_page(u)
        if not raw: continue
        pages.append((u, s, t, raw))
        time.sleep(0.4)

    domain = norm_domain(root)
    emails=set(); phones=set(); persons=set(); orgs=set()
    socials={}; address=None
    same_as_all=[]

    for u, s, t, raw in pages:
        sd = extract_structured(raw, u)
        emails |= set(sd.get("emails", []))
        phones |= set(sd.get("phones", []))
        if "org_names" in sd: orgs |= set(sd["org_names"])
        if "sameAs" in sd: same_as_all.extend(sd["sameAs"])
        if not address and "address_structured" in sd:
            address = sd["address_structured"]

        m_org = extract_meta_org(s)
        if m_org: orgs.add(m_org)

        emails |= extract_emails(s, raw)
        phones |= extract_phones(s, t)

        # socials (structured sameAs + anchors + rel=me + plaintext)
        sdict = extract_socials(s, t, structured_sameas=same_as_all)
        for k,v in sdict.items():
            socials.setdefault(k, v)

        p, o = ner_people_orgs(t)
        persons |= p; orgs |= o

    emails = sorted({e.lower() for e in emails})
    phones = sorted(phones)
    persons = sorted({p for p in persons if len(p.split())<=4 and len(p)>=2})
    orgs = sorted({o for o in orgs if len(o)>=2})

    return {
        "url": root,
        "domain": domain,
        "emails": emails,
        "phones": phones,
        "names": persons,
        "organizations": orgs,
        "address": address,
        "socials": socials,
        "timestamp": int(time.time())
    }

def write_outputs(rows:list[dict]):
    jpath = OUT_DIR / "contacts.json"
    with open(jpath, "w", encoding="utf-8") as f:
        json.dump(rows, f, indent=2, ensure_ascii=False)

    # Flatten address fields for CSV + keep original JSON
    cpath = OUT_DIR / "contacts.csv"
    fields = [
        "url","domain","emails","phones","names","organizations",
        "address","addr_street","addr_city","addr_region","addr_postal","addr_country",
        "socials","timestamp"
    ]
    with open(cpath, "w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        for r in rows:
            rr = r.copy()
            addr = r.get("address") or {}
            if isinstance(addr, dict):
                street = addr.get("streetAddress","")
                city = addr.get("addressLocality","")
                region = addr.get("addressRegion","")
                postal = addr.get("postalCode","")
                country = addr.get("addressCountry","")
                addr_json = json.dumps(addr, ensure_ascii=False)
            else:
                street = city = region = postal = country = ""
                addr_json = addr or ""

            rr["emails"] = ";".join(r.get("emails",[]))
            rr["phones"] = ";".join(r.get("phones",[]))
            rr["names"] = ";".join(r.get("names",[]))
            rr["organizations"] = ";".join(r.get("organizations",[]))
            rr["address"] = addr_json
            rr["addr_street"] = street
            rr["addr_city"] = city
            rr["addr_region"] = region
            rr["addr_postal"] = postal
            rr["addr_country"] = country
            rr["socials"] = json.dumps(r.get("socials",{}), ensure_ascii=False)

            w.writerow(rr)

    print(f"✓ Collector complete → {jpath} and {cpath}")

def main():
    urls=[u.strip() for u in sys.stdin if u.strip()]
    if not urls:
        print("Usage: echo 'https://example.com' | python tools/collect_contacts.py [REGION]", file=sys.stderr)
        sys.exit(1)
    results=[]
    for u in urls:
        try:
            results.append(collect_one(u))
        except Exception as e:
            results.append({"url":u, "error":str(e)})
    write_outputs(results)

if __name__ == "__main__":
    main()
