# Product design, animation and implementation roadmap

## 1. Visual direction

Create an original premium esports platform identity: graphite/near-black surfaces, restrained high-contrast accent, bold readable typography and clear tournament data. Avoid copying Free Fire/Garena marks, characters, UI, artwork, music or gameplay footage without written permission.

Avoid generic neon templates, purple gradients, pill-heavy controls, fake metrics, fabricated reviews, AI-slop imagery and distracting scroll motion. Use a consistent design token system across Flutter and web while respecting platform conventions.

## 2. Animation technology

- Flutter: native animation APIs and \`flutter_animate\`; Rive only for a small number of original vector brand interactions.
- Web: Motion for React for route/component transitions; CSS for simple state transitions.
- Every image/animation/audio asset must be original or properly licensed.

## 3. Required animated experiences

| Experience | Motion | Guardrail |
|---|---|---|
| App launch | Short logo reveal and transition to app shell | Skippable/non-blocking |
| Authentication | Smooth switch among email/password and Google | Stable accessible form |
| Home | Small content entrance, subtle card feedback | No repeated animation on every rebuild |
| Tournament cards | Press feedback, status/progress change | No fake slot counts |
| Tournament details | Section/rules expansion | Reduced-motion alternative |
| Team invitations | Pending → accepted member transition | Only after server confirms acceptance |
| Checkout | Price summary and link/QR method selection | Price comes from backend |
| Payment pending | Progress state / refresh | Never imply payment success prematurely |
| Payment success | Confirmation reveal | Only after server-verified capture and registration |
| Leaderboard | Rank movement | Only after official verified snapshot |
| Live match | Server-synchronized countdown and room reveal | Never leak early room secrets |
| Admin/organizer portals | Subtle drawer and row feedback | Data density and speed win over spectacle |

## 4. Motion tokens and performance

Initial values:
- Micro-interaction: 120–180 ms.
- Standard transition: 180–260 ms.
- Route/modal: 220–320 ms.
- Stagger: 30–50 ms for small groups only.

Use restrained enter/exit easing; avoid spring overshoot on money controls. Respect reduced-motion preferences on web and Android. Target 60 FPS on supported devices, not every device. Avoid continuous background animation, unnecessary 3D/shaders, excessive parallax and scroll hijacking. Lazy-load media; semantic labels, contrast, keyboard focus and clear state text are required. Motion/color cannot be the only status signal.

Before UI phases create component inventory, design tokens, responsive breakpoints, motion storyboard, asset-license register and low-end Android performance checklist.

## 5. Implementation roadmap

| Phase | Scope | Exit criteria |
|---|---|---|
| 0 | Repository and architecture baseline (current) | Documentation validator passes; owner accepts architecture and blockers |
| 1 | Cloud foundation, PostgreSQL/Prisma, Firebase identity, profiles, roles, audit and CI | Web and Android share one internal identity; negative authZ tests pass |
| 2 | Teams, platform/game UID, invitation and organizer tenancy | Captain/invitee flows pass; cross-organizer isolation tests pass |
| 3 | BR/CS tournament configuration, versioning, registration, slots and portals | Published tournament appears in app/web; last-slot concurrency cannot oversell |
| 4 | Match engine, encrypted room details, evidence, moderation, scoring and disputes | Golden scoring tests pass; unverified results never become official |
| 5 | PSP sandbox integration: link, QR, webhooks, duplicate prevention, test ledger/refunds | Written PSP approval and sandbox proof; production gates stay off until law/publisher approval |
| 6 | Organizer KYC, split settlement, commission and reconciliation | PSP confirms exact model; journals balance; no over-settlement |
| 7 | Prize commitments, awards, organizer evidence and verification | Legal/tax review; organizer cannot self-mark PAID_CONFIRMED |
| 8 | Security, production infra, load/restore tests and monitoring | Critical/high findings closed; restore and incident drill pass |
| 9 | Signed APK and distribution | Play and direct APK separately assessed; release signing/device matrix pass |

## 6. Phase 1 entry criteria

- Owner has reviewed and accepted Phase 0.
- Legal/product owner approves initial free launch scope.
- Cloud account/billing, Firebase environments and data-processing agreements are available.
- Privacy notice, age/guardian policy, data minimization and retention plan approved before real user data is collected.
- Domain, brand and public/private repository decision resolved.

## 7. Paid feature entry criteria

- Written Indian gaming-counsel opinion on exact title/event/fee/commission/prize/funds flow.
- Relevant esports determination/recognition/registration evidence.
- Garena commercial permission.
- PSP written approval for gaming category, marketplace split, payment link, dynamic QR, refunds and settlement.
- Organizer contract, player terms, refund and tax policy.
- Separate Google Play policy assessment; direct APK separately reviewed.
- All feature flags remain false until evidence is recorded and deployment is approved.

## 8. Definition of done per implementation phase

Acceptance criteria before work; migrations/rollback plan; unit/integration/contract and negative authorization tests; no fake production path; no secrets or customer PII in Git; updated docs; green CI; test evidence/screenshots/logs; unresolved issues listed honestly.
