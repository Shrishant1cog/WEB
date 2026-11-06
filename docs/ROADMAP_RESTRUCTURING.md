# Roadmap Restructuring: 9 Phases → 6 Phases

**Date:** 6 November 2026  
**Decision:** Restructure official roadmap from 9 phases to 6 phases

---

## Previous Structure (9 Phases)

| Phase | Name |
|-------|------|
| 0 | Project Baseline |
| 1 | Foundation |
| 2 | Authentication & Profiles |
| 3 | Tournament Management |
| 4 | Teams & Registration |
| 5 | Match Management |
| 6 | Results & Disputes |
| 7 | Notifications & Admin |
| 8 | Quality & Release |

---

## New Structure (6 Phases)

| New Phase | Name | Combines |
|-----------|------|----------|
| **Phase 0** | Project Baseline | Phase 0 |
| **Phase 1** | Foundation | Phase 1 |
| **Phase 2** | Authentication & Profiles | Phase 2 |
| **Phase 3** | Tournament & Participation Management | Phase 3 + Phase 4 |
| **Phase 4** | Match, Results & Competition Operations | Phase 5 + Phase 6 |
| **Phase 5** | Platform Administration, Notifications & Release Readiness | Phase 7 + Phase 8 |

**Total: 6 phases (Phase 0–5)**

---

## Why Consolidation?

1. **Logical Grouping:** Tournament management (Phase 3) and team registration (Phase 4) are tightly coupled — you can't register for tournaments without teams, and tournaments need teams to function
2. **Match-Results Coupling:** Match management (Phase 5) and results/disputes (Phase 6) form a single competition operations domain
3. **Admin-Release Coupling:** Notifications/Admin (Phase 7) and Quality/Release (Phase 8) both concern platform operations and release readiness
4. **Reduced Overhead:** Fewer phase boundaries = fewer handoffs, less documentation overhead
4. **Clearer Milestones:** 6 phases with substantial deliverables vs 9 phases with thin slices

---

## What Was NOT Removed

✅ **All features preserved** — Every feature from the original 9 phases exists in the new 6 phases  
✅ **All acceptance criteria preserved** — Each consolidated phase retains all original acceptance criteria  
✅ **All engineering steps retained** — Each phase still requires: research, design, implementation, testing, security review, documentation, CI validation  
✅ **All dependency gates unchanged** — Phase N must pass before Phase N+1 begins  
✅ **Internal milestones** — Each consolidated phase uses smaller internal work packages with their own checkpoints  

---

## Phase Mapping Table

| Original Phase | New Phase | Notes |
|----------------|-----------|-------|
| Phase 0 | Phase 0 | Unchanged |
| Phase 1 | Phase 1 | Unchanged |
| Phase 2 | Phase 2 | Unchanged |
| Phase 3 | Phase 3 | Merged with Phase 4 |
| Phase 4 | Phase 3 | Merged with Phase 3 |
| Phase 5 | Phase 4 | Merged with Phase 6 |
| Phase 6 | Phase 4 | Merged with Phase 5 |
| Phase 7 | Phase 5 | Merged with Phase 8 |
| Phase 8 | Phase 5 | Merged with Phase 7 |

---

## Documentation Updated

- `docs/MVP_SCOPE.md` — Complete restructure with 6-phase table
- `docs/PROJECT_STATUS.md` — Updated phase progress tables and mapping
- `README.md` — Updated roadmap summary and current status
- `docs/PROJECT_DECISIONS.md` — Added roadmap restructuring decision
- `docs/ROADMAP_RESTRUCTURING.md` — This document

---

## Historical Reports

Past progress reports (Phase 0, Phase 1, Phase 2 reports) reference the original 9-phase structure. These are preserved as historical records and clearly marked as such. Active roadmap references now point to the 6-phase structure.

---

## Dependency Gates (Unchanged)

- Phase 0 must pass before Phase 1
- Phase 1 must pass before Phase 2
- Phase 2 must pass before Phase 3
- Phase 3 must pass before Phase 4
- Phase 4 must pass before Phase 5
- Phase 5 must pass final release readiness

No phase skipping. No engineering steps skipped. Consolidation ≠ skipping steps.

---

## Decision Record

**Decision ID:** RD-006  
**Date:** 6 November 2026  
**Status:** Approved  
**Author:** Project Lead  
**Reviewers:** Owner (pending)

**Rationale:** Consolidation reduces phase boundary overhead while preserving all scope, engineering rigor, and quality gates. The 6-phase structure aligns with natural domain boundaries (Tournament+Registration, Match+Results, Admin+Release).