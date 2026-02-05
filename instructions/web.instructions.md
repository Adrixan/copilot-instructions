---
applyTo: 
  - "**/*.html"
  - "**/*.css"
  - "**/*.js"
  - "**/*.ts"
  - "**/*.jsx"
  - "**/*.tsx"
---
<agent_profile>
Role: Senior Frontend Architect
Skills: React, Vue, TypeScript, HTML5, CSS3, Web Standards
Focus: Accessibility, Performance, i18n, Progressive Enhancement
Examples: See examples/web/ for framework-specific patterns
</agent_profile>

<quick_reference>
**Critical Rules (TL;DR):**
- **No Hardcoded Strings:** Use i18n keys for ALL user-visible text
- **Semantic HTML:** Use proper HTML5 elements (not div soup)
- **ARIA Labels:** Required for interactive elements and dynamic content
- **Mobile First:** Design for mobile, enhance for desktop
- **TypeScript:** Strict mode enabled (`strict: true`)
- **Component Size:** Max 250 lines; extract if larger
- **Accessibility:** WCAG 2.1 AA minimum (AAA for government/public)
- **Security:** CSP headers, input sanitization, XSS prevention
- **Testing:** Unit tests for logic, integration tests for user flows
</quick_reference>

<architecture_standards>

## Microservices Architecture

**Principle:** Decouple frontend from backend

```
┌─────────────────────────────────────┐
│       Frontend (SPA/SSR/SSG)        │
├─────────────────────────────────────┤
│              API Layer              │
├──────────┬──────────┬───────────────┤
│ Auth API │ User API │ Product API   │
└──────────┴──────────┴───────────────┘
```

**Micro-Frontends (for large apps):**
- Split by domain (e.g., Dashboard, Settings, Analytics)
- Use Module Federation (Webpack 5) or import maps
- Shared design system package

**Monorepo Structure:**
```
workspace/
├── apps/
│   ├── web/          # Main web app
│   ├── mobile/       # React Native
│   └── admin/        # Admin dashboard
├── packages/
│   ├── ui/           # Shared component library
│   ├── utils/        # Shared utilities
│   └── i18n/         # Translation files
└── infrastructure/   # IaC configs
```

</architecture_standards>

<technology_standards>

## TypeScript (Mandatory)

**Configuration (tsconfig.json):**
```json
{
  "compilerOptions": {
    "strict": true,
    "strictNullChecks": true,
    "noImplicitAny": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx"
  }
}
```

**Type Safety Examples:**
```typescript
// ✅ Good: Explicit types
interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'user' | 'guest';
}

function getUser(id: number): Promise<User | null> {
  return fetch(`/api/users/${id}`)
    .then(res => res.json())
    .catch(() => null);
}

// ❌ Bad: Any types
function getUser(id: any): Promise<any> {
  return fetch(`/api/users/${id}`).then(res => res.json());
}
```

---

## React/Next.js Standards

**Component Structure:**
```tsx
// ✅ Good: Functional component with TypeScript
interface UserCardProps {
  user: User;
  onEdit: (user: User) => void;
}

export function UserCard({ user, onEdit }: UserCardProps) {
  const { t } = useTranslation();
  
  return (
    <article className="user-card" aria-labelledby={`user-${user.id}-name`}>
      <h2 id={`user-${user.id}-name`}>{user.name}</h2>
      <p>{user.email}</p>
      <button 
        onClick={() => onEdit(user)}
        aria-label={t('user.edit', { name: user.name })}
      >
        {t('common.edit')}
      </button>
    </article>
  );
}
```

**React Best Practices:**
- **Hooks:** Use functional components (no class components)
- **State Management:** Context API for simple, Zustand/Redux for complex
- **Server Components:** Use React Server Components (Next.js App Router)
- **Suspense:** Wrap async components in `<Suspense>`
- **Custom Hooks:** See [examples/web/react/useAsync.ts](../examples/web/react/useAsync.ts) for async data management with race condition handling and [useAsync.test.ts](../examples/web/react/useAsync.test.ts) for hook testing patterns

---

## HTML5 (Semantic Markup)

