# CLAUDE.md - Claude Code Guidelines for Yaru iOS Project

## Project Overview
**Yaru** is a personal finance and tracking iOS application that helps users track goals, time, and expenses with precision. This document provides Claude Code with essential context for working on this codebase.

## Technical Stack
| Component | Technology |
|-----------|------------|
| Platform | iOS (SwiftUI Latest Stable) |
| Architecture | MVVM (Model-View-ViewModel) |
| Backend | Firebase / Cloud Firestore |
| Testing | Swift Testing Framework |
| Minimum iOS | Check project settings |

## Architecture Guidelines

### MVVM Pattern (Strictly Enforced)

**Models**
- Immutable `struct`s conforming to `Codable` and `Identifiable`
- Located in the `Models/` directory
- No business logic - pure data containers

**Views**
- Purely declarative SwiftUI - NO business logic
- Maximum 300 lines per file - refactor if exceeded
- Must use `@EnvironmentObject` for `NavigationManager`
- Decompose into small, atomic sub-views

**ViewModels**
- Classes conforming to `ObservableObject` / `@Observable`
- Handle all business logic and state transformations
- Decouple from implementations via protocols
- Located in `ViewModels/` directory

## Coding Standards

### Formatting
- **Indentation:** 2 spaces (STRICTLY ENFORCED)
- **Line Length:** Prefer under 120 characters
- **Function Size:** Maximum 50 lines per function

### Safety Rules
- **NO force unwraps** (`!`) - Use `if let`, `guard let`, or `??`
- **NO `print()` statements** - Use `Logger.info()`, `Logger.debug()`, or `Logger.error()`
- **Prefer `async/await`** over completion handlers/closures

### Swift Best Practices
```swift
// Good: Safe unwrapping
guard let user = currentUser else { return }

// Bad: Force unwrap
let user = currentUser!

// Good: Proper logging
Logger.info("User logged in: \(user.id)")

// Bad: Print statement
print("User logged in")
```

## Dependency Injection
- Use **Constructor Injection** for all dependencies
- Services and Repositories must be injected, not instantiated directly
- Every Service/Repository needs a corresponding Mock for testing

## Firebase / Firestore
- All Firestore documents must use strict `Codable` typing
- Data fetching encapsulated in Service classes
- Never access Firestore directly from Views or ViewModels

## Testing Requirements
- Use **Swift Testing** framework (not XCTest unless necessary)
- Write tests for all ViewModel business logic
- Cover: Success cases, Failure cases, Edge cases
- Create Mock implementations for all Services/Repositories

## Common Commands

```bash
# Build the project
xcodebuild -scheme Yaru -destination 'platform=iOS Simulator,name=iPhone 15'

# Run tests
xcodebuild test -scheme Yaru -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Before Making Changes

1. **Read existing code** before modifying - understand the patterns in use
2. **Check for existing utilities** - don't duplicate functionality
3. **Follow existing conventions** - match the style of surrounding code
4. **Consider testability** - ensure changes can be unit tested

## Third-Party Libraries
- Prefer native Apple frameworks over third-party libraries
- If a library is absolutely necessary, verify it's well-maintained
- Document why a third-party dependency was added

## When Uncertain
- Ask for clarification on ambiguous requirements
- Especially regarding data models and user flows
- Don't assume - verify the expected behavior

## Key Directories
```
├── Models/          # Data structures
├── Views/           # SwiftUI views
├── ViewModels/      # Business logic
├── Services/        # API/Firestore services
├── Repositories/    # Data access layer
├── Utilities/       # Helper functions
└── Tests/           # Unit and integration tests
```

## Quick Reference Checklist
- [ ] 2-space indentation
- [ ] No force unwraps
- [ ] Using Logger instead of print
- [ ] Functions under 50 lines
- [ ] Views under 300 lines
- [ ] Constructor injection used
- [ ] Tests written for business logic
