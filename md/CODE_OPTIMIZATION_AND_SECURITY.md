# SpendWise — Code Optimization, Smoothness & Security Plan

**Last updated:** 2026-05-18
**Scope:** Everything codewise that makes the app feel faster, smoother, safer, and harder to misuse. Pairs with `Opus_plan.md` (the staged roadmap) and `UI_REDESIGN_SOFT_MINIMAL.md` (the visual contract).
**Audience:** Future-Claude and the owner.

---

## 0. Reading Order

1. `CLAUDE.md` — project context, mandated skills, hard rules.
2. `md/Opus_plan.md` — staged sequence (Stage 0 → 6). This file is the **how** for the perf + security pieces of Stages 0, 0.5, 2, 5.6.
3. This file.
4. `UI_REDESIGN_SOFT_MINIMAL.md` for any UI-adjacent change.

---

## 1. Performance: Why It Feels Laggy Today

Three concrete causes from the live codebase audit:

| Symptom | Root cause | Fix area |
|---|---|---|
| Data delay after Save | UI waits for full reload from DB after every write | § 1.1 Optimistic updates |
| Page-switch lag | Heavy widget trees rebuild on every `notifyListeners` | § 1.2 Provider granularity + selector |
| Long lists stutter | Single `ListView` builds all rows at once, no item extents | § 1.3 List virtualization |
| Cold-start slow | All providers eagerly load all tables on boot | § 1.4 Lazy + paginated load |
| Calculator multi-op slow | Recomputes full expression on each keystroke with `String.split` | § 1.5 Token-stream evaluator |
| Charts jank | `fl_chart` re-renders with new data instances each frame | § 1.6 Stable chart data refs |
| Repeated DB hits | Each transaction add = N sequential `INSERT/UPDATE` calls | § 1.7 Batched `db.transaction()` |

### 1.1 Optimistic Updates (single shape for every write)

```dart
// lib/services/db/write_result.dart
sealed class WriteResult<T> {
  const WriteResult();
}
class WriteOk<T> extends WriteResult<T> { final T value; const WriteOk(this.value); }
class WriteFail<T> extends WriteResult<T> { final Object error; final StackTrace stack; const WriteFail(this.error, this.stack); }

// Every service.create/update/delete returns Future<WriteResult<T>>.
// Caller pattern (lives in screen or controller):
Future<void> addTransaction(TransactionDraft d) async {
  final temp = state.insertOptimistic(d);            // 1. UI updates instantly
  final res = await txnService.create(d);            // 2. DB write in background
  if (res is WriteFail) {
    state.rollback(temp);                            // 3a. Revert
    snack('Could not save. Tap to retry.', onTap: () => addTransaction(d));
  } else if (res is WriteOk) {
    state.commit(temp, res.value);                   // 3b. Promote temp → real
  }
}
```

**Rule:** Never `await` a DB write before navigating or rendering. UI moves on the next frame; DB catches up.

### 1.2 Provider Granularity

Split `AppState` into focused notifiers:

- `TransactionsNotifier`
- `AccountsNotifier`
- `BudgetsNotifier`
- `LoansNotifier`
- `GoalsNotifier`
- `SettingsNotifier`

Wrap each consumer in `Selector<T, U>` or `context.select` so a transaction add doesn't rebuild the Accounts tab. Kill the monolithic `optimized_app_state.dart` once split.

### 1.3 List Virtualization

- Replace any `Column { for (...) Row(...) }` over more than 12 items with `ListView.builder` + `itemExtent` when row height is fixed.
- For variable-height rows (grouped-by-day transactions), use `SliverList` + `SliverPersistentHeader` for sticky date headers.
- Add `cacheExtent: 300` on long lists for smoother scroll.

### 1.4 Lazy + Paginated Load

- On cold start: load only what Home renders (last 8 transactions, all accounts, current-month budget summary, active goals).
- Defer Loans / Reports / Bills until their tab is first opened.
- Records tab paginates: 50 rows page 1, then 50 more on scroll end. Backed by `LIMIT/OFFSET` queries.

### 1.5 Calculator: Token-Stream Evaluator

Current code does `expression.split('+').split('-')...` — no operator precedence, breaks on chained ops. Replace with a tiny shunting-yard parser:

```dart
// lib/core/math/calculator.dart
double evaluate(String expr) {
  final tokens = _tokenize(expr);                // emits numbers + operators
  final rpn = _shuntingYard(tokens);             // converts to postfix
  return _evalRpn(rpn);                          // O(n) eval
}
```

Display rolling running total (Samsung-style):

```
12 + 23 + 238 + 329 - 265
= 337
```

Update running total in `onChanged`, parse only on `=` press to avoid re-parse every keystroke when nothing material changed (debounce 80 ms).

### 1.6 Stable Chart Data Refs

Memoize chart data inside the screen with `useMemo` equivalent (`flutter_hooks` or manual `late final` + invalidation flag):

```dart
List<FlSpot> _spotsCache;
int _spotsHash;
List<FlSpot> get spots {
  final h = _data.fold(0, (a, b) => a ^ b.hashCode);
  if (h != _spotsHash) { _spotsCache = _build(_data); _spotsHash = h; }
  return _spotsCache;
}
```

