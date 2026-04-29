# Recurring Patterns in High-Scoring Hat Collections

> **📸 Snapshot — 2026-04-21.** This document is a point-in-time research artifact captured on 2026-04-21. It is not actively maintained. External sources (GitHub repos, Amazon-internal packages) may have changed since. Scores, links, and findings reflect the state of the world on that date.

Patterns observed across collections scoring ≥19.5 (Exemplary/Strong): `code-assist.yml` (23.5), `cr-comment-actioner.yml` (22.5), `autoresearch.yml` (21.5), `debug.yml` (20.5), `research.yml` (19.5).

---

## 1. Pessimistic `default_publishes` on Gate Hats

Gate/reviewer hats set `default_publishes` to the rejection event rather than the pass event, ensuring that if the LLM fails to explicitly publish, the system defaults to "not approved." This creates real backpressure — the loop retries rather than silently passing broken work through.

**Example:** In `code-assist.yml`, the critic hat uses `default_publishes: "review.rejected"` and the finalizer uses `default_publishes: "finalization.failed"`. The builder must earn a pass; silence means rejection. In `debug.yml`, the fixer uses `default_publishes: "fix.blocked"` and the verifier uses `default_publishes: "fix.failed"`.

**Sources:**
- Critic/finalizer in `code-assist.yml`: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/code-assist.yml
- Fixer/verifier in `debug.yml`: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/debug.yml

---

## 2. Single-Owner Completion (One Hat Emits `completion_promise`)

High-scoring collections designate a primary hat as the owner of `completion_promise`, with all normal event paths converging to that single hat for termination. When a secondary hat also lists `completion_promise` in its `publishes`, it does so only as a last-resort escape hatch under explicitly different conditions — not as a normal termination path.

**Example:** In `research.yml`, only the synthesizer emits `RESEARCH_COMPLETE` — the researcher never self-terminates, ensuring all findings pass through synthesis before the loop ends. In `cr-comment-actioner.yml`, only the notifier emits `LOOP_COMPLETE` — all paths (fixable, reply-only, nothing-to-do) converge to the notifier for a Slack summary before completion. In `code-assist.yml`, only the finalizer emits `LOOP_COMPLETE` — the builder and critic cannot short-circuit the loop. In `autoresearch.yml`, the strategist is the primary owner of `LOOP_COMPLETE` (emitting when ideas are exhausted), while the evaluator has it as a secondary escape hatch (emitting only "if every remaining experiment crashes and the loop is stuck") — but the normal cycle always routes back through the strategist.

**Sources:**
- Synthesizer as sole completer: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/research.yml
- Notifier as sole completer: https://code.amazon.com/packages/PcadWiki/blobs/mainline/--/skills/cr-auto-action/hats/cr-comment-actioner.yml (line 2183: `publishes: ["LOOP_COMPLETE"]`)
- Finalizer as sole completer: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/code-assist.yml
- Strategist as primary completer with evaluator escape hatch: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/autoresearch.yml (strategist `publishes: ["experiment.planned", "LOOP_COMPLETE"]`; evaluator `publishes: ["experiment.evaluated", "LOOP_COMPLETE"]` with instruction "emit LOOP_COMPLETE only if every remaining experiment crashes and the loop is stuck")

---

## 3. Semantic `noun.state` Event Namespacing

High-scoring collections consistently name events using a `noun.state` convention (e.g., `review.passed`, `experiment.scored`, `hypothesis.confirmed`) rather than verbs or generic names. This makes the topology self-documenting — you can read the event names alone and understand the flow without consulting instructions. The namespace groups related events (all `experiment.*` events belong to the autoresearch cycle) and the state suffix communicates outcome.

**Example:** `debug.yml` uses `hypothesis.test`, `hypothesis.confirmed`, `hypothesis.rejected`, `fix.applied`, `fix.verified`, `fix.failed` — the entire flow reads as a sentence. Contrast with the CEO Suite gist which uses `executor.done` and `dev.done` (ambiguous — done how? done with what?), scoring lower on topology clarity.

**Sources:**
- Debug event names: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/debug.yml
- Autoresearch event names: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/autoresearch.yml
- Code-assist event names: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/code-assist.yml

---

## 4. Step-Wave Queue with Bounded Iteration

Rather than processing all work items at once, high-scoring collections decompose work into discrete steps and process one step per loop iteration. A planner/coordinator materializes the current step, a worker executes it, a gate verifies it, and only then does the loop advance to the next step. This bounds the blast radius of failures (only one step is lost on rejection) and gives the gate hat a tractable unit to review.

**Example:** `code-assist.yml` implements this explicitly: the planner decomposes work into numbered steps, the builder implements only the current step, the critic reviews only that step, and the finalizer either advances the queue (`queue.advance` → planner picks up next step) or emits `LOOP_COMPLETE` when all steps are done. `cr-comment-actioner.yml` uses a similar pattern where the triager classifies one batch of comments, the fixer addresses them, and the monitor loops back for the next batch.

**Sources:**
- Step-wave in code-assist: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/code-assist.yml (planner "materializes only current step's runtime tasks")
- Batch processing in cr-comment-actioner: https://code.amazon.com/packages/PcadWiki/blobs/mainline/--/skills/cr-auto-action/hats/cr-comment-actioner.yml (triager classifies → fixer addresses → monitor loops)

