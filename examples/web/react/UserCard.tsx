import { useTranslation } from 'react-i18next';
import styles from './UserCard.module.css';

export type User = {
  id: string;
  name: string;
  role: string;
  avatarUrl: string;
  isActive: boolean;
};

type UserCardProps = {
  user: User;
};

/**
 * Presentational card. All visual values come from theme tokens via CSS
 * variables (see UserCard.module.css) — no hardcoded colors or spacing here.
 * All user-visible text goes through i18n keys.
 */
export function UserCard({ user }: UserCardProps) {
  const { t } = useTranslation('dashboard');

  return (
    <article className={styles.card} aria-labelledby={`user-${user.id}-name`}>
      <img
        className={styles.avatar}
        src={user.avatarUrl}
        alt=""
        width={48}
        height={48}
      />
      <div className={styles.body}>
        <h3 id={`user-${user.id}-name`} className={styles.name}>
          {user.name}
        </h3>
        <p className={styles.role}>{t('user.role', { role: user.role })}</p>
      </div>
      {/* Status conveyed by text + color, never color alone (WCAG 1.4.1) */}
      <p className={user.isActive ? styles.active : styles.inactive}>
        {user.isActive ? t('user.status.active') : t('user.status.inactive')}
      </p>
    </article>
  );
}
