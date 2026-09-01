<?php

declare(strict_types=1);

namespace App\User;

use InvalidArgumentException;
use PHPUnit\Framework\TestCase;

/**
 * Unit test with an in-memory fake — no framework bootstrap, no database.
 */
final class InMemoryUserRepository implements UserRepository
{
    /** @var array<int, UserDTO> */
    private array $users = [];
    private int $nextId = 1;

    public function findById(int $id): ?UserDTO
    {
        return $this->users[$id] ?? null;
    }

    public function findByUsername(string $username): ?UserDTO
    {
        foreach ($this->users as $user) {
            if ($user->username === $username) {
                return $user;
            }
        }

        return null;
    }

    public function insert(string $username, string $email): UserDTO
    {
        $user = new UserDTO($this->nextId, $username, $email);
        $this->users[$user->id] = $user;
        $this->nextId++;

        return $user;
    }
}

final class UserServiceTest extends TestCase
{
    private UserService $service;

    #[\Override]
    protected function setUp(): void
    {
        $this->service = new UserService(new InMemoryUserRepository());
    }

    public function testRegisterCreatesUser(): void
    {
        $user = $this->service->register('ada', 'ada@example.com');

        $this->assertSame('ada', $user->username);
        $this->assertSame(1, $user->id);
    }

    public function testRegisterRejectsDuplicateUsername(): void
    {
        $this->service->register('ada', 'ada@example.com');

        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('already taken');
        $this->service->register('ada', 'other@example.com');
    }

    public function testRegisterRejectsInvalidEmail(): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->service->register('ada', 'not-an-email');
    }

    public function testGetUserThrowsWhenMissing(): void
    {
        $this->expectException(UserNotFoundException::class);
        $this->service->getUser(999);
    }
}
