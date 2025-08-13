# SpendWise

A comprehensive personal finance and expense tracking application built with Flutter. This is a feature-rich financial tracking app with advanced capabilities for personal finance management.

## 🚨 Current Status

**✅ IMPROVED**: This application has been significantly enhanced with many new features and improvements. While some areas still need refinement, the core functionality is now much more robust.

### Recent Major Improvements:

- ✅ **Database Implementation**: Migrated from SharedPreferences to SQLite for proper data persistence
- ✅ **Bill Reminders**: Complete bill reminder system with notifications
- ✅ **Financial Goals**: Comprehensive financial goal tracking and progress monitoring
- ✅ **Recurring Transactions**: Automated recurring transaction management
- ✅ **Enhanced Loan Management**: Improved loan tracking with auto-deduction capabilities
- ✅ **Error Handling**: Comprehensive error handling and user feedback system
- ✅ **Pagination**: Efficient data loading with pagination support
- ✅ **Enhanced UI**: Improved theme system and responsive design

### Areas Still Needing Attention:

- 🔧 Calculator functionality needs refinement (basic operations work but could be improved)
- 🔧 Some advanced analytics and reporting features
- 🔧 Performance optimization for very large datasets

## 📱 Features

### ✅ Fully Implemented Features

#### Core Functionality

- **Dashboard**: Comprehensive overview with advanced search, filtering, and period selection
- **Expense Tracking**: Add, edit, and manage expenses with detailed categories
- **Income Tracking**: Track income sources with categorization and notes
- **Account Management**: Multiple account support with real-time balance synchronization
- **Budget Creation**: Set monthly budgets with tracking and alerts
- **Loan Management**: Advanced loan tracking with payment scheduling and auto-deduction
- **Transfer Support**: Full transfer functionality between accounts
- **Transaction Editing**: Complete CRUD operations for all transaction types

#### Advanced Features

- **Bill Reminders**: Set up bill reminders with notifications and recurring patterns
- **Financial Goals**: Track savings, debt payoff, investment, and emergency fund goals
- **Recurring Transactions**: Automate regular income/expenses with flexible scheduling
- **Loan Reminders**: Automated loan payment reminders and auto-deduction system

#### Data Management

- **SQLite Database**: Robust data persistence with proper relationships
- **Import/Export**: CSV import/export functionality
- **Backup/Restore**: Comprehensive data backup and restoration
- **Data Reset**: Clear all data functionality with confirmation
- **Error Handling**: Comprehensive error logging and user feedback

#### User Interface

- **Advanced Theme System**: Light, dark, and system themes with Material 3
- **Currency Support**: Multiple world currencies with real-time conversion
- **Custom Drawer**: Enhanced navigation drawer with quick access
- **Responsive Design**: Optimized for different screen sizes and orientations
- **Advanced Search & Filter**: Comprehensive search, filtering, and sorting
- **Pagination**: Efficient data loading for large datasets

#### Settings & Customization

- **Theme Selection**: Multiple theme options with custom color schemes
- **Currency Selection**: Extensive currency support
- **Reminder Settings**: Configurable reminder system
- **Help & Feedback**: Built-in help system and feedback mechanism
- **Notification Management**: Local notification system for reminders

### 🚧 Partially Implemented Features

#### Budget System

- ✅ Budget creation, editing, and monthly tracking
- ✅ Budget vs actual spending comparison
- 🔧 Budget alerts and notifications (basic implementation)
- 🔧 Budget rollover functionality (needs refinement)

#### Reports & Analytics

- ✅ Financial totals and summaries
- ✅ Category-wise breakdowns
- ✅ Period-based filtering and analysis
- 🔧 Advanced charts and graphs (basic implementation)
- 🔧 Custom date range reports (needs enhancement)

#### Loan Management

- ✅ Complete loan tracking with CRUD operations
- ✅ Payment scheduling and history
- ✅ Auto-deduction system
- 🔧 Advanced interest calculations (basic implementation)
- 🔧 Payment reminders (needs refinement)

### ❌ Missing Features

#### Core Features

- Receipt scanning/photo attachment
- Expense splitting functionality
- Advanced investment tracking
- Tax preparation features

#### Advanced Features

- Cloud synchronization
- Family/shared expense tracking
- Advanced AI-powered insights
- Banking API integration

## 🛠️ Technical Stack

### Frontend

- **Framework**: Flutter 3.8.1+
- **Language**: Dart
- **UI**: Material Design 3 with custom themes
- **State Management**: Provider with ChangeNotifier

