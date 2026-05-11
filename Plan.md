# SpendWise — Full Project Plan

**Last updated:** 2026-05-11  
**App:** SpendWise (Flutter / SQLite / Provider)  
**Scope:** Personal use. Not commercial.

---

## What I Read to Write This

- `remaining_tasks.md` — your running dev diary (Aug 12–27, 2025)
- `errors.md` — original critical issues list
- `errors2.md` — UI/UX and advanced enhancement requests  
- `PERFORMANCE_OPTIMIZATIONS.md` — what the optimization pass did and why
- `README.md` — feature documentation
- Live code audit (8 screens, all models, services layer)

---

## My Understanding of Your Original Plan

You were building a personal finance app because market apps:
- Lock features behind subscriptions
- Are ugly or inconsistent
- Don't handle informal loans (friends/family) well
- Don't let you own your data

Your rough build order was:

1. Get core working (transactions, accounts, budgets) — **done**
2. Fix performance (data appearing slow after save) — **attempted via "optimized" files**
3. Improve loan module (personal + bank loans with amortization) — **partial**
4. Add reports/analytics — **partial (Trends tab empty)**
5. Redesign UI to be consistent and clean — **not started**
6. Add missing features (group spending, receipt photo, net worth) — **not started**

---

## Where You Are Right — And Where the Plan Went Wrong

### ✅ Correct decisions

**Building local-first with SQLite** — right call. Full data ownership, no subscriptions, works offline. Not changing this.

**Loan module vision** — personal (friends/family) + formal bank loans (with amortization simulation) is genuinely a killer feature market apps do badly. The model you described is correct.

**Using Provider + ChangeNotifier** — fine for an app this size. No need to switch to Bloc or Riverpod.

**Adding optimistic updates** — right idea. The PERFORMANCE_OPTIMIZATIONS.md described the correct pattern: update UI immediately, persist in background.

**Keeping feature count focused** — not trying to be everything. Smart.

---

### ❌ Where it went wrong

**The "optimized" files created a split-brain app.**

When performance was added, parallel files were created:
- `optimized_home_screen.dart` alongside `home_screen.dart` (now deleted)
- `optimized_budgets_screen.dart` alongside `budgets_screen.dart`
- `optimized_app_state.dart` alongside `app_state.dart`
- `optimized_data_service.dart` alongside `data_service.dart`

These files exist at different stages of completion and use different patterns. The result: **UI inconsistency is baked into the file structure itself.** Two screens written with different patterns will never look the same without a full design system.

**Half-built features are visible to users.**

The loans screen has a search bar and 6 filter options that do nothing (TODO comments in code). The Reports Trends tab shows placeholder text. Group spending has a full model but zero UI. Users see broken things, not incomplete things — that's worse.

**No design system = every screen reinvented the wheel.**

Some screens use `Theme.of(context).colorScheme.*`, others hardcode hex values. Some use `Card()`, others use `Container` with manual `BoxDecoration`. Some use `SizedBox(height: 16)` for spacing, others have 35+ hardcoded values. Without a shared design token file, every screen diverges.

**Budget month navigation crashes on January.**

`DateTime(_selectedMonth.year, _selectedMonth.month - 1)` when month is 1 gives `DateTime(year, 0)` — month 0 does not exist in Dart. This is a live crash.

---

## Current State — Honest Screen-by-Screen

| Screen | Complete | Visible Problems |
|--------|----------|-----------------|
| Home / Dashboard | 75% | Inefficient nesting, setState spam, not instant on tab change |
| Expenses / Income | 100% | Wrapper only — clean |
| Calculator (Add Transaction) | 85% | Working but needs polish |
| Accounts | 95% | `debugPrint` in prod, sort state not persisted, duplicate Add buttons |
| Budgets | 70% | **January crash**, 35+ hardcoded SizedBox, no input validation |
| Loans | 60% | Search/filter UI shows but **does nothing** — dead UI visible to user |
| Bill Reminders | 95% | Complete |
| Recurring Transactions | 90% | Complete |
| Reports — Overview | 75% | Working |
| Reports — Analytics | 70% | Working |
| Reports — Budget | 65% | Working |
| Reports — Trends | 10% | **Placeholder text visible to user** |
| Financial Goals | 85% | Complete, UI could be cleaner |
| Settings (all) | 90% | Working |
| **Group Spending** | 0% UI | Model exists, zero screens — feature invisible |

