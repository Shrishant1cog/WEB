# Contributing to FFT

Thank you for your interest in contributing to FFT! This document outlines the process and standards for contributing to this independent tournament management platform.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:
- Be respectful and inclusive
- Focus on constructive feedback
- No harassment, discrimination, or offensive behavior
- Respect intellectual property and legal boundaries

## Legal Boundaries

**FFT is an independent platform.** Contributors must not:
- Add Garena logos, Free Fire assets, or copyrighted game content
- Implement unauthorized game integrations or scrapers
- Add real-money features (prizes, wallets, betting, payouts)
- Claim official affiliation with Garena or Free Fire India

All contributions must maintain the clear disclaimer: "FFT is an independent tournament management platform. It is not affiliated with, endorsed by, or operated by Garena."

## Development Workflow

### 1. Branching Strategy

- **Main branch (`main`)**: Protected, only updated via approved releases
- **Development branch (`agent/fft-development`)**: Active development, CI validated
- **Feature branches**: `feat/<short-description>` from `agent/fft-development`
- **Fix branches**: `fix/<short-description>` from `agent/fft-development`
- **Documentation branches**: `docs/<short-description>`

### 2. Commit Convention

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code restructuring
- `test`: Adding/updating tests
- `chore`: Maintenance, dependencies
- `security`: Security improvements
- `perf`: Performance improvements

**Scopes:** `auth`, `tournaments`, `teams`, `matches`, `results`, `notifications`, `admin`, `mobile`, `web`, `db`, `ci`, `docs`

**Examples:**
```
feat(tournaments): add squad registration flow
fix(auth): handle expired refresh token in mobile
docs: update API documentation for match credentials
test(db): add RLS policy tests for tournament_entries
security: encrypt room credentials with pgcrypto
```

### 3. Pull Request Process

1. Create feature branch from `agent/fft-development`
2. Make changes with tests
3. Run all checks locally:
   ```bash
   pnpm check:all
   ```
4. Push branch and create PR to `agent/fft-development`
5. CI must pass (lint, typecheck, test, build, security)
6. Code review by maintainer
7. Squash merge to `agent/fft-development`

### 4. Code Review Checklist

- [ ] Tests added/updated for new functionality
- [ ] All CI checks pass
- [ ] No secrets or sensitive data in changes
- [ ] Documentation updated if API/behavior changed
- [ ] Security considerations addressed (RLS, validation, authz)
- [ ] Accessibility considered (WCAG 2.1 AA for web)
- [ ] Performance impact assessed
- [ ] Legal/compliance implications reviewed

## Technical Standards

### Flutter (Mobile)

- **Architecture**: Layered (presentation, domain, data, core)
- **State Management**: Bloc/Cubit (`flutter_bloc`)
- **Immutability**: Freezed for models, immutable states
- **Navigation**: GoRouter with auth guards
- **Dependency Injection**: GetIt/service_locator
- **Testing**: `flutter_test`, `bloc_test`, `mocktail`, `integration_test`
- **Analysis**: `flutter analyze` (zero warnings)
- **Formatting**: `dart format` (default)

### Next.js (Web)

- **Router**: App Router (React Server Components by default)
- **Language**: TypeScript strict mode
- **Styling**: Tailwind CSS + shadcn/ui
- **Forms**: React Hook Form + Zod validation
- **Auth**: Supabase SSR (`@supabase/ssr`)
- **Testing**: Vitest (unit/component), Playwright (E2E)
- **Linting**: ESLint + Prettier
- **Type Checking**: `tsc --noEmit`

### Supabase (Backend)

- **Migrations**: Versioned SQL (`supabase/migrations/*.sql`)
- **RLS**: Enabled on ALL exposed tables
- **Functions**: SECURITY DEFINER RPC for business logic
- **Triggers**: Audit logging, updated_at, constraints
- **Testing**: pgTAP for policies, functions, constraints
- **Types**: Generated from schema (`supabase gen types`)

### Security

- **Never** commit secrets, keys, or credentials
- **Never** disable RLS to make a feature work
- **Always** validate on server + database, not just client
- **Always** use parameterized queries / RPC
- **Always** audit sensitive operations
- **Rotate** secrets quarterly

## Testing Requirements

| Layer | Mobile | Web | Backend |
|-------|--------|-----|---------|
| Unit | Required | Required | Required (pgTAP) |
| Widget/Component | Required | Required | N/A |
| Integration | Critical paths | Critical paths | RPC + concurrency |
| E2E | Key journeys | Key journeys | N/A |
| Security | MASVS | ASVS | RLS matrix |

**Minimum for PR:**
- Unit tests for new logic
- Widget/Component tests for new UI
- RLS policy tests for new tables/policies
- Concurrency tests for capacity operations

## Documentation Standards

- Update relevant `.md` files in `docs/` with code changes
- Keep `README.md` current
- Document API changes in `docs/architecture/WORKFLOWS.md`
- Update data model docs for schema changes
- Record decisions in `docs/decisions/PROJECT_DECISIONS.md`

## Release Process

Only maintainers can release. See `docs/operations/BUILD_AND_RELEASE.md`.

## Getting Help

- Check existing documentation in `docs/`
- Search closed issues/PRs
- Ask in discussions (if enabled)
- Contact maintainers for security issues (see SECURITY.md)

## License

By contributing, you agree that your contributions will be licensed under the project's proprietary license (UNLICENSED). FFT is not open source.