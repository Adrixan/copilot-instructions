---
applyTo: 
  - "**/*.php"
  - "**/*.py"
  - "**/*.java"
  - "**/*.sql"
---
<agent_profile>
Role: Backend System Engineer
Skills: Java, PHP, Python, SQL
Focus: TDD, Security, Modularity
Examples: See examples/backend/ for language-specific patterns
</agent_profile>

<quick_reference>
**Critical Rules (TL;DR):**
- **TDD Always:** Write test first (Red → Green → Refactor)
- **Type Safety:** Strict types in PHP, type hints in Python, strong typing in Java
- **No SQL Injection:** Prepared statements ONLY, never string concatenation
- **Migrations:** Schema changes ONLY via migration files
- **Dependency Injection:** Constructor injection preferred (testability)
- **Code Size:** Functions <50 lines, classes <300 lines
- **Security:** Input validation, output encoding, least privilege
- **Testing:** Minimum 80% coverage for business logic
</quick_reference>

<language_standards>

## Java (Spring Boot / Jakarta EE)

**Framework Standards:**
- **Spring Boot 3.x** with Java 17+ (LTS)
- **Dependency Injection:** Constructor injection (immutability, testability)
- **Records:** Use for DTOs and value objects (Java 17+)
- **Testing:** JUnit 5 + Mockito + AssertJ
- **Build Tool:** Maven or Gradle with version catalogs

**Code Structure:**
```java
// ✅ Good: Record for DTO
public record UserDTO(
    @NotNull Long id,
    @NotBlank String username,
    @Email String email
) {}

// ✅ Good: Constructor injection
@Service
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    
    public UserService(UserRepository userRepository, 
                      PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }
    
    public UserDTO createUser(CreateUserRequest request) {
        // Business logic
    }
}
```

**Testing:**
```java
@SpringBootTest
class UserServiceTest {
    @Autowired
    private UserService userService;
    
    @MockBean
    private UserRepository userRepository;
    
    @Test
    @DisplayName("Should create user with encrypted password")
    void shouldCreateUserWithEncryptedPassword() {
        // Arrange
        var request = new CreateUserRequest("john", "password123");
        
        // Act
        var result = userService.createUser(request);
        
        // Assert
        assertThat(result.username()).isEqualTo("john");
        verify(userRepository).save(any(User.class));
    }
}
```

---

## PHP (Laravel / Symfony)

**Framework Standards:**
- **PHP 8.2+** with strict types
- **Laravel 10.x** or **Symfony 6.x**
- **Strict Types:** `declare(strict_types=1);` at top of EVERY file
- **Testing:** PHPUnit 10 or Pest
- **Static Analysis:** PHPStan (level 8+) or Psalm

**Code Structure:**
```php
<?php

declare(strict_types=1);

namespace App\Services;

use App\Repositories\UserRepositoryInterface;
use App\DTO\UserDTO;

final class UserService
{
    public function __construct(
        private readonly UserRepositoryInterface $userRepository,
        private readonly PasswordHasher $passwordHasher
    ) {}
    
    public function createUser(CreateUserRequest $request): UserDTO
    {
        $user = new User(
            username: $request->username,
            password: $this->passwordHasher->hash($request->password)
        );
        
        $this->userRepository->save($user);
        
        return UserDTO::fromEntity($user);
    }
}
```

**Testing (Pest):**
```php
<?php

use App\Services\UserService;
use App\Repositories\UserRepositoryInterface;

it('creates user with hashed password', function () {
    // Arrange
    $repository = Mockery::mock(UserRepositoryInterface::class);
    $repository->shouldReceive('save')->once();
    
    $service = new UserService($repository, new PasswordHasher());
    
    // Act
    $result = $service->createUser(new CreateUserRequest('john', 'pass123'));
    
    // Assert
    expect($result->username)->toBe('john');
});
```

