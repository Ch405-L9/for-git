# COMPLETE WORKFLOW: HEADER + HERO BUILD
## CH405_047 | Chaos Line | Production-Ready with Pre-Check & Auto-Validation

---

## WORKFLOW ARCHITECTURE SUMMARY

**This workflow includes:**

### 1. PRE-CHECK AGENT (Runs ONCE at start)
- Loads BUILD_LAWS ruleset
- Validates baseline environment
- Sets performance benchmarks
- Establishes quality gates

### 2. SETUP PHASE
- Next.js 14.2.18 initialization
- Dependency installation (verified compatible versions)
- Folder structure creation
- Configuration files

### 3. DATA GENERATION AGENT
- Generates site-content.json with CTA data
- Applies CTA best practices (+202% personalized, single-focus)
- Owner data generation
- Color palette definition

### 4. BUILD AGENTS
- **Header Component**: Navigation with mobile menu, sticky behavior
- **Hero Component**: Full-viewport section with optimized CTAs

### 5. INTEGRATION AGENT
- Combines components into app/page.tsx
- Configures routing
- Tests navigation flow

### 6. AUTOMATION LOOP (Self-Eval)
- Lighthouse scoring (Performance ≥90, SEO ≥90, BP ≥95, A11y ≥95)
- axe-core accessibility audit
- Core Web Vitals check
- Auto-refinement if scores below threshold

### 7. POST-BUILD VERIFICATION
- Link integrity check
- Console error check
- Responsive testing
- Final accessibility validation

### 8. HUMAN APPROVAL GATE
- Manual review
- Approve or iterate

---

## WHY THIS ORDER

**Pre-Check First**: Catches environment issues before wasted build effort  
**Setup Before Data**: Structure needed for file placement  
**Data Before Components**: Prevents hardcoding, enables reusability  
**Header Before Hero**: Navigation context needed for Hero CTAs  
**Automation Loop**: Catches quality issues immediately, auto-refines  
**Human Gate Last**: Final verification after automated checks pass

---

## CTA OPTIMIZATION STRATEGY

Based on verified 2025 research:

- **Personalized CTAs**: +202% conversion vs generic
- **Single CTA Focus**: 13.5% conversion vs 10.5% for 5+ CTAs
- **Exit-Intent**: 2-13.7% additional conversions
- **Sticky CTA Bar**: +27% conversion lift
- **Remove Navigation**: +100% conversion (funnel pages only)

**Hero CTAs Implementation:**
- Primary CTA: "View Menu" (action-oriented, first-person implied)
- Secondary CTA: "Order Catering" (clear value proposition)
- Sticky CTA Bar: "Order Now" (persistent, always visible)
- Exit-Intent: "Get 10% Off First Order" (abandonment recovery)

---

