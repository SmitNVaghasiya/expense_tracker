# SpendWise — Complete Staged Rebuild Plan

**Last updated:** 2026-05-11
**App:** SpendWise (Flutter / SQLite / Provider)
**Scope:** Personal use first, Play Store launch as stretch goal
**Primary goals:** UI consistency, smooth performance, finish half-built features, fix what's invisible or broken

---

## Why This Plan Exists

The app works but doesn't feel good. Three real problems:

1. **UI is inconsistent and looks dated** — every screen reinvented the wheel because no design system exists. Some screens use `Theme.of(context).colorScheme`, others hardcode hex. Some use `Card()`, others use `Container + BoxDecoration`. The result is an app that feels stitched together.

2. **App feels laggy** — adding a transaction takes longer than it should to reflect in the UI. The "optimized" file split was an attempt to fix this but created a split-brain architecture instead. Two competing patterns now coexist.

3. **Several features are invisible or broken to the user** — Group Spending has a full data model and zero UI. Loans screen shows a search bar and 6 filters that do nothing. Reports → Trends shows placeholder text. Budgets crashes when you go past January. Users see broken things, which is worse than missing things.

This plan fixes these in order. **Crashes first, foundation second, redesign third, features fourth.** Polishing a crashing app wastes time.

---

## What I Read to Build This

- Existing `Plan.md` (your prior plan)
- `README.md` (feature documentation)
- `errors.md`, `errors2.md` (issue lists)
- `remaining_tasks.md` (dev diary)
- `PERFORMANCE_OPTIMIZATIONS.md` (optimization attempt notes)
- Full code audit (8 screens, models, services)
- Conversation history (loan module vision, document-sorter aesthetic preference, undo concern, Play Store ambition)

---

## Honest Current State

| Area | Status | Real Problem |
|---|---|---|
| Transactions | Working | Slow UI feedback after save |
| Accounts | 95% | `debugPrint` in prod, duplicate Add buttons, sort not persisted |
| Budgets | 70% | **January crash**, 35+ hardcoded `SizedBox`, no input validation |
| Loans | 60% | Search bar + 6 filters visible but **do nothing** |
| Bill Reminders | 95% | Fine |
| Recurring | 90% | Fine |
| Reports — Overview/Analytics/Budget | 70% | Working |
| Reports — Trends | 10% | **Placeholder text visible to user** |
| Financial Goals | 85% | UI dated |
| Group Spending | **0% UI** | Model exists, zero screens, completely invisible |
| Settings | 90% | Working |
| Undo (anywhere) | 0% | **Doesn't exist** — accidental deletes are permanent |
| Onboarding / first-run | 0% | New user opens app to empty dashboard with no guidance |
| Design system | 0% | Every screen diverges |
| Performance feel | Laggy | Optimistic update pattern not consistently applied |

---

## What Went Wrong Originally

**The "optimized" files split-brained the app.** When performance work happened, parallel files were created (`optimized_home_screen.dart`, `optimized_budgets_screen.dart`, `optimized_app_state.dart`, `optimized_data_service.dart`) alongside the originals. They're at different completion stages and use different patterns. UI inconsistency is now structural — baked into the file tree itself. Two screens written with different patterns will never look the same until a real design system exists.

**Half-built features stayed visible.** Loans search/filter, Reports Trends tab, Group Spending model — all shipped to user-facing UI in broken or invisible state. The fix is to either finish them or hide them, not let them sit.

**No design tokens means every screen reinvents spacing, color, typography.** Font sizes scattered across 12/13/14/14.5/15/16/20/24/30. Spacing hardcoded everywhere. This is unfixable without a token file.

---

# The Staged Plan

Six stages. Do them in order. Each stage has a clear definition of done.

---

## Stage 0 — Stop the Bleeding (Week 1)

**Goal:** No crashes. No visible dead UI. No `debugPrint` in production. Repo cleaned up.

**Definition of done:** App can be used end-to-end without hitting a crash or a feature that lies to the user.

