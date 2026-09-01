package com.example.user;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;

import com.example.user.UserService.UserDTO;
import com.example.user.UserService.UserNotFoundException;
import com.example.user.UserService.UserRepository;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * Unit test — no Spring context loaded. Behavior-describing names.
 */
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository repository;

    private UserService service;

    @BeforeEach
    void setUp() {
        service = new UserService(repository);
    }

    @Test
    void shouldReturnUserWhenUserExists() {
        when(repository.findById(1L)).thenReturn(Optional.of(new UserDTO(1L, "ada", "ada@example.com")));

        UserDTO user = service.getUser(1L);

        assertThat(user.username()).isEqualTo("ada");
    }

    @Test
    void shouldThrowNotFoundWhenUserDoesNotExist() {
        when(repository.findById(999L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.getUser(999L))
                .isInstanceOf(UserNotFoundException.class)
                .hasMessageContaining("999");
    }

    @Test
    void shouldRejectDuplicateUsername() {
        when(repository.findByUsername("ada")).thenReturn(Optional.of(new UserDTO(1L, "ada", "ada@example.com")));

        assertThatThrownBy(() -> service.register("ada", "other@example.com"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("already taken");
    }

    @Test
    void shouldRejectInvalidEmail() {
        assertThatThrownBy(() -> service.register("ada", "not-an-email"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("invalid email");
    }

    @Test
    void shouldInsertWhenUsernameIsAvailable() {
        when(repository.findByUsername(anyString())).thenReturn(Optional.empty());
        when(repository.insert("ada", "ada@example.com")).thenReturn(new UserDTO(1L, "ada", "ada@example.com"));

        UserDTO created = service.register("ada", "ada@example.com");

        assertThat(created.id()).isEqualTo(1L);
    }
}
