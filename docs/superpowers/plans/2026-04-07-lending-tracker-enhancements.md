# Lending Tracker Enhancements

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Enhance the lending tracker with borrower history, overdue notifications, lending statistics, a dedicated borrowers management screen, and improved loan return flow. Currently lending is basic — lend/return from the item detail screen with no due dates, no notifications, and no borrower management beyond inline creation.

**Architecture:** Extends existing `borrowers` and `loans` tables with a `dueAt` column (schema migration). Adds `flutter_local_notifications` for overdue alerts. New `BorrowersScreen` surfaces all borrowers with loan history. Lending statistics feed into the insights dashboard. All new UI follows the existing design system.

**Tech Stack:** Flutter, Drift (SQLite), Riverpod 3.x (hand-written), flutter_local_notifications, Freezed, GoRouter

**Author:** Paul Snow

**Version:** 0.0.0

---

## Current State Analysis

### What exists
- **Schema (v5):** `borrowers` table (id, name, email, phone, notes, updatedAt, deleted) and `loans` table (id, mediaItemId, borrowerId, lentAt, returnedAt, notes, updatedAt, deleted). No `dueAt` column.
- **DAOs:** `BorrowersDao` (watchAll, getById, insert, update, softDelete) and `LoansDao` (watchActiveLoans, watchActiveLoanForItem, watchLoansForItem, watchLoansForBorrower, insertLoan, updateLoan, returnItem).
- **Domain entities:** `Borrower` and `Loan` (both Freezed). `Loan` has an `isActive` getter but no `isOverdue` or `dueAt`.
- **Repository interfaces:** `IBorrowerRepository` (watchAll, getById, save, softDelete) and `ILoanRepository` (watchActiveLoanForItem, watchActiveLoans, watchLoansForItem, watchLoansForBorrower, createLoan, returnItem).
- **Use cases:** `LendItemUseCase`, `ReturnItemUseCase`, `ManageBorrowersUseCase` (create and delete only, no update).
- **Providers:** `allBorrowersProvider`, `activeLoanForItemProvider`, `activeLoansProvider`, `lentItemIdsProvider`, `loansForItemProvider`. No `loansForBorrowerProvider` or `overdueLoansProvider`.
- **UI:** `_LendingSection` in item detail screen shows active loan with "Return" button and past loan history. `BorrowerPickerDialog` allows selecting or creating a borrower inline. No dedicated borrowers screen. No due date picker.
- **No notifications infrastructure** — `flutter_local_notifications` is not in `pubspec.yaml`.
- **StatisticsScreen** has no lending stats — only collection stats.

### What is missing
1. No `dueAt` on loans — cannot track overdue
2. No overdue notifications
3. No dedicated borrowers management screen
4. No borrower edit capability (only create and delete)
5. No borrower loan history view
6. No lending statistics in insights
7. No overdue visual indicators on item detail or collection screens

---

## File Structure (New & Modified)

```
lib/
  domain/
    entities/
      loan.dart                           (MODIFY — add dueAt, isOverdue getter)
  data/
    local/
      database/
        tables/
          loans_table.dart                (MODIFY — add dueAt column)
        app_database.dart                 (MODIFY — schema migration)
      dao/
        loans_dao.dart                    (MODIFY — overdue queries)
    repositories/
      loan_repository_impl.dart           (MODIFY — overdue support)
      borrower_repository_impl.dart       (MODIFY — update support)
  domain/
    repositories/
      i_loan_repository.dart              (MODIFY — add watchOverdueLoans)
      i_borrower_repository.dart          (MODIFY — add update)
    usecases/
      manage_borrowers_usecase.dart       (MODIFY — add update)
      schedule_overdue_notification_usecase.dart (CREATE)
  presentation/
    providers/
      lending_provider.dart               (MODIFY — add overdue, borrower history providers)
      notification_provider.dart          (CREATE — local notifications setup)
    screens/
      borrowers/
        borrowers_screen.dart             (CREATE — dedicated borrowers management)
        borrower_detail_screen.dart       (CREATE — borrower profile with loan history)
      item_detail/
        widgets/
          lending_section.dart            (MODIFY — due date picker, overdue badges)
    widgets/
      overdue_badge.dart                  (CREATE — reusable overdue indicator)
  app/
    router.dart                           (MODIFY — add borrower routes)
  core/
    services/
      notification_service.dart           (CREATE — flutter_local_notifications wrapper)
test/
  unit/
    domain/
      schedule_overdue_notification_test.dart (CREATE)
    data/
      dao/
        loans_dao_overdue_test.dart       (CREATE)
    presentation/
      providers/
        lending_provider_test.dart        (CREATE)
  presentation/
    screens/
      borrowers/
        borrowers_screen_test.dart        (CREATE)
        borrower_detail_screen_test.dart  (CREATE)
```

