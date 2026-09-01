---
applyTo: 
  - "**/*.cs"
  - "**/*.csproj"
  - "**/*.sln"
  - "**/*.razor"
---
<!-- markdownlint-disable -->
<dotnet_standards>

## .NET / C# (ASP.NET Core)

- **.NET LTS** (current LTS recommended, e.g. .NET 10; minimum .NET 8) with **C# 12+**
- **Primary constructors** for DI in services and controllers
- **Required members** and `init` properties for immutable DTOs
- **Records** for value objects, DTOs, and events
- **Pattern matching** (`switch` expressions, `is`, `and`/`or` patterns) over if-else chains
- **Nullable reference types** enabled project-wide (`<Nullable>enable</Nullable>`)
- **Global usings** and file-scoped namespaces
- **Testing:** xUnit + NSubstitute/Moq + FluentAssertions
- **Static Analysis:** Roslyn analyzers, SonarAnalyzer, `dotnet format` in CI
- **SAST:** Semgrep or CodeQL in CI

**Dependency Injection [MUST]:**

- Constructor injection only — field injection forbidden
- Service lifetimes: Scoped for request-bound (DbContext), Singleton for stateless, Transient for lightweight
- **Captive dependency = runtime bug:** never inject Scoped into Singleton
- Interfaces for all services crossing layer boundaries
- Use `IOptions<T>` / `IOptionsSnapshot<T>` for configuration — never read `IConfiguration` directly in services

**Layered Architecture [MUST]:**

- API/Presentation → Application (Services) → Domain (Entities, Interfaces) → Infrastructure (Repos, DB)
- `DbContext` never used directly in controllers — always behind a repository or service
- Repository interfaces defined in Domain, implementations in Infrastructure
- DTOs at API boundaries, domain entities internally — never expose EF entities in API responses
- MediatR or thin service layer for command/query separation

**Exception Handling [MUST]:**

- Global exception middleware (`IExceptionHandler` in .NET 8+) — no try/catch in controllers
- Business rule violations are domain results (`Result<T>`), not exceptions
- `catch (Exception)` without rethrowing requires a justifying comment
- Use `ProblemDetails` (RFC 9457) for all error responses
- Never expose stack traces or internal details in production responses

**Async [MUST]:**

- No `.Result` or `.Wait()` on Tasks in ASP.NET — causes deadlocks
- `CancellationToken` passed through entire call chain for all I/O operations
- Suffix async methods with `Async` — `GetUserAsync`, not `GetUser`
- Use `ValueTask<T>` only when profiling shows benefit (hot paths with frequent sync completion)
- `ConfigureAwait(false)` in library code, not in ASP.NET application code

**API Versioning [SHOULD]:**

- Version from day one — URL segment versioning default (`/api/v1/`)
- Breaking changes increment major version
- Use `Asp.Versioning.Http` package
- Document all versions in OpenAPI/Swagger

**Testing [SHOULD]:**

- Unit tests don't load ASP.NET host — test services and domain logic in isolation
- Integration tests use `WebApplicationFactory<T>` with Testcontainers (real DB, not SQLite/InMemory)
- Test names describe behavior: `Should_ReturnNotFound_When_UserDoesNotExist()`
- Use `[Theory]` + `[InlineData]` for parameterized tests
- Arrange/Act/Assert with blank line separators

**Pitfalls:**

1. ❌ Captive dependency (Scoped in Singleton) → ✅ Validate lifetimes; enable `ValidateScopes` in development.
2. ❌ Field injection (`[FromServices]` on fields) → ✅ Constructor injection only.
3. ❌ `.Result` / `.Wait()` → ✅ `await` all the way up. Async is viral — embrace it.
4. ❌ SQLite/InMemory for integration tests → ✅ Testcontainers with real database engine.
5. ❌ Exposing EF entities in API responses → ✅ Map to DTOs at the boundary.
6. ❌ Missing `CancellationToken` → ✅ Pass through entire call chain for all I/O.
7. ❌ `catch (Exception) { /* swallow */ }` → ✅ Rethrow or justify with comment.
</dotnet_standards>
