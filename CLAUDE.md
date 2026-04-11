# CLAUDE.md - Project Guidelines

## Project Overview
**Name:** Yaru (Personal Finance & Tracking App)
**Platform:** iOS
**Framework:** SwiftUI (Latest Stable)
**Backend:** Firebase / Cloud Firestore
**Architecture:** MVVM (Model-View-ViewModel)
**Testing:** Swift Testing (preferred over XCTest)

---

## Code Standards

### Formatting
- **Indentation:** 2 spaces (STRICT)
- **Line Length:** Prefer lines under 120 characters
- **Imports:** Group and sort alphabetically (Apple frameworks first, then third-party)

### Safety Rules
- **NO force unwraps (`!`)** - Use `if let`, `guard let`, or `??`
- **NO `print()` statements** - Use `Logger.info()`, `Logger.debug()`, `Logger.error()` (OSLog)
- **NO implicitly unwrapped optionals** unless required by UIKit/AppKit interop

### Function Guidelines
- **Max 50 lines per function**
- Single responsibility principle
- Prefer `async/await` over closures for concurrency
- Use descriptive naming (verb + noun pattern)

---

## Architecture (MVVM)

### Views
- Purely declarative - **NO business logic**
- **Max 300 lines per View file** - refactor into sub-views if exceeded
- Use `@EnvironmentObject` for `NavigationManager`
- Decompose into small, reusable atomic components

### ViewModels
- Conform to `ObservableObject` or use `@Observable`
- Handle ALL business logic and state transformations
- Decouple from implementations via protocols
- Must be testable with mock dependencies
- **Always use `[weak self]` in Task closures** to prevent retain cycles:
  ```swift
  Task { [weak self] in
      guard let self = self else { return }
      // async work here
  }
  ```

### Models
- Immutable `struct`s
- Conform to `Codable` and `Identifiable`
- Use strict typing for Firestore documents

---

## Dependency Injection

- **Constructor Injection** for all dependencies
- Services and Repositories injected via initializers
- All data fetching encapsulated in Service classes
- Every Service/Repository must have a Mock implementation

---

## Testing

- Use **Swift Testing** framework (not XCTest)
- Write tests for all ViewModel business logic
- Cover: Success, Failure, and Edge Cases
- Mock all external dependencies

---

## Firestore/Firebase

- Use `Codable` for all document serialization
- Encapsulate queries in dedicated Service classes
- Handle errors gracefully with proper logging

---

## Best Practices

1. **Prefer native Apple frameworks** over third-party libraries
2. **Ask for clarification** on ambiguous requirements before implementing
3. **Self-documenting code** preferred; add comments only for complex logic
4. **Modern Swift concurrency** (`async/await`) over callback patterns
5. **Type safety** is paramount - avoid `Any` and type erasure when possible

---

## Analytics (Firebase Analytics)

**IMPORTANT:** Every new feature or user action MUST include analytics tracking.

### Setup
- Use `AnalyticsManager.shared` singleton (located in `Utilities/AnalyticsManager.swift`)
- Add `private let analytics = AnalyticsManager.shared` to ViewModels

### When to Add Analytics
- **New features:** Track when users interact with the feature
- **CRUD operations:** Track create, update, delete actions
- **Navigation events:** Track when users open key screens
- **User milestones:** Track onboarding steps, first-time actions

### How to Add New Events
1. Add event name to `AnalyticsEvent` enum in `AnalyticsManager.swift`
2. Add parameter keys to `AnalyticsParam` enum if needed
3. Create a convenience method in `AnalyticsManager` (e.g., `logFeatureUsed()`)
4. Call the method from the appropriate ViewModel after successful action

### Existing Events Reference
| Event | Parameters | Trigger Location |
|-------|------------|------------------|
| `user_signup` | provider | AuthenticationViewModel |
| `onboarding_completed` | - | OnboardingViewModel |
| `user_onboarded` | - | Auto (first expense) |
| `expense_added` | category, amount_range, fund_source | AddSpendingViewModel |
| `expense_edited` | - | AddSpendingViewModel |
| `expense_deleted` | - | DashboardViewModel |
| `budget_set` | amount_range | BudgetViewModel |
| `budget_edited` | - | BudgetViewModel |
| `project_created` | icon | ProjectsViewModel |
| `project_completed` | - | (When implemented) |
| `analytics_viewed` | time_range | AnalyticsViewModel |
| `currency_changed` | from_currency, to_currency | CurrencySettingsViewModel |
| `settings_opened` | - | SettingsViewModel |
| `app_opened` | days_since_first_use, total_expenses_count | DashboardViewModel |

### Debug View
- Access via: Settings > Developer > Analytics Test (DEBUG builds only)
- Use to verify events are firing correctly during development

---

## Pre-Flight Checklist (Before Making Changes)

- [ ] Read this file (CLAUDE.md) for project guidelines
- [ ] Understand the existing code structure
- [ ] Identify affected Views, ViewModels, and Services
- [ ] Ensure changes follow MVVM architecture
- [ ] Verify no force unwraps or print statements
- [ ] Keep functions under 50 lines, Views under 300 lines
- [ ] **Add analytics tracking for new features/actions**

---

## Pre-Push Code Review (Self-Review Protocol)

Before marking any task complete, silently verify every file you modified:

### Silent checks (no output needed if passing)
- No force unwraps (`!`) introduced
- No `print()` statements added
- No retain cycles — `[weak self]` used in all Task closures
- Functions remain under 50 lines
- Views remain under 300 lines
- No business logic added to Views
- New user actions have analytics tracking

### Output a review block only if issues found
Format:
```
⚠️ Review findings:
[WARNING] FileName.swift — issue — suggested fix
[CRITICAL] FileName.swift — issue — suggested fix
```
Do not mark the task complete until all CRITICAL issues are resolved.
SUGGESTION and NITPICK level findings can be noted and left for the user to decide.

---

## Session Management

### On every session START:
- Read `HANDOFF.md` automatically
- Summarize the last session and current status
- Ask: "Ready to continue. Shall we pick up where we left off?"

### On every session END (when user says "bye", "done", "wrap up", or "end session"):
- Update `HANDOFF.md` with today's date, what was done, what's in progress, next steps, and any gotchas
- Confirm: "Handoff saved. See you next time."