Pass the same `List` instance across rebuilds → `fl_chart` skips its diff.

### 1.7 Batched DB Writes

Wrap multi-statement operations in one `db.transaction()`:

- CSV import — single transaction for the whole file.
- Recurring transaction generation on app start — one transaction.
- Soft-delete cascade (delete account → mark its txns as deleted) — one transaction.

---

## 2. Smoothness (Perceived Speed > Wall-Clock Speed)

- **Hero animations** on tap-to-detail (transaction row → detail screen, account card → detail).
- **Skeleton shimmer** for first-load lists instead of blank-then-pop.
- **60 fps target.** Run `flutter run --profile` + DevTools timeline before each release; fix any jank > 16 ms frames.
- **Page transitions:** prefer `PageTransitionsTheme` with `CupertinoPageTransitionsBuilder` on iOS, `OpenUpwardsPageTransitionsBuilder` on Android. Disable on cheap actions (filter sheet) — use `showModalBottomSheet`.
- **Haptic feedback** on destructive confirm, budget-exceeded warning, settled-loan completion. `HapticFeedback.lightImpact()` is enough; do not overdo it.
- **Pre-cache** category icons at app start so first scroll doesn't decode.

---

## 3. Code-Quality Reductions (Make It Easier to Work With)

### 3.1 Kill the Split-Brain
- For each `optimized_*.dart` / `*_screen.dart` pair: pick the better-architected version, migrate unique logic, delete the loser.
- One commit per pair. Tests (when they exist) green before merge.

### 3.2 Design-Token Discipline
- `lib/core/design_system.dart` is the only place defining colors, spacing, radii, shadows, font sizes.
- Add a CI lint that fails the build if `Color(0xFF` appears in `lib/screens/**` or `EdgeInsets.all(\d+)` with magic numbers > 8.

### 3.3 Reusable Widgets (only if used 3+ times)
- `AppCard`, `AppButton`, `AmountText`, `AppEmptyState`, `SectionHeader`, `AppPill`, `AppProgressRing`.
- Do not pre-extract. Wait until the same pattern appears 3+ times, then refactor.

### 3.4 Error Handling
- Single `ErrorService.report(error, stack, context)` — logs locally, surfaces SnackBar with retry where the user can act.
- No silent `try { } catch (_) { }`. Every catch logs.
- Async errors from `Future` / `Stream` go through `runZonedGuarded` at `main()`.

### 3.5 Testing Floor
- Three integration tests minimum (per `Opus_plan.md` § Concerns 6):
  1. Add transaction → appears in Records list within 100 ms.
  2. Set budget → exceed it → warning shown with correct numbers.
  3. Delete account → Undo SnackBar → state restored.
- One unit test per service method that touches money.

---

## 4. Data Safety (Non-Negotiable Before Touching Architecture)

Mirror of `Opus_plan.md` § Stage 0.5, with concrete commands.

### 4.1 Schema audit
- `lib/services/db/SCHEMA.md` documents every table + column + foreign key.
- Bump DB version on every `CREATE/ALTER`. `onUpgrade` covers every prior version.

### 4.2 Auto-backup
- On `AppLifecycleState.paused` and at app close: dump SQLite to `getApplicationDocumentsDirectory()/SpendWise/auto_backup/<isoDate>.db`.
- Retention sweep: keep last 30 daily, 12 weekly, 12 monthly. Older files removed.
- Settings → Backup → "Restore from snapshot" lists snapshots.

### 4.3 Soft-delete + Undo
- Add `deleted_at INTEGER NULL` (epoch ms) to: `transactions`, `accounts`, `loans`, `budgets`, `bill_reminders`, `recurring_transactions`, `financial_goals`, `group_expenses`.
- All read queries: `WHERE deleted_at IS NULL`.
- All "delete" actions: `UPDATE ... SET deleted_at = ?`.
- 8-second SnackBar with "Undo" — owner-confirmed pattern.
- Hard-delete sweep on app start: rows where `deleted_at < now - 30 days`.

### 4.4 Failed-write feedback
- See § 1.1. Never lie about save state.

---

## 5. Security: Biometric / PIN App Lock

### 5.1 Goal
- Optional. Off by default. Toggle in Settings → Privacy & Security.
- Two layers: a **mandatory PIN** (if lock is enabled) + **optional biometric** as a faster unlock on top.
- App-shell-level lock (covers everything) — not per-screen.

### 5.2 Dependencies
```yaml
# pubspec.yaml
dependencies:
  local_auth: ^2.x         # biometric prompt
  flutter_secure_storage: ^9.x   # PIN hash + lock settings
  crypto: ^3.x             # PBKDF2 / SHA-256
```

### 5.3 Data Model
Stored in `flutter_secure_storage` (encrypted by Android Keystore / iOS Keychain):

| Key | Value |
|---|---|
| `lock.enabled` | `"true"` / `"false"` |
| `lock.biometric_enabled` | `"true"` / `"false"` |
| `lock.pin_hash` | PBKDF2-HMAC-SHA256(pin, salt, iter=200_000) — base64 |
| `lock.pin_salt` | random 16-byte salt, base64 |
| `lock.timeout_seconds` | `0` immediate, `30`, `60`, `300` |
| `lock.failed_attempts` | int, resets on success |

