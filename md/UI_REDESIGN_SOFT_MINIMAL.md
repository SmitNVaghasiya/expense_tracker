# SpendWise — UI Redesign Spec (Soft Minimal)

**Last updated:** 2026-05-18
**Visual contract:** `New folder/soft-minimal-light.html` + (planned) `New folder/soft-minimal-dark.html`
**Scope:** Every user-facing screen rebuilt against one design system. Pairs with `Opus_plan.md` § Stage 1 + Stage 3 and `CODE_OPTIMIZATION_AND_SECURITY.md` § 3.2 (token discipline).
**Aesthetic:** Editorial minimal. Lots of negative space. Monospace numerals. Subtle borders, near-zero shadows, no decorative glyphs.

If anything in this file conflicts with `soft-minimal-light.html`, the HTML wins. The HTML is the contract; this file is the translation layer to Flutter.

---

## 0. Visual Vocabulary

The aesthetic is **document-sorter / archival editorial**:

- Surfaces look like cream paper.
- Type is utilitarian-elegant (Plus Jakarta Sans display, IBM Plex Mono for amounts and codes).
- Borders are hairline (1 px, low-contrast).
- Color is restrained — neutrals dominate; semantic color (green/red/amber) appears only for income/expense/warnings.
- No gradients. No drop-shadows beyond a single 1 px ambient on the FAB. No glassmorphism, no neumorphism.
- Everything rounded but lightly — radii 8 / 10 / 12 / 16. No pill-shaped "soft" cards.

---

## 1. Design Tokens

Single source of truth: `lib/core/design_system.dart`. **Every** color, spacing, radius, font size, shadow comes from here. The HTML's `T` object maps 1-to-1 to these classes.

### 1.1 Colors

```dart
class AppColors {
  // ── Light ────────────────────────────────────
  static const bg          = Color(0xFFFAFAF9); // page background
  static const surface     = Color(0xFFF2F2F0); // sunken / muted fills (icon tile, key)
  static const card        = Color(0xFFFFFFFF); // raised surfaces
  static const border      = Color(0xFFE4E4DE); // hairline 1 px
  static const ink         = Color(0xFF1C1C1A); // primary text
  static const ink2        = Color(0xFF6B6B64); // secondary text
  static const ink3        = Color(0xFFACACAA); // tertiary / labels
  static const accent      = Color(0xFF18181B); // brand action (near-black)
  static const accentBg    = Color(0xFFF0F0EE); // tinted muted accent

  static const ok          = Color(0xFF15803D); // income / positive
  static const okBg        = Color(0xFFF0FDF4);
  static const danger      = Color(0xFFDC2626); // expense / destructive
  static const dangerBg    = Color(0xFFFEF2F2);
  static const warn        = Color(0xFFD97706); // over-budget, due-soon
  static const warnBg      = Color(0xFFFFFBEB);

  // Category palette (used only by category chips + chart series)
  static const c1 = Color(0xFFDC2626); // food
  static const c2 = Color(0xFF2563EB); // transport
  static const c3 = Color(0xFFD97706); // shopping
  static const c4 = Color(0xFF15803D); // bills
  static const c5 = Color(0xFF7C3AED); // entertainment

  // ── Dark (mirror of soft-minimal-dark.html when written) ────
  static const bgDark      = Color(0xFF111110);
  static const surfaceDark = Color(0xFF1C1C1A);
  static const cardDark    = Color(0xFF242422);
  static const borderDark  = Color(0xFF2E2E2C);
  static const inkDark     = Color(0xFFFAFAF9);
  static const ink2Dark    = Color(0xFFA0A09C);
  static const ink3Dark    = Color(0xFF5A5A58);
  static const accentDark  = Color(0xFFE8E8E4); // light pill on dark
  static const accentBgDark= Color(0xFF1C1C1A);
}
```

### 1.2 Spacing

```dart
class AppSpacing {
  static const s2 = 2.0;
  static const s4 = 4.0;
  static const s6 = 6.0;
  static const s8 = 8.0;
  static const s10 = 10.0;
  static const s12 = 12.0;
  static const s14 = 14.0;
  static const s16 = 16.0;   // standard page edge inset
  static const s18 = 18.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
}
```

Default page inset: `s16` left/right. Cards inside use `s12` to `s18` inner padding.

### 1.3 Radius