**Full Example:** See [examples/backend/php/UserService.php](../examples/backend/php/UserService.php) and [UserServiceTest.php](../examples/backend/php/UserServiceTest.php) for complete PHP 8+ implementation with modern features (readonly properties, constructor promotion, match expressions) and PHPUnit 10+ tests

---

## Python (FastAPI / Django / Flask)

**Framework Standards:**
- **Python 3.11+**
- **Type Hints:** Mandatory for all functions/methods
- **FastAPI** (recommended for APIs), **Django 4.x** (full-stack)
- **Testing:** Pytest with pytest-cov
- **Linting:** Ruff or Black + isort + mypy

**Code Structure:**
```python
from typing import Protocol
from dataclasses import dataclass

class UserRepository(Protocol):
    def save(self, user: User) -> User: ...
    def find_by_id(self, user_id: int) -> User | None: ...

@dataclass(frozen=True)
class UserDTO:
    id: int
    username: str
    email: str

class UserService:
    def __init__(
        self,
        user_repository: UserRepository,
        password_hasher: PasswordHasher
    ) -> None:
        self._user_repository = user_repository
        self._password_hasher = password_hasher
    
    def create_user(self, request: CreateUserRequest) -> UserDTO:
        hashed_password = self._password_hasher.hash(request.password)
        user = User(
            username=request.username,
            password=hashed_password
        )
        saved_user = self._user_repository.save(user)
        return UserDTO.from_entity(saved_user)
```

**Testing (Pytest):**
```python
from unittest.mock import Mock
import pytest

def test_create_user_hashes_password():
    # Arrange
    repository = Mock(spec=UserRepository)
    hasher = Mock(spec=PasswordHasher)
    hasher.hash.return_value = "hashed_password"
    
    service = UserService(repository, hasher)
    request = CreateUserRequest(username="john", password="pass123")
    
    # Act
    result = service.create_user(request)
    
    # Assert
    assert result.username == "john"
    hasher.hash.assert_called_once_with("pass123")
    repository.save.assert_called_once()
```

---

## SQL Standards

**General Principles:**
- **Prefer ANSI SQL** for portability
- **Migrations ONLY:** Schema changes via migration files (Flyway, Liquibase, Alembic)
- **Indexes:** Automatically create indexes on Foreign Keys
- **Naming:** `snake_case` for all identifiers

**Security:**
```python
# ❌ NEVER DO THIS (SQL Injection vulnerability)
query = f"SELECT * FROM users WHERE username = '{username}'"

# ✅ ALWAYS USE THIS (Prepared statements)
query = "SELECT * FROM users WHERE username = %s"
cursor.execute(query, (username,))
```

**Migration Example (Alembic/Python):**
```python
"""Add users table

Revision ID: 001
Create Date: 2026-02-05
"""

def upgrade():
    op.create_table(
        'users',
        sa.Column('id', sa.BigInteger(), primary_key=True),
        sa.Column('username', sa.String(50), nullable=False, unique=True),
        sa.Column('email', sa.String(255), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('idx_users_email', 'users', ['email'])

def downgrade():
    op.drop_table('users')
```

**Comprehensive Migration Examples:**
- [examples/production/alembic_setup.py](../examples/production/alembic_setup.py) - Alembic environment configuration with offline/online modes
- [examples/production/001_create_users_table.py](../examples/production/001_create_users_table.py) - Initial schema with indexes, constraints, triggers
- [examples/production/002_add_user_preferences.py](../examples/production/002_add_user_preferences.py) - Foreign keys and data migration

**Query Optimization:**
- **N+1 Problem:** Use joins or batch loading (eager loading in ORMs)
- **Indexes:** On columns used in WHERE, JOIN, ORDER BY
- **EXPLAIN:** Always check query plans for slow queries
- **Pagination:** Use `LIMIT`/`OFFSET` or cursor-based pagination

</language_standards>

<testing_protocol>
**TDD Workflow (MANDATORY):**