---

## The Full Plan

Organized into 5 phases. Do them in order — polishing broken code wastes time.

---

### Phase 0 — Fix Crashes and Hidden Dead UI (Do First, 2–3 days)

These must happen before any UI work. They are user-facing bugs.

**0.1 Fix January budget crash**
- File: `lib/screens/financial/budgets_screen.dart`
- Fix: `DateTime(_selectedMonth.year, _selectedMonth.month - 1)` → use `DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1)` with month rollover guard
- Real fix: `month == 1 ? DateTime(year - 1, 12) : DateTime(year, month - 1)`

**0.2 Fix loans search/filter**
- File: `lib/screens/financial/loans_screen.dart`
- Decision: implement real search (filter in-memory against loaded list) OR remove the TextField and PopupMenu until implemented
- Recommend: implement. It's just in-memory filter on already-loaded data — 30 lines max.

**0.3 Fix or remove Reports Trends tab**
- File: `lib/screens/reports/reports_tab_screen.dart`
- Decision: build a real spending trend line chart (monthly totals over 12 months using fl_chart `LineChart`) OR remove the Trends tab
- Recommend: build it. Data is already in DB. A 12-month line chart is straightforward with fl_chart.

**0.4 Remove all `debugPrint` from production**
- Files: `lib/screens/financial/accounts_screen.dart` (lines 544, 546, 553) and any others
- Use grep to find all `debugPrint` calls across lib/

**0.5 Fix duplicate Add button in Accounts**
- File: `lib/screens/financial/accounts_screen.dart`
- Both FAB and AppBar action button exist. Remove the AppBar one.

---

### Phase 1 — Design System (Foundation, 3–4 days)

Build `lib/core/design_system.dart`. This is the single source of truth for colors, spacing, typography, and shadows. Every screen reads from this. Once this exists, inconsistency becomes fixable in one place.

**Color palette** — inspired by document-sorter design you showed me:
```dart
class AppColors {
  // Backgrounds
  static const bg          = Color(0xFFF5F2EE); // warm cream
  static const surface     = Color(0xFFFFFFFF); // card
  static const surfaceAlt  = Color(0xFFF0EDE8); // subtle alt
  static const divider     = Color(0xFFEBE6DE); // hairline border

  // Text
  static const ink         = Color(0xFF14110F); // near-black warm
  static const subtext     = Color(0xFF7A736B); // muted warm grey

  // Semantic
  static const income      = Color(0xFF4A8C5C); // muted green
  static const expense     = Color(0xFFB05050); // muted red
  static const accent      = Color(0xFF6B9E7A); // sage green (brand)
  static const warning     = Color(0xFFD4853A); // amber
  static const loan        = Color(0xFF5B7FA6); // slate blue

  // Dark theme variants (auto via ThemeData)
  static const bgDark      = Color(0xFF1A1714);
  static const surfaceDark = Color(0xFF242019);
  static const dividerDark = Color(0xFF332E28);
}
```

**Spacing system** — replace ALL hardcoded SizedBox values:
```dart
class AppSpacing {
  static const s4  = 4.0;
  static const s8  = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
}
```

**Typography scale:**
```dart
class AppText {
  static const h1     = 28.0; // screen titles
  static const h2     = 22.0; // section headers
  static const h3     = 17.0; // card titles
  static const body   = 14.5; // body copy
  static const label  = 12.0; // labels, captions
  // All money amounts use monospace: 'Roboto Mono' or system mono
}
```

**Shared widgets to build:**
- `AppCard` — replaces all `Container + BoxDecoration` patterns. Handles light/dark automatically.
- `AppButton` — primary (filled) and secondary (outlined). Replaces all custom buttons.
- `AppEmptyState` — unified empty state widget with icon, title, subtitle, optional action button.
- `AmountText` — monospace font widget for all money values. Handles currency symbol, positive/negative color.
- `SectionHeader` — consistent section label styling.

---

### Phase 2 — Navigation Restructure (2 days)

The current drawer with 16 items is the biggest UX problem in the app.

**Replace drawer with Bottom Navigation Bar (5 tabs):**

| Tab | Icon | Label |
|-----|------|-------|
| 1 | home | Home |
| 2 | receipt_long | Records |
| 3 | pie_chart | Reports |
| 4 | account_balance_wallet | Finance |
| 5 | more_horiz | More |

