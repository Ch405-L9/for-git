# BUILD ORDER MASTER GUIDE
# **CH405_047 | Complete Build Workflow**


## PHASE 1: PRE-BUILD SETUP

### STEP 1: Environment Check (2 min)
```bash
# Verify prerequisites
node --version          # Should be v18+
npm --version           # Should be v9+
python3 --version       # Should be v3.7+
git --version           # Any recent version

# Clone/update repo
git clone https://github.com/Ch405-L9/for-git.git
cd for-git
git pull origin main
```

**Verification:**
- ✅ Node 18+ installed
- ✅ Python 3.7+ installed
- ✅ Repo cloned/updated
- ✅ files_to_prompt.py accessible

---

### STEP 2: Component Library Check (1 min)
```bash
# Verify component library exists
ls component-library/ui/ | wc -l    # Should show 395

# Check icon library
ls icon-library/ui/ | wc -l         # Your UI icons count
ls icon-library/social/             # Should have social icons
```

**Verification:**
- ✅ 395 components in component-library/ui/
- ✅ Icons organized in ui/, social/, brand/
- ✅ COMPONENT-CATALOG.md exists

---

## PHASE 2: PROJECT INITIALIZATION

### STEP 3: Create New Project (5 min)
```bash
# Option A: Use generator script
python3 build-scripts/generate_site.py my-bakery-site

# Option B: Manual setup
npx create-next-app@14.2.18 my-bakery-site \
  --typescript \
  --tailwind \
  --app \
  --no-src-dir \
  --yes

cd my-bakery-site
```

**Verification:**
- ✅ Project directory created
- ✅ package.json exists
- ✅ Next.js + TypeScript + Tailwind initialized

---

### STEP 4: Install Dependencies (3 min)
```bash
cd my-bakery-site

# Core dependencies
npm install @heroicons/react@2.1.5 framer-motion@11.11.17

# Radix UI (for components)
npm install \
  @radix-ui/react-accordion \
  @radix-ui/react-alert-dialog \
  @radix-ui/react-avatar \
  @radix-ui/react-dialog \
  @radix-ui/react-dropdown-menu \
  @radix-ui/react-navigation-menu \
  @radix-ui/react-popover \
  @radix-ui/react-select \
  @radix-ui/react-slider \
  @radix-ui/react-switch \
  @radix-ui/react-tabs \
  @radix-ui/react-tooltip

# Utility packages
npm install class-variance-authority clsx tailwind-merge

# Dev dependencies
npm install -D @types/node
```

**Verification:**
- ✅ package.json shows all dependencies
- ✅ node_modules/ folder created
- ✅ No installation errors

---

### STEP 5: Create Folder Structure (2 min)
```bash
# Create directories
mkdir -p components/{ui,layout,sections}
mkdir -p components/images/{Hero,Services,Gallery}
mkdir -p public/{icons,fonts}
mkdir -p src/{config,styles}
mkdir -p data

# Create placeholder files
touch src/config/site.ts
touch src/config/cloudinary.ts
touch src/styles/fonts.css
touch data/site-content.json
touch data/owner.json
```

**Verification:**
- ✅ components/ui/ exists (for library components)
- ✅ components/layout/ exists (Header, Footer)
- ✅ components/sections/ exists (Hero, Services, etc.)
- ✅ public/icons/ exists
- ✅ src/config/ exists
- ✅ data/ exists

---

### STEP 6: Copy Components from Library (3 min)
```bash
# Determine which components you need
# For landing page:
COMPONENTS=(
  "button.tsx"
  "card.tsx"
  "navigation-menu.tsx"
  "input.tsx"
  "textarea.tsx"
  "alert.tsx"
)

# Copy from library
for component in "${COMPONENTS[@]}"; do
  cp ../for-git/component-library/ui/$component components/ui/
done

echo "✓ Copied ${#COMPONENTS[@]} components"
```

**Verification:**
- ✅ components/ui/button.tsx exists
- ✅ components/ui/card.tsx exists
- ✅ All needed components copied

---

### STEP 7: Copy Icons from Library (2 min)
```bash
# Copy essential icons
ICONS=(
  "ui/menu.svg"
  "ui/close.svg"
  "ui/phone.svg"
  "ui/mail.svg"
  "social/github.svg"
  "social/linkedin.svg"
  "social/twitter.svg"
)

# Copy icons
for icon in "${ICONS[@]}"; do
  mkdir -p public/icons/$(dirname $icon)
  cp ../for-git/icon-library/$icon public/icons/$icon
done

echo "✓ Copied ${#ICONS[@]} icons"
```

**Verification:**
- ✅ public/icons/ui/ has UI icons
- ✅ public/icons/social/ has social icons

---

## PHASE 3: DATA GENERATION

### STEP 8: Prepare Context for Data Generation (2 min)
```bash
# Navigate back to for-git repo
cd ../for-git

# Ingest project structure
python3 files_to_prompt.py ../my-bakery-site -n -t -o context.txt
```

**Verification:**
- ✅ context.txt file created
- ✅ File contains project structure

---

