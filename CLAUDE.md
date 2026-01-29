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

## Pre-Flight Checklist (Before Making Changes)

- [ ] Read this file (CLAUDE.md) for project guidelines
- [ ] Understand the existing code structure
- [ ] Identify affected Views, ViewModels, and Services
- [ ] Ensure changes follow MVVM architecture
- [ ] Verify no force unwraps or print statements
- [ ] Keep functions under 50 lines, Views under 300 lines