```dart
class AppRadius {
  static const r8  = 8.0;   // chips, keypad, icon tiles
  static const r10 = 10.0;  // transaction rows, search, note input
  static const r12 = 12.0;  // budget bars, list cards
  static const r16 = 16.0;  // hero cards (balance, account)
  static const pill = 8.0;  // matches HTML `pill: 8` for filter chips, segmented controls
  static const fab = 12.0;  // FAB radius (pill + 4 in HTML)
}
```

### 1.4 Typography

```dart
class AppText {
  static const fontFamily = 'PlusJakartaSans';
  static const monoFamily = 'IBMPlexMono';

  // Numbers (always monoFamily)
  static const heroNumber = 38.0; // net balance
  static const bigNumber  = 48.0; // calculator amount
  static const num        = 15.0; // income/expense pair
  static const numSmall   = 12.5;

  // Text (fontFamily)
  static const screenTitle = 22.0; // "Records", "Reports", section pages
  static const sectionTitle = 15.0;
  static const cardTitle   = 12.5;
  static const rowTitle    = 12.0;
  static const body        = 12.0;
  static const label       = 11.0;
  static const tiny        = 9.5;
  static const tinier      = 9.0;

  // Letter-spacing for uppercase mono labels: 0.10em
}
```

### 1.5 Shadows

```dart
class AppShadow {
  // Cards: no shadow. Borders carry visual weight.
  static const none = <BoxShadow>[];

  // FAB only
  static List<BoxShadow> get fab => const [
    BoxShadow(color: Color(0x4018181B), blurRadius: 16, offset: Offset(0, 4)),
  ];
}
```

Hairline border is the visual separator. Do not add shadow to cards.

---

## 2. Shared Widgets

Build these once in `lib/core/widgets/`. They consume tokens, nothing hardcoded.

| Widget | Purpose | Tokens used |
|---|---|---|
| `AppCard` | Standard raised surface — `card` bg, 1 px `border`, `r12` | colors, radius |
| `AppHeroCard` | Bigger raised surface for balance/account — `r16`, `s18` padding | colors, radius, spacing |
| `AppDivider` | 1 px `border` line | colors |
| `AmountText` | Mono font, sign-colored (`+` green, `−` red), accepts `int paise` + locale | mono font, ok/danger |
| `LabelText` | Uppercase mono micro-label (10 px, 0.10em tracking, `ink3`) | mono, ink3 |
| `SectionHeader` | Bold 12 px title + optional "View all" link in `accent` | colors, text |
| `AppPill` | Filter chip / segmented option. Selected = `accent` bg `#fff` text; unselected = `surface` bg `ink2` text | colors, radius |
| `AppButtonPrimary` | 46 px tall, `pill` radius, `accent` bg, white text, 13 px 700 | accent |
| `AppButtonGhost` | Text-only `accent` color | |
| `AppKeypadButton` | 42 px, `card` bg, `r8`, mono 17 px. Backspace variant uses `accentBg` + `accent` text | |
| `AppEmptyState` | Centered icon + 14 px title + 11 px subtext + optional CTA | |
| `AppProgressRing` | Stroke 4 px, `accent` arc on `surface` track. Used for budgets, goals | |
| `AppProgressBar` | 4 px tall, `r99`, `accent` fill on `surface` track | |
| `BottomNavBar` | 72 px, `card` bg, `border` top. 4 tabs + center FAB. Active tab = `accent` filled pill with 9 px white label | |
| `StatusBarSpacer` | 44 px height — phone status bar margin (real device: `MediaQuery.padding.top`) | |
| `AppSearchField` | 9 px 12 px padded `card` row with 🔍 prefix, `r10`, `border` | |

Soft rule: do not create a new shared widget until the pattern appears in 3+ places. Premature abstraction is the second-most-common failure mode after color sprawl.

---

## 3. Screen-by-Screen Specs

Maps directly to screens in `soft-minimal-light.html`. For each screen: layout, components, behavior. Cross-reference HTML line ranges where helpful.

### 3.1 Home Dashboard (HTML § HomeScreen)

**Layout (top → bottom):**

1. **Greeting block** — `s16` page inset.
   - "MAY 2026" — mono 10 px, `ink3`, 0.12em tracking, uppercase.
   - "Good morning, Smit" — 13 px 500, `ink2`.