```
┌─────────────────────────────────────────────────────────────────┐
│                          START BUILD                            │
│                    CH405_047 | Chaos Line                       │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────────────┐
│ ████████████████████████████████████████████████████████████████████  │
│ █  PRE-CHECK AGENT (RUNS ONCE)                                    █  │
│ █  ────────────────────────────────────────────────────────────  █  │
│ █  Load BUILD_LAWS Ruleset:                                       █  │
│ █                                                                 █  │
│ █  Pre-Build Bench:                                               █  │
│ █  ☐ Verify Node.js v18+ installed                               █  │
│ █  ☐ Check npm/yarn availability                                 █  │
│ █  ☐ Confirm Git installed for version control                   █  │
│ █  ☐ Test internet connectivity for package downloads            █  │
│ █  ☐ Verify disk space >500MB available                          █  │
│ █                                                                 █  │
│ █  Baseline Metrics (for comparison post-build):                 █  │
│ █  ☐ Record: Lighthouse Performance target ≥90                   █  │
│ █  ☐ Record: Lighthouse SEO target ≥90                           █  │
│ █  ☐ Record: Lighthouse Best Practices target ≥95                █  │
│ █  ☐ Record: Lighthouse Accessibility target ≥95                 █  │
│ █  ☐ Record: Core Web Vitals targets (LCP <2.5s, INP <200ms,    █  │
│ █           CLS <0.1)                                             █  │
│ █                                                                 █  │
│ █  Quality Gates Established:                                     █  │
│ █  ☐ TypeScript strict mode required                             █  │
│ █  ☐ No console errors/warnings in production                    █  │
│ █  ☐ All images require alt text                                 █  │
│ █  ☐ Contrast ratio ≥4.5:1 for text                              █  │
│ █  ☐ Single CTA focus per page (Hero exception: 2 CTAs max)      █  │
│ █  ☐ Personalized CTA language mandatory                         █  │
│ █                                                                 █  │
│ █  Output: ruleset-config.json saved to project root             █  │
│ ████████████████████████████████████████████████████████████████████  │
└───────────────────────────┬───────────────────────────────────────────┘
                            │
                            ▼
                   ┌────────────────┐
                   │  CONDITIONAL   │ Pre-check passed?
                   └────┬──────┬────┘
                        │ NO   │ YES
             ┌──────────┘      └──────────┐
             ▼                              ▼
    ┌─────────────────┐         ┌──────────────────────────────────────┐
    │  ERROR HANDLER  │         │  SETUP AGENT                         │
    │  ─────────────  │         │  ──────────────────────────────────  │
    │  Display:       │         │  Initialize Next.js Project:         │
    │  - Missing deps │         │                                      │
    │  - Fix commands │         │  Commands:                           │
    │  - Retry option │         │  npx create-next-app@14.2.18 \       │
    │                 │         │      bakery-mockup \                 │
    │  Log error to:  │         │      --typescript \                  │
    │  setup-error.log│         │      --tailwind \                    │
    └─────────────────┘         │      --app \                         │
                                 │      --no-src-dir                    │
                                 │                                      │
                                 │  cd bakery-mockup                    │
                                 │                                      │
                                 │  Install Dependencies:               │
                                 │  npm install \                       │
                                 │    @heroicons/react@2.1.5 \          │
                                 │    framer-motion@11.11.17 \          │
                                 │    react-hook-form@7.53.2 \          │
                                 │    zod@3.23.8                        │
                                 │                                      │
                                 │  Create Folder Structure:            │
                                 │  mkdir -p components data \          │
                                 │           public/images styles       │
                                 │                                      │
                                 │  touch components/.gitkeep           │
                                 │  touch data/.gitkeep                 │
                                 │  touch public/images/.gitkeep        │
                                 │                                      │
                                 │  Configure next.config.js:           │
                                 │  - Enable image optimization         │
                                 │  - Set domains for external images   │
                                 │  - Enable compression                │
                                 │                                      │
                                 │  Create tailwind.config.ts:          │
                                 │  - Custom color palette:             │
                                 │    * coral: #FF6B6B                  │
                                 │    * sunnyYellow: #FFD93D            │
                                 │    * teal: #6BCB77                   │
                                 │    * gray: #F5F5F5                   │
                                 │  - Custom font sizes                 │
                                 │  - Responsive breakpoints            │
                                 │                                      │
                                 │  Initialize Git:                     │
                                 │  git init                            │
                                 │  git add .                           │
                                 │  git commit -m "Initial setup"       │
                                 └──────────────┬───────────────────────┘
                                                │
                                                ▼
                                       ┌────────────────┐
                                       │  VALIDATION    │ Setup successful?
                                       └────┬──────┬────┘
                                            │ NO   │ YES
                                 ┌──────────┘      └──────────┐
                                 ▼                              ▼
                        ┌─────────────────┐         ┌──────────────────────────┐
                        │  DEBUG AGENT    │         │  DATA GENERATION AGENT   │
                        │  ─────────────  │         │  ──────────────────────  │
                        │  Check logs:    │         │                          │
                        │  - npm-debug.log│         │  Batch Ingestion:        │
                        │  - Package vers │         │  python files_to_prompt.py \│
                        │  - Disk space   │         │      ~/bakery-mockup -n \│
                        │  Retry setup    │         │      -t -o setup.txt     │
                        └─────────────────┘         │                          │
                                                     │  Claude Prompt:          │
                                                     │  "BUILD: Generate JSON   │
                                                     │   data files:            │
                                                     │                          │
                                                     │   1. site-content.json:  │
                                                     │   {                      │
                                                     │     hero: {              │
                                                     │       headline: str,     │
                                                     │       tagline: str,      │
                                                     │       cta_primary: {     │
                                                     │         text: str (1st-person),│
                                                     │         href: '/menu',   │
                                                     │         variant: 'primary'│
                                                     │       },                 │
                                                     │       cta_secondary: {   │
                                                     │         text: str,       │
                                                     │         href: '/catering',│
                                                     │         variant: 'secondary'│
                                                     │       },                 │
                                                     │       background_image: str,│
                                                     │       gradient_overlay: bool│
                                                     │     },                   │
                                                     │     navigation: {        │
                                                     │       logo_text: str,    │
                                                     │       menu_items: [      │
                                                     │         {label, href}... │
                                                     │       ],                 │
                                                     │       cta_button: {      │
                                                     │         text: 'Order Now',│
                                                     │         href: '/order'   │
                                                     │       }                  │
                                                     │     },                   │
                                                     │     sticky_cta: {        │
                                                     │       enabled: true,     │
                                                     │       text: str,         │
                                                     │       href: '/order'     │
                                                     │     },                   │
                                                     │     exit_intent: {       │
                                                     │       enabled: true,     │
                                                     │       headline: str,     │
                                                     │       offer: str,        │
                                                     │       cta_text: str      │
                                                     │     }                    │
                                                     │   }                      │
                                                     │                          │
                                                     │   2. owner.json:         │
                                                     │   {                      │
                                                     │     name: str (fake),    │
                                                     │     bio: str (2 paras),  │
                                                     │     address: {fake},     │
                                                     │     phone: (555) format, │
                                                     │     email: fake,         │
                                                     │     social: {fake handles}│
                                                     │   }                      │
                                                     │                          │
                                                     │   REQUIREMENTS:          │
                                                     │   - Use first-person CTAs│
                                                     │     ('Start My Order'   │
                                                     │      not 'Start Order') │
                                                     │   - Urgency language     │
                                                     │     ('Today', 'Now')    │
                                                     │   - Clear value props    │
                                                     │   - Action verbs         │
                                                     │   - Personalized tone    │
                                                     │                          │
                                                     │   OUTPUT: Save as JSON   │
                                                     │   files in data/ folder" │
                                                     └──────────┬───────────────┘
                                                                │
                                                                ▼
                                                       ┌────────────────┐
                                                       │   SET STATE    │
                                                       │   Save data to │
                                                       │   data/ folder │
                                                       └────────┬───────┘
                                                                │
                                                                ▼
                                            ┌───────────────────────────────────┐
                                            │  BUILD AGENT: HEADER              │
                                            │  ───────────────────────────────  │
                                            │  Batch Ingestion:                 │
                                            │  python files_to_prompt.py \      │
                                            │      ~/bakery-mockup/data \       │
                                            │      -o header-context.txt        │
                                            │                                   │
                                            │  Claude Prompt:                   │
                                            │  "BUILD: Header.tsx component     │
                                            │                                   │
                                            │   REQUIREMENTS (BUILD_LAWS):      │
                                            │   ☐ TypeScript strict mode        │
                                            │   ☐ All ARIA labels present       │
                                            │   ☐ Keyboard navigation support   │
                                            │   ☐ Focus indicators visible      │
                                            │   ☐ Color contrast ≥4.5:1         │
                                            │   ☐ Semantic HTML (<nav>, <ul>)  │
                                            │   ☐ Single primary CTA (Order Now)│
                                            │                                   │
                                            │   COMPONENT SPEC:                 │
                                            │   - Import data from              │
                                            │     site-content.json             │
                                            │   - Logo: Text-based, left side   │
                                            │   - Desktop Nav (≥768px):         │
                                            │     * Horizontal menu items       │
                                            │     * Home, Menu, Catering,       │
                                            │       About, Contact              │
                                            │     * Order Now CTA (coral bg)    │
                                            │   - Mobile Nav (<768px):          │
                                            │     * Hamburger icon (Heroicons)  │
                                            │     * Slide-in menu (Framer)      │
                                            │     * Close button                │
                                            │   - Sticky behavior:              │
                                            │     * Fixed position on scroll    │
                                            │     * Smooth transition           │
                                            │     * Shadow on scroll            │
                                            │   - Active state:                 │
                                            │     * Highlight current page      │
                                            │     * Underline or color change   │
                                            │                                   │
                                            │   TYPESCRIPT INTERFACE:           │
                                            │   interface HeaderProps {         │
                                            │     navigation: NavigationData;   │
                                            │     currentPath?: string;         │
                                            │   }                               │
                                            │                                   │
                                            │   ACCESSIBILITY:                  │
                                            │   - aria-label on nav             │
                                            │   - aria-expanded on hamburger    │
                                            │   - aria-current on active link   │
                                            │   - Skip to content link          │
                                            │   - Focus trap in mobile menu     │
                                            │                                   │
                                            │   STYLING:                        │
                                            │   - Tailwind utility classes      │
                                            │   - Custom coral color (#FF6B6B)  │
                                            │   - Responsive breakpoints        │
                                            │   - Smooth animations             │
                                            │                                   │
                                            │   OUTPUT: Complete Header.tsx     │
                                            │   with all imports, types, and    │
                                            │   styles inline"                  │
                                            └───────────┬───────────────────────┘
                                                        │
                                                        ▼
                                               ┌────────────────┐
                                               │  VALIDATION    │ Header renders?
                                               └────┬──────┬────┘
                                                    │ NO   │ YES
                                         ┌──────────┘      └──────────┐
                                         ▼                              ▼
                                ┌─────────────────┐         ┌──────────────────────────┐
                                │  FIX AGENT      │         │  BUILD AGENT: HERO       │
                                │  ─────────────  │         │  ──────────────────────  │
                                │  Load component:│         │  Batch Ingestion:        │
                                │  python ... \   │         │  python files_to_prompt.py \│
                                │    Header.tsx \ │         │    ~/bakery-mockup/components/Header.tsx \│
                                │    -t -i -o fix.│         │    ~/bakery-mockup/data \│
                                │                 │         │    -o hero-context.txt   │
                                │  "EDIT: Fix     │         │                          │
                                │   [specific     │         │  Claude Prompt:          │
                                │    error from   │         │  "BUILD: Hero.tsx        │
                                │    console]"    │         │                          │
                                └─────────────────┘         │   REQUIREMENTS           │
                                                             │   (BUILD_LAWS):          │
                                                             │   ☐ TypeScript strict    │
                                                             │   ☐ Responsive design    │
                                                             │   ☐ Lazy-load images     │
                                                             │   ☐ Alt text present     │
                                                             │   ☐ ARIA landmarks       │
                                                             │   ☐ Color contrast ≥4.5:1│
                                                             │   ☐ Max 2 CTAs (primary, │
                                                             │     secondary only)      │
                                                             │   ☐ First-person CTA text│
                                                             │                          │
                                                             │   COMPONENT SPEC:        │
                                                             │   - Full viewport height │
                                                             │     (min-h-screen)       │
                                                             │   - Background:          │
                                                             │     * Image from         │
                                                             │       site-content.json  │
                                                             │     * Gradient overlay   │
                                                             │       (black opacity 40%)│
                                                             │     * Background-size:   │
                                                             │       cover              │
                                                             │   - Content container:   │
                                                             │     * Centered (flex)    │
                                                             │     * Max-width 1200px   │
                                                             │     * Padding responsive │
                                                             │   - Headline (H1):       │
                                                             │     * 4xl mobile,        │
                                                             │       6xl desktop        │
                                                             │     * Font weight bold   │
                                                             │     * White text         │
                                                             │     * Text shadow for    │
                                                             │       readability        │
                                                             │   - Tagline:             │
                                                             │     * xl mobile,         │
                                                             │       2xl desktop        │
                                                             │     * Light gray text    │
                                                             │     * Margin top 4       │
                                                             │   - CTA Container:       │
                                                             │     * Flex row           │
                                                             │     * Gap 4              │
                                                             │     * Stack mobile       │
                                                             │   - Primary CTA:         │
                                                             │     * Coral bg (#FF6B6B) │
                                                             │     * White text         │
                                                             │     * Padding x-8 y-4    │
                                                             │     * Rounded-lg         │
                                                             │     * Hover: scale-105   │
                                                             │     * Transition smooth  │
                                                             │     * First-person text  │
                                                             │       ('Start My Order') │
                                                             │   - Secondary CTA:       │
                                                             │     * White border       │
                                                             │     * Transparent bg     │
                                                             │     * White text         │
                                                             │     * Same padding/round │
                                                             │     * Hover: white bg,   │
                                                             │       coral text         │
                                                             │   - Animation:           │
                                                             │     * Framer Motion      │
                                                             │     * Fade in on mount   │
                                                             │     * Duration 0.8s      │
                                                             │     * Stagger children   │
                                                             │                          │
                                                             │   TYPESCRIPT INTERFACE:  │
                                                             │   interface HeroProps {  │
                                                             │     content: HeroData;   │
                                                             │   }                      │
                                                             │                          │
                                                             │   ACCESSIBILITY:         │
                                                             │   - Main landmark        │
                                                             │   - Alt text on bg image │
                                                             │   - ARIA labels on CTAs  │
                                                             │   - Sufficient contrast  │
                                                             │   - Keyboard accessible  │
                                                             │                          │
                                                             │   IMPORTS:               │
                                                             │   - Next Link for routing│
                                                             │   - Next Image optimized │
                                                             │   - Framer Motion        │
                                                             │   - Site content data    │
                                                             │                          │
                                                             │   OUTPUT: Complete       │
                                                             │   Hero.tsx with all      │
                                                             │   requirements met"      │
                                                             └──────────┬───────────────┘
                                                                        │
                                                                        ▼
                                                               ┌────────────────┐
                                                               │   SET STATE    │
                                                               │   Save Hero to │
                                                               │   components/  │
                                                               └────────┬───────┘
                                                                        │
                                                                        ▼
                                                    ┌───────────────────────────────────┐
                                                    │  INTEGRATION AGENT                │
                                                    │  ───────────────────────────────  │
                                                    │  Batch Ingestion:                 │
                                                    │  python files_to_prompt.py \      │
                                                    │      ~/bakery-mockup/components \ │
                                                    │      -o integration.txt           │
                                                    │                                   │
                                                    │  Claude Prompt:                   │
                                                    │  "BUILD: app/page.tsx homepage    │
                                                    │                                   │
                                                    │   COMPONENT SPEC:                 │
                                                    │   'use client' // Required for    │
                                                    │                   interactivity   │
                                                    │                                   │
                                                    │   import Header from              │
                                                    │     '../components/Header'        │
                                                    │   import Hero from                │
                                                    │     '../components/Hero'          │
                                                    │   import siteContent from          │
                                                    │     '../data/site-content.json'   │
                                                    │                                   │
                                                    │   export default function HomePage│
                                                    │   () {                            │
                                                    │     return (                      │
                                                    │       <>                          │
                                                    │         <Header navigation={      │
                                                    │           siteContent.navigation} │
                                                    │         />                        │
                                                    │         <Hero content={           │
                                                    │           siteContent.hero}       │
                                                    │         />                        │
                                                    │       </>                         │
                                                    │     );                            │
                                                    │   }                               │
                                                    │                                   │
                                                    │   METADATA:                       │
                                                    │   export const metadata = {       │
                                                    │     title: 'Home | [Bakery Name]',│
                                                    │     description: '[SEO desc]',    │
                                                    │     openGraph: {...}              │
                                                    │   }                               │
                                                    │                                   │
                                                    │   OUTPUT: Complete page.tsx"      │
                                                    └───────────┬───────────────────────┘
                                                                │
                                                                ▼
                                                       ┌────────────────┐
                                                       │  TEST RUNNER   │
                                                       │  ────────────  │
                                                       │  npm run dev   │
                                                       │                │
                                                       │  Open:         │
                                                       │  localhost:3000│
                                                       └────────┬───────┘
                                                                │
                                                                ▼
            ┌───────────────────────────────────────────────────────────────────────────┐
            │ ████████████████████████████████████████████████████████████████████████  │
            │ █  AUTOMATION LOOP (SELF-EVAL & REFINEMENT)                           █  │
            │ █  ────────────────────────────────────────────────────────────────  █  │
            │ █                                                                     █  │
            │ █  EVALUATION AGENT:                                                  █  │
            │ █  ─────────────────                                                  █  │
            │ █  Run Lighthouse CLI:                                                █  │
            │ █  lighthouse http://localhost:3000 \                                 █  │
            │ █    --output json --output-path ./lighthouse-report.json             █  │
            │ █                                                                     █  │
            │ █  Extract Scores:                                                    █  │
            │ █  - Performance: [score] / 100                                       █  │
            │ █  - Accessibility: [score] / 100                                     █  │
            │ █  - Best Practices: [score] / 100                                    █  │
            │ █  - SEO: [score] / 100                                               █  │
            │ █                                                                     █  │
            │ █  Run axe-core Audit:                                                █  │
            │ █  npx @axe-core/cli http://localhost:3000 \                          █  │
            │ █    --save ./axe-report.json                                         █  │
            │ █                                                                     █  │
            │ █  Extract Violations:                                                █  │
            │ █  - Critical: [count]                                                █  │
            │ █  - Serious: [count]                                                 █  │
            │ █  - Moderate: [count]                                                █  │
            │ █  - Minor: [count]                                                   █  │
            │ █                                                                     █  │
            │ █  Core Web Vitals (from Lighthouse):                                 █  │
            │ █  - LCP: [value] seconds                                             █  │
            │ █  - INP: [value] milliseconds                                        █  │
            │ █  - CLS: [value]                                                     █  │
            │ █                                                                     █  │
            │ █  SCORING AGENT:                                                     █  │
            │ █  ──────────────                                                     █  │
            │ █  Compare to BUILD_LAWS thresholds:                                  █  │
            │ █                                                                     █  │
            │ █  Quality Gate Results:                                              █  │
            │ █  ☐ Performance ≥ 90: [PASS/FAIL]                                    █  │
            │ █  ☐ Accessibility ≥ 95: [PASS/FAIL]                                  █  │
            │ █  ☐ Best Practices ≥ 95: [PASS/FAIL]                                 █  │
            │ █  ☐ SEO ≥ 90: [PASS/FAIL]                                            █  │
            │ █  ☐ LCP < 2.5s: [PASS/FAIL]                                          █  │
            │ █  ☐ INP < 200ms: [PASS/FAIL]                                         █  │
            │ █  ☐ CLS < 0.1: [PASS/FAIL]                                           █  │
            │ █  ☐ Zero critical/serious axe violations: [PASS/FAIL]                █  │
            │ █                                                                     █  │
            │ █  Overall Status: [ALL PASS / NEEDS REFINEMENT]                      █  │
            │ █                                                                     █  │
            │ █  SELF-ASSESSMENT PROMPT (if NEEDS REFINEMENT):                      █  │
            │ █  ──────────────────────────────────────────────                     █  │
            │ █  Batch ingestion:                                                   █  │
            │ █  python files_to_prompt.py \                                        █  │
            │ █      ~/bakery-mockup -e "*.json" -o self-assess.txt                █  │
            │ █                                                                     █  │
            │ █  Claude Prompt:                                                     █  │
            │ █  "SELF-ASSESS: Review generated site files                          █  │
            │ █                                                                     █  │
            │ █   INPUT:                                                            █  │
            │ █   - Lighthouse report: [attach lighthouse-report.json]              █  │
            │ █   - axe report: [attach axe-report.json]                            █  │
            │ █   - All component files: [from batch ingestion]                     █  │
            │ █                                                                     █  │
            │ █   EVALUATION CRITERIA:                                              █  │
            │ █   ☐ WCAG 2.2 Level AA compliance                                    █  │
            │ █   ☐ SEO metadata completeness                                       █  │
            │ █   ☐ Code style (ESLint/Prettier)                                    █  │
            │ █   ☐ TypeScript type safety                                          █  │
            │ █   ☐ Performance optimizations                                       █  │
            │ █   ☐ Image optimization (lazy-load, next/image)                      █  │
            │ █   ☐ Color contrast ratios                                           █  │
            │ █   ☐ Keyboard navigation                                             █  │
            │ █   ☐ ARIA labels/landmarks                                           █  │
            │ █                                                                     █  │
            │ █   OUTPUT: JSON diagnostics                                          █  │
            │ █   {                                                                 █  │
            │ █     'performance': {                                                █  │
            │ █       'status': 'Pass'/'Fail',                                      █  │
            │ █       'issues': [list],                                             █  │
            │ █       'fixes': [list of corrective prompts]                         █  │
            │ █     },                                                              █  │
            │ █     'accessibility': {...},                                         █  │
            │ █     'seo': {...},                                                   █  │
            │ █     'code_quality': {...}                                           █  │
            │ █   }                                                                 █  │
            │ █                                                                     █  │
            │ █   If any criterion = Fail, auto-suggest                             █  │
            │ █   corrective edit prompts"                                          █  │
            │ █                                                                     █  │
            │ █  REFINEMENT AGENT (if fixes needed):                                █  │
            │ █  ────────────────────────────────────                               █  │
            │ █  For each failed criterion:                                         █  │
            │ █                                                                     █  │
            │ █  1. Load affected component via batch tool                          █  │
            │ █  2. Apply corrective edit prompt from self-assessment               █  │
            │ █  3. Save updated component                                          █  │
            │ █  4. Re-run tests                                                    █  │
            │ █                                                                     █  │
            │ █  Example:                                                           █  │
            │ █  Issue: "Contrast ratio 3.2:1 on CTA button (needs ≥4.5:1)"        █  │
            │ █                                                                     █  │
            │ █  Fix Prompt: "EDIT: Hero.tsx - Change secondary CTA                 █  │
            │ █   border color from white (rgba(255,255,255,0.6)) to               █  │
            │ █   rgba(255,255,255,1.0) for contrast compliance"                    █  │
            │ █                                                                     █  │
            │ █  ITERATION LIMIT: Max 3 refinement loops                            █  │
            │ █  If still failing after 3 loops → escalate to human                 █  │
            │ ████████████████████████████████████████████████████████████████████  │
            └───────────────────────────┬───────────────────────────────────────────┘
                                        │
                                        ▼
                               ┌────────────────┐
                               │  CONDITIONAL   │ All quality gates passed?
                               └────┬──────┬────┘
                                    │ NO   │ YES
                         ┌──────────┘      └──────────┐
                         ▼                              ▼
                ┌─────────────────┐         ┌──────────────────────────────┐
                │  MAX ITERATIONS │         │  POST-BUILD VERIFICATION     │
                │  REACHED?       │         │  ──────────────────────────  │
                └────┬──────┬─────┘         │  Final Checks:               │
                     │ NO   │ YES            │                              │
          ┌──────────┘      └──────────┐    │  ☐ Link Integrity:           │
          ▼                              ▼    │    - All nav links resolve   │
  ┌───────────────┐           ┌──────────────────┐│    - No 404 errors      │
  │  RETURN TO    │           │  ESCALATE TO     ││    - CTAs route correctly│
  │  REFINEMENT   │           │  HUMAN           ││                          │
  │  AGENT        │           │  ──────────────  ││  ☐ Console Check:        │
  │               │           │  Log all issues  ││    npm run build         │
  │  Apply next   │           │  Flag blockers   ││    - Zero errors         │
  │  fix from     │           │  Request manual  ││    - Zero warnings       │
  │  self-assess  │           │  review          ││                          │
  └───────────────┘           └──────────────────┘│  ☐ Responsive Test:      │
                                                   │    - Mobile (375px)      │
                                                   │    - Tablet (768px)      │
                                                   │    - Desktop (1440px)    │
                                                   │    - All layouts work    │
                                                   │                          │
                                                   │  ☐ Accessibility Final:  │
                                                   │    - Screen reader test  │
                                                   │    - Keyboard nav test   │
                                                   │    - Focus indicators    │
                                                   │    - Alt text complete   │
                                                   │                          │
                                                   │  ☐ Performance Final:    │
                                                   │    - Images compressed   │
                                                   │    - Lazy-loading active │
                                                   │    - No blocking scripts │
                                                   │                          │
                                                   │  ☐ Git Commit:           │
                                                   │    git add .             │
                                                   │    git commit -m         │
                                                   │      "Header + Hero      │
                                                   │       complete with      │
                                                   │       validation pass"   │
                                                   │                          │
                                                   │  Generate Report:        │
                                                   │  - Lighthouse scores     │
                                                   │  - axe violations: 0     │
                                                   │  - Build time            │
                                                   │  - File sizes            │
                                                   │  - Before/after metrics  │
                                                   └──────────┬───────────────┘
                                                              │
                                                              ▼
                                                     ┌────────────────┐
                                                     │  HUMAN APPROVAL│
                                                     │  GATE          │
                                                     │  ────────────  │
                                                     │  Review:       │
                                                     │  - Visual QA   │
                                                     │  - Content QA  │
                                                     │  - UX flow     │
                                                     │  - Brand align │
                                                     └────┬──────┬────┘
                                                          │ REJ  │ APP
                                               ┌──────────┘      └──────────┐
                                               ▼                              ▼
                                      ┌─────────────────┐         ┌──────────────┐
                                      │  FEEDBACK LOOP  │         │   SUCCESS    │
                                      │  ─────────────  │         │   ────────   │
                                      │  Identify issues│         │  Phase 1:    │
                                      │  Document needs │         │  Header +    │
                                      │  Route to       │         │  Hero        │
                                      │  appropriate    │         │  COMPLETE    │
                                      │  agent:         │         │              │
                                      │  - Design →     │         │  Deliverables│
                                      │    BUILD AGENT  │         │  ☑ Header.tsx│
                                      │  - Content →    │         │  ☑ Hero.tsx  │
                                      │    DATA AGENT   │         │  ☑ app/page  │
                                      │  - Technical →  │         │  ☑ Data files│
                                      │    FIX AGENT    │         │  ☑ Config    │
                                      └─────────────────┘         │  ☑ Lighthouse│
                                                                   │    ≥90 all   │
                                                                   │  ☑ axe clean │
                                                                   │  ☑ Git commit│
                                                                   │              │
                                                                   │  Ready for:  │
                                                                   │  Phase 2 →   │
                                                                   │  Featured    │
                                                                   │  Products    │
                                                                   └──────────────┘
```