---

## 5. Separation of Investigation from Action

High-scoring collections enforce a strict phase boundary: hats that investigate/analyze are forbidden from modifying state, and hats that modify state receive their instructions from the investigation phase. This prevents the common failure mode where an LLM "fixes" something it hasn't fully understood, and makes rejection cheaper (no rollback needed for investigation-only work).

**Example:** In `debug.yml`, the investigator hat's DON'T list states "❌ Change code during investigation phase" — it only forms hypotheses. The tester hat only runs experiments (read-only verification). Only the fixer hat is allowed to modify code, and only after a hypothesis is confirmed. In `ralph.reviewer.yml`, the scoper and verifier hats operate in a git worktree (read-only isolation) before the reviewer hat produces its verdict.

**Sources:**
- Investigator constraint ("❌ Change code during investigation phase"): https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/debug.yml
- Git worktree isolation in reviewer: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.reviewer.yml
- Triager (classify-only, `disallowed_tools: ["edit", "write"]`) vs Fixer (modify) separation: https://code.amazon.com/packages/PcadWiki/blobs/mainline/--/skills/cr-auto-action/hats/cr-comment-actioner.yml (line 107)

---

## 6. Minimal Hat Count with Distinct Roles (3–5 Hats)

The highest-scoring collections use 2–5 hats where each hat has a single, non-overlapping responsibility. No hat can be removed without breaking the topology. This keeps the event graph simple enough to reason about, reduces the chance of routing ambiguity, and makes each hat's instructions shorter and more focused. Collections that exceed 6 hats consistently score lower on Focus (C8) and often on Topology (C1).

**Example:** `research.yml` (19.5) achieves strong scores with just 2 hats: researcher (gather) and synthesizer (judge/complete). `code-assist.yml` (23.5) uses 4 hats: planner (decompose), builder (implement), critic (gate), finalizer (advance/complete). Each hat maps to exactly one verb. Contrast with `pdd-to-code-assist.yml` (16.0) which uses 11 hats and scores 1/3 on Focus.

**Sources:**
- 2-hat minimal collection: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/research.yml
- 4-hat focused collection: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/code-assist.yml
- 4-hat debug collection: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/debug.yml

---

## 7. Exhaustive Event-Flow Documentation in File Header

The top-scoring collections document their event topology either through an `events:` metadata block (with `description` per topic, and optionally `on_trigger`/`on_publish` fields per the schema) or through structured header comments that enumerate all possible paths. This makes the collection self-documenting without requiring `ralph hats graph` and serves as a contract that reviewers can verify against the actual hat definitions.

**Example:** `cr-comment-actioner.yml` (22.5) includes a header comment block documenting 7 distinct paths (A–G) with full routing for each, including retry loops and blocked-state handling (lines 19–68). The ElcidRalph `feature-dev-e2e.yml` collection (17.0) uses a full `events:` block with `description` fields for all 19 custom topics (lines 23–63), making the topology readable without tracing triggers/publishes across hats — this is the primary reason it scores 3/3 on Topology despite its complexity.

**Sources:**
- Header comment paths A–G: https://code.amazon.com/packages/PcadWiki/blobs/mainline/--/skills/cr-auto-action/hats/cr-comment-actioner.yml (lines 19–68)
- ElcidRalph `events:` block with `description` fields: https://code.amazon.com/packages/ElcidRalph/blobs/mainline/--/frontend-dev-hats/hats/feature-dev-e2e.yml (lines 23–63)
- Schema support for `events:` metadata: ../../../../skills/ralph-hats/references/schema.md

---

## Summary

| # | Pattern | Seen In | Primary Rubric Impact |
|---|---------|---------|----------------------|
| 1 | Pessimistic `default_publishes` | code-assist, debug | C4 Backpressure |
| 2 | Single-owner completion | All 5 top collections | C5 Completion |
| 3 | Semantic `noun.state` naming | code-assist, autoresearch, debug | C1 Topology, C2 Trigger |
| 4 | Step-wave bounded iteration | code-assist, cr-comment-actioner | C4 Backpressure, C5 Completion |
| 5 | Investigation/action separation | debug, ralph.reviewer, cr-comment-actioner | C3 Instructions, C4 Backpressure |
| 6 | Minimal hat count (3–5) | research, code-assist, debug | C8 Focus, C1 Topology |
| 7 | Exhaustive flow documentation | cr-comment-actioner, ElcidRalph | C1 Topology |

## Sources

- docs/comparison/scores.md (local)
- Schema reference: ../../../../skills/ralph-hats/references/schema.md
- code-assist.yml: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/code-assist.yml
- autoresearch.yml: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/autoresearch.yml
- debug.yml: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/debug.yml
- research.yml: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/research.yml
- cr-comment-actioner.yml: https://code.amazon.com/packages/PcadWiki/blobs/mainline/--/skills/cr-auto-action/hats/cr-comment-actioner.yml
- ralph.reviewer.yml: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.reviewer.yml
- ElcidRalph feature-dev-e2e.yml: https://code.amazon.com/packages/ElcidRalph/blobs/mainline/--/frontend-dev-hats/hats/feature-dev-e2e.yml
