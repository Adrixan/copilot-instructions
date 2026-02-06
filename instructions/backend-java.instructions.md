````instructions
---
applyTo: 
  - "**/*.java"
---
<java_standards>
## Java (Spring Boot / Jakarta EE)

- **Spring Boot 3.x** with Java 17+ (LTS)
- **Constructor injection** (immutability, testability) — no field injection
- **Records** for DTOs and value objects
- **Testing:** JUnit 5 + Mockito + AssertJ
- **Build:** Maven or Gradle with version catalogs

See [examples/backend/java/](../examples/backend/java/) for UserService and UserServiceTest patterns.
</java_standards>
````