---

## IMPLEMENTATION COMMANDS REFERENCE

### 1. PRE-CHECK (Run Once)
```bash
# Verify environment
node --version  # Should be v18+
npm --version
git --version

# Create baseline config
cat > ruleset-config.json << EOF
{
  "thresholds": {
    "lighthouse": {
      "performance": 90,
      "accessibility": 95,
      "bestPractices": 95,
      "seo": 90
    },
    "coreWebVitals": {
      "lcp": 2.5,
      "inp": 200,
      "cls": 0.1
    },
    "accessibility": {
      "contrastRatio": 4.5,
      "zeroCriticalViolations": true
    }
  },
  "rules": {
    "typeScriptStrict": true,
    "singleCTAFocus": true,
    "personalizedCTAs": true,
    "noConsoleErrors": true,
    "allImagesHaveAlt": true
  }
}
EOF
```

### 2. SETUP
```bash
# Initialize project
npx create-next-app@14.2.18 bakery-mockup --typescript --tailwind --app --no-src-dir
cd bakery-mockup

# Install dependencies
npm install @heroicons/react@2.1.5 framer-motion@11.11.17 react-hook-form@7.53.2 zod@3.23.8

# Create structure
mkdir -p components data public/images styles
touch components/.gitkeep data/.gitkeep public/images/.gitkeep

# Initialize Git
git init
git add .
git commit -m "Initial setup: Next.js + TypeScript + Tailwind"
```