- **Home** — Dashboard (current home screen)
- **Records** — Transactions (expenses, income, transfers in one tabbed screen)
- **Reports** — Reports tab screen (Overview, Analytics, Budget, Trends)
- **Finance** — Accounts, Budgets, Loans, Financial Goals (sub-navigation inside)
- **More** — Bill Reminders, Recurring, Settings, Backup, Help

**Remove the Drawer completely** after bottom nav is working.

**FAB behavior:** FAB appears on Home and Records tabs only, opens the Add Transaction (calculator) screen.

---

### Phase 3 — Screen-by-Screen UI Redesign (1–2 weeks)

Apply design system to each screen. Priority order:

**3.1 Home Dashboard**
- Background: `AppColors.bg` (warm cream, not white)
- Large balance card at top: total net worth (all accounts combined)
- Income vs expense summary row (this month)
- Recent transactions list (last 10, grouped by today/yesterday/date)
- FAB for quick add

**3.2 Records (Transactions)**
- Tab bar: All | Expenses | Income (remove Transfer from filter tabs)
- Transaction cards: category icon with color dot, title, amount in `AmountText`, date
- Search in a persistent search bar at top (not buried in dialog)
- Filter: bottom sheet with date range, category, account selectors

**3.3 Budgets**
- Fix month navigation crash
- Month selector: horizontal scrolling month chips, not a dropdown calendar
- Budget cards: circular progress ring instead of `LinearProgressIndicator`
- Overall budget at top as a hero card
- Category budgets in a list below

**3.4 Loans (complete redesign)**

See Phase 4 — Loan Module below.

**3.5 Reports**
- Build real Trends tab (12-month line chart)
- Side-by-side pie charts for category breakdown
- Date range selector as a persistent chip row at top of tab

**3.6 Accounts**
- Net worth hero number at top
- Account cards: simple, show account name, type icon, balance in `AmountText`
- Tap card → account detail sheet showing transactions for that account
- Remove duplicate Add button

**3.7 Financial Goals**
- Progress ring per goal
- Amount remaining + target date countdown

---

### Phase 4 — Loan Module Complete Build (4–5 days)

This is your most distinctive feature. Build it properly.

**Two loan types, one screen:**

```
[ Personal ] [ Bank Loan ]     ← segmented control at top of Add screen
```

**Personal Loan (simple):**
- Who (person name, text field)
- Direction (I gave money / I received money)
- Amount
- Date
- Notes (optional)
- Interest (optional toggle) → if on: rate, calculation basis (monthly/yearly), duration

**Bank Loan (formal):**
- Loan name (e.g., "Home Loan - HDFC")
- Principal amount
- Interest rate (APR %)
- Loan term (months)
- Start date
- Linked account (for payment deductions)
- → App auto-calculates EMI (monthly payment)

**Loan Detail Screen (for bank loans):**
- EMI amount (large, prominent)
- Amount paid vs remaining
- Amortization table (scrollable, shows principal/interest split per month)
- **"What if I pay extra?" simulator:**
  - Input: extra monthly amount OR one-time lump sum
  - Output: months saved, interest saved

**Loan List Screen:**
- Single list (not two tabs)
- Filter pills: All | I Owe | Owed to Me | Bank Loans
- Status badges: Active / Settled / Overdue
- Tap → detail screen

---

### Phase 5 — Missing Features (prioritized, implement after Phases 0–4)

These are good ideas but do them after the core is solid.

**P1 (High value, build soon):**
- **Net worth view** — sum of all accounts minus active loans. Show on Home screen.
- **Transaction search** — real text search across description, category, amount
- **Quick add from notification/widget** — Android home screen widget showing balance + quick-add button
- **Spending insights** — "You spent 34% more on Food this month vs last 3 months"

**P2 (Medium value):**
- **Group spending** — build UI for existing group model. Add members, split expense, track who paid what, settlement summary
- **Receipt photo attachment** — camera/gallery picker, store image path on transaction
- **Category deletion with migration** — allow deleting category, prompt to reassign existing transactions
- **Biometric app lock** — `local_auth` package, PIN or fingerprint to open app

