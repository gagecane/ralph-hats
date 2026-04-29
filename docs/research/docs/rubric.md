# Hat Collection Scoring Rubric

> **📸 Snapshot — 2026-04-21.** This document is a point-in-time research artifact captured on 2026-04-21. It is not actively maintained. External sources (GitHub repos, Amazon-internal packages) may have changed since. Scores, links, and findings reflect the state of the world on that date.

## Overview

This rubric scores Ralph hat collections on 8 criteria, each rated 0–3. Maximum possible score: 24.

**Weighting:** All criteria are equally weighted (×1) except **Completion Semantics** which is ×1.5 (a collection that can't reliably finish is fundamentally broken regardless of other qualities). Weighted maximum: 25.5 (see Scoring Formula below).

## Criteria

### 1. Clarity of Topology

Can you read the YAML and predict the full event flow without running `ralph hats graph`?

| Score | Anchor |
|-------|--------|
| 0 | Events are unnamed/opaque; impossible to trace flow without tooling |
| 1 | Flow is partially traceable but has ambiguous branches or undocumented events |
| 2 | Flow is traceable; `events:` metadata present for non-obvious topics |
| 3 | Flow is immediately obvious; `events:` metadata explains every custom topic; `starting_event` and `completion_promise` clearly named |

### 2. Trigger/Publish Discipline

Are triggers narrow and unambiguous? Does each event route to exactly one hat?

| Score | Anchor |
|-------|--------|
| 0 | Multiple hats triggered by the same event with no `max_activations` guard; wildcard sprawl |
| 1 | Some overlap exists but is partially mitigated; a few overly broad topic names |
| 2 | Each trigger routes to one hat; topic names are semantic and scoped (e.g. `plan.ready` not `done`) |
| 3 | Perfect 1:1 trigger routing; topic names follow a consistent namespace convention; `default_publishes` set on every hat that has a single primary output |

### 3. Instruction Quality

Are hat instructions concrete, short, testable, and resistant to prompt drift?

| Score | Anchor |
|-------|--------|
| 0 | Instructions are vague platitudes ("do a good job") or missing entirely |
| 1 | Instructions describe the role but lack actionable constraints or acceptance criteria |
| 2 | Instructions include specific constraints, output format expectations, or verification steps |
| 3 | Instructions are concise (<300 words), include explicit acceptance criteria, define what NOT to do, and reference concrete artifacts or schemas |

### 4. Backpressure / Gating

Does a reviewer or gate hat actually reject incomplete work, creating a real feedback loop?

| Score | Anchor |
|-------|--------|
| 0 | No review/gate hat exists; pipeline is fire-and-forget |
| 1 | A reviewer hat exists but always publishes the "pass" event (decorative) |
| 2 | Reviewer can reject (publishes both pass and reject events); rejection routes back to the producer |
| 3 | Reviewer has explicit rejection criteria in instructions; rejection event routes to the correct upstream hat; rejection count or exhaustion is handled |

### 5. Completion Semantics (×1.5 weight)

Is there a single clear path to `completion_promise`? Are dead-end states impossible?

| Score | Anchor |
|-------|--------|
| 0 | No `completion_promise` defined, or multiple conflicting completion paths |
| 1 | `completion_promise` exists but some event paths can't reach it (dead ends) |
| 2 | All paths eventually reach `completion_promise`; one hat is clearly responsible for emitting it |
| 3 | Single designated finalizer/closer hat emits `completion_promise`; all branches (including rejection loops) have bounded iteration or exhaustion handling that converges to completion |

### 6. Error / Exhaustion Handling

Does the collection handle `.exhausted`, `.failed`, or orphan events?

> **Note:** `.exhausted`, `.blocked`, and `.failed` are conventional event-naming suffixes used in practice (and referenced in the PRD), not schema-mandated fields. The schema only defines the `triggers`/`publishes` mechanism — topic names are user-chosen.

| Score | Anchor |
|-------|--------|
| 0 | No error handling; failures silently stall the loop |
| 1 | One error path exists but coverage is incomplete (e.g. handles rejection but not exhaustion) |
| 2 | Explicit handling for the primary failure mode (e.g. `.blocked` event routes to a recovery hat) |
| 3 | Comprehensive: handles exhaustion, blocked states, and unexpected failures; recovery hats have clear instructions for graceful degradation or escalation |

### 7. Backend Discipline

Are `backend` overrides used intentionally with clear rationale?

| Score | Anchor |
|-------|--------|
| 0 | Expensive model used uniformly with no consideration of task complexity |
| 1 | Single backend specified globally; no per-hat differentiation |
| 2 | At least one hat uses a cheaper/faster backend for routing or simple decisions; choice is reasonable |
| 3 | Deliberate tiering: cheap model for routing/triage, expensive model for synthesis/review; `backend_args` tuned per hat (e.g. lower temperature for deterministic tasks) |

### 8. Size / Focus

Does the collection do one job well, or does it sprawl across unrelated concerns?

| Score | Anchor |
|-------|--------|
| 0 | >10 hats with unclear boundaries; multiple unrelated workflows crammed into one file |
| 1 | 6–10 hats but some have overlapping responsibilities or unclear roles |
| 2 | 3–6 hats with distinct roles; collection addresses a single workflow |
| 3 | 3–5 hats, each with a clearly distinct role; collection is laser-focused on one workflow; could not remove a hat without breaking the topology |

## Scoring Formula

```
Total = (C1 + C2 + C3 + C4 + C5×1.5 + C6 + C7 + C8)
Max   = 3 + 3 + 3 + 3 + 4.5 + 3 + 3 + 3 = 25.5
```

## Interpretation

| Range | Label |
|-------|-------|
| 21–25.5 | Exemplary — adopt patterns directly |
| 16–20.9 | Strong — good foundation with minor gaps |
| 10–15.9 | Adequate — functional but has structural weaknesses |
| 5–9.9 | Weak — significant issues; use only as counter-examples |
| 0–4.9 | Broken — non-functional or fundamentally misdesigned |

## Sources

- PRD rubric starting point (local file `PRD.md`)
- Ralph hats schema: `../../../skills/ralph-hats/references/schema.md`
- Ralph hats examples: `../../../skills/ralph-hats/references/examples.md`
- Ralph hats commands (validation criteria): `../../../skills/ralph-hats/references/commands.md`
