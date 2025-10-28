#!/usr/bin/env python3
"""
AUTONOMOUS DOMAIN SCOUT - Forever Mode
Continuously discovers, scores, and logs poor-performing business sites

Features:
- Auto-discovery via Google/Bing search rotation
- PageSpeed Insights API scoring
- Keyword pool rotation (IT, ecommerce, local services, etc.)
- Smart rate limiting + random delays
- Deduplication via SQLite
- Runs indefinitely until stopped (Ctrl+C)

Setup:
    pip install googlesearch-python aiohttp aiosqlite

    Get PSI API key (free):
    https://console.cloud.google.com/apis/credentials

Usage:
    python autonomous_scout.py --api-key YOUR_PSI_KEY
    python autonomous_scout.py --api-key YOUR_PSI_KEY --score-limit 50
    python autonomous_scout.py --api-key YOUR_PSI_KEY --loop-delay 7200  # 2 hours
"""

import asyncio
import aiohttp
import aiosqlite
import argparse
import random
import time
import json
import csv
from datetime import datetime
from urllib.parse import urlparse, quote
from typing import Set, List, Dict, Optional

try:
    from googlesearch import search
except ImportError:
    print("❌ Install: pip install googlesearch-python")
    exit(1)

# ============================================================================
# KEYWORD POOLS - Rotate through these to discover different industries
# ============================================================================

KEYWORD_POOLS = {
    "it_services": [
        "managed IT services",
        "IT support company",
        "network security services",
        "cloud migration services",
        "cybersecurity company",
        "IT consulting firm"
    ],
    "ecommerce": [
        "online store",
        "ecommerce shop",
        "online boutique",
        "digital marketplace",
        "online retail store"
    ],
    "local_services": [
        "local plumbing company",
        "hvac repair services",
        "electrical contractor",
        "home renovation company",
        "landscaping services",
        "pest control company"
    ],
    "professional_services": [
        "accounting firm",
        "law office",
        "financial advisor",
        "marketing agency",
        "real estate agency",
        "insurance broker"
    ],
    "healthcare": [
        "dental practice",
        "medical clinic",
        "physical therapy",
        "chiropractic office",
        "veterinary clinic"
    ],
    "restaurants": [
        "restaurant website",
        "cafe menu online",
        "pizzeria delivery",
        "catering services",
        "food truck business"
    ]
}

# Geographic modifiers (optional - adds variety)
GEO_MODIFIERS = [
    "Atlanta", "Austin", "Boston", "Chicago", "Dallas",
    "Denver", "Houston", "Los Angeles", "Miami", "New York",
    "Phoenix", "Portland", "San Diego", "Seattle", "Tampa"
]

# ============================================================================
# DATABASE SETUP - Track discovered domains to avoid duplicates
# ============================================================================

async def init_db(db_path: str = "scout_data.db"):
    """Initialize SQLite database for tracking discovered domains"""
    async with aiosqlite.connect(db_path) as db:
        await db.execute("""
            CREATE TABLE IF NOT EXISTS discovered_domains (
                url TEXT PRIMARY KEY,
                domain TEXT,
                first_seen TEXT,
                last_checked TEXT,
                mobile_score INTEGER,
                desktop_score INTEGER,
                keyword_source TEXT,
                flagged BOOLEAN DEFAULT 0
            )
        """)
        await db.commit()
    print(f"✅ Database initialized: {db_path}")

async def is_domain_known(db_path: str, url: str) -> bool:
    """Check if domain already in database"""
    async with aiosqlite.connect(db_path) as db:
        async with db.execute(
            "SELECT url FROM discovered_domains WHERE url = ?", (url,)
        ) as cursor:
            result = await cursor.fetchone()
            return result is not None

async def save_domain(db_path: str, url: str, mobile_score: int,
                      desktop_score: int, keyword: str, flagged: bool):
    """Save discovered domain to database"""
    domain = urlparse(url).netloc
    now = datetime.utcnow().isoformat()

    async with aiosqlite.connect(db_path) as db:
        await db.execute("""
            INSERT OR REPLACE INTO discovered_domains
            (url, domain, first_seen, last_checked, mobile_score, desktop_score, keyword_source, flagged)
            VALUES (?, ?, COALESCE((SELECT first_seen FROM discovered_domains WHERE url = ?), ?), ?, ?, ?, ?, ?)
        """, (url, domain, url, now, now, mobile_score, desktop_score, keyword, flagged))
        await db.commit()

# ============================================================================
# DISCOVERY ENGINE - Find real business sites
# ============================================================================