**P3 (Future, don't rush):**
- CSV export to PDF (actual PDF, not just CSV)
- Investment tracking (stocks, mutual funds, FDs)
- Google Drive auto-backup
- Home screen widget (Android)

---

## .gitignore — Update Required

Current .gitignore is missing important entries. Replace with:

```gitignore
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.build/
.buildlog/
.history
.svn/
.swiftpm/
migrate_working_dir/

# IntelliJ / Android Studio
*.iml
*.ipr
*.iws
.idea/

# VS Code (keep launch.json if you want, but ignore workspace settings)
.vscode/settings.json
.vscode/tasks.json

# Flutter/Dart/Pub
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.pub-cache/
.pub/
/build/

# Android build artifacts
/android/app/build/
/android/build/
android/build/reports/          ← these huge HTML reports are in git now — should not be
android/.gradle/

# iOS build artifacts
ios/Pods/
ios/.symlinks/
ios/Flutter/Flutter.framework/
ios/Flutter/Flutter.podspec/

# Symbolication / Obfuscation
app.*.symbols
app.*.map.json

# Local environment and secrets
.env
*.env.local
google-services.json            ← if added later, never commit this
GoogleService-Info.plist        ← if added later, never commit this

# Project-specific tool dirs
/.agent/
/.claude/
/.planning/

# Planning docs that are work-in-progress (keep Plan.md, README.md)
errors.md
errors2.md
remaining_tasks.md
PERFORMANCE_OPTIMIZATIONS.md
document-sorter/

# OS
Thumbs.db
ehthumbs.db
Desktop.ini
```

**Critical:** `android/build/reports/` is currently committed (those 3 HTML files in git status). These are large generated files — remove them from git tracking.

---

## My Concerns

**1. The "optimized" vs "original" file split is the root cause of all UI inconsistency.**  
Having `optimized_home_screen.dart`, `optimized_budgets_screen.dart`, `optimized_app_state.dart` alongside their originals means the app has two competing architectures. Phases 1–3 above will resolve this by rebuilding screens on top of the design system — at that point, pick one version and delete the other.

**2. `shared_preferences` and `app_state` still coexist with SQLite in some flows.**  
The personal transaction feature originally used SharedPreferences. If any vestige of that remains after the loan module consolidation, it needs to be removed. All financial data must live in SQLite.

**3. The app has no error boundary.**  
If a database operation fails silently (optimistic update pattern), the UI shows success but data didn't save. There's no rollback confirmation shown to user. This needs a try/catch with user feedback (SnackBar) on failure.

**4. `flutter_lints` is in dev_dependencies but the code has many lint violations.**  
Running `flutter analyze` will surface these. Should be cleaned up during the design system phase since we'll be touching most files anyway.

**5. No app signing or build flavors configured.**  
This is a personal app so not urgent, but if you ever want to install it cleanly on your phone via `flutter build apk --release`, you need a keystore configured. Worth doing before Phase 3.

---

## New Ideas I'm Adding

**Idea 1: Monthly "finance report" notification**  
At end of each month, show a local notification summary: "October: you spent ₹24,500 across 47 transactions. Food was your biggest category at ₹7,200. You stayed under budget." One notification, no fluff. Requires data you already have.

**Idea 2: "Quick add" gesture on home screen**  
Long-press the FAB → shows 3 quick-add options (expense, income, loan payment) without going through the full calculator screen. For the most common actions, remove friction.

**Idea 3: Account-aware transaction form**  
When adding an expense, auto-select the account that was most recently used. Currently user must select account each time. Track last-used account per transaction type.

**Idea 4: "Settled" loan flow**  
When a personal loan is fully paid back, show a satisfying "Settled" animation and move it to a Settled section. Small dopamine hit. Good for habit forming.

**Idea 5: Spending calendar view**  
An optional calendar heatmap on the Reports tab showing spending intensity by day. Darker = more spent. Helps spot patterns (do you spend more on weekends?).

---

## What to Do First — Recommended Order

```
Week 1: Phase 0 (fix crashes, dead UI) + .gitignore cleanup
Week 2: Phase 1 (design system + shared widgets)
Week 3: Phase 2 (bottom nav) + Phase 3.1/3.2 (Home + Records redesign)
Week 4: Phase 3.3–3.7 (remaining screens)
Week 5: Phase 4 (Loan module)
Week 6+: Phase 5 features in priority order
```

Start Phase 0 today. Everything else builds on a stable, non-crashing foundation.