### 0.1 Fix January budget crash
- **File:** `lib/screens/financial/budgets_screen.dart`
- **Bug:** `DateTime(_selectedMonth.year, _selectedMonth.month - 1)` returns `DateTime(year, 0)` when month is 1. Month 0 doesn't exist in Dart and the date math breaks.
- **Fix:** `month == 1 ? DateTime(year - 1, 12) : DateTime(year, month - 1)`
- **Also fix the forward direction:** `month == 12 ? DateTime(year + 1, 1) : DateTime(year, month + 1)`

### 0.2 Hide or remove dead Loans search/filter
- **File:** `lib/screens/financial/loans_screen.dart`
- **Decision:** Hide for now. Implementing properly belongs in Stage 4 (Loan Module rebuild). Showing a non-functional search bar is worse than not showing it.
- **Action:** Comment out the `TextField` and `PopupMenuButton`. Add a `// TODO: re-enable in Stage 4` marker.

### 0.3 Remove Reports → Trends placeholder
- **File:** `lib/screens/reports/reports_tab_screen.dart`
- **Decision:** Remove the tab entirely for now. Bring it back in Stage 3 with a real 12-month line chart using `fl_chart`.
- **Why remove vs. hide:** Three working tabs is cleaner than four tabs with one broken.

### 0.4 Strip all `debugPrint` from production code
- **Command:** `grep -rn "debugPrint" lib/`
- **Action:** Delete every occurrence. Known offenders: `lib/screens/financial/accounts_screen.dart` lines 544, 546, 553.

