# CLAUDE.md — SpendWise Project Context

**Last updated:** 2026-05-19
**Owner:** Smit Vaghasiya (`smitvaghasiya11280@gmail.com`)
**App:** SpendWise — personal-first Flutter expense tracker
**Stack:** Flutter · SQLite (`sqflite`) · Provider · `fl_chart`
**Platforms:** Android primary, iOS later, Play Store stretch goal
**Repo root:** `C:\Users\smitv\OneDrive\Desktop\Apps\expense_tracker`

---

## What We Are Building

SpendWise is a local-first personal finance app. No cloud, no subscription, no ads. User owns their data via on-device SQLite + manual/auto backup. Core surfaces:

- **Transactions** — income/expense/transfer with calculator entry
- **Accounts** — multi-account, multi-currency, custom types, negative-balance warnings
- **Budgets** — monthly per-category + overall, defaults to previous month
- **Loans** — distinctive feature: simple personal lent/borrow + formal bank loans with EMI, amortization table, and "what-if extra payment" simulator
- **Reports** — Overview / Analytics / Budget / Trends (12-month line chart)
- **Bill Reminders + Recurring transactions**
- **Financial Goals** — savings targets with progress
- **Group Spending** — split-bill (Splitwise-style), model exists, UI to build
- **Settings** — theme (light/dark/system), currency, backup, biometric/PIN lock

## Why We Are Building It

Market apps lock features behind subscriptions, look stitched-together, don't handle informal friend/family loans well, and don't let users own their data. SpendWise is the alternative the owner wants for themselves, then maybe Play Store at ₹99–149 one-time.

## Source of Truth Documents

| File | Purpose |
|---|---|
| `PROJECT_DECISIONS.md` | **Every architectural/code decision — READ THIS FIRST** |
| `PROJECT_SESSIONS.md` | **Session log, newest first — READ THIS FIRST** |
| `md/Opus_plan.md` | Authoritative staged rebuild plan (Stage 0 → 6) |
| `md/CODE_OPTIMIZATION_AND_SECURITY.md` | Codewise smoothness/perf/security plan + biometric/PIN auth |
| `md/UI_REDESIGN_SOFT_MINIMAL.md` | Full UI redesign spec mapped to `New folder/soft-minimal-light.html` |
| `New folder/soft-minimal-light.html` | Visual design contract (theme, fonts, spacing, screens) |
| `New folder/soft-minimal-dark.html` | Dark variant of the same contract |
| `remaining_tasks.md` | Owner's running dev diary (historical context) |
| `README.md` | Feature documentation |
| `.claude/sessions/` | Per-session work logs (timestamped, granular) |
| `.claude/decisions/` | Decision log (timestamped, ADR-style, granular) |

If `Opus_plan.md` and any other md conflict, `Opus_plan.md` wins for scope and `UI_REDESIGN_SOFT_MINIMAL.md` wins for visual design.

## Current State Snapshot (carry forward when stale, re-read code)

### Design system + shared widgets — DONE
- `lib/core/design_system.dart` — full token set (AppColors, AppSpacing, AppRadius, AppText, AppShadow, AppTheme light/dark, BuildContext extensions)
- `lib/core/widgets/` — AppCard, AppHeroCard, AmountText, AppPill, AppButtonPrimary, AppButtonGhost, AppEmptyState, AppProgressBar, AppProgressRing, SectionHeader, LabelText, AppSearchField, index.dart barrel

