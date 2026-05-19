# UI Audit — SpendWise Expense Tracker
*Analyzed against: frontend-design skill, ui-ux-pro-max-skill principles, awesome-design-md patterns, Dribbble 2025 finance app trends*

---

## Verdict First

**The UI is ugly. Not broken ugly — confused ugly.** It has no visual identity. Every screen feels like it was designed by a different person on a different day. The dark theme is half-committed. The colors fight each other. There is overflow on at least 3 screens visible in screenshots. This is not a polished MVP — it is a functional prototype wearing multiple unfinished costumes.

---

## Screen-by-Screen Breakdown

### Dashboard (Home)
**Problems:**
- Empty state is the ONLY thing showing. Giant "Add New Transaction" button dominates empty screen. No summary cards, no net worth widget, no "how are you doing this month" context. User opens app → sees nothing useful.
- "SpendWise" header uses `fontFamily: 'cursive'` — this is literally the CSS fallback font. Not a real font. Looks like a placeholder that was never replaced.
- Date nav: green chevrons feel random. Why green specifically? Nowhere else is green used for navigation.
- EXPENSE / INCOME / BALANCE summary row shows fine but sits below header with no visual separation or card treatment. Looks like floating text.
- Filter pills (All / Income / Expense) are fine but redundant with the tab system that was apparently removed.

**Severity: HIGH** — Home screen is the first impression. Currently it makes the app feel empty and unfinished.

---

### Add Transaction (Calculator Screen)
**Problems:**
- Orange `C` button + blue `+/-` operators + black number keys = 3 competing color families on one keyboard.
- `CANCEL` top-left splits into two lines ("CAN / CEL") — text overflow bug.
- Time format selector (AM/PM toggle) is jammed into the bottom with `24H / 12H` pills — visually disconnected from the rest of the form.
- No visual hierarchy. Account picker + Category picker look identical. Nothing guides the eye.
- The calculator pad feels copy-pasted from a calculator app, not designed for expense entry. Users expect: amount → category → account → note → save. Not a calculator.

**Severity: HIGH** — Core user action (adding a transaction) has the worst UX flow.

---

### Budgets Screen
**Problems:**
- 5 different card background colors on one screen: blue, dark-green, red/maroon, purple-ish green, teal. None of these are in `AppColors`. They are hardcoded inside the screen.
- ALL CAPS labels (`CATEGORY BUDGETS`, `OVERALL BUDGET`, `TOTAL SPENT`) inside tiny cards with colored backgrounds → impossible to read.
- "Budget O..." — truncated title. The word "Overview" is cut off. 
- `Budget Summary` section below repeats the exact same data as the header cards. Duplicated information with no added context.
- `Budget Insights` section is a 2×2 grid of green cards with small text — looks like a status dashboard, not actionable.
- The `+` FAB overlaps content on scroll — a well-known Flutter UX problem that was not handled.

**Severity: CRITICAL** — Most visually broken screen in the app.

---

### Budget Categories List (scrolled view)
**Problems:**
- Income categories and Expense categories use different section header colors (green for income, red for expense) — fine in principle but the green is too bright and doesn't match the dark theme.
- Category rows are clean but inconsistent icon background sizes/colors make the list feel noisy.
- `SET BUDGET` text link looks like an afterthought. No visual affordance that it's tappable beyond blue text.

**Severity: MEDIUM**

---

### Reports Screen
**Problems:**
- "Overview" tab just shows a blue card with Total Balance = ₹0.00. One card. Huge empty space below. This is a waste of screen.
- "Budget" tab shows a line chart that is completely flat at 0% with axis labels running together (`Jun 2025 20Aug 20Sep 20Oct 2025...`). The x-axis labels overlap and are unreadable.
- 3 summary pills (Category A..., Overall Ad..., Budget Util...) all truncated with `...`. Labels are cut off because the cards are too narrow for the text.
- The `+` FAB appears on the Reports screen — what does adding something do here? This is confusing.

**Severity: HIGH**

---

### Accounts Screen
**Problems:**
- Single white card on dark background. The CASH account card is light-colored while everything else is dark. Jarring visual mismatch.
- Green balance card at top is clean but generic — same green square used on every "total" card across the app.
- Barely any content. Screen feels unfinished.

**Severity: MEDIUM**

---

### Loans Screen
**Problems:**
- Clean and functional. Best-designed screen in the app.
- Minor: filter pills (All / Lent / Borrowed) use different radius than everything else.
- `handshake` icon in bottom nav is unusual and doesn't convey "loans" clearly.

