package com.example.user;

import java.util.Optional;

/**
 * Pattern points:
 * - Java records for DTOs; entities never leave the service boundary
 * - Constructor injection (no field @Autowired)
 * - Constructor takes the interface — Mockito swaps it in tests
 */
public class UserService {

    public record UserDTO(long id, String username, String email) {}

    public static class UserNotFoundException extends RuntimeException {
        public UserNotFoundException(long id) {
            super("user %d not found".formatted(id));
        }
    }

    public interface UserRepository {
        Optional<UserDTO> findById(long id);
        Optional<UserDTO> findByUsername(String username);
        UserDTO insert(String username, String email);
    }

    private final UserRepository repository;

    public UserService(UserRepository repository) {
        this.repository = repository;
    }

    public UserDTO getUser(long id) {
        return repository.findById(id)
                .orElseThrow(() -> new UserNotFoundException(id));
    }

    public UserDTO register(String username, String email) {
        if (username == null || username.isBlank() || username.length() > 64) {
            throw new IllegalArgumentException("username must be 1-64 characters");
        }
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("invalid email address");
        }
        repository.findByUsername(username).ifPresent(existing -> {
            throw new IllegalArgumentException("username '%s' already taken".formatted(username));
        });
        return repository.insert(username, email);
    }
}