### STEP 9: Generate Data with Claude (5 min)
**Upload context.txt to Claude and use this prompt:**
```
BUILD: Generate site-content.json and owner.json for a bakery website with:

SITE CONTENT:
- Hero section: headline, tagline, 2 CTAs
- Navigation: 5 menu items + Order Now button
- Services: 3 service cards with icons
- Contact: form fields + contact info

OWNER DATA:
- Fake owner name
- Bio (2-3 sentences)
- Fake address (realistic format)
- Fake email + phone
- Business hours

Use first-person CTAs ("Start My Order", "View My Menu")
```

**Save Claude's output to:**
- `../my-bakery-site/data/site-content.json`
- `../my-bakery-site/data/owner.json`

**Verification:**
- ✅ data/site-content.json has hero, nav, services, contact
- ✅ data/owner.json has owner info
- ✅ JSON is valid (no syntax errors)

---

## PHASE 4: COMPONENT BUILDING

### STEP 10: Build Header Component (10 min)
```bash
# Ingest data context
python3 files_to_prompt.py ../my-bakery-site/data -o header-context.txt
```

**Upload header-context.txt to Claude:**
```
BUILD: Header.tsx component with:
- Logo (text-based, reads from site-content.json)
- Desktop: horizontal nav with menu items from site-content.json
- Mobile: hamburger menu (slide-in from right)
- Sticky on scroll
- Order Now CTA button
- Import Button from @/components/ui/button
- Use icons from /public/icons/ui/menu.svg
- TypeScript + Tailwind
- Fully accessible (ARIA labels)
```

**Save to:** `../my-bakery-site/components/layout/Header.tsx`

**Verification:**
- ✅ components/layout/Header.tsx exists
- ✅ Imports data from site-content.json
- ✅ Uses Button component from library
- ✅ Mobile menu functional

---

### STEP 11: Build Hero Component (10 min)
```bash
# Ingest Header + data
python3 files_to_prompt.py \
  ../my-bakery-site/components/layout/Header.tsx \
  ../my-bakery-site/data \
  -o hero-context.txt
```

**Upload hero-context.txt to Claude:**
```
BUILD: Hero.tsx component with:
- Full viewport height (min-h-screen)
- Background image with gradient overlay
- Centered content
- H1 headline + tagline (from site-content.json)
- 2 CTA buttons (primary + secondary)
- Fade-in animation (Framer Motion)
- Import Button and Card from @/components/ui/
- Responsive (stack on mobile)
- TypeScript + Tailwind
```

**Save to:** `../my-bakery-site/components/sections/Hero.tsx`

**Verification:**
- ✅ components/sections/Hero.tsx exists
- ✅ Reads from site-content.json
- ✅ Uses library components
- ✅ Framer Motion animations work

---

### STEP 12: Build Services Component (10 min)
```bash
# Ingest existing components + data
python3 files_to_prompt.py \
  ../my-bakery-site/components \
  ../my-bakery-site/data \
  -o services-context.txt
```

**Upload services-context.txt to Claude:**
```
BUILD: Services.tsx component with:
- Section ID "services" for anchor links
- H2 heading
- 3-column grid (responsive: 1 column mobile, 3 desktop)
- Service cards using Card component from library
- Each card: icon, title, description
- Icons from /public/icons/
- Data from site-content.json
- TypeScript + Tailwind
```

**Save to:** `../my-bakery-site/components/sections/Services.tsx`

**Verification:**
- ✅ components/sections/Services.tsx exists
- ✅ Grid layout responsive
- ✅ Uses Card component

---

### STEP 13: Build Contact Component (10 min)
```bash
# Ingest components + data
python3 files_to_prompt.py \
  ../my-bakery-site/components \
  ../my-bakery-site/data \
  -o contact-context.txt
```

**Upload contact-context.txt to Claude:**
```
BUILD: Contact.tsx component with:
- Section ID "contact"
- Contact form: Name, Email, Message fields
- Submit button
- Contact info display (email, phone from owner.json)
- Uses Input, Textarea, Button from library
- Form validation (basic)
- TypeScript + Tailwind
- Accessible (labels, ARIA)
```

**Save to:** `../my-bakery-site/components/sections/Contact.tsx`

**Verification:**
- ✅ components/sections/Contact.tsx exists
- ✅ Form fields use library components
- ✅ Contact info displayed

---

### STEP 14: Build Footer Component (5 min)
```bash
# Quick footer build
python3 files_to_prompt.py \
  ../my-bakery-site/data/owner.json \
  -o footer-context.txt
```

**Upload footer-context.txt to Claude:**
```
BUILD: Footer.tsx component with:
- Company name from owner.json
- Copyright notice
- Social media links (icons from /public/icons/social/)
- Simple layout
- TypeScript + Tailwind
```

**Save to:** `../my-bakery-site/components/layout/Footer.tsx`

**Verification:**
- ✅ components/layout/Footer.tsx exists
- ✅ Social icons displayed

---

## PHASE 5: INTEGRATION