### Screens — Soft Minimal rebuild status
- **Navigation shell** (`main_navigation_shell.dart`) — DONE: 4 tabs + center FAB
- **Home Dashboard** (`optimized_home_screen.dart`) — DONE: greeting, balance hero, budget bar, recent transactions grouped
- **Records** (`records_screen.dart`) — DONE: All/Expense/Income tabs, search, grouped by date, edit + delete
- **Calculator / Add Transaction** (`calculator_transaction_screen.dart`) — DONE: Soft Minimal UI, math_expressions eval, transfer support, negative balance warning
- **Accounts** (`accounts_screen.dart`) — DONE: hero total, per-account cards with monthly in/out, add/edit/delete sheet
- **Budgets** (`budgets_screen.dart`) — DONE: month navigator, overall bar, per-category cards, add/edit/delete sheet
- **Reports** (`reports_screen.dart`) — DONE: range pills, Overview/Spending/Budget tabs, 6-month bar chart, category breakdown
- **Financial Goals** — NOT STARTED
- **Bill Reminders** — NOT STARTED
- **Loans** — NOT STARTED (needs Stage 4 full redesign)
- **Settings** — NOT STARTED (incl. biometric/PIN toggle)

### Known issues / TODO
- Home screen `_openAdd` calls `addTransaction(result)` after pop — calculator now does the save internally via `addTransactionOptimistically`. May double-add. Fix: remove `addTransaction` call from home screen `_openAdd` or change calculator to not save internally and let callers decide (D-015).
- Group Spending: model only, zero UI — out of scope until Stage 5
- Undo / soft-delete: not implemented
- Auto-backup: not implemented
- Biometric/PIN lock: not implemented

---

## Mandatory Skills (use EVERY session, not optional)

Run the relevant skill via the `Skill` tool **before** taking action of that type. If multiple apply, run them in priority order.

| When | Skill | Why |
|---|---|---|
| Any new feature, redesign, behavior change | `superpowers:brainstorming` | Clarify intent + design before code. Hard gate before implementation. |
| Any UI / component / screen build | `frontend-design:frontend-design` | Distinctive, non-AI-slop visuals. Match `soft-minimal-light.html` contract. |
| Any creative/architectural decision needing options | `superpowers:brainstorming` then `superpowers:writing-plans` | 2–3 alternatives, then plan. |
| 2+ independent tasks | `superpowers:dispatching-parallel-agents` | Parallelize file generation, screen builds, audits. |
| Bug or unexpected behavior | `superpowers:systematic-debugging` | Hypothesis → experiment, not random edits. |
| Before claiming done | `superpowers:verification-before-completion` | Run commands, confirm output. No "should work". |
| Writing/changing skills | `superpowers:writing-skills` | |
| Code review of own work | `superpowers:requesting-code-review` | |
| Receiving review feedback | `superpowers:receiving-code-review` | |
| Implementing a written plan | `superpowers:executing-plans` or `superpowers:subagent-driven-development` | |
| TDD-applicable changes | `superpowers:test-driven-development` | |

### External skill references (read on demand)

- **Superpowers (obra/superpowers)** — `https://github.com/obra/superpowers` — installed as plugin; invoke via `Skill` tool with `superpowers:<name>` slugs above.
- **UI/UX Pro Max Skill (nextlevelbuilder/ui-ux-pro-max-skill)** — `https://github.com/nextlevelbuilder/ui-ux-pro-max-skill` — apply its heuristics whenever doing UI work (alongside `frontend-design`).
- **Frontend Design (frontend-design plugin)** — invoke via `Skill` tool `frontend-design:frontend-design`.
- **Brainstorming (superpowers brainstorming)** — invoke via `Skill` tool `superpowers:brainstorming`.
- **Awesome Design MD (voltagent/awesome-design-md)** — `https://github.com/voltagent/awesome-design-md` — reference catalog. Consult when writing/refreshing design docs in `md/`.

### Hard rules