### 3. DATA GENERATION
```bash
# Batch ingestion
python files_to_prompt.py ~/bakery-mockup -n -t -o setup-context.txt

# Upload to Claude with data generation prompt (see workflow)
# Save output to data/site-content.json and data/owner.json
```

### 4. BUILD HEADER
```bash
# Batch ingestion with data context
python files_to_prompt.py ~/bakery-mockup/data -o header-context.txt

# Upload to Claude with Header build prompt
# Save output to components/Header.tsx
```

### 5. BUILD HERO
```bash
# Batch ingestion with Header + data context
python files_to_prompt.py ~/bakery-mockup/components/Header.tsx ~/bakery-mockup/data -o hero-context.txt

# Upload to Claude with Hero build prompt
# Save output to components/Hero.tsx
```

### 6. INTEGRATION
```bash
# Batch ingestion of all components
python files_to_prompt.py ~/bakery-mockup/components -o integration.txt

# Upload to Claude with integration prompt
# Save output to app/page.tsx
```

### 7. AUTOMATION LOOP
```bash
# Run dev server
npm run dev

# Install Lighthouse CLI
npm install -g lighthouse

# Run Lighthouse audit
lighthouse http://localhost:3000 --output json --output-path ./lighthouse-report.json

# Install axe CLI
npm install -g @axe-core/cli

# Run axe audit
npx @axe-core/cli http://localhost:3000 --save ./axe-report.json

# Review reports
cat lighthouse-report.json | jq '.categories | {performance: .performance.score, accessibility: .accessibility.score, seo: .seo.score, "best-practices": .["best-practices"].score}'

cat axe-report.json | jq '.violations | length'

# If refinement needed, load components for editing
python files_to_prompt.py ~/bakery-mockup -e "*.json" -o self-assess.txt
# Upload to Claude with self-assessment prompt
```

