# Yaru — Personal Finance & Tracking App

**Platform:** iOS | **Framework:** SwiftUI | **Backend:** Firebase / Firestore | **Architecture:** MVVM

---

## Project Overview

Yaru is a personal finance tracking app that helps users manage daily spendings, set monthly budgets, track project-based expenses, and visualize spending analytics. It supports multi-currency, social authentication (Google/Apple), push notifications, and Firebase Analytics.

The Xcode project is named `WhatIdo` — the app's internal/development name.

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI (native, no third-party UI libs) |
| Architecture | MVVM + Dependency Injection |
| Concurrency | async/await, AsyncThrowingStream |
| Database | Firebase Firestore |
| Authentication | Firebase Auth (Google Sign-In, Apple Sign-In) |
| Analytics | Firebase Analytics |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Local Storage | UserDefaults via custom `AppStorage` wrapper |
| Currency | Multi-currency with exchange rates from Firestore |
| Testing | Swift Testing framework |

---

## Folder Structure

```
WhatIdo/
├── Assets.xcassets/              # Images and icons
├── Colors.xcassets/              # Color definitions
├── CustomViews/                  # Reusable UI components (17 components)
├── Extensions/                   # Swift type extensions
├── Features/                     # Feature modules by domain
│   ├── Authentication/           # Login, Google/Apple auth
│   ├── Goals/                    # Financial goals
│   ├── Onboarding/               # New user setup flow
│   ├── Settings/                 # App settings, feedback, developer tools
│   └── WhatISpend/               # Core spending/budget/project/analytics
│       ├── AddSpending/
│       ├── Analytics/
│       ├── Container/            # Dependency injection container
│       ├── Currency/
│       ├── DomainModels/
│       ├── ProjectSpending/
│       ├── Services/
│       ├── SetBudget/
│       └── SpendingDetail/
├── Firebase/                     # Dev/Prod GoogleService-Info.plist files
├── Fonts/                        # Custom font files
├── Managers/                     # App-level managers
├── Models/                       # Global enums and models
├── Navigation/                   # NavigationManager + Route definitions
├── Networking/                   # Firestore generic layer + social auth
├── Splash/                       # Launch screen routing
├── Utilities/                    # AnalyticsManager, OverlayManager, etc.
├── AppState.swift                # Global app state
├── WhatIdoApp.swift              # App entry point + Firebase init
└── ContentView.swift             # Legacy CoreData placeholder
```

---

## Features & Screens

| Screen | Purpose |
|---|---|
| Splash | Initial routing (auth check, onboarding state) |
| Authentication | Google/Apple Sign-In |
| Onboarding | New user setup (currency, first budget) |
| Dashboard | Monthly spending overview, budget progress |
| Add/Edit Spending | Create or modify expense transactions |
| Spending Detail | View individual transaction |
| Projects | Project-based expense grouping/tracking |
| Budget Settings | Set/edit/delete monthly budget |
| Analytics | Spending charts and breakdowns by time range |
| Currency Settings | Preferred currency selection |
| Goals | Financial goal creation and tracking |
| Settings | Account management, logout, notifications |
| Feedback | User feedback submission to Firestore |
| Developer (DEBUG) | Analytics event testing tool |

---

## Architecture: MVVM

### Views
- Purely declarative — no business logic
- Max 300 lines per file; decomposed into sub-views
- Use `@EnvironmentObject` for `NavigationManager`

### ViewModels
- `@MainActor` for thread safety
- Conform to `ObservableObject` or use `@Observable`
- All business logic and state transformations
- Async/await for concurrency (no callbacks)
- Always use `[weak self]` in Task closures

### Models
- Immutable `struct`s conforming to `Codable` and `Identifiable`
- DTOs (Data Transfer Objects) used for UI representation

### Services / Repositories
- Protocol-based with mock implementations for testing
- Encapsulate all Firestore queries
- Constructor injection for all dependencies

---

## Key ViewModels