**Semantic Elements:**
```html
<!-- ❌ Bad: Div soup -->
<div class="header">
  <div class="nav">
    <div class="nav-item">Home</div>
  </div>
</div>

<!-- ✅ Good: Semantic HTML5 -->
<header>
  <nav aria-label="Main navigation">
    <ul>
      <li><a href="/">Home</a></li>
    </ul>
  </nav>
</header>

<main>
  <article>
    <h1>Article Title</h1>
    <p>Content...</p>
  </article>
  
  <aside>
    <h2>Related Content</h2>
  </aside>
</main>

<footer>
  <p>&copy; 2026 Company</p>
</footer>
```

---

## CSS Standards

**Mobile-First Media Queries:**
```css
/* ✅ Good: Mobile first */
.container {
  padding: 1rem;  /* Mobile */
}

@media (min-width: 768px) {
  .container {
    padding: 2rem;  /* Tablet */
  }
}

@media (min-width: 1024px) {
  .container {
    padding: 3rem;  /* Desktop */
  }
}
```

**Modern CSS Features:**
- **CSS Grid/Flexbox:** Layout (avoid floats)
- **CSS Variables:** Theme values
- **Container Queries:** Component-based responsive design
- **CSS Modules/Tailwind:** Scoped styles

**Tailwind Example:**
```tsx
<div className="flex flex-col gap-4 p-4 md:flex-row md:p-8">
  <Card className="w-full md:w-1/2" />
</div>
```

**CSS Module Example:**
See [examples/web/react/UserCard.module.css](../examples/web/react/UserCard.module.css) for comprehensive CSS module patterns including:
- CSS custom properties for theming
- Dark mode with `prefers-color-scheme`
- Accessibility features (focus-visible, reduced-motion)
- Responsive design with container queries
- High contrast mode support

</technology_standards>

<internationalization>
**i18n Implementation (MANDATORY):**

**Never hardcode strings:**
```tsx
// ❌ Bad: Hardcoded strings
<button>Submit Form</button>
<p>Welcome, {user.name}!</p>

// ✅ Good: Translation keys
<button>{t('form.submit')}</button>
<p>{t('welcome.message', { name: user.name })}</p>
```

**Translation File Structure:**
```
locales/
├── en/
│   ├── common.json
│   ├── dashboard.json
│   └── errors.json
├── es/
│   ├── common.json
│   ├── dashboard.json
│   └── errors.json
└── de/
    └── ...
```

**en/common.json:**
```json
{
  "form": {
    "submit": "Submit",
    "cancel": "Cancel",
    "required": "This field is required"
  },
  "welcome": {
    "message": "Welcome, {{name}}!"
  }
}
```

**Library Recommendations:**
- **React:** react-i18next
- **Vue:** vue-i18n
- **Next.js:** next-i18next or built-in i18n routing

**Date/Time Formatting:**
```typescript
// ✅ Use Intl API for locale-aware formatting
const date = new Date();
const formatted = new Intl.DateTimeFormat(locale, {
  year: 'numeric',
  month: 'long',
  day: 'numeric'
}).format(date);

// Numbers
const price = new Intl.NumberFormat(locale, {
  style: 'currency',
  currency: 'USD'
}).format(99.99);
```

</internationalization>

<accessibility_standards>
**WCAG 2.1 AA Compliance (MANDATORY):**

1. **Keyboard Navigation:**
   ```tsx
   // ✅ All interactive elements keyboard accessible
   <button onClick={handleClick} onKeyDown={handleKeyDown}>
     {t('common.submit')}
   </button>
   
   // Custom components
   <div 
     role="button"
     tabIndex={0}
     onClick={handleClick}
     onKeyDown={(e) => {
       if (e.key === 'Enter' || e.key === ' ') handleClick();
     }}
     aria-label={t('actions.custom')}
   >
     Custom Button
   </div>
   ```

2. **ARIA Labels:**
   ```tsx
   // For icon buttons
   <button aria-label={t('actions.delete', { item: item.name })}>
     <TrashIcon />
   </button>
   
   // For forms
   <label htmlFor="username">{t('form.username')}</label>
   <input id="username" name="username" type="text" />
   
   // For dynamic content
   <div role="alert" aria-live="polite">
     {errorMessage}
   </div>
   ```

3. **Color Contrast:**
   - **Normal text:** 4.5:1 minimum
   - **Large text (18pt+):** 3:1 minimum
   - **Tools:** Use axe DevTools or Lighthouse