---

## Task 1: Add Due Date to Loans

**Files:**
- Modify: `lib/data/local/database/tables/loans_table.dart`
- Modify: `lib/data/local/database/app_database.dart`
- Modify: `lib/domain/entities/loan.dart`

- [ ] **Step 1: Add `dueAt` nullable integer column to loans table**

- [ ] **Step 2: Add schema migration** (add ALTER TABLE for `dueAt` column)

- [ ] **Step 3: Update `Loan` Freezed entity** — add `dueAt` (int?), add `isOverdue` getter (`dueAt != null && returnedAt == null && DateTime.now().millisecondsSinceEpoch > dueAt!`)

- [ ] **Step 4: Run build_runner**
- [ ] **Step 5: Update loan mapper** to handle `dueAt`
- [ ] **Step 6: Write tests** — `isOverdue` returns true/false correctly
- [ ] **Step 7: Run tests**
- [ ] **Step 8: Commit**

---

## Task 2: Overdue Loan Queries

**Files:**
- Modify: `lib/data/local/dao/loans_dao.dart`
- Modify: `lib/domain/repositories/i_loan_repository.dart`
- Modify: `lib/data/repositories/loan_repository_impl.dart`

- [ ] **Step 1: Add `watchOverdueLoans()` to DAO** — active loans where `dueAt < now` and `returnedAt` is null

- [ ] **Step 2: Add `watchOverdueLoans()` to `ILoanRepository`**

- [ ] **Step 3: Implement in `LoanRepositoryImpl`**

- [ ] **Step 4: Write DAO tests** in `test/unit/data/dao/loans_dao_overdue_test.dart`

- [ ] **Step 5: Run tests**
- [ ] **Step 6: Commit**

---

## Task 3: Enhanced Borrower Management

**Files:**
- Modify: `lib/domain/repositories/i_borrower_repository.dart`
- Modify: `lib/data/repositories/borrower_repository_impl.dart`
- Modify: `lib/domain/usecases/manage_borrowers_usecase.dart`

- [ ] **Step 1: Add `update` method to `IBorrowerRepository`**

- [ ] **Step 2: Implement in `BorrowerRepositoryImpl`**

- [ ] **Step 3: Add `updateBorrower` to `ManageBorrowersUseCase`**

- [ ] **Step 4: Write tests**
- [ ] **Step 5: Commit**

---

## Task 4: Lending Providers — Overdue & Borrower History

**Files:**
- Modify: `lib/presentation/providers/lending_provider.dart`

- [ ] **Step 1: Add `overdueLoansProvider`** — streams overdue loans from repository

- [ ] **Step 2: Add `loansForBorrowerProvider`** — family provider by borrower ID

- [ ] **Step 3: Add `overdueCountProvider`** — derived count for badges

- [ ] **Step 4: Write provider tests** in `test/unit/presentation/providers/lending_provider_test.dart`

- [ ] **Step 5: Run tests**
- [ ] **Step 6: Commit**

---

## Task 5: Notification Service

**Files:**
- Modify: `pubspec.yaml` (add `flutter_local_notifications`)
- Create: `lib/core/services/notification_service.dart`
- Create: `lib/presentation/providers/notification_provider.dart`
- Create: `lib/domain/usecases/schedule_overdue_notification_usecase.dart`

- [ ] **Step 1: Add `flutter_local_notifications` dependency**

- [ ] **Step 2: Create `NotificationService`** — initialises channels for Android/iOS/macOS, exposes `scheduleNotification(id, title, body, scheduledDate)` and `cancelNotification(id)`

- [ ] **Step 3: Create `ScheduleOverdueNotificationUseCase`** — when a loan is created with a `dueAt`, schedules a notification for that date. When a loan is returned, cancels the notification.

- [ ] **Step 4: Create `notificationServiceProvider`**

- [ ] **Step 5: Wire into `LendItemUseCase`** — schedule notification after creating loan with due date

- [ ] **Step 6: Wire into `ReturnItemUseCase`** — cancel notification on return