### Backend & Data

- **Database**: SQLite with sqflite package
- **Local Storage**: SharedPreferences for settings
- **File Handling**: CSV import/export, file picker
- **Notifications**: Flutter Local Notifications

### Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.2.3
  intl: ^0.17.0
  uuid: ^4.5.1
  fl_chart: ^0.69.0
  csv: ^6.0.0
  provider: ^6.1.1
  path_provider: ^2.1.1
  file_picker: ^8.0.0+1
  url_launcher: ^6.2.4
  sqflite: ^2.3.0
  sqflite_common_ffi: ^2.3.2
  path: ^1.8.3
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.2
  image_picker: ^1.0.7
  camera: ^0.10.5+9
  http: ^1.1.2
  permission_handler: ^11.2.0
```

## 📁 Project Structure

```
lib/
├── main.dart                           # App entry point with theme configuration
├── core/                               # Core utilities and constants
│   ├── constants.dart                  # App constants and configuration
│   ├── extensions.dart                 # Dart extensions for common operations
│   ├── utils.dart                      # Utility functions and helpers
│   ├── pagination_service.dart         # Data pagination and loading
│   └── index.dart                      # Core exports
├── models/                             # Data models
│   ├── transaction.dart                # Transaction model with transfer support
│   ├── account.dart                    # Account model with balance tracking
│   ├── budget.dart                     # Budget model with period tracking
│   ├── loan.dart                       # Loan model with payment scheduling
│   ├── group.dart                      # Group model for categorization
│   ├── bill_reminder.dart              # Bill reminder model with notifications
│   ├── financial_goal.dart             # Financial goal model with progress tracking
│   ├── recurring_transaction.dart      # Recurring transaction model
│   └── index.dart                      # Model exports
├── screens/                            # UI screens
│   ├── dashboard/                      # Dashboard and home screens
│   │   ├── dashboard_screen.dart       # Financial overview with advanced filtering
│   │   └── home_screen.dart            # Main navigation with bottom tabs
│   ├── transactions/                   # Transaction management screens
│   │   ├── expenses_screen.dart        # Expense list with CRUD operations
│   │   ├── income_screen.dart          # Income list with CRUD operations
│   │   ├── recurring_transactions_screen.dart # Recurring transaction management
│   │   └── calculator_transaction_screen.dart # Advanced transaction calculator
│   ├── financial/                      # Financial management screens
│   │   ├── accounts_screen.dart        # Account management with balance sync
│   │   ├── budgets_screen.dart         # Budget management and tracking
│   │   ├── financial_goals_screen.dart # Financial goal tracking
│   │   ├── loans_screen.dart           # Loan tracking and management
│   │   └── add_loan_screen.dart        # Add/edit loan screen
│   ├── reminders/                      # Reminder management screens
│   │   ├── bill_reminders_screen.dart  # Bill reminder management
│   │   ├── reminder_settings_screen.dart # Reminder configuration
│   │   └── loan_reminder_settings_screen.dart # Loan reminder settings
│   ├── reports/                        # Reporting and analytics
│   │   └── reports_screen.dart         # Financial reports and analytics
│   ├── settings/                       # App settings and configuration
│   │   ├── theme_selection_screen.dart # Theme customization
│   │   ├── currency_selection_screen.dart # Currency selection
│   │   ├── backup_restore_screen.dart  # Data backup and restoration
│   │   ├── import_export_screen.dart   # Data import/export functionality
│   │   ├── delete_reset_screen.dart    # Data management
│   │   ├── help_screen.dart            # Help and documentation
│   │   └── feedback_screen.dart        # User feedback system
│   ├── shared/                         # Shared UI components
│   │   └── custom_drawer.dart          # Navigation drawer
│   └── index.dart                      # Screen exports
├── services/                           # Business logic and data services
│   ├── database_service.dart           # SQLite database management
│   ├── data_service.dart               # Data operations and CRUD
│   ├── loan_service.dart               # Loan management operations
│   ├── budget_service.dart             # Budget tracking and management
│   ├── bill_reminder_service.dart      # Bill reminder and notification system
│   ├── financial_goal_service.dart     # Financial goal tracking
│   ├── recurring_transaction_service.dart # Recurring transaction automation
│   ├── loan_reminder_service.dart      # Loan payment reminders
│   ├── csv_import_service.dart         # CSV data import
│   ├── export_service.dart             # Data export functionality
│   ├── theme_provider.dart             # Theme state management
│   ├── currency_provider.dart          # Currency state management
│   ├── reminder_service.dart           # General reminder system
│   ├── app_state.dart                  # Global application state
│   ├── error_service.dart              # Error handling and logging
│   └── index.dart                      # Service exports
└── widgets/                            # Reusable UI components
    ├── common/                         # Common reusable widgets
    │   └── index.dart                  # Common widget exports
    ├── charts/                         # Chart and visualization widgets
    │   └── index.dart                  # Chart widget exports
    └── index.dart                      # Widget exports
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/spendwise.git
   cd spendwise
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 📊 Usage Guide