def discover_domains(keyword: str, num_results: int = 20,
                     add_geo: bool = False) -> Set[str]:
    """
    Discover domains via Google search

    Args:
        keyword: Search term (e.g., "IT services company")
        num_results: Number of results to fetch
        add_geo: Whether to add geographic modifier

    Returns:
        Set of discovered URLs
    """
    if add_geo:
        geo = random.choice(GEO_MODIFIERS)
        search_query = f"{keyword} {geo}"
    else:
        search_query = keyword

    print(f"🔍 Searching: {search_query}")

    discovered = set()
    try:
        for url in search(search_query, num_results=num_results, sleep_interval=2):
            # Filter out non-business sites
            parsed = urlparse(url)
            domain = parsed.netloc.lower()

            # Skip common non-business domains
            skip_domains = [
                'wikipedia.org', 'youtube.com', 'facebook.com',
                'linkedin.com', 'twitter.com', 'instagram.com',
                'yelp.com', 'google.com', 'amazon.com'
            ]

            if not any(skip in domain for skip in skip_domains):
                discovered.add(url)

        print(f"   ✓ Found {len(discovered)} candidate URLs")
    except Exception as e:
        print(f"   ⚠️  Search error: {e}")

    return discovered

# ============================================================================
# SCORING ENGINE - PageSpeed Insights API
# ============================================================================

async def get_pagespeed_score(session: aiohttp.ClientSession, url: str,
                               api_key: str, strategy: str = "mobile") -> Optional[Dict]:
    """
    Get PageSpeed Insights score for a URL

    Args:
        session: aiohttp session
        url: URL to test
        api_key: Google PSI API key
        strategy: 'mobile' or 'desktop'

    Returns:
        Dict with score data or None if failed
    """
    api_url = (
        f"https://www.googleapis.com/pagespeedonline/v5/runPagespeed"
        f"?url={quote(url)}&key={api_key}&strategy={strategy}"
    )

    try:
        async with session.get(api_url, timeout=60) as response:
            if response.status == 200:
                data = await response.json()
                categories = data.get("lighthouseResult", {}).get("categories", {})
                perf = categories.get("performance", {}).get("score", 0)

                # Get Core Web Vitals
                audits = data.get("lighthouseResult", {}).get("audits", {})
                lcp = audits.get("largest-contentful-paint", {}).get("numericValue", 0)
                cls = audits.get("cumulative-layout-shift", {}).get("numericValue", 0)

                return {
                    "score": int(perf * 100) if perf else 0,
                    "lcp_ms": int(lcp),
                    "cls": round(cls, 3),
                    "strategy": strategy
                }
            else:
                print(f"   ⚠️  PSI API error {response.status} for {url}")
                return None
    except asyncio.TimeoutError:
        print(f"   ⚠️  Timeout for {url}")
        return None
    except Exception as e:
        print(f"   ⚠️  Error scoring {url}: {e}")
        return None

async def score_domain(session: aiohttp.ClientSession, url: str,
                       api_key: str) -> Optional[Dict]:
    """
    Score a domain on both mobile and desktop

    Returns:
        Dict with mobile_score, desktop_score, url
    """
    print(f"📊 Scoring: {url}")

    # Get mobile score
    mobile_result = await get_pagespeed_score(session, url, api_key, "mobile")
    await asyncio.sleep(1)  # Rate limit respect

    # Get desktop score
    desktop_result = await get_pagespeed_score(session, url, api_key, "desktop")

    if mobile_result and desktop_result:
        return {
            "url": url,
            "mobile_score": mobile_result["score"],
            "desktop_score": desktop_result["score"],
            "lcp_ms": mobile_result["lcp_ms"],
            "cls": mobile_result["cls"]
        }

    return None

# ============================================================================
# EXPORT FUNCTIONS
# ============================================================================

async def export_flagged_domains(db_path: str, output_file: str = "flagged_leads.csv"):
    """Export all flagged domains to CSV"""
    async with aiosqlite.connect(db_path) as db:
        async with db.execute("""
            SELECT url, domain, mobile_score, desktop_score, keyword_source, first_seen, last_checked
            FROM discovered_domains
            WHERE flagged = 1
            ORDER BY mobile_score ASC
        """) as cursor:
            rows = await cursor.fetchall()

            if rows:
                with open(output_file, 'w', newline='') as f:
                    writer = csv.writer(f)
                    writer.writerow([
                        "URL", "Domain", "Mobile Score", "Desktop Score",
                        "Source Keyword", "First Seen", "Last Checked"
                    ])
                    writer.writerows(rows)
                print(f"📁 Exported {len(rows)} flagged leads to {output_file}")

# ============================================================================
# MAIN SCOUT LOOP
# ============================================================================