- [ ] **Step 7: Write tests** in `test/unit/domain/schedule_overdue_notification_test.dart`

- [ ] **Step 8: Run tests**
- [ ] **Step 9: Commit**

---

## Task 6: Due Date Picker in Lending Section

**Files:**
- Modify: `lib/presentation/screens/item_detail/widgets/lending_section.dart` (or equivalent)

- [ ] **Step 1: Add optional due date picker to lend dialog**

When lending an item, show a `DatePicker` below the borrower selector. Default: no due date. Minimum: today. Format: localised date.

- [ ] **Step 2: Pass `dueAt` through to `LendItemUseCase`**

- [ ] **Step 3: Show due date on active loan display** — with overdue badge if past due

- [ ] **Step 4: Add "Extend Due Date" action** on active loans — opens date picker to update `dueAt`

- [ ] **Step 5: Write widget tests**
- [ ] **Step 6: Commit**

---

## Task 7: Overdue Badge Widget

**Files:**
- Create: `lib/presentation/widgets/overdue_badge.dart`

- [ ] **Step 1: Create `OverdueBadge` widget** — small chip with error colour background, "OVERDUE" text, and days overdue count. Reusable across item detail, collection list, and borrower screens.

- [ ] **Step 2: Add overdue indicators to collection list items** — show badge on items that have an overdue active loan

- [ ] **Step 3: Write widget tests**
- [ ] **Step 4: Commit**

---

## Task 8: Borrowers Management Screen

**Files:**
- Create: `lib/presentation/screens/borrowers/borrowers_screen.dart`
- Modify: `lib/app/router.dart`

- [ ] **Step 1: Create `BorrowersScreen`** — list of all borrowers with:
  - Name, contact info summary
  - Active loan count badge
  - Overdue count badge (error colour)
  - Search/filter by name
  - Add borrower FAB
  - Tap to navigate to borrower detail
  - Long-press/swipe to soft delete

Desktop: `ScreenHeader` + tonal container cards in grid layout.
Mobile: `AppBar` + `ListView`.

- [ ] **Step 2: Add route** — `/borrowers` or nested under settings

- [ ] **Step 3: Add navigation entry** — Settings screen tile or sidebar entry

- [ ] **Step 4: Write widget tests** in `test/presentation/screens/borrowers/borrowers_screen_test.dart`

- [ ] **Step 5: Commit**

---

## Task 9: Borrower Detail Screen

**Files:**
- Create: `lib/presentation/screens/borrowers/borrower_detail_screen.dart`

- [ ] **Step 1: Create `BorrowerDetailScreen`** showing:
  - Borrower name, email, phone, notes (editable)
  - Active loans section with item titles, lent dates, due dates, overdue badges
  - Past loans section (returned) with item titles, lent/returned dates
  - Statistics: total loans, average loan duration, currently overdue count
  - Edit and delete actions

- [ ] **Step 2: Add route** — `/borrowers/:id`

- [ ] **Step 3: Write widget tests** in `test/presentation/screens/borrowers/borrower_detail_screen_test.dart`

- [ ] **Step 4: Commit**

---

## Task 10: Full Test Suite & Verification

- [ ] **Step 1: Run full test suite** — `flutter test`
- [ ] **Step 2: Run static analysis** — `flutter analyze`
- [ ] **Step 3: Manual smoke test** — lend item with due date, verify notification scheduled, return item, verify notification cancelled, check borrowers screen, check overdue badges
- [ ] **Step 4: Final commit**

---

## Architecture Notes

**Notification Strategy:** Notifications are scheduled at loan creation time using `flutter_local_notifications`. Each notification ID is derived from the loan ID (hash to int). On return, the notification is cancelled. If the app is reinstalled, pending notifications are lost — this is acceptable for a local-first app.

**Overdue Threshold:** A loan is overdue when `dueAt` is in the past and the loan is still active. There is no grace period — the due date is the exact boundary.

**Borrower Soft Deletes:** Borrowers are soft-deleted (consistent with the app's convention). A soft-deleted borrower's past loans remain visible in history but the borrower cannot be selected for new loans.

**Schema Migration:** Adding `dueAt` as a nullable column is non-destructive. Existing loans without a due date simply have `dueAt = null` and are never considered overdue.

**Platform Notes:** `flutter_local_notifications` supports Android, iOS, and macOS. On Linux and Windows, notifications are best-effort (may require additional platform setup). The notification service should gracefully degrade on unsupported platforms.
