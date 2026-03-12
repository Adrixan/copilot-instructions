---
applyTo: 
  - "**/*.java"
---
<java_standards>

## Java (Spring Boot / Jakarta EE)

- **Java 21 LTS** with **Spring Boot 3.3+**
- **Virtual threads** (`@Async` with virtual thread executor, or
  `Executors.newVirtualThreadPerTaskExecutor()`) for I/O-bound workloads
- **Pattern matching** for `instanceof`, `switch` expressions, and record patterns
- **Sequenced collections** (`SequencedCollection`, `SequencedMap`) for ordered access
- **Records** for DTOs, value objects, and sealed type hierarchies
- **Constructor injection** (immutability, testability) — no field `@Autowired` injection. `@Autowired` on fields is forbidden: hides dependencies, prevents immutability, breaks testability.
- **Testing:** JUnit 5 + Mockito + AssertJ
- **Build:** Maven or Gradle with version catalogs
- **SAST:** SpotBugs, PMD, or Semgrep in CI
- **GraalVM native image** for serverless/CLI tools where startup time matters

**Layered Architecture:** Controllers (HTTP only, no business logic) → Services (business logic, orchestration) → Repositories (data access only) → Entities (JPA). Controllers never call repositories. DTOs at controller boundary — JPA entities never serialized to API responses directly.

**Exception Handling:** `@RestControllerAdvice` handles all exceptions globally. Controllers do not try/catch business exceptions. Checked exceptions from libraries caught at infrastructure layer, rethrown as unchecked domain exceptions.

**Transactions:** `@Transactional` at service layer. Read-only operations use `@Transactional(readOnly = true)` — not optional, enables query optimizations. `@Transactional` on private methods has no effect (Spring proxy-based AOP) — restructure if needed.

**API Versioning:** All APIs versioned from day one with URL segments (`/api/v1/`). Breaking changes introduce a new version. Old versions remain until formally deprecated.

**Testing:** Unit tests do not load Spring context — test classes directly with Mockito mocks. Integration tests use `@SpringBootTest` with `@Testcontainers` for real infrastructure. No H2 in-memory database — it masks SQL compatibility issues. Test names describe behavior: `shouldReturnNotFoundWhenUserDoesNotExist()`.

See [examples/backend/java/](../examples/backend/java/) for UserService and UserServiceTest patterns.
</java_standards>