### STEP 15: Create Main Page (5 min)
```bash
# Ingest all components
python3 files_to_prompt.py \
  ../my-bakery-site/components \
  ../my-bakery-site/data \
  -o page-integration.txt
```

**Upload page-integration.txt to Claude:**
```
BUILD: app/page.tsx that:
- Imports Header, Hero, Services, Contact, Footer
- Passes data from site-content.json to components
- Proper TypeScript types
- Clean component composition
```

**Save to:** `../my-bakery-site/app/page.tsx`

**Verification:**
- ✅ app/page.tsx exists
- ✅ All components imported
- ✅ Data flow correct

---

## PHASE 6: TESTING & VALIDATION

### STEP 16: Development Server Test (5 min)
```bash
cd ../my-bakery-site
npm run dev
```

**Open:** http://localhost:3000

**Check:**
- ✅ Header loads with navigation
- ✅ Hero section displays
- ✅ Services cards render
- ✅ Contact form visible
- ✅ Footer appears
- ✅ Mobile menu works
- ✅ No console errors
- ✅ All links functional

---

### STEP 17: Build Production (3 min)
```bash
npm run build
```

**Verification:**
- ✅ Build completes successfully
- ✅ No TypeScript errors
- ✅ No build warnings
- ✅ .next/ folder created

---

### STEP 18: Optional - Lighthouse Audit (5 min)
```bash
# Install Lighthouse
npm install -g lighthouse

# Run audit
lighthouse http://localhost:3000 \
  --output json \
  --output-path ./lighthouse-report.json \
  --only-categories=performance,accessibility,seo,best-practices
```

**Target Scores:**
- ✅ Performance: ≥90
- ✅ Accessibility: ≥95
- ✅ Best Practices: ≥95
- ✅ SEO: ≥90

---

## PHASE 7: FINALIZATION

### STEP 19: Git Commit (2 min)
```bash
git init
git add .
git commit -m "Initial build: Header, Hero, Services, Contact, Footer"
```

**Verification:**
- ✅ Git repository initialized
- ✅ All files committed
- ✅ Clean git status

---

### STEP 20: Documentation (3 min)
Create `README.md` in project:
```markdown
# My Bakery Site

Built using CH405 component library

## Components Used
- button, card, navigation-menu, input, textarea

## Run Locally
npm install
npm run dev

## Build
npm run build
```

**Verification:**
- ✅ README.md created
- ✅ Run instructions clear

---

## COMPLETE FILE CHECK
```
my-bakery-site/
│
├── app/
│   ├── page.tsx                    ✅ Step 15
│   ├── layout.tsx                  ✅ Auto-created
│   └── globals.css                 ✅ Auto-created
│
├── components/
│   ├── ui/                         ✅ Step 6
│   │   ├── button.tsx
│   │   ├── card.tsx
│   │   ├── input.tsx
│   │   ├── navigation-menu.tsx
│   │   └── textarea.tsx
│   ├── layout/                     
│   │   ├── Header.tsx              ✅ Step 10
│   │   └── Footer.tsx              ✅ Step 14
│   └── sections/
│       ├── Hero.tsx                ✅ Step 11
│       ├── Services.tsx            ✅ Step 12
│       └── Contact.tsx             ✅ Step 13
│
├── data/
│   ├── site-content.json           ✅ Step 9
│   └── owner.json                  ✅ Step 9
│
├── public/
│   └── icons/
│       ├── ui/                     ✅ Step 7
│       │   ├── menu.svg
│       │   ├── close.svg
│       │   ├── phone.svg
│       │   └── mail.svg
│       └── social/                 ✅ Step 7
│           ├── github.svg
│           ├── linkedin.svg
│           └── twitter.svg
│
├── src/
│   ├── config/
│   │   ├── site.ts                 ✅ Step 5
│   │   └── cloudinary.ts           ✅ Step 5
│   └── styles/
│       └── fonts.css               ✅ Step 5
│
├── package.json                    ✅ Step 3
├── tsconfig.json                   ✅ Step 3
├── tailwind.config.ts              ✅ Step 3
├── next.config.js                  ✅ Step 3
├── .gitignore                      ✅ Step 3
└── README.md                       ✅ Step 20
```

---

## TIMELINE SUMMARY

| Phase | Steps | Time | Status |
|-------|-------|------|--------|
| Pre-Build Setup | 1-2 | 3 min | ⬜ |
| Project Init | 3-7 | 15 min | ⬜ |
| Data Generation | 8-9 | 7 min | ⬜ |
| Component Building | 10-14 | 45 min | ⬜ |
| Integration | 15 | 5 min | ⬜ |
| Testing | 16-18 | 13 min | ⬜ |
| Finalization | 19-20 | 5 min | ⬜ |
| **TOTAL** | **1-20** | **~90 min** | ⬜ |

---

## SUCCESS CRITERIA

✅ All 20 steps completed  
✅ All files in checklist exist  
✅ Dev server runs without errors  
✅ Production build successful  
✅ Lighthouse scores ≥90  
✅ Git repository initialized  
✅ Documentation complete

---

**BUILD COMPLETE! 🎯**