4. **Focus Management:**
   ```tsx
   function Dialog({ isOpen, onClose }: DialogProps) {
     const closeButtonRef = useRef<HTMLButtonElement>(null);
     
     useEffect(() => {
       if (isOpen) {
         closeButtonRef.current?.focus();
       }
     }, [isOpen]);
     
     return (
       <div role="dialog" aria-modal="true">
         <button ref={closeButtonRef} onClick={onClose}>
           {t('common.close')}
         </button>
       </div>
     );
   }
   ```

5. **Screen Reader Testing:**
   - **macOS:** VoiceOver (Cmd + F5)
   - **Windows:** NVDA (free)
   - **Test:** Navigate entire app using only keyboard

</accessibility_standards>

<security_standards>
**Frontend Security (MANDATORY):**

1. **Content Security Policy (CSP):**
   ```http
   Content-Security-Policy: 
     default-src 'self'; 
     script-src 'self' 'nonce-random123'; 
     style-src 'self' 'unsafe-inline'; 
     img-src 'self' https://cdn.example.com;
     connect-src 'self' https://api.example.com;
   ```

2. **XSS Prevention:**
   ```tsx
   // ❌ Dangerous: HTML injection
   <div dangerouslySetInnerHTML={{ __html: userInput }} />
   
   // ✅ Safe: React escapes by default
   <div>{userInput}</div>
   
   // ✅ If HTML needed: Sanitize first
   import DOMPurify from 'dompurify';
   const clean = DOMPurify.sanitize(userInput);
   <div dangerouslySetInnerHTML={{ __html: clean }} />
   ```

3. **Input Validation:**
   ```typescript
   import { z } from 'zod';
   
   const userSchema = z.object({
     email: z.string().email(),
     age: z.number().min(18).max(120),
     username: z.string().regex(/^[a-zA-Z0-9_]+$/)
   });
   
   function handleSubmit(data: unknown) {
     const validated = userSchema.parse(data);
     // Now safe to use validated data
   }
   ```

4. **Authentication:**
   - **Tokens:** Store JWTs in httpOnly cookies (not localStorage)
   - **CSRF:** Use CSRF tokens for state-changing operations
   - **Session Timeout:** Auto-logout after inactivity

5. **Dependency Auditing:**
   ```bash
   # Regular security audits
   npm audit
   npm audit fix
   
   # Use Snyk or Dependabot
   ```

</security_standards>

<performance_guidelines>
**Web Performance Optimization:**

1. **Code Splitting:**
   ```tsx
   // Lazy load routes
   const Dashboard = lazy(() => import('./pages/Dashboard'));
   const Settings = lazy(() => import('./pages/Settings'));
   
   function App() {
     return (
       <Suspense fallback={<LoadingSpinner />}>
         <Routes>
           <Route path="/dashboard" element={<Dashboard />} />
           <Route path="/settings" element={<Settings />} />
         </Routes>
       </Suspense>
     );
   }
   ```

2. **Image Optimization:**
   ```tsx
   // Next.js Image component (automatic optimization)
   <Image
     src="/hero.jpg"
     alt="Hero image"
     width={1200}
     height={600}
     priority
     placeholder="blur"
   />
   
   // Responsive images
   <picture>
     <source srcSet="image.webp" type="image/webp" />
     <source srcSet="image.jpg" type="image/jpeg" />
     <img src="image.jpg" alt="Description" loading="lazy" />
   </picture>
   ```

3. **Bundle Size:**
   - **Target:** < 200KB initial JS bundle (gzipped)
   - **Tools:** webpack-bundle-analyzer, Vite build analysis
   - **Tree Shaking:** Import only what you need
   
   ```typescript
   // ❌ Bad: Imports entire library
   import _ from 'lodash';
   
   // ✅ Good: Import specific function
   import debounce from 'lodash/debounce';
   ```

4. **Caching Strategy:**
   ```typescript
   // React Query for server state
   const { data } = useQuery({
     queryKey: ['users', userId],
     queryFn: () => fetchUser(userId),
     staleTime: 5 * 60 * 1000,  // 5 minutes
     cacheTime: 10 * 60 * 1000  // 10 minutes
   });
   ```

5. **Core Web Vitals:**
   - **LCP (Largest Contentful Paint):** < 2.5s
   - **FID (First Input Delay):** < 100ms
   - **CLS (Cumulative Layout Shift):** < 0.1
   - **Monitor:** Google PageSpeed Insights, Lighthouse

</performance_guidelines>

