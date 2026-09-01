package com.example.user;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

/**
 * Integration test pattern: real PostgreSQL via Testcontainers.
 * No H2 — in-memory databases mask SQL compatibility issues.
 */
@SpringBootTest
@Testcontainers
class UserServiceIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres =
            new PostgreSQLContainer<>("postgres:16-alpine");

    @DynamicPropertySource
    static void registerProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private UserService service;

    @Test
    void shouldPersistAndRetrieveUser() {
        UserService.UserDTO created = service.register("ada", "ada@example.com");

        UserService.UserDTO fetched = service.getUser(created.id());

        assertThat(fetched.username()).isEqualTo("ada");
    }

    @Test
    void shouldEnforceUniqueUsernameAtDatabaseLevel() {
        service.register("grace", "grace@example.com");

        // Real constraint behavior — an in-memory fake could never show this.
        org.assertj.core.api.Assertions.assertThatThrownBy(
                        () -> service.register("grace", "other@example.com"))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
