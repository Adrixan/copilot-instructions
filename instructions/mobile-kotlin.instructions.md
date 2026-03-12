---
applyTo: 
  - "**/*.kt"
  - "**/*.kts"
  - "**/build.gradle.kts"
  - "**/build.gradle"
---
<!-- markdownlint-disable -->
<kotlin_android_standards>

## Kotlin / Android / Jetpack Compose

### Coroutine Scopes [MUST]

- **ViewModel** → `viewModelScope`; **Activity/Fragment** → `lifecycleScope`
- **Repository / Service** → `suspend fun` (inherits scope from caller)
- **App-level long-lived work** → injected `CoroutineScope` (e.g., via Hilt `@Singleton`)
- **`GlobalScope` is forbidden** — it leaks coroutines and ignores structured concurrency
- Use `withContext(Dispatchers.IO)` for blocking calls inside suspend functions

### UI State as Sealed Class [MUST]

- ViewModel exposes **one** `StateFlow<ScreenState>` per screen using a sealed class/interface:
  ```kotlin
  sealed interface FeedState {
      data object Loading : FeedState
      data class Success(val items: List<Item>) : FeedState
      data class Error(val message: String) : FeedState
  }
  ```
- **Never** split into separate `isLoading`, `error`, `data` StateFlow fields — this causes inconsistent UI states
- All state-mutation logic lives in ViewModel; Composables only read and render

### Compose Theme [MUST]

- Define **all** colors, typography, and shapes in `ui/theme/` (Theme.kt, Color.kt, Type.kt, Shape.kt)
- Reference via `MaterialTheme.colorScheme`, `MaterialTheme.typography`, `MaterialTheme.shapes`
- **Never hardcode** colors (`Color(0xFF...)`) or text styles in composables
- Support dark/light themes from project start; use `isSystemInDarkTheme()` in theme setup
- Extract reusable composables into `ui/components/`

### Repository Pattern [MUST]

- ViewModel **never** accesses Room DAOs, Retrofit services, or DataStore directly
- Repository **interface** lives in `domain/`; **implementation** lives in `infrastructure/` (or `data/`)
- Domain models are plain Kotlin data classes — **no** `@SerializedName`, `@ColumnInfo`, or any serialization annotations
- Mapping between domain and data-layer models happens inside the repository implementation
- Inject repositories into ViewModels via constructor (Hilt `@Inject`)

### Dependency Injection [MUST]

- Use **Hilt** (`@HiltViewModel`, `@Inject constructor`, `@Module`, `@Provides`)
- One Hilt module per layer: `NetworkModule`, `DatabaseModule`, `RepositoryModule`
- Avoid service locator patterns or manual singleton objects

### Testing [SHOULD]

- **ViewModel tests:** `kotlinx-coroutines-test` (`runTest`, `StandardTestDispatcher`, `Turbine` for Flow assertions)
- **Repository tests:** real in-memory Room database (`Room.inMemoryDatabaseBuilder`), **not** mocked DAOs
- **Compose UI tests:** `createComposeRule()` + `onNodeWithText` / `onNodeWithTag` — **not** Espresso for Compose screens
- **Naming:** `fun methodName_condition_expectedResult()` or backtick-quoted names
- Fake repositories for ViewModel tests; real Room DB for repository tests

### Common Pitfalls — Avoid These

| Pitfall | Fix |
|---|---|
| `GlobalScope.launch { … }` | Use `viewModelScope` / `lifecycleScope` / injected scope |
| Multiple StateFlows per screen (`_loading`, `_error`, `_data`) | Single sealed-class StateFlow |
| `Color(0xFFFF0000)` inside a composable | `MaterialTheme.colorScheme.error` |
| Mocking Room DAOs in tests | Use `Room.inMemoryDatabaseBuilder` |
| ViewModel calling `dao.getAll()` directly | Inject repository interface |
| `remember { mutableStateOf(...) }` for screen-level state | Hoist to ViewModel as StateFlow |

</kotlin_android_standards>
