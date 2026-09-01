import { render, screen } from '@testing-library/react';
import { axe } from 'jest-axe';
import { describe, expect, it, vi } from 'vitest';
import { UserCard, type User } from './UserCard';

// i18n stubbed: tests assert on key rendering behavior, not copy.
vi.mock('react-i18next', () => ({
  useTranslation: () => ({
    t: (key: string, opts?: Record<string, string>) =>
      key === 'user.role' ? `Role: ${opts?.role}` : key,
  }),
}));

const user: User = {
  id: 'u1',
  name: 'Ada Lovelace',
  role: 'Engineer',
  avatarUrl: 'https://example.com/ada.png',
  isActive: true,
};

describe('UserCard', () => {
  it('renders name, role, and active status text', () => {
    render(<UserCard user={user} />);
    expect(screen.getByRole('heading', { name: 'Ada Lovelace' })).toBeInTheDocument();
    expect(screen.getByText('Role: Engineer')).toBeInTheDocument();
    expect(screen.getByText('user.status.active')).toBeInTheDocument();
  });

  it('renders inactive status as text, not color alone', () => {
    render(<UserCard user={{ ...user, isActive: false }} />);
    expect(screen.getByText('user.status.inactive')).toBeInTheDocument();
  });

  it('has no axe violations', async () => {
    const { container } = render(<UserCard user={user} />);
    expect(await axe(container)).toHaveNoViolations();
  });
});