async def scout_loop(api_key: str, score_limit: int = 60,
                     loop_delay: int = 3600, db_path: str = "scout_data.db"):
    """
    Main autonomous scouting loop

    Args:
        api_key: Google PSI API key
        score_limit: Flag domains below this score
        loop_delay: Seconds between discovery cycles
        db_path: SQLite database path
    """
    await init_db(db_path)

    cycle = 0
    total_discovered = 0
    total_flagged = 0

    print("\n" + "="*70)
    print("🤖 AUTONOMOUS DOMAIN SCOUT - Forever Mode Active")
    print("="*70)
    print(f"Score threshold: {score_limit}")
    print(f"Loop delay: {loop_delay}s ({loop_delay/3600:.1f} hours)")
    print(f"Press Ctrl+C to stop\n")

    async with aiohttp.ClientSession() as session:
        try:
            while True:
                cycle += 1
                cycle_start = time.time()

                print(f"\n{'='*70}")
                print(f"🔄 CYCLE {cycle} - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
                print(f"{'='*70}\n")

                # Randomly select a keyword pool
                pool_name = random.choice(list(KEYWORD_POOLS.keys()))
                keyword = random.choice(KEYWORD_POOLS[pool_name])

                print(f"📍 Industry focus: {pool_name}")
                print(f"🎯 Keyword: {keyword}\n")

                # Discover domains
                use_geo = random.random() > 0.5  # 50% chance to add geo
                discovered_urls = discover_domains(keyword, num_results=15, add_geo=use_geo)

                # Filter out already-known domains
                new_urls = []
                for url in discovered_urls:
                    if not await is_domain_known(db_path, url):
                        new_urls.append(url)

                print(f"\n🆕 New domains to check: {len(new_urls)}\n")

                # Score new domains
                flagged_this_cycle = 0
                for url in new_urls:
                    result = await score_domain(session, url, api_key)

                    if result:
                        mobile_score = result["mobile_score"]
                        desktop_score = result["desktop_score"]
                        avg_score = (mobile_score + desktop_score) / 2

                        flagged = avg_score < score_limit

                        # Save to database
                        await save_domain(
                            db_path, url, mobile_score, desktop_score,
                            keyword, flagged
                        )

                        status = "🚩 FLAGGED" if flagged else "✓"
                        print(f"   {status} Mobile: {mobile_score} | Desktop: {desktop_score}")

                        if flagged:
                            flagged_this_cycle += 1
                            total_flagged += 1

                        total_discovered += 1

                        # Respect rate limits
                        await asyncio.sleep(2)

                # Cycle summary
                cycle_duration = time.time() - cycle_start
                print(f"\n{'─'*70}")
                print(f"📊 Cycle {cycle} Summary:")
                print(f"   • Discovered: {len(discovered_urls)} URLs")
                print(f"   • New: {len(new_urls)} URLs")
                print(f"   • Flagged this cycle: {flagged_this_cycle}")
                print(f"   • Total flagged: {total_flagged}")
                print(f"   • Total discovered: {total_discovered}")
                print(f"   • Duration: {cycle_duration:.1f}s")
                print(f"{'─'*70}\n")

                # Export flagged leads
                await export_flagged_domains(db_path)

                # Wait before next cycle
                print(f"⏳ Waiting {loop_delay}s until next cycle...\n")
                await asyncio.sleep(loop_delay)

        except KeyboardInterrupt:
            print("\n\n🛑 Scout stopped by user")
            print(f"\n📊 Final Stats:")
            print(f"   • Total cycles: {cycle}")
            print(f"   • Total discovered: {total_discovered}")
            print(f"   • Total flagged: {total_flagged}")
            print(f"\n✅ Data saved to: {db_path}")
            await export_flagged_domains(db_path)

# ============================================================================
# CLI
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Autonomous Domain Scout - Continuous discovery engine"
    )
    parser.add_argument(
        "--api-key",
        required=True,
        help="Google PageSpeed Insights API key (get free at console.cloud.google.com)"
    )
    parser.add_argument(
        "--score-limit",
        type=int,
        default=60,
        help="Flag domains with scores below this (default: 60)"
    )
    parser.add_argument(
        "--loop-delay",
        type=int,
        default=3600,
        help="Seconds between discovery cycles (default: 3600 = 1 hour)"
    )
    parser.add_argument(
        "--db-path",
        default="scout_data.db",
        help="SQLite database path (default: scout_data.db)"
    )

    args = parser.parse_args()

    # Run the scout
    asyncio.run(scout_loop(
        api_key=args.api_key,
        score_limit=args.score_limit,
        loop_delay=args.loop_delay,
        db_path=args.db_path
    ))

if __name__ == "__main__":
    main()