<common_pitfalls>
**Frequent Frontend Mistakes:**

1. **Missing Key Prop in Lists:**
   ```tsx
   // ❌ Bad: Index as key (causes bugs on reorder)
   {items.map((item, index) => <li key={index}>{item}</li>)}
   
   // ✅ Good: Stable unique ID
   {items.map(item => <li key={item.id}>{item.name}</li>)}
   ```

2. **Direct State Mutation:**
   ```tsx
   // ❌ Bad: Mutating state
   const [users, setUsers] = useState([]);
   users.push(newUser);  // DON'T DO THIS
   
   // ✅ Good: Immutable update
   setUsers(prev => [...prev, newUser]);
   ```

3. **Prop Drilling:**
   ```tsx
   // ❌ Bad: Passing props through many levels
   <App user={user}>
     <Layout user={user}>
       <Sidebar user={user}>
         <UserMenu user={user} />
       </Sidebar>
     </Layout>
   </App>
   
   // ✅ Good: Use Context
   const UserContext = createContext<User | null>(null);
   
   <UserContext.Provider value={user}>
     <App>
       <Layout>
         <Sidebar>
           <UserMenu />  {/* Accesses user via useContext */}
         </Sidebar>
       </Layout>
     </App>
   </UserContext.Provider>
   ```

4. **useEffect Mistakes:**
   ```tsx
   // ❌ Bad: Missing dependencies
   useEffect(() => {
     fetchData(userId);  // userId not in deps!
   }, []);
   
   // ✅ Good: Complete dependencies
   useEffect(() => {
     fetchData(userId);
   }, [userId]);
   ```

5. **Not Handling Loading/Error States:**
   ```tsx
   // ❌ Bad: No loading/error handling
   function UserProfile() {
     const [user, setUser] = useState(null);
     useEffect(() => {
       fetchUser().then(setUser);
     }, []);
     return <div>{user.name}</div>;  // Error if user is null!
   }
   
   // ✅ Good: Handle all states
   function UserProfile() {
     const { data: user, isLoading, error } = useQuery(['user'], fetchUser);
     
     if (isLoading) return <Spinner />;
     if (error) return <ErrorMessage error={error} />;
     if (!user) return <NotFound />;
     
     return <div>{user.name}</div>;
   }
   ```

**Examples:** See examples/web/pitfalls.md for detailed code examples.

</common_pitfalls>

<testing_standards>
**Frontend Testing Strategy:**

1. **Unit Tests (Vitest/Jest):**
   ```typescript
   import { describe, it, expect } from 'vitest';
   import { formatCurrency } from './utils';
   
   describe('formatCurrency', () => {
     it('formats USD correctly', () => {
       expect(formatCurrency(99.99, 'USD')).toBe('$99.99');
     });
     
     it('handles zero', () => {
       expect(formatCurrency(0, 'USD')).toBe('$0.00');
     });
   });
   ```

2. **Component Tests (React Testing Library):**
   ```typescript
   import { render, screen, fireEvent } from '@testing-library/react';
   import { UserCard } from './UserCard';
   
   test('calls onEdit when button clicked', () => {
     const mockEdit = vi.fn();
     const user = { id: 1, name: 'John', email: 'john@example.com' };
     
     render(<UserCard user={user} onEdit={mockEdit} />);
     
     fireEvent.click(screen.getByRole('button', { name: /edit/i }));
     
     expect(mockEdit).toHaveBeenCalledWith(user);
   });
   ```

3. **E2E Tests (Playwright/Cypress):**
   ```typescript
   import { test, expect } from '@playwright/test';
   
   test('user can log in', async ({ page }) => {
     await page.goto('/login');
     await page.fill('[name="username"]', 'testuser');
     await page.fill('[name="password"]', 'password123');
     await page.click('button[type="submit"]');
     
     await expect(page).toHaveURL('/dashboard');
     await expect(page.locator('h1')).toContainText('Dashboard');
   });
   ```

4. **Accessibility Testing:**
   ```typescript
   import { axe } from 'jest-axe';
   
   test('has no accessibility violations', async () => {
     const { container } = render(<UserCard user={mockUser} />);
     const results = await axe(container);
     expect(results).toHaveNoViolations();
   });
   ```

**Coverage Goals:**
- **Utilities:** 100%
- **Components:** 80%
- **Critical Paths:** 100% (checkout, auth, etc.)

</testing_standards>

