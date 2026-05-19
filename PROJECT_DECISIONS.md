# PROJECT_DECISIONS.md — SpendWise Decision Log
> Every architectural, technical, or product decision made across all sessions.
> **Never delete entries.** Mark outdated ones as `[SUPERSEDED]` and add the new decision below.

---

## Architecture Decisions

| Date | Decision | Reason |
|------|----------|--------|
| 2026-05-18 | **Local-first, no cloud sync** | Owner wants full data ownership. SQLite on device. No subscriptions, no telemetry, no third-party SDKs |
| 2026-05-18 | **Provider (not Riverpod/Bloc) for state** | Already in codebase. Provider is sufficient for this app's complexity. Switching mid-rebuild adds churn with no benefit |
| 2026-05-18 | **`OptimizedDataService` as the single data access layer** | Centralizes caching + DB calls. All screens call this, never raw `UnifiedDatabaseService` directly |
| 2026-05-18 | **Each screen owns its own `_load()` + setState** | Stage 2 will centralize into per-domain notifiers. During Stage 3 UI rebuild, decentralized is safer — no merge conflicts across screens |
| 2026-05-18 | **`OptimizedAppState` kept monolithic during UI rebuild** | Splitting it during Stage 3 UI work would create conflicts in every screen. Stage 2 refactor will split it in one focused pass after all screens are done |
| 2026-05-18 | **No new files unless under explicit plan or source-of-truth docs** | Prevents scope creep. Every file must have a named home in the plan |

---

## Design System Decisions

| Date | Decision | Reason |
|------|----------|--------|
| 2026-05-18 | **`lib/core/design_system.dart` — single token file** | Every screen was reinventing colors, spacing, font sizes. One file eliminates drift. Zero hardcoded hex/spacing/size in screens |
| 2026-05-18 | **`google_fonts` package over bundled font assets** | No font file management, automatic caching, one-line API. APK size difference negligible. First-run needs internet to download fonts — acceptable for personal-use MVP |
| 2026-05-18 | **Plus Jakarta Sans (UI) + IBM Plex Mono (amounts/codes)** | Matches `soft-minimal-light.html` design contract exactly |
| 2026-05-18 | **Soft Minimal theme: near-black #18181B accent, #FAFAF9 off-white bg** | Design contract from `New folder/soft-minimal-light.html`. No improvising visual choices |
| 2026-05-18 | **No card shadows — hairline 1px border only** | Soft Minimal spec. Shadows add visual noise; borders give structure without depth |
| 2026-05-18 | **Indian number format (L/Cr) in AmountText** | App targets Indian user. `₹2.4L` is more readable than `₹240,000`. Implemented via custom `_format()` in AmountText |
| 2026-05-18 | **`AppProgressRing` via CustomPainter** | fl_chart not needed for simple ring. CustomPainter is zero-dependency, exact control |

---

## Navigation Decisions

| Date | Decision | Reason |
|------|----------|--------|
| 2026-05-18 | **Bottom nav: 4 tabs + center FAB — no Loans tab** | Loans screen needs full Stage 4 redesign. Broken UI in a prime nav slot violates "no dead UI" principle. Loans accessible via route only until Stage 4 |
| 2026-05-18 | **Tab layout: Home / Records / [FAB] / Accounts / Reports** | Home = dashboard, Records = full transaction list, FAB = add transaction, Accounts = multi-account, Reports = analytics |
| 2026-05-18 | **Home screen = dashboard, not transaction list** | Dashboard gives at-a-glance financial health. Transaction list belongs in Records tab. Old home was confusing |
| 2026-05-18 | **FAB opens CalculatorTransactionScreen with slide-up + haptic** | Consistent with iOS/Android add-item patterns. Slide-up = modal flow |

---

## Screen-Level Decisions