2. **Balance hero card** — `AppHeroCard`, margin `s12 / s16 / 0`.
   - Label "NET BALANCE" (`LabelText`).
   - Big number "₹12,450" — mono 38 px 600, `ink`, letter-spacing -0.045em.
   - Hairline divider, then two-column footer: Income (mono 15 px `ok`) and Expense (mono 15 px `danger`) split with vertical 1 px border.
3. **Budget strip** — `AppCard`, `r12`, padding `s14 / s14`.
   - Row: "Budget · May" (12 px 600) left, "72%" (mono 10 px `ink3`) right.
   - 4 px progress bar.
   - Caption: "₹32,550 spent · ₹12,450 left" (mono 9.5 px `ink3`).
4. **Recent section.**
   - `SectionHeader`: "Recent" (12 px 700 `ink`) + "View all" (`accent`).
   - 5 transaction rows: `AppCard`, `r10`, padding `s10 / s11`. Icon tile (34 sq, `r8`, `surface` bg, emoji). Name 12 px 600. Sub `cat · date` 9.5 px `ink3`. Amount mono 12 px right.

**FAB:** floating from `BottomNavBar` — center cutout, opens `AddTransactionScreen`.

**Empty state:** "Add your first transaction" with `AppButtonPrimary`.

**Refresh:** pull-to-refresh re-runs the home query — but underlying data is reactive so this is just a re-bind, not a network call.

### 3.2 Records / Transactions (HTML § RecordsScreen)

- **Header:** screen title "Records" (22 px 700 `ink`, letter-spacing -0.03em). Subtitle "May 2026" (mono 11 px `ink3`).
- **Search field** — `AppSearchField` placeholder "Search transactions...". Live-filter, no separate button.
- **Tab bar (inline):** All / Expenses / Income.
  - Active = `ink` 700 with 2 px `accent` bottom border. Inactive = `ink3` 500.
  - Hairline `border` baseline.
- **Grouped list:** sticky day headers (Today / Yesterday / DD MMM). Mono 10 px uppercase 0.10em.
  - Rows: icon (36 sq), name (12.5 px 600), cat (mono 9.5 px `ink3`). Right column: amount (mono 12.5 px sign-colored), date (mono 9 px `ink3`).
- **Filter sheet:** bottom sheet, opens via icon to the right of search.
  - Sections: Date range (chip row of presets + custom), Categories (multi-select chips), Accounts (multi-select chips), Amount range (two number inputs).
  - "Apply" button (`AppButtonPrimary`), "Reset" (`AppButtonGhost`).

### 3.3 Add Transaction (Calculator) (HTML § AddScreen)

This is the highest-traffic screen. Make it feel instant.

- **Header strip:** back chevron in 30-sq surface tile. Title "Add Transaction" (15 px 700). Right segmented control [Expense | Income]:
  - Selected segment = solid `danger` (expense) or `ok` (income) bg, white text. Unselected = `surface` bg `ink3` text.
- **Expression line:** mono 10 px above the amount, e.g. `200 + 140`.
- **Amount line:** mono 48 px 600, letter-spacing -0.045em. Blinking 2×3 cursor pip in `accent`.
- **Category chips row:** horizontal wrap of 26 px-tall pills (`r8`). Selected chip = `accent` bg white text. Otherwise `surface` bg `ink2` text.
- **Note field:** `AppCard` row with 📝 prefix, label "NOTE" (mono uppercase), and 12 px placeholder/value.
- **Keypad grid:** 3-column, 6-row layout. Keys: 1–9, `.`, 0, `⌫`.
  - Backspace key uses `accentBg` bg + `accent` text. Other keys: `card` bg.
  - 42 px tall, `r8`, mono 17 px 600.
  - Long-press `⌫` clears all.
  - Optional operator column on the right edge (+, −, ×, ÷, =) — feature gated to a "calculator mode" toggle; default mode is single-amount.
- **Save button:** full-width 46 px tall `AppButtonPrimary` at the bottom (`pill` radius).
- **Account selector:** small chip below note. Tap → bottom sheet of accounts. Remembers last-used per type.
- **Date selector:** small chip on the right of the segmented control. Tap → date picker.

### 3.4 Accounts

- Screen title "Accounts". Subtitle "3 accounts · ₹68,450 total".
- Per-account card: `AppHeroCard`.
  - Left: account name (14 px 700), masked number (mono 10 px `ink3`).
  - Right: balance (mono 18 px 600 sign-colored). Negative = `danger`.
  - Footer row: "This month: +₹32,000 / −₹19,750" (mono 10 px).