| ViewModel | Responsibility |
|---|---|
| `DashboardViewModel` | Monthly spending list, budget summary, event bus listener |
| `SpendingsViewModel` | Spending CRUD, month filtering, budget integration |
| `AddSpendingViewModel` | Form validation, spending create/edit |
| `SpendingDetailViewModel` | Single transaction display |
| `ProjectsViewModel` | Project CRUD, project spending tracking |
| `BudgetViewModel` | Budget set/edit/delete, currency conversion |
| `AnalyticsViewModel` | Chart data aggregation by time range |
| `GoalsViewModel` | Financial goals CRUD |
| `AuthenticationViewModel` | Social auth, user profile creation |
| `SettingsViewModel` | App settings, logout |
| `CurrencySettingsViewModel` | Currency preference management |
| `FeedbackViewModel` | Feedback form submission |

---

## Services

| Service | Protocol | Operations |
|---|---|---|
| `SpendingsService` | `SpendingsServiceProtocol` | getAllSpendings, getSpendingsOfMonth, getSpendingsForProject, add, edit, delete (async + streaming) |
| `BudgetsService` | `BudgetsServiceProtocol` | getMonthlyBudget, add, edit, delete |
| `ProjectsService` | `ProjectsServiceProtocol` | getProjects, add, edit, deleteProject (atomic with spendings) |
| `GoalsService` | `GoalsServiceProtocol` | getGoals, add, edit, delete |
| `AuthService` | `AuthServiceProtocol` | signIn, logout, deleteAccount |
| `UserRepository` | `UserRepositoryType` | getUser, createUser, updateFCMToken, updateCurrency |
| `FeedbackService` | — | submitFeedback |

---

## Domain Models

| Model | Key Fields | Firestore Collection |
|---|---|---|
| `Spending` | id, userId, name, amount, date, spendingType, source, projectInfo, currencyCode | `spendings` |
| `Budget` | id (userId_year_month), budgetAmount, month, year, currencyCode | `budget` |
| `ProjectSpending` | id, name, budget, icon, status, userId | `projects` |
| `Goal` | id, userId, title, targetDate, isCompleted | `goals` |
| `DUser` | id, name, email, currency, fcmToken, enableNotification | `users` |

---

## Firestore Structure

```
firestore/
├── spendings/         { id, userId, name, amount, date, spendingType, projectInfo, source, currencyCode }
├── budget/            { id: "{userId}_{year}_{month}", budgetAmount, month, year, userId, currencyCode }
├── projects/          { id, name, budget, icon, status, userId }
├── users/             { id, name, email, currency, fcmToken, enableNotification }
├── goals/             { id, userId, title, targetDate, isCompleted }
└── user_feedback/     { id, userId, category, message, created }
```

---

## Networking Layer (`Networking/`)

- `FirebaseService` — Generic protocol for Firestore CRUD
- `FirestoreEndpoint` — Defines collection/document paths per feature
- `FirestoreParser` — Decodes Firestore snapshots into typed models
- `FirestoreIdentifiable` — Base protocol (Codable + Identifiable) for all domain models
- `AsyncThrowingStream` — Real-time data streaming for live updates

**Social Auth (`Networking/SocialAuthentication/`):**
- `GoogleAuthentication` — Google Sign-In handler
- `AppleSocialAuthentication` — Apple Sign-In handler
- `SocialAuthenticator` — Unified auth abstraction

---

## Dependency Injection

`AppDependencyContainer` (`Features/WhatISpend/Container/`) centralizes service creation:
- Lazy-loaded service singletons
- Factory methods for all ViewModels
- `PassthroughSubject<AppGlobalEvent, Never>` event bus for cross-VM communication

**AppGlobalEvents:** `reloadDashboard`, `projectDeleted`, `budgetUpdated`, `userLoggedOut`

---

## Navigation

- `NavigationManager` manages `NavigationPath` (EnvironmentObject)
- `NavigationRoutes` enum defines all app screens
- Supports deep linking via `NavigationStack`
- Injected via `@EnvironmentObject` into all views

---

## Utilities

