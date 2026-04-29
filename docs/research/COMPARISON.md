# Hat Collection Comparison

> **📸 Snapshot — 2026-04-21.** This document is a point-in-time research artifact captured on 2026-04-21. It is not actively maintained. External sources (GitHub repos, Amazon-internal packages) may have changed since. Scores, links, and findings reflect the state of the world on that date.

Scored comparison of Ralph hat collections against a quality rubric, with patterns worth adopting and anti-patterns to avoid.

---

## Methodology

Ten hat collections were selected from the full inventory (see `INVENTORY.md`) based on having ≥3 hats with non-trivial instructions. Collections were scored independently on 8 criteria using the rubric below. Evidence for each score is cited with source URLs. Candidate selection rationale is documented in `docs/comparison/candidates.md`.

---

## Rubric

Eight criteria, each rated 0–3. Completion Semantics is weighted ×1.5 (a collection that can't reliably finish is fundamentally broken). Weighted maximum: 25.5.

| # | Criterion | What It Measures |
|---|-----------|-----------------|
| 1 | Clarity of Topology | Can you predict event flow from the YAML alone? |
| 2 | Trigger/Publish Discipline | Narrow triggers, 1:1 routing, consistent naming |
| 3 | Instruction Quality | Concrete, short, testable, resistant to prompt drift |
| 4 | Backpressure / Gating | Do gates actually reject? Does rejection route back? |
| 5 | Completion Semantics (×1.5) | Single clear path to `completion_promise`; no dead ends |
| 6 | Error / Exhaustion Handling | Recovery for `.exhausted`, `.failed`, orphan events |
| 7 | Backend Discipline | Intentional model tiering per hat |
| 8 | Size / Focus | One job done well; 3–5 hats with distinct roles |

**Scoring formula:** `C1 + C2 + C3 + C4 + C5×1.5 + C6 + C7 + C8` (max 25.5)

| Range | Label |
|-------|-------|
| 21–25.5 | Exemplary — adopt patterns directly |
| 16–20.9 | Strong — good foundation with minor gaps |
| 10–15.9 | Adequate — functional but has structural weaknesses |
| 5–9.9 | Weak — significant issues; use only as counter-examples |
| 0–4.9 | Broken — non-functional or fundamentally misdesigned |

Full rubric with scoring anchors: `docs/rubric.md`

---

## Scored Table

| # | Collection | C1 | C2 | C3 | C4 | C5 (×1.5) | C6 | C7 | C8 | Total | Label |
|---|-----------|:--:|:--:|:--:|:--:|:----------:|:--:|:--:|:--:|:-----:|:------|
| 1 | `code-assist.yml` | 3 | 3 | 3 | 3 | 3 (4.5) | 2 | 2 | 3 | **23.5** | Exemplary |
| 2 | PcadWiki `cr-comment-actioner.yml` | 3 | 3 | 3 | 3 | 3 (4.5) | 3 | 1 | 2 | **22.5** | Exemplary |
| 3 | `autoresearch.yml` | 3 | 3 | 3 | 2 | 3 (4.5) | 2 | 1 | 3 | **21.5** | Exemplary |
| 4 | `debug.yml` | 3 | 3 | 3 | 2 | 3 (4.5) | 1 | 1 | 3 | **20.5** | Strong |
| 5 | `research.yml` | 3 | 2 | 3 | 2 | 3 (4.5) | 1 | 1 | 3 | **19.5** | Strong |
| 6 | `ralph.reviewer.yml` | 3 | 3 | 3 | 1 | 3 (4.5) | 1 | 1 | 2 | **18.5** | Strong |
| 7 | CEO Suite Gist | 2 | 2 | 2 | 1 | 2 (3.0) | 3 | 3 | 1 | **17.0** | Strong |
| 8 | ElcidRalph `feature-dev-e2e.yml` | 3 | 2 | 2 | 3 | 2 (3.0) | 1 | 2 | 1 | **17.0** | Strong |
| 9 | `wave-review.yml` | 3 | 3 | 2 | 0 | 3 (4.5) | 0 | 1 | 3 | **16.5** | Strong |
| 10 | `pdd-to-code-assist.yml` | 2 | 2 | 3 | 3 | 2 (3.0) | 1 | 1 | 1 | **16.0** | Strong |

Detailed per-criterion rationale with evidence: `docs/comparison/scores.md`

---

## Patterns Worth Adopting

Seven recurring patterns from collections scoring ≥19.5:

### 1. Pessimistic `default_publishes` on Gate Hats

Gate hats set `default_publishes` to the rejection event. If the LLM fails to explicitly publish, the system defaults to "not approved" — silence means retry, not pass.

*Seen in:* code-assist (critic: `review.rejected`), debug (fixer: `fix.blocked`, verifier: `fix.failed`)
*Sources:* [code-assist.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/code-assist.yml), [debug.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/debug.yml)

### 2. Single-Owner Completion

One designated hat owns `completion_promise`. All paths converge to it. Secondary hats may list it in `publishes` only as a last-resort escape hatch under explicitly different conditions.

*Seen in:* All 5 top collections. research.yml (synthesizer only), code-assist (finalizer only), cr-comment-actioner (notifier only).
*Sources:* [research.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/research.yml), [cr-comment-actioner.yml](https://code.amazon.com/packages/PcadWiki/blobs/mainline/--/skills/cr-auto-action/hats/cr-comment-actioner.yml)

### 3. Semantic `noun.state` Event Naming

Events follow `noun.state` convention (e.g., `review.passed`, `hypothesis.confirmed`). The topology is self-documenting from event names alone.

*Seen in:* code-assist, autoresearch, debug
*Sources:* [debug.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/debug.yml), [autoresearch.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/autoresearch.yml)

### 4. Step-Wave Queue with Bounded Iteration

Work is decomposed into discrete steps; one step per iteration. A gate verifies each step before advancing. Bounds blast radius of failures.

*Seen in:* code-assist (planner materializes current step only), cr-comment-actioner (triager classifies one batch)
*Sources:* [code-assist.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/code-assist.yml), [cr-comment-actioner.yml](https://code.amazon.com/packages/PcadWiki/blobs/mainline/--/skills/cr-auto-action/hats/cr-comment-actioner.yml)

### 5. Separation of Investigation from Action

Hats that analyze are forbidden from modifying state. Hats that modify receive instructions from the analysis phase. Rejection is cheap (no rollback needed).

*Seen in:* debug (investigator: "❌ Change code during investigation phase"), ralph.reviewer (git worktree isolation), cr-comment-actioner (triager: `disallowed_tools: ["edit", "write"]`)
*Sources:* [debug.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/debug.yml), [cr-comment-actioner.yml](https://code.amazon.com/packages/PcadWiki/blobs/mainline/--/skills/cr-auto-action/hats/cr-comment-actioner.yml)

### 6. Minimal Hat Count (3–5 Hats)

Each hat has one non-overlapping responsibility. No hat can be removed without breaking the topology. Collections exceeding 6 hats consistently score lower on Focus.

*Seen in:* research (2), code-assist (4), debug (4), autoresearch (5)
*Sources:* [research.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/research.yml), [code-assist.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/code-assist.yml)

### 7. Exhaustive Event-Flow Documentation

Top collections document topology via `events:` metadata blocks or structured header comments enumerating all paths.

*Seen in:* cr-comment-actioner (header paths A–G, lines 19–68), ElcidRalph (full `events:` block with descriptions, lines 23–63)
*Sources:* [cr-comment-actioner.yml](https://code.amazon.com/packages/PcadWiki/blobs/mainline/--/skills/cr-auto-action/hats/cr-comment-actioner.yml), [ElcidRalph feature-dev-e2e.yml](https://code.amazon.com/packages/ElcidRalph/blobs/mainline/--/frontend-dev-hats/hats/feature-dev-e2e.yml)

---

## Anti-Patterns to Avoid

Four recurring anti-patterns from collections scoring ≤17.0:

### 1. Kitchen-Sink Collection (Hat Sprawl)

Multiple unrelated workflows crammed into one file (9–11 hats). The event graph becomes too complex to reason about; `max_iterations` becomes the only safety net.

*Seen in:* pdd-to-code-assist (11 hats, C8=1), ElcidRalph (10 hats, C8=1), CEO Suite (9 hats, C8=1)
*Sources:* [pdd-to-code-assist.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/pdd-to-code-assist.yml), [ElcidRalph](https://code.amazon.com/packages/ElcidRalph/blobs/mainline/--/frontend-dev-hats/hats/feature-dev-e2e.yml)

### 2. Fire-and-Forget Pipeline (No Backpressure)

Work flows strictly forward with no rejection mechanism. Gate hats exist in name only. The system cannot self-correct.

*Seen in:* wave-review (C4=0, synthesizer always passes), ralph.reviewer (C4=1, verdict without routing)
*Sources:* [wave-review.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/wave-review.yml), [ralph.reviewer.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.reviewer.yml)

### 3. Missing Error and Exhaustion Handling

No recovery path for failures. The loop burns iterations doing nothing until timeout.

*Seen in:* wave-review (C6=0), pdd-to-code-assist (C6=1), ElcidRalph (C6=1)
*Sources:* [wave-review.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/wave-review.yml), [pdd-to-code-assist.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/pdd-to-code-assist.yml)

### 4. Mega-Fan-In Triggers (Router-Hat Overload)

A single hat triggers on 7–16 events, becoming a de facto router with complex conditional logic buried in prose instructions rather than declared in the topology.

*Seen in:* CEO Suite chief_of_staff (16 triggers), ElcidRalph builder (7 triggers)
*Sources:* [CEO Suite gist](https://gist.github.com/mikeyobrien/b15d22d7979ecae7cdd3f8f9e34d7337), [ElcidRalph](https://code.amazon.com/packages/ElcidRalph/blobs/mainline/--/frontend-dev-hats/hats/feature-dev-e2e.yml)

---

## Recommendations

Patterns that would suit the existing agent-task-loop work (the bash + kiro-cli state machine documented in `docs/inventory/internal-similar-patterns.md`):

1. **Adopt pessimistic defaults.** The agent-task-loop already implements this: the reviewer marks `[revise:N+1]` by default and must actively decide to mark `[completed]`. This maps directly to Pattern #1. No change needed — it's already a strength.

2. **Add semantic event naming to task markers.** Currently tasks use generic `[ ]`/`[review]`/`[revise]` markers. Consider adding a phase prefix (e.g., `[review:design]`, `[review:impl]`) to make the state machine self-documenting, mirroring Pattern #3.

3. **Formalize step-wave decomposition.** The agent-task-loop's decomposition heuristic ("if >300 lines or 3+ concerns, split") is Pattern #4 in spirit. Making it explicit — e.g., a planner pass that materializes subtasks before implementation begins — would reduce mid-task decomposition failures.

4. **Separate investigation from action.** The current loop conflates research and implementation in the same `[ ]` state. Splitting into `[research]` → `[implement]` phases (mirroring Pattern #5) would make rejection cheaper and context windows cleaner.

5. **Consider Ralph for parallel workflows.** The agent-task-loop is sequential by design. For workflows requiring parallel review (like wave-review's fan-out/fan-in) or concurrent specialists (like the CEO Suite's hub-and-spoke), Ralph's event-driven model is structurally superior. The internal `RalphAgentCapabilities` 3-agent architecture shows a middle ground: process-level isolation with file-based coordination.

6. **Keep hat count low if migrating.** If converting the agent-task-loop to Ralph hats, target 3–4 hats (implementer, reviewer, finalizer, optionally a planner). The `code-assist.yml` preset (23.5/25.5) is the closest structural analog and the best starting template.

---

## Sources

- Rubric: `docs/rubric.md`
- Detailed scores: `docs/comparison/scores.md`
- Patterns analysis: `docs/comparison/patterns.md`
- Anti-patterns analysis: `docs/comparison/antipatterns.md`
- Internal patterns: `docs/inventory/internal-similar-patterns.md`
- Schema reference: `../../skills/ralph-hats/references/schema.md`
- code-assist.yml: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/code-assist.yml
- autoresearch.yml: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/autoresearch.yml
- debug.yml: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/debug.yml
- research.yml: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/research.yml
- wave-review.yml: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/wave-review.yml
- pdd-to-code-assist.yml: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/pdd-to-code-assist.yml
- ralph.reviewer.yml: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.reviewer.yml
- CEO Suite Gist: https://gist.github.com/mikeyobrien/b15d22d7979ecae7cdd3f8f9e34d7337
- ElcidRalph feature-dev-e2e.yml: https://code.amazon.com/packages/ElcidRalph/blobs/mainline/--/frontend-dev-hats/hats/feature-dev-e2e.yml
- cr-comment-actioner.yml: https://code.amazon.com/packages/PcadWiki/blobs/mainline/--/skills/cr-auto-action/hats/cr-comment-actioner.yml