- Add account FAB (only on this tab, not from bottom nav center).
- Tap card → account detail (transactions of that account, monthly totals chart).
- Long-press card → action sheet (Edit, Archive).

### 3.5 Budgets

- Tab title "Budgets".
- Horizontal month chip selector (scrollable). Active month = `accent` pill.
- Overall budget hero card:
  - Big `AppProgressRing` (left) + "₹32,550 / ₹45,000" stacked (right), "₹12,450 left · 9 days" caption.
- Category budget list: each row is `AppCard` with mini `AppProgressRing` (28 px) + category name + spent / total + remaining caption.
  - Bar color uses the category's palette color (`c1`–`c5`); track is `surface`.
  - Over-budget rows have a `warn` left border (3 px).
- Tap row → category detail (transactions within budget + edit).

### 3.6 Loans (split brain killer — single screen, segmented filter)

- Title "Loans". Subtitle counts e.g. "3 active · ₹24,23,000".
- Filter pill row: All / I Lent / I Borrowed / Bank / Settled. `AppPill` widget.
- List card per loan:
  - Personal: name + direction badge ("Lent" green / "Borrowed" red), amount mono, date, note (truncated).
  - Bank: bank name + "EMI ₹19,840 / mo" + paid/total progress bar.
- Add screen — top segmented control `[Personal] [Bank Loan]`:
  - Personal form: Person, Direction (Lent/Borrowed), Amount, Date, Notes. Toggle "Add interest" reveals Rate / Type (simple/compound) / Period (monthly/yearly) / Duration (months) — all optional.
  - Bank form: Name, Principal, APR%, Term (months), Start date, Linked account. Auto-shows computed EMI and total interest in a footer card.
- Detail screen (Bank):
  - EMI hero (big mono number).
  - Paid vs Remaining `AppProgressBar`.
  - Amortization table (sticky header: Month | Principal | Interest | Balance). Mono numbers throughout.
  - "What if you pay extra?" panel — two inputs (Extra monthly / One-time lump sum) + outputs (months saved, interest saved). Compute on input change; debounce 200 ms.
- Detail screen (Personal):
  - Person, amount, date, optional interest detail.
  - "Mark as settled" button — confirm dialog + soft-delete + green check animation.

### 3.7 Reports

- Date range chip row top: Today / This Week / This Month / Last Month / Custom.
- Tab bar: Overview / Analytics / Budget / Trends.
- **Overview:** 4 stat cards in 2×2 grid (Income, Expense, Savings rate, Net change).
- **Analytics:** two donut charts side-by-side (Expense by category, Income by source). Below: top 5 categories list per donut.
- **Budget:** per-category bar chart (current vs limit). Below: list view.
- **Trends:** 12-month line chart (income + expense lines, `ok` and `danger`). Tap a point → drill-in to that month's records.

### 3.8 Financial Goals

- Goal card: emoji + name, target/saved, `AppProgressRing`, "Aug 2026" deadline mono 10 px.
- Tap → detail with contributions list and "Add contribution" button.
- "On-track" badge if saved ≥ pro-rated target by date. Otherwise `warn` "Behind" badge.

### 3.9 Bills & Reminders

- Upcoming bills list grouped by week.
- Each row: bill name + due date + amount + status pill (Upcoming / Due / Overdue / Paid).
- Tap → detail / mark paid.
- Notification scheduled 1 day before due (Stage 5).

### 3.10 Group Spending (Stage 4 — new UI)

- Groups list card per group: name, member count, "You owe ₹X" or "You're owed ₹Y" with sign-colored amount.
- Group detail: members list, expense list, settlement summary block ("A owes B ₹500").
- Add expense: title, amount, paid-by selector, split-between multi-select, split type (Equal / Shares / Percentages / Exact).
- Mark settled: per-debt action.

### 3.11 Settings

Grouped list, `AppCard` group containers (`r12`, `s14` padding).

- **Appearance**
  - Theme: Light / Dark / System (segmented).
  - Accent variant (locked to Soft Minimal until D-002 changes).
- **Privacy & Security**
  - App Lock (toggle). When ON:
    - Auto-lock after: 0 s (immediate) / 30 s / 60 s / 5 min.
    - Unlock with biometric: toggle (visible if device supports).
    - Change PIN.
  - Disclaimer line under: "Forgot PIN means restore from backup. There is no reset."
