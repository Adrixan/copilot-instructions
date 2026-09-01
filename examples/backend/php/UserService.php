<?php

declare(strict_types=1);

namespace App\User;

use InvalidArgumentException;

/**
 * Pattern points:
 * - strict_types on every file
 * - readonly promoted constructor properties, constructor injection
 * - DTO record-style class at the boundary
 * - #[\Override] on interface implementations
 */
final class UserDTO
{
    public function __construct(
        public readonly int $id,
        public readonly string $username,
        public readonly string $email,
    ) {}
}

interface UserRepository
{
    public function findById(int $id): ?UserDTO;

    public function findByUsername(string $username): ?UserDTO;

    public function insert(string $username, string $email): UserDTO;
}

final class UserNotFoundException extends \RuntimeException
{
    public function __construct(int $id)
    {
        parent::__construct(sprintf('user %d not found', $id));
    }
}

final class UserService
{
    public function __construct(
        private readonly UserRepository $repository,
    ) {}

    public function getUser(int $id): UserDTO
    {
        return $this->repository->findById($id)
            ?? throw new UserNotFoundException($id);
    }

    public function register(string $username, string $email): UserDTO
    {
        if ($username === '' || strlen($username) > 64) {
            throw new InvalidArgumentException('username must be 1-64 characters');
        }
        if (!str_contains($email, '@')) {
            throw new InvalidArgumentException('invalid email address');
        }
        if ($this->repository->findByUsername($username) !== null) {
            throw new InvalidArgumentException("username '$username' already taken");
        }

        return $this->repository->insert($username, $email);
    }
}
