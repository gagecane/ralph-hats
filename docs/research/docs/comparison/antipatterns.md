# Anti-Patterns in Low-Scoring Hat Collections

> **📸 Snapshot — 2026-04-21.** This document is a point-in-time research artifact captured on 2026-04-21. It is not actively maintained. External sources (GitHub repos, Amazon-internal packages) may have changed since. Scores, links, and findings reflect the state of the world on that date.

Anti-patterns observed across collections scoring ≤17.0: `pdd-to-code-assist.yml` (16.0), `wave-review.yml` (16.5), ElcidRalph `feature-dev-e2e.yml` (17.0), CEO Suite Gist (17.0). Supporting evidence from `ralph.reviewer.yml` (18.5) where applicable.

---

## 1. Kitchen-Sink Collection (Hat Sprawl)

Cramming multiple distinct workflows into a single hat file — design, implementation, testing, deployment, monitoring — produces collections with 9–11 hats where the event graph becomes too complex to reason about without external tooling. The topology is technically traceable but requires reading all hat definitions to understand routing, and the file becomes a maintenance burden where changes to one workflow risk breaking another. This anti-pattern directly harms Focus (C8) and indirectly harms Completion (C5) by creating dead-end risks in the complex graph.

**Examples:** `pdd-to-code-assist.yml` (11 hats spanning idea→design→research→plan→implement→review→validate→commit, scoring C8=1) and ElcidRalph `feature-dev-e2e.yml` (10 hats spanning planning, Figma sync, implementation, debugging, UX review, code review, E2E testing, visual verification, and CR management, scoring C8=1). The CEO Suite gist (9 hats spanning research, design, UX, implementation, QA, verification, and recovery, scoring C8=1) exhibits the same sprawl. Contrast with `code-assist.yml` (4 hats, C8=3) and `research.yml` (2 hats, C8=3) which each do one job well.

**Why it hurts:** Large collections create combinatorial routing complexity — `pdd-to-code-assist.yml` has 15+ custom events, making it impossible to predict flow from event names alone. They also resist decomposition: if the design phase needs a schema change, you risk breaking the implementation phase's assumptions. The `max_iterations: 150` safety net in `pdd-to-code-assist.yml` is a symptom — the author couldn't bound iteration analytically, so they set a high ceiling and hoped.

**Sources:**
- `pdd-to-code-assist.yml` (11 hats): https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/pdd-to-code-assist.yml
- ElcidRalph (10 hats): https://code.amazon.com/packages/ElcidRalph/blobs/mainline/--/frontend-dev-hats/hats/feature-dev-e2e.yml
- CEO Suite (9 hats): https://gist.github.com/mikeyobrien/b15d22d7979ecae7cdd3f8f9e34d7337

---

## 2. Fire-and-Forget Pipeline (No Backpressure)

