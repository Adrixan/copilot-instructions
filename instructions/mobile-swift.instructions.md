---
applyTo:
  - "**/*.swift"
  - "**/Package.swift"
  - "**/*.xcodeproj/**"
  - "**/*.xcworkspace/**"
---
<!-- markdownlint-disable MD013 MD022 MD031 MD032 -->
<swift_standards>

## Swift / SwiftUI / iOS

- **Swift 5.9+** with strict concurrency checking enabled
- **SwiftUI** default. UIKit only when SwiftUI lacks capability.
- **Architecture:** MVVM — one ViewModel per screen
- **Dependencies:** Swift Package Manager preferred over CocoaPods/Carthage
- **Linting:** SwiftLint with `--strict` in CI
- **Testing:** Swift Testing framework (`#expect`/`#require`) + XCTest

### MVVM Structure [MUST]

- Views render state — never compute or transform data in the View body.
- ViewModel is `@Observable` (Swift 5.9+) or `ObservableObject`, annotated `@MainActor`.
- Navigation state owned by ViewModel or a dedicated Router/Coordinator.

```swift
// ❌ Logic in View
Text(items.filter { $0.isActive }.count.description)
// ✅ ViewModel exposes computed state
@Observable @MainActor final class ItemListViewModel {
    var activeCount: Int { items.filter(\.isActive).count }
}
```

### Async/Await & Actors [MUST]

- All async work in `Task {}` — no `DispatchQueue.main.async` in new code.
- Every stored `Task` cancelled in `deinit` or `.onDisappear`.
- `Task.detached` requires inline comment explaining why.
- Use `actor` for shared mutable state across contexts.

```swift
// ❌ DispatchQueue.global().async { ... DispatchQueue.main.async { ... } }
// ✅ Structured concurrency
func loadItems() {
    loadTask = Task { [weak self] in
        self?.items = try await self?.service.fetchItems() ?? []
    }
}
deinit { loadTask?.cancel() }
```

### Memory Management [MUST]

- Explicit capture lists in **every** escaping closure: `Task { [weak self] in }`.
- `unowned` requires inline comment guaranteeing lifetime. Use `weak` if unsure.
- Verify no retain cycles with Instruments > Leaks before merge.

### Error Handling [SHOULD]

- Errors as `enum` conforming to `LocalizedError` with `errorDescription`.
- `try!` forbidden in production. `try?` requires inline comment explaining silent failure.
- ViewModels expose errors as published state for the View to display.

```swift
enum UserError: LocalizedError {
    case decodingFailed
    var errorDescription: String? {
        switch self { case .decodingFailed: "Unable to load user profile." }
    }
}
```

### Testing [SHOULD]

- ViewModels testable without full app — inject all dependencies via init as protocols.
- Test async code with `@MainActor` test functions or `MainActor.run {}`.

```swift
@MainActor func testLoadItems() async {
    let vm = ItemListViewModel(service: MockItemService())
    await vm.loadItems()
    #expect(vm.items.count == 3)
}
```

### Common Pitfalls

1. ❌ Implicit `self` capture → ✅ `[weak self]` in every escaping closure.
2. ❌ `DispatchQueue` in async code → ✅ `Task {}`, actors, `MainActor`.
3. ❌ `try!` in production → ✅ `do/catch` with typed error enums.
4. ❌ ViewModel creates own deps → ✅ Inject via init for testability.
5. ❌ Stored `Task` never cancelled → ✅ Cancel in `deinit`/`.onDisappear`.
6. ❌ Logic in View body → ✅ ViewModel computed properties or methods.

</swift_standards>
