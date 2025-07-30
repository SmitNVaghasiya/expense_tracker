# Recommended Folder Structure for Expense Tracker

## Current Issues:

1. **Inconsistent imports** - mixing direct imports with barrel exports
2. **Incomplete barrel exports** - missing many screen exports
3. **Mixed responsibilities** - UI components mixed with screens
4. **Large files** - some screens are 900+ lines
5. **No separation of concerns** - business logic mixed with UI

## Recommended Structure:

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # Main app configuration
│   └── routes.dart                 # Route definitions
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── theme_constants.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── currency_utils.dart
│   │   └── validation_utils.dart
│   └── extensions/
│       └── string_extensions.dart
├── data/
│   ├── models/
│   │   ├── transaction.dart
│   │   ├── account.dart
│   │   ├── budget.dart
│   │   ├── group.dart
│   │   └── index.dart
│   ├── repositories/
│   │   ├── transaction_repository.dart
│   │   ├── account_repository.dart
│   │   └── budget_repository.dart
│   └── datasources/
│       └── local_datasource.dart
├── domain/
│   ├── entities/
│   │   └── (same as models but for business logic)
│   └── usecases/
│       ├── get_transactions.dart
│       ├── add_transaction.dart
│       └── calculate_totals.dart
├── presentation/
│   ├── screens/
│   │   ├── dashboard/
│   │   │   ├── dashboard_screen.dart
│   │   │   └── widgets/
│   │   │       ├── transaction_list.dart
│   │   │       └── summary_cards.dart
│   │   ├── transactions/
│   │   │   ├── calculator_transaction_screen.dart
│   │   │   ├── expenses_screen.dart
│   │   │   └── income_screen.dart
│   │   ├── accounts/
│   │   │   └── accounts_screen.dart
│   │   ├── budgets/
│   │   │   └── budgets_screen.dart
│   │   ├── reports/
│   │   │   └── reports_screen.dart
│   │   └── settings/
│   │       ├── theme_selection_screen.dart
│   │       ├── currency_selection_screen.dart
│   │       ├── backup_restore_screen.dart
│   │       ├── import_export_screen.dart
│   │       ├── delete_reset_screen.dart
│   │       ├── feedback_screen.dart
│   │       └── help_screen.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── custom_drawer.dart
│   │   │   ├── custom_app_bar.dart
│   │   │   └── loading_widget.dart
│   │   ├── forms/
│   │   │   ├── transaction_form.dart
│   │   │   └── account_form.dart
│   │   └── charts/
│   │       └── expense_chart.dart
│   └── providers/
│       ├── theme_provider.dart
│       ├── currency_provider.dart
│       └── data_provider.dart
└── services/
    ├── data_service.dart
    ├── csv_import_service.dart
    └── reminder_service.dart
```

## Benefits of This Structure:

### 1. **Clear Separation of Concerns**

- **Data Layer**: Models, repositories, datasources
- **Domain Layer**: Business logic and use cases
- **Presentation Layer**: UI components and screens

### 2. **Better Organization**

- Screens grouped by feature (dashboard, transactions, accounts, etc.)
- Common widgets separated from screens
- Utilities and constants in dedicated folders

### 3. **Improved Maintainability**

- Smaller, focused files
- Easier to find specific functionality
- Better testability with separated concerns

### 4. **Consistent Import Patterns**

- Use barrel exports consistently
- Clear import paths
- Reduced import complexity

## Immediate Actions Needed:

1. **Complete the barrel exports** ✅ (Done)
2. **Move `custom_drawer.dart` to widgets folder**
3. **Create feature-based screen folders**
4. **Extract large widgets from screens**
5. **Add missing barrel exports for services**

## Migration Strategy:

1. **Phase 1**: Complete current barrel exports and fix imports
2. **Phase 2**: Create new folder structure
3. **Phase 3**: Move files to new structure
4. **Phase 4**: Update all imports
5. **Phase 5**: Extract widgets and utilities

This structure will make your codebase much more maintainable and reduce confusion as the project grows.