**Severity: LOW**

---

### Backup & Restore Screen
**Problems:**
- `Import JSON` button text wraps to 3 lines inside an oval button: "Impor / t / JSON". Critical overflow bug.
- `Import CSV` similarly wraps.
- 3 buttons of different colors (orange, lavender/purple, blue) with no hierarchy logic.
- This screen looks like it was built in 10 minutes and never visually tested.

**Severity: HIGH** — Active overflow bug visible in production screenshot.

---

### Daily Reminder Screen
**Problems:**
- Bottom overflow by 21 pixels — visible yellow debug stripe in screenshot. This shipped with a layout bug.
- "How it works" card has a light blue background that looks completely out of place on a dark screen.
- "Tips for Better Tracking" card below has an emoji 💡 and a different background shade. Two cards, two different background colors, neither fits the dark theme.

**Severity: HIGH** — Active overflow bug.

---

### Add Loan / Financial Goal Modals
**Problems:**
- Financial Goals modal: `RIGHT OVERFLOWED BY 6.2 PIXELS` — visible in screenshot. Another layout bug.
- Goal Type dropdown (`Savings`) and Target Date field side-by-side cause the overflow.
- "Create" button at bottom uses `TextButton` style — no visual weight. Doesn't look like a primary action button.

**Severity: HIGH** — Active overflow bug.

---

### Delete & Reset Screen
**Problems:**
- Bottom overflow on "Reset All Data" card.
- The AppBar is blue on this screen — inconsistent with other screens that have dark AppBar.
- Decent information hierarchy otherwise.

**Severity: MEDIUM**

---

## Cross-Cutting UI Problems

### 1. No Consistent Color System
`AppColors` defines: primary=blue (#2196F3), accent=orange (#FF9800), success=green (#4CAF50).
But screens use Colors.blue, Colors.green, Colors.teal, Colors.purple, Colors.red, Colors.orange directly and individually. The color system is defined but **not followed**.

### 2. No Typography System
The app uses `fontFamily: 'cursive'` for the app name (not a real font). No custom fonts are imported in `pubspec.yaml`. All text uses the system default. No heading / body / caption size scale is defined or followed.

### 3. Dark Theme is Half-Done
Dark card = `#3A3A3A`. Dark background = `#2C2C2C`. Light-colored account cards, light blue info boxes, and inconsistent AppBar colors break the dark theme immersion constantly.

### 4. Multiple Active Layout Overflow Bugs
At least 3 screens have visible overflow bugs that shipped to production:
- Daily Reminder: bottom overflow 21px
- Financial Goal modal: right overflow 6.2px
- Delete & Reset: bottom overflow 7.2px
- Backup screen: button text wrapping

### 5. No Visual Identity
The app could be any app. Nothing says "finance" or "professional" or "trustworthy." Colors feel random. Layout feels template-generated. There is no moment of delight anywhere in the app.

### 6. FAB Confusion
The `+` FAB appears on Reports and other screens where its purpose is unclear. No tooltip shown consistently.

---

## What Professional Finance Apps Do (2025 Standard)

Based on research of Dribbble 2025 finance designs and design4users analysis:

| What pros do | What SpendWise does |
|---|---|
| One primary accent color + neutrals | 6+ competing colors per screen |
| Custom typography (Sora, DM Sans, Plus Jakarta) | System default / cursive fallback |
| Hero balance card with glassmorphism or gradient | Plain colored rectangle |
| Categorized spending with donut chart on home | Empty screen with a button |
| Subtle animations on number changes | No animations |
| Consistent card elevation system | Mix of 0dp, 2dp, random shadows |
| 8px grid spacing | Inconsistent padding/margin |
| Empty states with illustration + action | Grey icon + text |

---

## Summary Rating

| Dimension | Score | Notes |
|---|---|---|
| Visual Identity | 2/10 | No coherent style |
| Color Consistency | 3/10 | System defined, not followed |
| Typography | 2/10 | No custom fonts, no scale |
| Layout Correctness | 4/10 | Active overflow bugs on 3+ screens |
| Information Hierarchy | 4/10 | Budget screen fails completely |
| User Flow (Add Transaction) | 5/10 | Works but UX is clunky |
| Empty States | 3/10 | Uninformative and dull |
| Dark Mode Quality | 4/10 | Inconsistent — light elements bleed in |
| **Overall UI Score** | **3.4/10** | Needs full redesign |