| Utility | Purpose |
|---|---|
| `AnalyticsManager` | Firebase Analytics wrapper with typed events |
| `OverlayManager` | App-wide toast, popup, and loader display |
| `CurrencyManager` | Active currency state |
| `CurrencyService` | Loads exchange rates from Firestore |
| `CurrencyConfig` | Currency rate cache + conversion logic |
| `AppData` | Global UserDefaults state (user, budget, onboarding) |
| `AppStorage` / `AppStorageObject` | UserDefaults wrappers |
| `AppConfiguration` | Loads correct Firebase plist (Dev/Prod) |
| `Constants` | App-wide constant values |
| `NotificationSyncManager` | FCM token registration and push handling |

---

## Custom UI Components (`CustomViews/`)

| Component | Description |
|---|---|
| `AppHeaderView` | Consistent screen header with back/title |
| `AppTextfield` | Styled text input |
| `AppPickerView` | Styled picker |
| `AppPrimaryButton` | Primary CTA button |
| `CalendarFieldView` | Date picker input |
| `CustomDonutChart`, `PieChart` | Spending charts |
| `FlexibleBottomSheet` | Drag-to-dismiss modal sheet |
| `SearchBarView` | Search input bar |
| `EmptyStateView` | Empty list placeholder |
| `ToastView`, `PopupView` | User feedback overlays |
| `CircularIndicatorView` | Loading spinner |
| `SocialButtonView` | Google/Apple auth button |

---

## Analytics Events

All events use `AnalyticsManager.shared`. Add new events to the `AnalyticsEvent` enum in `Utilities/AnalyticsManager.swift`.

| Event | Parameters | Trigger |
|---|---|---|
| `user_signup` | provider | AuthenticationViewModel |
| `onboarding_completed` | — | OnboardingViewModel |
| `user_onboarded` | — | First expense added |
| `expense_added` | category, amount_range, fund_source | AddSpendingViewModel |
| `expense_edited` | — | AddSpendingViewModel |
| `expense_deleted` | — | DashboardViewModel |
| `budget_set` | amount_range | BudgetViewModel |
| `budget_edited` | — | BudgetViewModel |
| `project_created` | icon | ProjectsViewModel |
| `project_completed` | — | ProjectsViewModel |
| `analytics_viewed` | time_range | AnalyticsViewModel |
| `currency_changed` | from_currency, to_currency | CurrencySettingsViewModel |
| `settings_opened` | — | SettingsViewModel |
| `app_opened` | days_since_first_use, total_expenses_count | DashboardViewModel |

Debug tool: **Settings > Developer > Analytics Test** (DEBUG builds only)

---

## Extensions (`Extensions/`)

| Extension | Purpose |
|---|---|
| `DateExtension` | Formatting, month/year components, date math |
| `StringExtension` | Date parsing, string utilities |
| `DoubleExtension` | Currency formatting |
| `ViewExtension` | SwiftUI view modifiers |
| `ColorsExtension` | Design system colors |
| `FontExtension` | Design system fonts |
| `ArrayExtension` | Collection helpers |

---

## Code Standards

- **Indentation:** 2 spaces (strict)
- **No force unwraps (`!`)** — use `if let`, `guard let`, `??`
- **No `print()`** — use `Logger.info()`, `Logger.debug()`, `Logger.error()`
- **Max 50 lines per function**
- **Max 300 lines per View file**
- **`[weak self]` in all Task closures**
- `async/await` over closures for all concurrency
- Protocol-based services with mock implementations

---

## Firebase Environments

Two Firebase configurations:
- **Dev:** `Firebase/Dev/GoogleService-Info.plist`
- **Prod:** `Firebase/Prod/GoogleService-Info.plist`

Loaded dynamically via `AppConfiguration` in `AppDelegate`.

---

## Testing

- Framework: **Swift Testing** (not XCTest)
- Location: `WhatIdoTests/`
- Tests target ViewModel business logic
- All external dependencies mocked via protocols
- Cover success, failure, and edge cases

---

## Entry Points

| File | Role |
|---|---|
| `WhatIdoApp.swift` | App launch, Firebase init, environment setup |
| `Splash/Spalsh.swift` | Auth/onboarding routing on launch |
| `Navigation/NavigationManager.swift` | Navigation state management |
| `Navigation/NavigationRoutes.swift` | All screen route definitions |
| `Features/WhatISpend/Container/AppDependencyContainer.swift` | DI container + event bus |