1. **No implementation before brainstorming + plan** for non-trivial work. Trivial = single-line fix, typo, mechanical rename.
2. **Every UI change** reads `UI_REDESIGN_SOFT_MINIMAL.md` + the matching HTML file in `New folder/`. No improvising visuals.
3. **Every session** appends to `.claude/sessions/YYYY-MM-DD-HHMM-session.md` with: what asked, what done, what blocked, what next.
4. **Every architectural/scope decision** appends to `.claude/decisions/YYYY-MM-DD-HHMM-decisions.md` with: context, options, choice, why, consequences.
5. **Caveman mode is active** (level: full). Drop articles/filler/pleasantries/hedging in conversational replies. Code, commits, security warnings, PRs: write normal.
6. **No emoji** in code or files unless owner explicitly requests.
7. **No new files** unless they live under an explicit plan or are one of the source-of-truth docs above.
8. **Verify before completion** — run `flutter analyze`, the relevant feature manually, and any tests before declaring a task done.
9. No need for you to use the flutter app building or error tracking commands ask me about it ok.
10. - **Superpowers (obra/superpowers)** — `https://github.com/obra/superpowers` — installed as plugin; invoke via `Skill` tool with `superpowers:<name>` slugs above.
- **UI/UX Pro Max Skill (nextlevelbuilder/ui-ux-pro-max-skill)** — `https://github.com/nextlevelbuilder/ui-ux-pro-max-skill` — apply its heuristics whenever doing UI work (alongside `frontend-design`).
- **Frontend Design (frontend-design plugin)** — invoke via `Skill` tool `frontend-design:frontend-design`.
- **Brainstorming (superpowers brainstorming)** — invoke via `Skill` tool `superpowers:brainstorming`.
- **Awesome Design MD (voltagent/awesome-design-md)** — `https://github.com/voltagent/awesome-design-md` — reference catalog. Consult when writing/refreshing design docs in `md/`. you have read and think if this is useful or not and if usefull must use this md file ok.

---

## Coding Conventions

- Design tokens come from `lib/core/design_system.dart` (Stage 1 — to be built). Once it exists, **zero hardcoded hex / spacing / font size** in screens.
- State: Provider only. Drop `optimized_app_state.dart` split-brain — one `AppState`.
- Storage: SQLite for all money/transaction/loan data. `SharedPreferences` only for theme, currency, sort memory, dismissed-warning IDs.
- Optimistic updates: every write goes through service method that (1) updates UI, (2) writes DB, (3) rolls back + SnackBar on failure.
- Soft-delete (`deleted_at NULL`) + 8-second SnackBar Undo + 30-day hard-delete sweep.
- Auto-backup: SQLite dump on `didChangeAppLifecycleState` paused. Retention 30 daily / 12 weekly / 12 monthly.
- Fonts: `Plus Jakarta Sans` (UI), `IBM Plex Mono` (amounts and codes).
- Currency rendering: `AmountText` widget — monospace, sign-colored, locale-aware.

## Security Defaults

- Biometric / PIN app-lock via `local_auth` — off by default, toggle in Settings. Fallback PIN required (in case biometric enrollment removed). Lock-after-N-seconds-background configurable.
- No analytics, no third-party SDKs other than what's already declared in `pubspec.yaml`. Adding any new SDK is a decision-log event.
- Database file lives in app-private storage. Backup files written to `Documents/SpendWise/auto_backup/` — surface a warning to user that this folder is user-readable.
- No secrets in repo. Keystore properties live in `android/key.properties` (gitignored).

---

## Workflow for Any New Task

1. Read this file. Read `Opus_plan.md` for stage context. Read the matching md for the work area.
2. Append session entry under `.claude/sessions/`.
3. Invoke `superpowers:brainstorming` if the task is creative/non-trivial.
4. Invoke `frontend-design:frontend-design` if visual work is involved.
5. Write/extend the relevant plan in `md/` if it's a new direction.
6. Implement.
7. Verify via `superpowers:verification-before-completion`.
8. Append decision entry under `.claude/decisions/` if a non-obvious choice was made.
9. Close the session entry with outcome + next step.

---

## Active Constraints

- Personal use first; do not block on Play Store concerns until Stage 6.
- Do not introduce cloud sync, SMS parsing, ad SDKs, subscription paywalls, or AI-prediction features. Out of scope by owner decision.
- Existing user data must survive every refactor. Migrations test on a real old DB dump.
