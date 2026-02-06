````instructions
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
</agent_profile>

<quick_reference>
**Critical Rules (TL;DR):**
- **No Hardcoded Strings:** Use i18n keys for ALL user-visible text
- **Semantic HTML:** Proper HTML5 elements, not div soup
- **ARIA Labels:** Required for interactive elements and dynamic content
- **Mobile First:** Design for mobile, enhance for desktop
- **TypeScript:** Strict mode (`strict: true`, `noImplicitAny`, `noUncheckedIndexedAccess`)
- **Component Size:** Max 250 lines; extract if larger
- **Accessibility:** WCAG 2.1 AA minimum (AAA for government/public)
- **Security:** CSP headers, input sanitization, XSS prevention
- **Testing:** Unit tests for logic, integration tests for user flows
</quick_reference>

<architecture_standards>
Decouple frontend from backend. Use micro-frontends for large apps (Module Federation / import maps).

**Monorepo Structure:**
```
workspace/
├── apps/          # web, mobile, admin
├── packages/      # ui (shared components), utils, i18n
└── infrastructure/
```
</architecture_standards>

<technology_standards>

## TypeScript (Mandatory)

- `strict: true` with `noUncheckedIndexedAccess` and `exactOptionalPropertyTypes`
- Explicit types for function signatures. Union types over enums for string literals.
- No `any` — use `unknown` and narrow.

## React/Next.js

- Functional components only (no class components)
- State: Context API for simple, Zustand/Redux for complex
- React Server Components (Next.js App Router) + Suspense for async
- Custom hooks for reusable logic — see [examples/web/react/useAsync.ts](../examples/web/react/useAsync.ts)
- Component patterns — see [examples/web/react/UserCard.tsx](../examples/web/react/UserCard.tsx)

## HTML5

- Semantic elements: `<header>`, `<nav>`, `<main>`, `<article>`, `<aside>`, `<footer>`
- `<nav aria-label="...">` for navigation landmarks
- Headings in order (h1 → h2 → h3), never skip levels

## CSS

- **Mobile-first** media queries (min-width breakpoints)
- CSS Grid/Flexbox for layout (no floats)
- CSS Variables for theming, CSS Modules or Tailwind for scoping
- Container queries for component-based responsive design
- See [examples/web/react/UserCard.module.css](../examples/web/react/UserCard.module.css) for patterns (dark mode, reduced-motion, high contrast)
</technology_standards>

<internationalization>
**MANDATORY — never hardcode user-visible strings.**

```tsx
// ❌ <button>Submit</button>
// ✅ <button>{t('form.submit')}</button>
```

- **Libraries:** react-i18next (React), vue-i18n (Vue), next-i18next (Next.js)
- **Structure:** `locales/{lang}/common.json`, `dashboard.json`, `errors.json`
- **Dates/Numbers:** Use `Intl.DateTimeFormat` and `Intl.NumberFormat` — never manual formatting
</internationalization>

<accessibility_standards>
**WCAG 2.1 AA Compliance (MANDATORY):**

1. **Keyboard:** All interactive elements keyboard-accessible. Custom components need `role`, `tabIndex`, and keyboard event handlers (`Enter`, `Space`).
2. **ARIA:** `aria-label` on icon buttons, `htmlFor` on labels, `aria-live="polite"` for dynamic content, `role="dialog" aria-modal="true"` for modals.
3. **Color Contrast:** 4.5:1 for normal text, 3:1 for large text (18pt+). Use axe DevTools/Lighthouse.
4. **Focus Management:** Trap focus in modals, auto-focus first interactive element on open, return focus on close.
5. **Screen Reader Testing:** VoiceOver (macOS), NVDA (Windows). Navigate entire app with keyboard only.
</accessibility_standards>

<security_standards>
1. **CSP:** `default-src 'self'`; whitelist specific script/style/img/connect sources with nonces.
2. **XSS:** Never use `dangerouslySetInnerHTML` without `DOMPurify.sanitize()`. React escapes by default — don't bypass it.
3. **Input Validation:** Schema validation (Zod) at form boundaries. Validate before submission.
4. **Auth:** JWTs in httpOnly cookies (not localStorage). CSRF tokens for state-changing operations. Auto-logout on inactivity.
5. **Dependency Auditing:** `npm audit` regularly. Use Dependabot/Snyk.
</security_standards>

<performance_guidelines>
1. **Code Splitting:** `lazy()` + `<Suspense>` for route-level splitting.
2. **Images:** Next.js `<Image>` or `<picture>` with WebP + lazy loading. Always include `alt` and dimensions.
3. **Bundle Size:** <200KB initial JS (gzipped). Tree-shake imports (`import debounce from 'lodash/debounce'`, not `import _ from 'lodash'`).
4. **Caching:** React Query / SWR for server state with staleTime configuration.
5. **Core Web Vitals Targets:** LCP <2.5s, FID <100ms, CLS <0.1. Monitor with Lighthouse.
</performance_guidelines>

<common_pitfalls>
1. **Key Prop:** Use stable unique IDs, never array index (`key={item.id}`, not `key={index}`).
2. **State Mutation:** Immutable updates only (`setUsers(prev => [...prev, newUser])`, never `users.push()`).
3. **Prop Drilling:** Use Context or state management when passing through >2 intermediate components.
4. **useEffect Deps:** Include all referenced variables in dependency array. Use exhaustive-deps lint rule.
5. **Missing Loading/Error States:** Always handle loading, error, and empty states for async data.
</common_pitfalls>

<testing_standards>
- **Unit (Vitest/Jest):** Logic utilities — 100% coverage
- **Components (React Testing Library):** User interactions, rendered output — 80% coverage
- **E2E (Playwright/Cypress):** Critical user flows (auth, checkout) — 100% coverage
- **Accessibility (jest-axe):** `expect(await axe(container)).toHaveNoViolations()` on all components

See [examples/web/react/UserCard.test.tsx](../examples/web/react/UserCard.test.tsx) and [useAsync.test.ts](../examples/web/react/useAsync.test.ts) for patterns.
</testing_standards>
````