### 8. POST-BUILD
```bash
# Build for production
npm run build

# Check for errors
# Should complete with 0 errors, 0 warnings

# Test responsive
# Use browser DevTools device emulation

# Final commit
git add .
git commit -m "Phase 1 complete: Header + Hero with validation pass"
```

---

## CTA BEST PRACTICES APPLIED

### Personalization (+202% conversion)
**Hero Primary CTA**: "Start My Order" (first-person)  
**Not**: "Start Order" (generic)

### Single Focus (13.5% vs 10.5%)
**Hero**: Max 2 CTAs (primary + secondary only)  
**Header**: Single CTA (Order Now)  
**Sticky Bar**: Single CTA (Order Now)

### Urgency Language (+90-332%)
**Hero Headline**: "Freshly Baked Every Morning"  
**Sticky CTA**: "Order Now" (action-oriented)  
**Exit-Intent**: "Get 10% Off Your First Order Today"

### Exit-Intent (2-13.7% recovery)
Triggers on mouse leave, offers discount, captures abandoning visitors

### Sticky CTA (+27% lift)
Always-visible Order Now button in fixed bar at bottom

---

## SUCCESS METRICS

### Quality Gates
✅ Lighthouse Performance ≥ 90  
✅ Lighthouse Accessibility ≥ 95  
✅ Lighthouse Best Practices ≥ 95  
✅ Lighthouse SEO ≥ 90  
✅ LCP < 2.5 seconds  
✅ INP < 200 milliseconds  
✅ CLS < 0.1  
✅ Zero critical/serious axe violations

### Deliverables
✅ Header.tsx (fully responsive, accessible)  
✅ Hero.tsx (optimized CTAs, animations)  
✅ app/page.tsx (integration)  
✅ site-content.json (CTA data)  
✅ owner.json (fake owner info)  
✅ Git commit (clean history)  
✅ Lighthouse report (passing scores)  
✅ axe report (zero violations)

---

## TIMELINE ESTIMATE

**Pre-Check**: 10 minutes  
**Setup**: 20 minutes  
**Data Generation**: 15 minutes  
**Build Header**: 30 minutes  
**Build Hero**: 30 minutes  
**Integration**: 15 minutes  
**Automation Loop**: 30 minutes (1-3 iterations)  
**Post-Build**: 20 minutes  

**TOTAL**: 2.5 - 3.5 hours

---

**BUILD WITH PRECISION | CH405_047 | CHAOS LINE**

*Complete workflow with pre-check ruleset, automation loop, self-eval, and CTA optimization based on verified 2025 research. Zero guesswork, all data-backed.*