### 0.5 Remove duplicate Add button in Accounts
- **File:** `lib/screens/financial/accounts_screen.dart`
- **Action:** Remove the AppBar action button. Keep the FAB (it's the standard pattern).

### 0.6 .gitignore cleanup + remove tracked build artifacts
- **Currently committed but shouldn't be:** `android/build/reports/` HTML files
- **Action:**
  - `git rm -r --cached android/build/reports/`
  - `git rm -r --cached android/.gradle/` if present
  - Replace `.gitignore` with the version at the end of this doc
  - Commit as a single "chore: gitignore cleanup" commit

### 0.7 Run `flutter analyze` and fix critical lints
- Don't fix all of them. Fix the errors and warnings flagged as critical. Style nits can wait until Stage 1 when we're touching every file anyway.

**Estimated time:** 2–3 days.

---

## Stage 0.5 — Data Safety Net (Week 1, parallel to Stage 0)

**Goal:** Before we touch architecture, make sure no refactor can lose user data. This stage is non-negotiable.

**Definition of done:** Existing user data survives any code change in later stages.

### 0.5.1 Schema audit
- Document the current SQLite schema in `lib/services/db/SCHEMA.md`. List every table, column, type, foreign key.
- Pin the current database version number. Future migrations must increment it.
- Verify migration code (`onUpgrade`) handles every historical version cleanly.

### 0.5.2 Auto-backup on app close
- Currently backup is manual. That's a single point of failure for a local-first app.
- **Action:** On app pause/close, write a SQLite dump to device storage at `~/Documents/SpendWise/auto_backup/`.
- **Retention:** Keep last 30 daily backups, last 12 weekly backups, last 12 monthly backups (90+ days of recoverable history).
- **Implementation:** `path_provider` for the directory, `sqflite` already has dump capability, schedule via `WidgetsBindingObserver.didChangeAppLifecycleState`.
- **User control:** Settings → Backup → "Restore from auto-backup" lists available snapshots with date/size, tap to restore.

### 0.5.3 Soft-delete + Undo for destructive actions
- **The gap you flagged:** No undo anywhere. Accidental deletes are permanent.
- **Approach:**
  - Add `deleted_at TIMESTAMP NULL` column to: `transactions`, `accounts`, `loans`, `budgets`, `bill_reminders`, `recurring_transactions`, `financial_goals`.
  - All "delete" actions set `deleted_at = NOW()` instead of `DELETE FROM`.
  - All read queries filter `WHERE deleted_at IS NULL`.
  - Show SnackBar with "Undo" action for 8 seconds after any delete.
  - Background cleanup: hard-delete rows where `deleted_at < NOW() - 30 days`.
- **Why 30 days:** Long enough to recover a mistaken delete you noticed weeks later. Short enough that the table doesn't bloat.

### 0.5.4 Error boundary + failed-write feedback
- **Current problem:** Optimistic updates show success in UI even if DB write fails. Data appears saved but isn't.
- **Fix:** Every DB write goes through a service method that:
  1. Updates UI state immediately (optimistic)
  2. Attempts DB write
  3. On failure: revert UI state + show SnackBar "Couldn't save. Tap to retry."
  4. On success: silent (UI already updated)

**Estimated time:** 3–4 days. Worth every hour.

---

## Stage 1 — Design System Foundation (Week 2)

**Goal:** Single source of truth for colors, spacing, typography, shadows, shared widgets. Every later UI change reads from this file.

**Definition of done:** `lib/core/design_system.dart` exists, 5 shared widgets exist, one screen has been rebuilt on top of it as proof of concept.

### 1.1 Create `lib/core/design_system.dart`

```dart
// lib/core/design_system.dart

import 'package:flutter/material.dart';

// =============== COLORS ===============
class AppColors {
  // Light theme
  static const bg          = Color(0xFFF5F2EE); // warm cream
  static const surface     = Color(0xFFFFFFFF);
  static const surfaceAlt  = Color(0xFFF0EDE8);
  static const divider     = Color(0xFFEBE6DE);
  static const ink         = Color(0xFF14110F);
  static const subtext     = Color(0xFF7A736B);

  // Dark theme
  static const bgDark         = Color(0xFF1A1714);
  static const surfaceDark    = Color(0xFF242019);
  static const surfaceAltDark = Color(0xFF2E2820);
  static const dividerDark    = Color(0xFF332E28);
  static const inkDark        = Color(0xFFF0EDE8);
  static const subtextDark    = Color(0xFFA89F94);

  // Semantic (theme-neutral)
  static const income   = Color(0xFF4A8C5C);
  static const expense  = Color(0xFFB05050);
  static const accent   = Color(0xFF6B9E7A); // sage — primary brand
  static const warning  = Color(0xFFD4853A);
  static const loan     = Color(0xFF5B7FA6);
  static const settled  = Color(0xFF7A8F6B);
}

// =============== SPACING ===============
class AppSpacing {
  static const s2  = 2.0;
  static const s4  = 4.0;
  static const s8  = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s48 = 48.0;
}

// =============== TYPOGRAPHY ===============
class AppText {
  static const h1    = 28.0;
  static const h2    = 22.0;
  static const h3    = 17.0;
  static const body  = 14.5;
  static const label = 12.0;
  static const fontFamily = 'PlusJakartaSans';
  static const monoFamily = 'RobotoMono';
}

// =============== SHADOWS ===============
class AppShadow {
  static List<BoxShadow> get card => const [
    BoxShadow(color: Color(0x0A14110F), blurRadius: 1, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0D14110F), blurRadius: 22, offset: Offset(0, 8)),
  ];
}

// =============== RADIUS ===============
class AppRadius {
  static const r8  = 8.0;
  static const r12 = 12.0;
  static const r16 = 16.0;
  static const r24 = 24.0;
}
```

### 1.2 Add Plus Jakarta Sans + Roboto Mono fonts
- Download from Google Fonts, place in `assets/fonts/`
- Register in `pubspec.yaml`
- Set globally via `ThemeData(fontFamily: AppText.fontFamily)`

### 1.3 Build shared widgets in `lib/core/widgets/`

- **`AppCard`** — replaces all `Container + BoxDecoration` patterns. Auto-handles light/dark via `Theme.of(context)`.
- **`AppButton`** — variants: `primary` (filled sage), `secondary` (outlined hairline), `danger` (filled red), `ghost` (text only).
- **`AmountText`** — monospace font, currency symbol, color rule: positive=income green, negative=expense red, neutral=ink. Takes `double amount` and `Currency currency`.
- **`AppEmptyState`** — icon, title, subtitle, optional CTA button. Used by every empty list.
- **`SectionHeader`** — label-style text (12px, subtext color, letter-spaced).
- **`AppPill`** — chip-style for filter pills, status badges.
- **`AppProgressRing`** — circular progress (replaces linear progress in Budgets/Goals).

### 1.4 Proof-of-concept screen
- Pick one small screen (Financial Goals is a good candidate — small, contained).
- Rebuild it using only design system tokens and shared widgets.
- This proves the system works before bulk refactor in Stage 3.

**Estimated time:** 4–5 days.

---

## Stage 2 — Architecture Cleanup (Week 3)

**Goal:** Kill the split-brain. One state management pattern, one data service, one version of each screen.

**Definition of done:** No `optimized_*.dart` files exist. All screens use the same state pattern. Performance feels instant on every action.

### 2.1 Pick a winner: optimized vs original
- For each pair (`home_screen` vs `optimized_home_screen`, `app_state` vs `optimized_app_state`, etc.):
  - Read both. Pick the better-architected one.
  - Migrate any unique features from the loser into the winner.
  - Delete the loser.

### 2.2 Standardize the optimistic update pattern
- One service method shape for every write:
  ```dart
  Future<Result<T>> create<T>({
    required T entity,
    required Function() optimisticApply,
    required Function() rollback,
  });
  ```
- UI calls service, service handles optimistic apply → DB write → rollback on failure → SnackBar feedback.

### 2.3 Remove `shared_preferences` for financial data
- All money/transaction/loan data must live in SQLite.
- `shared_preferences` only for: theme choice, currency preference, sort order memory, hidden warning IDs.
- Audit every `SharedPreferences.getInstance()` call. If it touches financial data, migrate to SQLite.

### 2.4 Database write batching
- Currently each transaction add is a separate DB transaction.
- For bulk operations (CSV import, recurring transaction generation): wrap in single `db.transaction()`.

**Estimated time:** 4–5 days.

---

## Stage 3 — UI Redesign Screen-by-Screen (Weeks 4–5)

**Goal:** Every screen rebuilt on the design system. Consistent look. Document-sorter-inspired warm aesthetic.

**Definition of done:** Every screen uses only design system tokens. Zero hardcoded hex, zero hardcoded `SizedBox`, zero ad-hoc `Container + BoxDecoration`.

### 3.0 Navigation restructure (do first)
**Replace drawer with bottom navigation bar (5 tabs):**

| Tab | Icon | Label | Contains |
|---|---|---|---|
| 1 | `home_outlined` | Home | Dashboard, net worth, recent transactions |
| 2 | `receipt_long` | Records | Transactions tabbed (All/Expense/Income) |
| 3 | `pie_chart_outline` | Reports | Overview, Analytics, Budget, Trends |
| 4 | `account_balance_wallet_outlined` | Finance | Accounts, Budgets, Loans, Goals |
| 5 | `more_horiz` | More | Bills, Recurring, Settings, Backup, Group Spending |

- Delete the Drawer entirely.
- FAB visible only on Home and Records, opens calculator/add-transaction screen.
- Long-press FAB → quick-add menu (Expense / Income / Loan Payment) — friction reduction for common actions.

### 3.1 Home Dashboard
- Background: `AppColors.bg` (warm cream, not white)
- **Hero net-worth card:** sum of all accounts minus active loans, big monospace number, sage accent
- Below: side-by-side "Income this month" / "Expenses this month" cards
- "Top categories this month" — 3 horizontal pills with category + amount
- "Recent transactions" — last 8, grouped by Today/Yesterday/Date
- "Insights" carousel (optional, see Stage 5)

### 3.2 Records (Transactions)
- Tab bar at top: All | Expenses | Income | Transfers
- Persistent search bar (not buried in dialog)
- Filter sheet (bottom sheet): date range, category multi-select, account multi-select, amount range
- Transaction rows: category icon + color dot, title, date, `AmountText` right-aligned
- Group by day with sticky date headers

### 3.3 Budgets
- Fix month nav (already done in Stage 0)
- Horizontal scrolling month chip selector at top
- **Hero overall budget card:** large progress ring, "₹X spent of ₹Y", "Z days left in month"
- Category budget list below: each card has small progress ring + amount + remaining
- Input validation: budget amount > 0, can't set budget for a deleted category

### 3.4 Loans
**Full redesign — this is your distinctive feature, treat it right.**

- **List screen:**
  - Filter pills: All | I Owe | Owed to Me | Bank Loans | Settled
  - Cards show: person/lender name, amount (color-coded by direction), status badge (Active/Overdue/Settled), days since/until
- **Add screen:** segmented control at top — `[ Personal ] [ Bank Loan ]`
  - **Personal:** who, direction (I lent / I borrowed), amount, date, optional interest (rate + monthly/yearly basis + duration), notes
  - **Bank Loan:** name (e.g. "Home Loan - HDFC"), principal, APR%, term in months, start date, linked account → auto-calculate EMI
- **Detail screen (bank loans):**
  - EMI amount big and prominent
  - Paid vs Remaining bar
  - Amortization table (scrollable, principal/interest split per month)
  - **"What if I pay extra?" simulator:** input extra monthly or one-time lump sum → output months saved + interest saved
- **Settled flow:** when fully paid, satisfying animation, moves to Settled section

### 3.5 Reports
- Date range chip row at top (persistent, not in a dialog)
- **Overview:** summary cards (income, expense, savings rate, net change)
- **Analytics:** side-by-side pie charts (expense + income breakdowns)
- **Budget:** monthly/yearly adherence chart with category breakdown
- **Trends (NEW):** 12-month line chart of monthly totals using `fl_chart`. Optional: heatmap calendar showing spending intensity by day.

### 3.6 Finance tab (Accounts / Budgets / Loans / Goals)
- Sub-navigation as horizontal segmented control or tabs at top
- Each sub-section uses the patterns above

### 3.7 More tab
- Grouped list: Money Tools (Bills, Recurring, Group Spending), Data (Backup, Import/Export), App (Settings, Help, About)
- Use `AppCard` group containers for each section

**Estimated time:** 10–12 days. This is the biggest chunk.

---

## Stage 4 — Finish Half-Built Features (Week 6)

**Goal:** Everything visible to the user actually works.

### 4.1 Group Spending UI (you already have the model — finish it)
- **Groups list:** card per group with name, member count, "your balance" (you owe / owed to you)
- **Group detail:** members list, expenses list, "Settlement Summary" section showing who owes whom
- **Add expense to group:** title, amount, paid by (member), split between (multi-select members), split type (equal / shares / percentages / exact amounts)
- **Settlement:** "Mark as settled" button on individual debts, settlement history

### 4.2 Real loan search/filter (re-enable from Stage 0)
- In-memory filter on already-loaded list — 30 lines max
- Filter by: person/lender name, status, direction, date range

### 4.3 Trends tab (real implementation)
- 12-month line chart of total expense + income
- Tap a point → drill into that month's records

### 4.4 Transaction search (global)
- Search across description, category name, amount (parsed), tag, account name
- Triggered from Records tab search bar

### 4.5 Net worth view (already in Stage 3.1, but verify calculation)
- Sum(active account balances) − Sum(remaining loan principal where direction = I owe)
- Update live whenever underlying data changes

**Estimated time:** 5–6 days.

---

## Stage 5 — Quality of Life + New Ideas (Week 7+)

**Goal:** The polish that turns a working app into one that's pleasant to use.

### 5.1 Onboarding flow (3 screens max, mandatory before Play Store)
1. Welcome + set currency
2. Create first account (with sensible defaults)
3. Add first transaction (with tutorial overlay)
- Skippable but with a "you can do this later in Settings" note

### 5.2 Spending insights (rolling 3-month baseline, not last month)
- Compute on Reports tab and on Home dashboard
- Examples: "You spent 34% more on Food this month vs your 3-month average", "Your savings rate this month is 18%, up from 12% average"
- Why 3-month baseline: smooths seasonal noise. Last-month comparison is too jumpy.

### 5.3 Account-aware transaction form
- Remember last-used account per transaction type (expense / income / transfer)
- Pre-select it next time. User can still change it.

### 5.4 Monthly summary notification
- End of month: local notification "October: ₹24,500 across 47 transactions. Food biggest at ₹7,200. Under budget by ₹3,200."
- Tap → opens that month's Reports view

### 5.5 Spending calendar heatmap (optional Reports tab feature)
- Calendar view, darker = more spent on that day
- Helps spot patterns (weekends, monthly cycle)

### 5.6 Biometric / PIN app lock
- `local_auth` package
- Optional in Settings, off by default

### 5.7 Receipt photo attachment
- Camera or gallery picker
- Store image path on transaction
- Compress to ~200KB max before saving

### 5.8 Category deletion with migration
- When deleting a category that has transactions: prompt "Reassign 47 transactions to which category?"

**Estimated time:** 5–7 days for everything in this stage. Pick what matters most to you.

---

## Stage 6 — Pre-Launch (if going to Play Store)

**Goal:** App is ready for strangers to install, not just you.

### 6.1 Onboarding flow (from 5.1) is non-negotiable here

### 6.2 App signing + release keystore
- Generate keystore, configure `android/key.properties` (gitignored)
- Test `flutter build apk --release` and `flutter build appbundle --release`

### 6.3 Play Store assets
- Icon (1024x1024)
- Feature graphic (1024x500)
- Screenshots (minimum 4): Dashboard, Records, Loans detail with simulator, Reports trends
- Short description (80 chars), full description (4000 chars)
- Privacy policy URL (required even if you don't collect data — must state that)

### 6.4 Monetization decision
- **My honest recommendation:** one-time purchase ₹99–149, not ads.
- Reasoning: finance apps with ads destroy user trust. Your "local data ownership" positioning targets privacy-conscious users — exactly the segment that hates ads most. A one-time purchase aligns the value proposition with the price model.
- Alternative: free with a single, clearly-marked "Pro" unlock (₹149) for advanced features like the EMI simulator or unlimited groups. Free tier already covers core needs.
- Avoid: recurring subscription. It's what you set out to escape. Don't become what you hated.

### 6.5 Crash reporting (optional but smart)
- Sentry or Firebase Crashlytics
- Will catch bugs real users hit that you never will

**Estimated time:** 3–5 days for everything except waiting on Play Store review.

---

# Concerns

**1. Timeline is optimistic.** "Week 4–5: UI redesign of every screen" assumes touching 13+ screens in 10 days without introducing regressions. Realistically, expect 3 weeks if you want it done well. Don't rush this stage — it's the one users notice most.

**2. Schema migrations during Stage 0.5 are risky.** Adding `deleted_at` columns to 7 tables means writing migration logic that survives across all historical database versions. Test the migration with an actual old DB dump before deploying to your own phone.

**3. Plus Jakarta Sans + Roboto Mono will increase APK size.** Maybe 600KB total. Acceptable, but if you want lean, use the system font and only ship Roboto Mono for amounts.

**4. The "what if I pay extra" loan simulator is a non-trivial calculation.** It's not just basic amortization — you need to recalculate the full schedule with the prepayment and diff against original. Budget extra time for this one feature.

**5. Group Spending UI is more work than it looks.** Settlement logic ("if A owes B ₹100 and B owes C ₹50, simplify to A owes C ₹50 + A owes B ₹50") is a graph simplification problem. Splitwise has hundreds of edge cases. Build the basic case first, simplify settlements later.

**6. No automated tests exist.** Refactoring this much code with zero test coverage is fragile. Consider adding integration tests for at least: add transaction → see it in list, set budget → exceed it → see warning, soft-delete → undo. Three tests would catch most regressions.

---

# Original Ideas + New Ideas (All Kept)

### From your original vision
- Local-first, SQLite, no cloud dependency
- Loan tracking that handles informal (friends/family) + formal (bank with amortization) — your distinctive feature
- Recurring transactions
- CSV import/export as data escape hatch
- Bill reminders with local notifications
- Multi-account, multi-currency
- Financial goals
- Dark mode
- Budget management with category + overall limits
- Smart warnings with priority levels
- Income-based financial health (salary-first calculation)
- Comprehensive reports (Overview/Analytics/Budget/Trends)

### Added during planning
- **Net worth view** — single number combining all accounts and loans (Stage 3.1)
- **Group Spending UI** — finish what the model already started (Stage 4.1)
- **Tags / custom labels** — for cross-cutting groupings like "Goa trip" (consider for Stage 5)
- **Soft-delete + Undo** — 30-day retention, 8-second SnackBar undo (Stage 0.5)
- **Auto-backup with retention** — 30 daily / 12 weekly / 12 monthly (Stage 0.5)
- **Spending insights against 3-month baseline** — not last month (Stage 5.2)
- **Quick-add via long-press FAB** — friction reduction (Stage 3.0)
- **Account-aware transaction form** — remember last-used account (Stage 5.3)
- **"Settled" loan animation** — small dopamine hit on completion (Stage 3.4)
- **Spending calendar heatmap** — pattern spotting (Stage 5.5)
- **Monthly summary notification** — one notification, real data (Stage 5.4)
- **Onboarding flow** — mandatory before Play Store (Stage 5.1 / 6.1)
- **Error boundary + failed-write feedback** — UI lies less (Stage 0.5.4)
- **Biometric / PIN lock** — optional, for sensitive financial data (Stage 5.6)
- **Receipt photo attachment** — compressed, path-stored (Stage 5.7)
- **Crash reporting** — for Play Store version only (Stage 6.5)
- **One-time purchase monetization** — not ads, not subscription (Stage 6.4)

### Explicitly cut from scope (don't do these now)
- **Investment tracking (stocks, MFs, FDs)** — different problem domain, would dilute focus
- **Bank account integration / SMS parsing** — privacy nightmare, regulatory mess in India, breaks local-first promise
- **Cloud sync** — contradicts "data is yours" positioning. If you want multi-device, do encrypted Google Drive backup only.
- **AI-powered predictions** — buzzword, low actual value vs. effort

---

# .gitignore (Replacement)

```gitignore
# Misc
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

# IDEs
*.iml
*.ipr
*.iws
.idea/
.vscode/settings.json
.vscode/tasks.json

# Flutter / Dart / Pub
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.pub-cache/
.pub/
/build/

# Android
/android/app/build/
/android/build/
android/build/reports/
android/.gradle/
android/key.properties
android/app/upload-keystore.jks
android/app/release-keystore.jks

# iOS
ios/Pods/
ios/.symlinks/
ios/Flutter/Flutter.framework/
ios/Flutter/Flutter.podspec/

# Symbolication / Obfuscation
app.*.symbols
app.*.map.json

# Secrets
.env
*.env.local
google-services.json
GoogleService-Info.plist

# Tooling
/.agent/
/.claude/
/.planning/

# Work-in-progress planning docs (keep Plan.md, README.md)
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

**Critical action:** `git rm -r --cached android/build/reports/` before committing the new gitignore.

---

# Recommended Timeline

```
Week 1:    Stage 0 (crash fixes) + Stage 0.5 (data safety + undo + backups)
Week 2:    Stage 1 (design system + shared widgets + 1 POC screen)
Week 3:    Stage 2 (architecture cleanup, kill split-brain)
Week 4–5:  Stage 3 (UI redesign, all screens)
Week 6:    Stage 4 (finish half-built features)
Week 7:    Stage 5 (quality of life, pick what matters)
Week 8+:   Stage 6 (pre-launch, only if going to Play Store)
```

**Start with Stage 0 today.** Everything else builds on a stable, non-crashing foundation with a data safety net underneath.