- **Data**
  - Backup now → exports SQLite snapshot.
  - Restore from snapshot → list of auto-backups.
  - Import CSV / Export CSV.
  - Clear all data (danger, double-confirm).
- **App**
  - Currency picker.
  - Default account.
  - About / Version / Open-source licenses.

### 3.12 Onboarding (Stage 5/6)

3 screens max:

1. Welcome + currency.
2. Create first account.
3. Add first transaction (with tutorial overlay).

Skippable. "You can do this later in Settings" footnote.

---

## 4. Navigation Structure

`BottomNavBar` (4 tabs + center FAB):

| Slot | ID | Icon | Label |
|---|---|---|---|
| 1 | home | ⊞ | Home |
| 2 | records | ◧ | Records |
| 3 | (FAB) | + | Add (Calculator) |
| 4 | finance | ◫ | Finance |
| 5 | reports | ◈ | Reports |

**Finance tab** is a sub-screen with horizontal segmented control (Accounts / Budgets / Loans / Goals).

**More entries** (Settings, Bills, Recurring, Group Spending, Backup) live in Home top-right "menu" icon → modal route to a More screen.

Drawer is removed. Bottom nav + More screen replaces it.

---

## 5. Motion + Interaction

- **Page transitions:** Cupertino-style horizontal slide on push, fade on bottom-nav tab swap.
- **FAB tap:** scale 0.92 → 1.0 spring (200 ms).
- **Save button success:** brief 300 ms scale 1.0 → 0.96 → 1.0, color flashes `ok`, then SnackBar "Saved. Tap to view." with Undo for delete operations.
- **Toggle changes:** instant; settings persist in `SharedPreferences` immediately (no save button).
- **Charts:** animate-in once on first render (400 ms ease-out). Updates do not animate (avoid jitter).
- **Keypad press:** light haptic + 50 ms color flash on key bg from `card` → `surface`.

---

## 6. Accessibility

- All text contrast meets WCAG AA against its background. The `ink3` (#ACACAA) is below AA on `bg` (#FAFAF9) for body sizes — **only use `ink3` at ≥ 10 px and only for labels, never primary content.**
- Tap targets ≥ 44×44 logical pixels. Keypad keys are 42 — bump to 44 in Flutter implementation.
- Semantic labels on every icon-only button.
- Dynamic Type: scale all `AppText` sizes proportionally to `MediaQuery.textScaleFactor`, capped at 1.3× to prevent layout breakage.
- Dark theme parity (when `soft-minimal-dark.html` lands).

---

## 7. Dark Mode

When `soft-minimal-dark.html` is generated (D-002 deferred), mirror the same widgets with `AppColors.*Dark` variants. The `ThemeData` switch is the only change. **No screen file should branch on theme.** All bg/border/text reads `Theme.of(context).extension<AppColorsExt>()`.

If `soft-minimal-dark.html` is not yet generated, the dark color values in § 1.1 are the working contract — update them on first render of the dark HTML.

---

## 8. What This Spec Replaces

- All hardcoded `Color(0xFF...)` in `lib/screens/**`.
- All ad-hoc `Container(decoration: BoxDecoration(...))` for surfaces — use `AppCard`.
- All custom progress widgets — use `AppProgressRing` / `AppProgressBar`.
- The drawer — replaced by bottom nav + More screen.
- Reports → Trends placeholder — replaced by 12-month line chart.
- Loans dual-tab UI — replaced by single filter-pill list.

---

## 9. Order of Implementation (maps to `Opus_plan.md` Stage 3)

1. `lib/core/design_system.dart` (tokens) — § 1.
2. Shared widgets — § 2.
3. Rebuild Financial Goals as proof-of-concept (smallest screen).
4. Bottom navigation restructure — § 4.
5. Home → Records → Add (highest-traffic surfaces).
6. Accounts → Budgets → Reports.
7. Loans (full rebuild, biggest screen).
8. Settings (incl. Privacy & Security from `CODE_OPTIMIZATION_AND_SECURITY.md` § 5).
9. Group Spending UI (new feature).
10. Dark theme switch.
11. Onboarding (Stage 5/6).

Each screen merges in its own commit. CI lint forbids hardcoded hex / spacing in `lib/screens/**` after step 1 lands.