1. **Phase 1: Red (Write Failing Test)**
   ```python
   def test_user_service_creates_user():
       # This test will fail because create_user doesn't exist yet
       service = UserService(repository, hasher)
       result = service.create_user(request)
       assert result.username == "john"
   ```

2. **Phase 2: Green (Make It Pass)**
   ```python
   # Write simplest code to pass
   def create_user(self, request):
       return UserDTO(username=request.username)
   ```

3. **Phase 3: Refactor (Clean Up)**
   ```python
   # Add proper implementation, extract methods, improve names
   def create_user(self, request: CreateUserRequest) -> UserDTO:
       validated_request = self._validate(request)
       hashed_password = self._password_hasher.hash(validated_request.password)
       user = self._build_user(validated_request, hashed_password)
       return self._save_and_return(user)
   ```

**Coverage Requirements:**
- **Business Logic:** Minimum 80% coverage
- **Controllers/Routes:** Basic integration tests
- **Repositories:** Test with real database (testcontainers)
- **Critical Paths:** 100% coverage (authentication, payments, etc.)

**Test Organization:**
```
tests/
├── unit/           # Fast, isolated tests
│   ├── services/
│   └── utils/
├── integration/    # Tests with database/external services
│   └── repositories/
└── e2e/           # End-to-end API tests
    └── api/
```

**Integration Testing Examples:**
- **Python:** [examples/integration-tests/test_user_service_integration.py](../examples/integration-tests/test_user_service_integration.py) - Testcontainers with PostgreSQL, session-level container, transaction rollback between tests
- **Java:** [examples/integration-tests/UserServiceIntegrationTest.java](../examples/integration-tests/UserServiceIntegrationTest.java) - Spring Boot + Testcontainers, nested test classes, MockMvc for API testing

</testing_protocol>

<security_standards>
**MANDATORY Security Practices:**

1. **Input Validation:**
   ```python
   from pydantic import BaseModel, validator, EmailStr
   
   class CreateUserRequest(BaseModel):
       username: str
       email: EmailStr
       password: str
       
       @validator('username')
       def username_alphanumeric(cls, v):
           if not v.isalnum():
               raise ValueError('Username must be alphanumeric')
           if len(v) < 3 or len(v) > 30:
               raise ValueError('Username must be 3-30 characters')
           return v
       
       @validator('password')
       def password_strength(cls, v):
           if len(v) < 12:
               raise ValueError('Password must be at least 12 characters')
           return v
   ```

2. **Authentication & Authorization:**
   - **JWT Example:** See [examples/production/jwt_auth_fastapi.py](../examples/production/jwt_auth_fastapi.py) for FastAPI implementation with refresh tokens, rate limiting, and security headers
   - **Passwords:** Hash with bcrypt/Argon2 (NEVER plain text or MD5)
   - **Tokens:** Use JWT with short expiration (15 min access, 7 days refresh)
   - **RBAC:** Role-Based Access Control (least privilege)
   - **MFA:** Mandatory for admin accounts

3. **SQL Injection Prevention:**
   ```java
   // ❌ NEVER
   String query = "SELECT * FROM users WHERE id = " + userId;
   
   // ✅ ALWAYS
   String query = "SELECT * FROM users WHERE id = ?";
   PreparedStatement stmt = conn.prepareStatement(query);
   stmt.setLong(1, userId);
   ```

4. **Secrets Management:**
   - **Environment Variables:** For dev/test
   - **Vault/Secrets Manager:** For production
   - **Never Commit:** `.env` files, API keys, credentials

5. **API Security:**
   - **Rate Limiting:** Prevent brute force (e.g., 100 req/min per IP)
   - **CORS:** Whitelist specific origins
   - **HTTPS Only:** Redirect HTTP → HTTPS
   - **Security Headers:** CSP, X-Frame-Options, HSTS

</security_standards>

<performance_guidelines>
**Optimization Strategies:**

