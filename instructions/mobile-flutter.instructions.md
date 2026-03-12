---
applyTo:
  - "**/*.dart"
  - "**/pubspec.yaml"
  - "**/pubspec.lock"
---
<!-- markdownlint-disable MD013 MD022 MD031 MD032 -->
<flutter_standards>

## Flutter / Dart

- **Dart 3.0+** with sound null safety; never use `!` operator without prior null check
- **Widget Granularity [MUST]:** `build()` methods must stay under 60 lines — extract private widgets (`_SectionHeader`) in the same file if used once, move to `shared/components/` if reused. **No business logic in `build()`** — delegate to state management or helper methods
- **Naming:** files `snake_case.dart`, classes `PascalCase`, constants `lowerCamelCase`, private members prefixed `_`
- **Imports:** prefer relative imports within the same package; sort: dart core → package → relative

### State Management [MUST]

- **One solution per project** — Riverpod (preferred) or Bloc (acceptable). **Never mix.** Choice recorded in `DECISIONS.md` at project start
- `setState` **only** for purely local UI state: animations, focus, transient visual toggles
- Riverpod: use `@riverpod` code generation; providers in `lib/providers/`, one provider per file
- Bloc: events are sealed classes, states are freezed unions; one Bloc per feature in `lib/blocs/<feature>/`

### AppTheme [MUST]

- `ThemeData` defined **once** in `lib/theme/app_theme.dart`. No hardcoded `Color`, `TextStyle`, font size, or spacing anywhere else
- Theme directory structure: `app_colors.dart`, `app_text_styles.dart`, `app_spacing.dart`, `app_theme.dart`
- Dark theme configured at project start — use `ColorScheme.fromSeed()` or explicit `ColorScheme`
- Access via `Theme.of(context)` or `context.theme` extension — never `const Color(0xFF...)`

```dart
// ❌ NEVER
Container(color: Color(0xFF2196F3), padding: EdgeInsets.all(16))

// ✅ ALWAYS
Container(
  color: Theme.of(context).colorScheme.primary,
  padding: EdgeInsets.all(AppSpacing.md),
)
```

### Platform-Specific Code [MUST]

- `Platform.isIOS` / `Platform.isAndroid` **never scattered** through UI or business logic
- Isolate in `lib/core/platform/` with abstract interfaces + platform implementations
- Use conditional imports or `defaultTargetPlatform` for web-safe checks

### Navigation

- Use `go_router` (declarative). Route definitions in `lib/router/`. Type-safe routes with code generation
- Deep links tested on both platforms

### Testing [SHOULD]

- **Widget tests:** use `WidgetTester`, assert on what the user sees (`find.text`, `find.byType`), not implementation details
- **Riverpod tests:** `ProviderContainer` with `.overrides([])` for dependency injection
- **Bloc tests:** `bloc_test` package — `blocTest<Bloc, State>()` pattern
- **Golden tests** for critical UI screens (run `flutter test --update-goldens` to regenerate)
- **Integration tests** in `integration_test/` for core user flows

### Project Structure

```
lib/
  core/         # platform/, network/, di/
  features/     # feature-first folders (auth/, home/, settings/)
  shared/       # components/, utils/, extensions/
  theme/        # app_theme.dart, app_colors.dart, etc.
  router/       # route definitions
  providers/    # (Riverpod) or blocs/ (Bloc)
```

### Common Pitfalls

| Pitfall | Fix |
|---|---|
| Business logic in `build()` | Move to provider/bloc/controller |
| Mixed state management (Riverpod + Bloc) | Pick one, enforce via lint rule |
| Hardcoded colors/spacing | Use `AppColors`, `AppSpacing` from theme |
| `Platform.isIOS` in widget code | Abstract behind `core/platform/` interface |
| Deep widget nesting (>4 levels) | Extract sub-widgets |
| Missing `const` constructors | Add `const` wherever possible — enforced by `prefer_const_constructors` lint |

**Linting:** Use `flutter_lints` or `very_good_analysis`. Enable `prefer_const_constructors`, `avoid_print`, `always_use_package_imports` (for cross-package refs).

</flutter_standards>