A pipeline where work flows strictly forward with no rejection mechanism — every hat always passes its output to the next stage regardless of quality. Gate hats exist in name only (or don't exist at all), and the `default_publishes` is set to the pass event (optimistic) or omitted entirely. The system cannot self-correct; garbage in produces garbage out, and the only termination is `max_iterations` or a human noticing the output is wrong.

**Examples:** `wave-review.yml` scores C4=0 because the synthesizer always emits `review.complete` — there is no mechanism to reject a poor review and request re-review. Reviews flow forward unconditionally. `ralph.reviewer.yml` (C4=1) has a similar issue: the reviewer emits a verdict (REQUEST_CHANGES) but this doesn't route back to any hat for fixes — it's just a label in the final synthesis. The CEO Suite gist (C4=1) mediates backpressure through a human-in-the-loop (CEO approval) rather than automated rejection, making the system dependent on external intervention.

**Why it hurts:** Without backpressure, the loop cannot distinguish between "work is done well" and "work is done" — it always terminates in the same number of iterations regardless of output quality. This makes the `completion_promise` semantically weak: completion means "the pipeline ran" not "the pipeline produced acceptable output." In `wave-review.yml`, a reviewer that hallucinates findings will have those findings synthesized and reported as real.

**Sources:**
- `wave-review.yml` (no rejection): https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/wave-review.yml
- `ralph.reviewer.yml` (verdict without routing): https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.reviewer.yml
- CEO Suite (human-mediated only): https://gist.github.com/mikeyobrien/b15d22d7979ecae7cdd3f8f9e34d7337

---

## 3. Missing Error and Exhaustion Handling

Collections that define no recovery path for hat failures, build errors, or repeated rejections. When a hat gets stuck or an external tool fails, the only safety net is `max_iterations` or `max_runtime_seconds` — the loop burns through iterations doing nothing useful until it times out. No `.exhausted`, `.failed`, or `.blocked` events exist to route failures to a recovery hat or graceful termination.

**Examples:** `wave-review.yml` (C6=0) has zero error handling — if a reviewer hat fails, the only safety net is a 300-second `timeout` on the aggregate (a non-standard field). No `.exhausted` or `.failed` events exist. `pdd-to-code-assist.yml` (C6=1) has only `build.blocked` for the builder; if `design_critic` or `validator` keeps rejecting, the loop relies entirely on `max_iterations: 150`. ElcidRalph (C6=1) has `debug.needed` and `figma.blocked` but no dedicated recovery hat and no `.exhausted` handling beyond `max_activations` limits. `ralph.reviewer.yml` (C6=1) has only `review.blocked` for TUI unavailability — no recovery for build failures or git worktree issues.

**Why it hurts:** Without explicit error routing, failures manifest as silent iteration waste. A loop that hits `max_iterations` after 100 fruitless retries gives the user no signal about *what* failed or *when* — they discover the problem only after the full timeout elapses. Contrast with `cr-comment-actioner.yml` (C6=3) which routes `build.failed`, `self_review.failed`, `dryrun.failed`, and `e2e.failed` all to a dedicated Fixer hat, and the CEO Suite's Self-Healer hat (C6=3) which implements an ordered recovery strategy chain. These collections fail fast and informatively.

**Sources:**
- `wave-review.yml` (no error events): https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/wave-review.yml
- `pdd-to-code-assist.yml` (only `build.blocked`): https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/pdd-to-code-assist.yml
- `cr-comment-actioner.yml` (comprehensive error routing, for contrast): https://code.amazon.com/packages/PcadWiki/blobs/mainline/--/skills/cr-auto-action/hats/cr-comment-actioner.yml
- CEO Suite Self-Healer (for contrast): https://gist.github.com/mikeyobrien/b15d22d7979ecae7cdd3f8f9e34d7337

---

## 4. Mega-Fan-In Triggers (Router-Hat Overload)

A single hat triggers on 7–16 events, becoming a de facto router that must contain complex conditional logic in its instructions to handle each trigger differently. The hat's behavior becomes unpredictable because the LLM must parse which trigger activated it and branch accordingly — a task that grows unreliable as the trigger count increases. The routing logic that should be declarative in the topology is instead buried in prose instructions.

**Examples:** The CEO Suite's `chief_of_staff` triggers on 16 events (C2=2) — it must route to 7 different specialists based on which event fired, but this routing logic lives in brief instructions ("Keep momentum and involve the CEO only when decisions materially affect scope, cost, or behavior") rather than in the event topology. ElcidRalph's `builder` triggers on 7 events (C2=2) — `design.ready`, `review.rejected`, `ux.rejected`, `debug.done`, `e2e.failed`, `visual.rejected`, `cr.fix.needed` — all semantically distinct rejection paths that route to the same hat. `pdd-to-code-assist.yml`'s builder also triggers on 4 events with distinct semantics (C2=2).

**Why it hurts:** Each additional trigger is a branch the LLM must handle correctly in its instructions. At 7+ triggers, the instructions either become a massive conditional tree (hard to maintain, easy to hallucinate wrong branches) or stay brief and hope the LLM infers the right behavior (unreliable). The CEO Suite's chief_of_staff has brief instructions despite 16 triggers — it's relying on the LLM to "figure it out." This is the opposite of the high-scoring pattern where each hat has 1–2 triggers with unambiguous semantics.

**Sources:**
- CEO Suite chief_of_staff (16 triggers): https://gist.github.com/mikeyobrien/b15d22d7979ecae7cdd3f8f9e34d7337
- ElcidRalph builder (7 triggers): https://code.amazon.com/packages/ElcidRalph/blobs/mainline/--/frontend-dev-hats/hats/feature-dev-e2e.yml
- `pdd-to-code-assist.yml` builder (4 triggers): https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/pdd-to-code-assist.yml

---

## Summary

| # | Anti-Pattern | Seen In | Primary Rubric Impact | Inverse of Pattern |
|---|-------------|---------|----------------------|-------------------|
| 1 | Kitchen-sink collection | pdd-to-code-assist, ElcidRalph, CEO Suite | C8 Focus, C5 Completion | #6 Minimal hat count |
| 2 | Fire-and-forget pipeline | wave-review, ralph.reviewer, CEO Suite | C4 Backpressure | #1 Pessimistic `default_publishes` |
| 3 | Missing error/exhaustion handling | wave-review, pdd-to-code-assist, ElcidRalph, ralph.reviewer | C6 Error | (no direct inverse — only 2 collections score 3) |
| 4 | Mega-fan-in triggers | CEO Suite, ElcidRalph, pdd-to-code-assist | C2 Trigger, C1 Topology | #3 Semantic `noun.state` naming + #6 Minimal hat count |

## Sources

- docs/comparison/scores.md (local)
- docs/comparison/patterns.md (local)
- Schema reference: ../../../../skills/ralph-hats/references/schema.md
- `pdd-to-code-assist.yml`: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/pdd-to-code-assist.yml
- `wave-review.yml`: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/wave-review.yml
- ElcidRalph `feature-dev-e2e.yml`: https://code.amazon.com/packages/ElcidRalph/blobs/mainline/--/frontend-dev-hats/hats/feature-dev-e2e.yml
- `ralph.reviewer.yml`: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.reviewer.yml
- CEO Suite Gist: https://gist.github.com/mikeyobrien/b15d22d7979ecae7cdd3f8f9e34d7337
- `cr-comment-actioner.yml`: https://code.amazon.com/packages/PcadWiki/blobs/mainline/--/skills/cr-auto-action/hats/cr-comment-actioner.yml