1. **Database Optimization:**
   - **Connection Pooling:** Reuse connections (HikariCP for Java, SQLAlchemy pool for Python)
   - **Query Optimization:** Use EXPLAIN, add indexes
   - **Caching:** Redis/Memcached for hot data
   - **Read Replicas:** Separate read/write traffic

2. **API Performance:**
   - **Pagination:** Never return unbounded results
   - **Async I/O:** Use async/await for I/O-bound operations
   - **Lazy Loading:** Load related entities on demand
   - **Compression:** gzip responses > 1KB

3. **Caching Strategy:**
   ```python
   from functools import lru_cache
   
   @lru_cache(maxsize=1000)
   - **Prometheus Setup:** See [examples/production/prometheus.yml](../examples/production/prometheus.yml) for complete monitoring configuration with alert rules, recording rules, and service discovery
   def get_user_permissions(user_id: int) -> list[str]:
       # Expensive database lookup cached in memory
       return repository.get_permissions(user_id)
   ```

4. **Monitoring:**
   - **APM:** Application Performance Monitoring (New Relic, Datadog)
   - **Logging:** Structured JSON logs
   - **Metrics:** Request latency, error rate, throughput
   - **Alerts:** P99 latency > 500ms, error rate > 1%

</performance_guidelines>

<common_pitfalls>
**Frequent Mistakes & Solutions:**

1. **N+1 Query Problem:**
   ```python
   # ❌ Bad: 1 query for users + N queries for posts
   users = User.query.all()
   for user in users:
       posts = user.posts  # Triggers separate query!
   
   # ✅ Good: 2 queries total (eager loading)
   users = User.query.options(joinedload(User.posts)).all()
   ```

2. **Missing Input Validation:**
   ```java
   // ❌ Bad: No validation
   public void updateEmail(Long userId, String email) {
       user.setEmail(email);  // What if email is "not-an-email"?
   }
   
   // ✅ Good: Validate first
   public void updateEmail(Long userId, @Email String email) {
       if (!emailValidator.isValid(email)) {
           throw new InvalidEmailException(email);
       }
       user.setEmail(email);
   }
   ```

3. **Leaking Implementation Details:**
   ```python
   # ❌ Bad: Exposing database entity
   @app.get("/users/{user_id}")
   def get_user(user_id: int) -> User:  # Database model!
       return user_repository.find_by_id(user_id)
   
   # ✅ Good: Return DTO
   @app.get("/users/{user_id}")
   def get_user(user_id: int) -> UserDTO:
       user = user_repository.find_by_id(user_id)
       return UserDTO.from_entity(user)
   ```

4. **Transaction Management:**
   ```php
   // ❌ Bad: No transaction (partial updates on failure)
   $user->name = 'New Name';
   $user->save();
   $user->profile->bio = 'New Bio';
   $user->profile->save();  // What if this fails?
   
   // ✅ Good: Atomic transaction
   DB::transaction(function () use ($user) {
       $user->name = 'New Name';
       $user->save();
       $user->profile->bio = 'New Bio';
       $user->profile->save();
   });
   ```

**Examples:** See examples/backend/pitfalls.md for detailed code examples.

</common_pitfalls>

<modularity_architecture>
**Code Organization:**

1. **Module Size Limits:**
   - **Functions:** Max 50 lines (prefer 20-30)
   - **Classes:** Max 300 lines
   - **Files:** Max 500 lines
   - **Action:** Extract into separate modules/services when exceeded

2. **Layered Architecture:**
   ```
   Controllers/Routes  -> Services -> Repositories -> Database
        ↓                   ↓            ↓
      DTOs              Domain       Entities
   ```

3. **Dependency Injection:**
   - **Constructor Injection:** Required dependencies
   - **Interface Segregation:** Depend on abstractions, not concrete classes
   - **Single Responsibility:** One reason to change

4. **Microservices Guidelines:**
   - **Threshold:** When service > 10,000 LOC or distinct bounded context
   - **Communication:** REST/gRPC (sync), Message Queue (async)
   - **Data:** Each service owns its database

</modularity_architecture>