### Adding Transactions

1. Navigate to Dashboard
2. Tap the "+" button
3. Select transaction type (Income/Expense/Transfer)
4. Use the calculator to enter amount
5. Select category and account
6. Add notes (optional)
7. Tap "SAVE"

### Managing Bill Reminders

1. Go to Bill Reminders tab
2. Tap "+" to add new reminder
3. Set due date and reminder preferences
4. Enable notifications for timely reminders
5. Mark as paid when completed

### Setting Financial Goals

1. Go to Financial Goals tab
2. Tap "+" to create new goal
3. Select goal type and set target amount
4. Set target date and track progress
5. Monitor progress with visual indicators

### Managing Recurring Transactions

1. Go to Recurring Transactions tab
2. Tap "+" to set up recurring transaction
3. Choose frequency (daily, weekly, monthly, yearly)
4. Set start and end dates
5. Monitor automatic transaction creation

### Managing Accounts

1. Go to Accounts tab
2. Tap "+" to add new account
3. Enter account details and initial balance
4. View real-time balance and transaction history
5. Transfer funds between accounts

### Setting Budgets

1. Go to Budgets tab
2. Tap "+" to create new budget
3. Select category and set monthly limit
4. Monitor spending vs budget with alerts
5. Track budget performance over time

### Tracking Loans

1. Go to Loans tab
2. Tap "+" to add new loan
3. Enter loan details and payment schedule
4. Enable auto-deduction if desired
5. Track payments and remaining balance

## 🔧 Development Roadmap

### Phase 1: Core Stability ✅ (COMPLETED)

- ✅ Implement SQLite database
- ✅ Fix calculator functionality
- ✅ Implement proper error handling
- ✅ Add transaction editing
- ✅ Implement bill reminders
- ✅ Add financial goals
- ✅ Add recurring transactions

### Phase 2: Advanced Features 🚧 (IN PROGRESS)

- 🔧 Enhanced budget tracking and alerts
- 🔧 Advanced reporting and analytics
- 🔧 Performance optimization
- 🔧 Advanced loan management features

### Phase 3: Future Enhancements 📋 (PLANNED)

- 📋 Receipt scanning and photo attachment
- 📋 Expense splitting functionality
- 📋 Cloud synchronization
- 📋 Advanced AI-powered insights
- 📋 Banking API integration
- 📋 Family/shared expense tracking

## 🤝 Contributing

We welcome contributions! Please read our contributing guidelines before submitting pull requests.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests (if applicable)
5. Submit a pull request

### Code Standards

- Follow Dart/Flutter conventions
- Add proper documentation
- Include error handling
- Write unit tests for new features
- Use the established service architecture

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [issues](https://github.com/yourusername/spendwise/issues) page
2. Read the [errors.md](errors.md) file for known issues
3. Create a new issue with detailed information

## 📈 Recent Achievements

### Major Features Implemented

- **Database Migration**: Successfully migrated from SharedPreferences to SQLite
- **Bill Reminders**: Complete notification system with recurring patterns
- **Financial Goals**: Comprehensive goal tracking with progress visualization
- **Recurring Transactions**: Automated transaction management
- **Enhanced Loan System**: Advanced loan tracking with auto-deduction
- **Error Handling**: Robust error management and user feedback
- **Pagination**: Efficient data loading for large datasets
- **Advanced UI**: Material 3 design with custom themes

### Performance Improvements

- **Data Loading**: Implemented pagination for better performance
- **Database Optimization**: Proper indexing and query optimization
- **Memory Management**: Efficient data handling and cleanup
- **UI Responsiveness**: Smooth animations and transitions

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for the design system
- SQLite team for the robust database engine
- Open source community for various packages used
- Contributors and testers for feedback and improvements

---

**Note**: This application has been significantly enhanced and is now much more feature-complete. The core functionality is stable and ready for production use, with ongoing improvements being made to advanced features and performance optimization.