### 5.4 Lock Flow

1. **App launch** or **resume from background ≥ `lock.timeout_seconds`** → push `LockScreen` over root navigator, block all other routes.
2. `LockScreen`:
   - Renders PIN keypad (6 digits, monospace).
   - If biometric enabled + available: auto-prompt `local_auth.authenticate(...)` on mount.
   - Biometric success → unlock.
   - Biometric fail / cancel → fall back to PIN.
   - PIN entered → PBKDF2 + constant-time compare against stored hash.
   - PIN success → unlock + reset `failed_attempts`.
   - PIN fail → increment `failed_attempts`; at 5 → 30-second cool-down; at 10 → 5-minute cool-down. Cool-down persists across app restarts.
3. **Forgot PIN** → user must restore from a backup (no recovery, by design). Disclaimer shown when enabling lock.

### 5.5 Settings UI (sketch)

```
Settings → Privacy & Security
├─ App Lock                                [Toggle: OFF]
├─ Auto-lock after                         [30 sec ▾]   (visible when enabled)
├─ Unlock with biometric                   [Toggle: OFF] (visible when enabled + device supports)
├─ Change PIN                              [>]          (visible when enabled)
└─ ⚠ Forgot PIN means restore-from-backup. No reset.
```

### 5.6 Edge Cases
- Biometric enrollment removed mid-session → on next lock, biometric prompt returns `notAvailable`, fall back to PIN cleanly.
- Device rebooted → PIN required first unlock (matches platform expectation).
- Background → foreground inside `timeout_seconds` → no re-lock.
- Backup restore on a new device → lock settings carry over because they're inside the SQLite metadata table (separate from PIN hash, which lives in secure storage and does NOT carry across). Result: lock prompts for a fresh PIN setup on first launch after restore.

### 5.7 Threat Model (Honest Scope)
- **In scope:** casual physical access (someone picks up your phone).
- **Out of scope:** root/jailbreak attacker with `frida` or device access at OS level. Local-first design means data lives on device — full-device encryption (OS-level passcode) is the real defense; app lock is a privacy layer, not a vault.

---

## 6. Privacy Hardening

- No third-party analytics, telemetry, or crash SDK by default. Add Sentry/Crashlytics only at Stage 6 with explicit opt-in toggle.
- All network capability removed from the manifest unless a feature explicitly needs it. Currency conversion (if added) uses an offline rate table; refresh is a manual user action.
- Export files (CSV, backup) include a header line warning that the file is unencrypted.
- Logs (`debugPrint`) stripped from production builds — guarded behind `kDebugMode`.

---

## 7. Build & Runtime Defaults

- `flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols/`
- `pubspec.yaml`: pin transitive critical deps (`sqflite`, `local_auth`, `flutter_secure_storage`) to exact versions.
- ProGuard / R8 rules in `android/app/proguard-rules.pro` to keep `sqflite` and `local_auth` reflection paths.
- Min SDK 23 (Android 6.0) — required for full biometric API.

---

## 8. Verification Checklist Before Calling Anything "Done"

Run every item before marking a perf/security task complete. Re-runs are cheap, regressions are expensive.

- [ ] `flutter analyze` — zero new warnings.
- [ ] `flutter test` — all integration + unit tests pass.
- [ ] Manual cold start < 2 s to interactive Home tab.
- [ ] Add a transaction with Save → row visible in Records within 100 ms.
- [ ] Toggle App Lock ON, set PIN, kill app, reopen → PIN required.
- [ ] Toggle biometric ON → reopen → fingerprint/face prompt fires.
- [ ] Fail biometric 3× → PIN keypad reachable.
- [ ] Fail PIN 5× → 30-second cool-down enforced.
- [ ] Delete a transaction → 8-second Undo SnackBar → Undo restores it.
- [ ] Force-quit during a write → restart → no half-saved state (DB transaction rolled back).
- [ ] Auto-backup file produced after pause.
- [ ] Restore from backup snapshot → all data present.

---

## 9. Sequence (Map to `Opus_plan.md` Stages)

| Stage | This file's sections |
|---|---|
| Stage 0 — Stop the bleeding | § 3.4 error handling, debugPrint strip (§ 6) |
| Stage 0.5 — Data safety | § 4 in full |
| Stage 1 — Design system | § 3.2 token discipline (lint) |
| Stage 2 — Architecture cleanup | § 1.1 optimistic shape, § 1.2 provider split, § 1.4 lazy load, § 1.7 batched writes, § 3.1 kill split-brain |
| Stage 3 — UI redesign | § 1.3 lists, § 1.6 charts, § 2 smoothness |
| Stage 4 — Finish features | § 1.5 calculator rewrite |
| Stage 5 — Quality of life | § 5 biometric/PIN in full |
| Stage 6 — Pre-launch | § 7 build defaults, § 8 verification |

Stages run in order. Skipping a stage to chase polish is the failure mode this plan exists to prevent.