| Date | Decision | Reason |
|------|----------|--------|
| 2026-05-18 | **Delete all `debugPrint` calls — do not guard with `kDebugMode`** | `debugPrint` runs in release builds (rate-limited, not suppressed). Guarding adds noise. Stage 0 goal: stop the bleeding fast |
| 2026-05-18 | **Reports: pure Flutter bar chart, no fl_chart** | 6-month income/expense trend is simple enough with Container rectangles. fl_chart reserved for complex analytics (Stage 3). Keeps reports_screen.dart self-contained |
| 2026-05-18 | **Budgets: drop `BaseFinancialScreen` + `ValueNotifierMixin`** | These predated the design system and couple screens to a complex mixin hierarchy. All screens now use consistent `_load()` + setState pattern |
| 2026-05-19 | **Calculator: keep `OptimizedAppState` for categories, use `OptimizedDataService` for accounts** | Categories are app-wide state already managed by OptimizedAppState. Accounts need fresh balances from OptimizedDataService. Two sources temporary until Stage 2 centralizes |
| 2026-05-19 | **Calculator: pop with `Transaction` object, not `bool`** | Records screen `_editTransaction` needs the transaction to call `updateTransaction(result)`. Home screen `_openAdd` also passes result to `addTransactionOptimistically`. Both handle null correctly |

---

## Code Quality / Lint Fixes

| Date | Decision | Reason |
|------|----------|--------|
| 2026-05-19 | **Replace `_`, `__` wildcard params with named `a`, `b` in `PageRouteBuilder.pageBuilder`** | `unnecessary_underscores` lint: multiple leading-underscore params (`_`, `__`) are redundant — Dart already ignores unused params. Renamed to `a`, `b` to satisfy `no_leading_underscores_for_local_identifiers` too |
| 2026-05-19 | **Wrap all bare `if` branches in braces throughout `calculator_transaction_screen.dart`** | `curly_braces_in_flow_control_structures` lint. Bare single-statement `if`/`else` chains are brittle — adding a line silently falls outside the branch. Braces make intent explicit |
| 2026-05-19 | **Replace empty `catch (e) {}` with `catch (_) { // No-op }` in `financial_goal_service.dart`** | `empty_catches` lint. Empty catch silently swallows exceptions. Renamed param to `_` (unused, intentional) and added comment explaining placeholder status |

---

## Known Issues / Deferred

| Date | Issue | Plan |
|------|-------|------|
| 2026-05-19 | **Home screen `_openAdd` may double-add after calculator save** | Calculator now calls `addTransactionOptimistically` internally. Home screen also calls `addTransaction(result)` after pop. Fix: remove addTransaction call from home screen `_openAdd` in next pass |
| 2026-05-18 | **Budgets January crash** | `DateTime(year, month - 1)` when month=1 produces month=0. Fix with explicit prev-month calculation. Low priority — current rebuild replaces that code |
| 2026-05-18 | **Group Spending** | Model only, zero UI. Out of scope until Stage 5 |
| 2026-05-18 | **Undo / soft-delete** | Not implemented. Plan: 8-second SnackBar undo + `deleted_at` column + 30-day sweep |
| 2026-05-18 | **Auto-backup** | Not implemented. Plan: SQLite dump on `didChangeAppLifecycleState` paused, 30 daily / 12 weekly / 12 monthly retention |
| 2026-05-18 | **Biometric/PIN lock** | Not implemented. Plan: `local_auth` + `flutter_secure_storage`, PBKDF2-HMAC-SHA256 PIN hash, fallback PIN, lock-after-N-seconds-background |

---

## Things Explicitly Rejected

| Date | Rejected | Reason |
|------|----------|--------|
| 2026-05-18 | Cloud sync | Privacy. User owns data on device |
| 2026-05-18 | SMS parsing | Out of scope by owner decision |
| 2026-05-18 | Subscription paywalls | Personal use, eventual ₹99-149 one-time. No recurring billing |
| 2026-05-18 | AI predictions / spending insights | Out of scope. Overcomplicates MVP |
| 2026-05-18 | Ad SDKs | No. Ever. |
| 2026-05-18 | `kDebugMode` guards on `debugPrint` | Adds noise. Delete debugPrint entirely |
| 2026-05-18 | `optimized_budgets_screen.dart` as canonical budgets screen | Old file extends BaseFinancialScreen. Replaced with clean StatefulWidget rebuild |

---

## How to Add New Decisions

When a non-obvious choice is made — architecture, scope, UX, tech selection, or a bug that revealed a design assumption:

1. Add a row to the relevant section above **immediately** — do NOT wait to be asked
2. Use today's date (YYYY-MM-DD)
3. Keep the decision statement clear and actionable
4. Include the reason so future sessions understand context

**Never delete.** If a decision changes, mark old one `[SUPERSEDED by YYYY-MM-DD entry]` and add new one below.
