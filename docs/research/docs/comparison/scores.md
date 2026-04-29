# Hat Collection Scores

> **📸 Snapshot — 2026-04-21.** This document is a point-in-time research artifact captured on 2026-04-21. It is not actively maintained. External sources (GitHub repos, Amazon-internal packages) may have changed since. Scores, links, and findings reflect the state of the world on that date.

## Summary Table

| # | Collection | C1 Topology | C2 Trigger | C3 Instructions | C4 Backpressure | C5 Completion (×1.5) | C6 Error | C7 Backend | C8 Focus | Total | Label |
|---|-----------|:-----------:|:----------:|:---------------:|:---------------:|:--------------------:|:--------:|:----------:|:--------:|:-----:|:------|
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

## Detailed Scoring Rationale

### 1. `presets/code-assist.yml` — 23.5/25.5 (Exemplary)

| Criterion | Score | Evidence |
|-----------|:-----:|----------|
| C1 Topology | 3 | `starting_event: "build.start"`, `completion_promise: "LOOP_COMPLETE"`, `events:` section not needed because the 4-hat linear flow is self-documenting: planner→builder→critic→finalizer. Event names are semantic (`tasks.ready`, `review.ready`, `review.passed`, `queue.advance`). Source: [code-assist.yml L30–35](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/code-assist.yml) |
| C2 Trigger | 3 | Each hat has distinct triggers with no overlap. `default_publishes` set on every hat. Topic names follow `noun.state` convention consistently. Builder handles three rejection paths (`tasks.ready`, `review.rejected`, `finalization.failed`) — all distinct routing. Source: triggers/publishes declarations in each hat definition |
| C3 Instructions | 3 | Instructions are extensive but concrete: step-by-step numbered processes, explicit constraints ("You MUST NOT"), acceptance criteria, confidence protocol, file layout specs. Builder instructions include TDD cycle (RED→GREEN→REFACTOR) with explicit verification steps. Source: builder `instructions` field |
| C4 Backpressure | 3 | Critic has `default_publishes: "review.rejected"` (pessimistic default). Explicit rejection criteria in instructions. Rejection routes back to Builder. Finalizer provides a second gate with `default_publishes: "finalization.failed"`. Two-layer gating with concrete rejection semantics. Source: critic and finalizer hat definitions |
| C5 Completion | 3 | Single Finalizer hat owns `LOOP_COMPLETE`. All paths converge through `review.passed` → Finalizer. Finalizer checks runtime task queue exhaustion before emitting completion. Step-wave pattern ensures bounded iteration. Source: finalizer instructions "Decide one of: queue.advance / finalization.failed / LOOP_COMPLETE" |
| C6 Error | 2 | `build.blocked` event exists for Builder failures. No explicit `.exhausted` or `.failed` recovery hat, but `finalization.failed` creates a retry loop. Missing: dedicated recovery for repeated failures or hat exhaustion. Source: builder `publishes: ["review.ready", "build.blocked"]` |
| C7 Backend | 2 | Uses `backend: "kiro"` globally. No per-hat differentiation. However, the design acknowledges this is intentional for a single-model workflow. No `backend_args` tuning. Source: `cli.backend: "kiro"` at top level |
| C8 Focus | 3 | 4 hats, each with a clearly distinct role (plan, build, review, gate). Single workflow: TDD implementation. Cannot remove any hat without breaking the topology. Source: hat count and role descriptions |

### 2. `presets/autoresearch.yml` — 21.5/25.5 (Exemplary)

| Criterion | Score | Evidence |
|-----------|:-----:|----------|
| C1 Topology | 3 | Cyclic topology clearly documented: strategist→implementer→benchmarker→judge→evaluator→strategist. `starting_event: "experiment.start"`, `completion_promise: "LOOP_COMPLETE"`. Event names are semantic and predictable (`experiment.planned`, `experiment.ready`, `experiment.measured`, `experiment.scored`, `experiment.evaluated`). Source: [autoresearch.yml event_loop](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/autoresearch.yml) |
| C2 Trigger | 3 | Perfect 1:1 routing. Each event triggers exactly one hat. `default_publishes` set on every hat. Topic names follow `experiment.{state}` namespace. Source: triggers/publishes in each hat |
| C3 Instructions | 3 | Highly concrete: specifies exact `autoresearch.md` format, JSONL schema, git commands, decision criteria (KEEP/DISCARD/CRASH), scoring formulas. Each hat has explicit "Constraints" section with MUST/MUST NOT rules. Source: evaluator instructions with decision matrix |
| C4 Backpressure | 2 | Judge scores experiments and can fail them (`judge_pass: false`). Evaluator discards failed experiments. However, there's no explicit "rejection back to producer" loop — discarded experiments just trigger a new strategy. The feedback is implicit via `autoresearch.md` "What's Been Tried" section. Source: evaluator KEEP/DISCARD logic |
| C5 Completion | 3 | Strategist owns `LOOP_COMPLETE` when ideas are exhausted. Evaluator can also emit it if stuck. Clear bounded iteration via `max_consecutive_failures: 5`. All paths converge through the evaluate→strategize cycle. Source: strategist "When Ideas Run Dry" section |
| C6 Error | 2 | `experiment.blocked` event handles implementer failures. Evaluator handles benchmark crashes. Missing: no dedicated recovery hat for repeated failures or orchestrator-level issues. Source: implementer `publishes: ["experiment.ready", "experiment.blocked"]` |
| C7 Backend | 1 | Single `backend: "claude"` globally. No per-hat differentiation despite clear opportunities (cheap model for benchmarker, expensive for strategist). Source: `cli.backend: "claude"` |
| C8 Focus | 3 | 5 hats with perfectly distinct roles in a single experiment loop. Each hat has one job. Cannot remove any without breaking the cycle. Source: hat descriptions and topology |

### 3. `presets/debug.yml` — 20.5/25.5 (Strong)

| Criterion | Score | Evidence |
|-----------|:-----:|----------|
| C1 Topology | 3 | Scientific method flow: investigator→tester→(confirm/reject)→fixer→verifier→complete. `starting_event: "debug.start"`, `completion_promise: "DEBUG_COMPLETE"`. `required_events` lists the full chain. Event names map to scientific method steps. Source: [debug.yml event_loop](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/debug.yml) |
| C2 Trigger | 3 | Each event routes to exactly one hat. Investigator handles multiple triggers but they represent distinct phases (start, rejected, confirmed, verified). `default_publishes` set on fixer and verifier for pessimistic defaults. Source: hat trigger declarations |
| C3 Instructions | 3 | Concrete scientific method: "Form exactly one falsifiable hypothesis", explicit trigger handling per event type, real harness requirements (Playwright/tmux), numbered process steps. Constraints sections with ❌ DON'T lists. Source: investigator and tester instructions |
| C4 Backpressure | 2 | Tester can reject hypotheses (`hypothesis.rejected` routes back to investigator). Verifier can fail fixes (`fix.failed` routes back to fixer). However, no explicit rejection count or exhaustion handling for repeated hypothesis failures. Source: tester `publishes: ["hypothesis.confirmed", "hypothesis.rejected"]` |
| C5 Completion | 3 | Single path: `fix.verified` → investigator → `DEBUG_COMPLETE`. Investigator is the sole emitter of completion. All branches (reject loops) converge back to investigator. Source: investigator "On fix.verified" section |
| C6 Error | 1 | `fix.blocked` event exists for fixer failures. No `.exhausted` handling. No recovery for repeated hypothesis rejections (could loop indefinitely). Source: fixer `publishes: ["fix.applied", "fix.blocked"]` |
| C7 Backend | 1 | Single `backend: "claude"` globally. No per-hat differentiation. Source: `cli.backend: "claude"` |
| C8 Focus | 3 | 4 hats, each mapping to a scientific method step. Single workflow: bug investigation. Laser-focused. Source: hat count and descriptions |

### 4. `presets/research.yml` — 19.5/25.5 (Strong)

| Criterion | Score | Evidence |
|-----------|:-----:|----------|
| C1 Topology | 3 | Minimal 2-hat ping-pong: researcher↔synthesizer. `starting_event: "research.start"`, `completion_promise: "RESEARCH_COMPLETE"`. Event names are clear: `research.finding`, `research.followup`. Source: [research.yml event_loop](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/research.yml) |
| C2 Trigger | 2 | Researcher triggers on both `research.start` and `research.followup` — reasonable but means two entry points to the same hat. No `default_publishes` on synthesizer (publishes both `research.followup` and `RESEARCH_COMPLETE`). Source: researcher triggers |
| C3 Instructions | 3 | Extremely detailed: step-wave research plan, runtime task discipline, numbered trigger handling, explicit DON'T lists, scratchpad format specification. Source: researcher instructions (very long, concrete) |
| C4 Backpressure | 2 | Synthesizer can reject shallow conclusions and request followup via `research.followup`. However, no explicit rejection criteria — it's judgment-based. No bounded iteration on followup loops. Source: synthesizer "If meaningful gaps remain" section |
| C5 Completion | 3 | Single synthesizer hat owns `RESEARCH_COMPLETE`. Clear rule: "emit RESEARCH_COMPLETE only when the active research task is closed, all planned research waves are complete, and no research follow-up tasks remain open." Source: synthesizer instructions |
| C6 Error | 1 | No error events. No `.exhausted` handling. If researcher gets stuck, the loop relies on `max_iterations: 20` to terminate. Source: absence of error events in publishes |
| C7 Backend | 1 | Single `backend: "claude"` globally. Source: `cli.backend: "claude"` |
| C8 Focus | 3 | 2 hats, minimal-viable-collection. Single workflow: research. Proves that tight discipline can work with minimal hat count. Source: hat count |

### 5. `presets/wave-review.yml` — 16.5/25.5 (Strong)

| Criterion | Score | Evidence |
|-----------|:-----:|----------|
| C1 Topology | 3 | Clear fan-out/fan-in: coordinator→(parallel reviewers)→synthesizer. `starting_event: "review.start"`, `completion_promise: "review.complete"`. Uses `ralph wave emit` for parallel dispatch. Source: [wave-review.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/wave-review.yml) |
| C2 Trigger | 3 | Perfect routing. Coordinator→`review.perspective`→Reviewer (`concurrency`:3, non-standard field)→`review.done`→Synthesizer. `default_publishes: "review.complete"` on synthesizer. Source: hat triggers |
| C3 Instructions | 2 | Coordinator instructions are concrete (dispatch examples with role descriptions). Reviewer instructions are adequate but generic ("Review thoroughly from your expert perspective"). Synthesizer has `disallowed_tools` for enforcement. Missing: explicit acceptance criteria for what constitutes a good review. Source: reviewer instructions |
| C4 Backpressure | 0 | No rejection mechanism. Reviews always flow forward. Synthesizer always emits `review.complete`. No feedback loop to re-review or reject poor findings. Fire-and-forget pipeline. Source: synthesizer only publishes `review.complete` |
| C5 Completion | 3 | Single synthesizer hat emits `review.complete` after aggregating all `review.done` events via `aggregate: mode: wait_for_all` (non-standard field). Clear, deterministic completion. Source: synthesizer aggregate config |
| C6 Error | 0 | No error handling. No timeout recovery. If a reviewer fails, the `aggregate` `timeout` (300s, non-standard fields) is the only safety net. No `.exhausted` or `.failed` events. Source: absence of error events |
| C7 Backend | 1 | Single `backend: "claude"` globally. Source: `cli.backend: "claude"` |
| C8 Focus | 3 | 3 hats, single workflow (parallel code review). Minimal and focused. Uses `concurrency` and `aggregate` (non-standard schema extensions) effectively. Source: hat count and topology |

### 6. `presets/pdd-to-code-assist.yml` — 16.0/25.5 (Strong)

| Criterion | Score | Evidence |
|-----------|:-----:|----------|
| C1 Topology | 2 | 11 hats with complex multi-phase flow: inquisitor↔architect→design_critic→explorer→planner→task_writer→builder↔critic→finalizer→validator→committer. `events:` metadata not present despite the complexity. Flow is traceable but requires careful reading of all 11 hat definitions. Source: [pdd-to-code-assist.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/pdd-to-code-assist.yml) |
| C2 Trigger | 2 | Most routing is 1:1, but builder triggers on 4 events (`tasks.ready`, `review.rejected`, `finalization.failed`, `validation.failed`) creating a complex fan-in. Task_writer triggers on both `plan.ready` and `queue.advance`. Some topic names are clear (`design.approved`) but the sheer number (15+ custom events) makes the namespace harder to follow. Source: builder triggers |
| C3 Instructions | 3 | Each hat has extremely detailed instructions with storage layout specs, process steps, constraints, and format templates. Given-When-Then acceptance criteria format. Confidence protocol shared across hats. Source: all hat instructions |
| C4 Backpressure | 3 | Three-layer gating: design_critic, critic, and validator each can reject. Validator has `default_publishes: "validation.failed"` (pessimistic). Critic has `default_publishes: "review.rejected"` (pessimistic). Design_critic has `default_publishes: "design.approved"` (optimistic). Explicit rejection criteria in each gate hat's instructions. Source: design_critic, critic, validator definitions |
| C5 Completion | 2 | `LOOP_COMPLETE` emitted by committer after validator passes. However, the path from start to completion crosses 11 hats with multiple potential dead-end risks (e.g., what if design_critic keeps rejecting? No bounded iteration). `required_events` lists 5 events but doesn't guarantee all paths reach them. Source: event_loop `required_events` |
| C6 Error | 1 | `build.blocked` exists for builder. No dedicated recovery hat. No `.exhausted` handling. If design_critic or validator keeps rejecting, the loop relies on `max_iterations: 150` as the only safety net. Source: absence of recovery events |
| C7 Backend | 1 | Single `backend: "claude"` globally. Clear opportunity missed: inquisitor/architect could use cheaper model, validator/committer could use cheaper model for mechanical tasks. Source: `cli.backend: "claude"` |
| C8 Focus | 1 | 11 hats spanning idea→design→research→plan→implement→review→validate→commit. Multiple distinct workflows crammed into one file. Could be decomposed into 2-3 smaller collections (design phase, implementation phase, validation phase). Source: hat count and scope |

### 7. `ralph.reviewer.yml` — 18.5/25.5 (Strong)

| Criterion | Score | Evidence |
|-----------|:-----:|----------|
| C1 Topology | 3 | Linear 4-hat pipeline: scoper→verifier→reviewer→synthesizer. `starting_event: "review.start"`, `completion_promise: "LOOP_COMPLETE"`. Event names are clear (`scope.ready`, `verification.done`, `review.done`). Source: [ralph.reviewer.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.reviewer.yml) |
| C2 Trigger | 3 | Perfect 1:1 routing. Each event triggers exactly one hat. `default_publishes: "review.done"` on reviewer, `default_publishes: "LOOP_COMPLETE"` on synthesizer. Source: hat triggers |
| C3 Instructions | 3 | Highly concrete: exact bash commands for git worktree setup, TUI verification with tmux, structured output formats, explicit DON'T lists. Scoper includes full worktree isolation pattern. Verifier has detailed TUI verification protocol. Source: scoper and verifier instructions |
| C4 Backpressure | 1 | Reviewer can emit `review.done` with verdict REQUEST_CHANGES, but this doesn't route back to any hat for fixes — it just gets reported in the final synthesis. The pipeline is effectively fire-and-forget with a verdict label. Source: reviewer only publishes `review.done` |
| C5 Completion | 3 | Single synthesizer hat emits `LOOP_COMPLETE`. All paths (including `review.blocked`) converge to synthesizer. Deterministic single-path completion. Source: synthesizer triggers `["review.done", "review.blocked"]` |
| C6 Error | 1 | `review.blocked` event exists (TUI verification unavailable). No other error handling. No recovery for build failures or git worktree issues. Source: verifier can emit `review.blocked` |
| C7 Backend | 1 | Single `backend: "claude"` globally. Source: `cli.backend: "claude"` |
| C8 Focus | 2 | 4 hats for code review. Focused on one workflow but the verifier hat is quite large (handles both test suite AND TUI verification — two distinct concerns). Could arguably split TUI verification into its own hat. Source: verifier instructions length |

### 8. CEO Suite Gist — 17.0/25.5 (Strong)

| Criterion | Score | Evidence |
|-----------|:-----:|----------|
| C1 Topology | 2 | Hub-and-spoke with chief_of_staff as central router to 7 specialist hats. `starting_event: "assistant.plan"`, `completion_promise: "assistant.complete"`. `events:` metadata present for recovery events. However, the routing logic is implicit in the chief_of_staff's instructions rather than declarative in the topology. Source: [CEO Suite gist](https://gist.github.com/mikeyobrien/b15d22d7979ecae7cdd3f8f9e34d7337) |
| C2 Trigger | 2 | Chief_of_staff triggers on 16 events — massive fan-in that makes routing hard to predict without reading instructions. Some events like `executor.done` and `dev.done` are semantically similar. No `default_publishes` on chief_of_staff (publishes 7 different events). Source: chief_of_staff triggers list |
| C3 Instructions | 2 | Chief_of_staff instructions are brief ("Keep momentum and involve the CEO only when decisions materially affect scope, cost, or behavior"). Specialist hats have adequate but short instructions. Confidence protocol shared via YAML anchors. Missing: explicit process steps for most specialists. Source: researcher, architect instructions |
| C4 Backpressure | 1 | Verifier can fail (`verify.failed` routes to chief_of_staff). However, the chief_of_staff decides what to do — no explicit rejection-to-producer loop. The gating is mediated through a human-in-the-loop (CEO approval) rather than automated backpressure. Source: verifier publishes, chief_of_staff routing |
| C5 Completion | 2 | Chief_of_staff owns `assistant.complete` but the completion criteria are vague ("all tasks are closed and CEO approves"). The `persistent: true` flag (non-standard field, not in schema.md) means the loop is designed to idle, not terminate — completion semantics are intentionally loose. Source: event_loop `persistent: true` |
| C6 Error | 3 | Dedicated Self-Healer hat with `max_activations: 3`. Triggers on `build.task.abandoned`, `*.exhausted`, `recovery.needed`. Implements ordered recovery strategy chain (rollback→skip→reduce scope→fallback→escalate). Publishes `recovery.applied`, `recovery.failed`, `recovery.escalate`. Best error handling of any collection. Source: healer hat definition |
| C7 Backend | 3 | Deliberate multi-model tiering: Codex as default backend (chief_of_staff, qa_tester) and explicit on executor/developer/verifier (code execution), OpenCode+Kimi for researcher/ux_designer (multimodal research). Two distinct backends with intentional differentiation — code-execution tasks use Codex, multimodal/research tasks use Kimi via OpenCode. `working_directory` (non-standard field, not in schema.md) scoped per hat. Source: `cli: backend: "codex"` at top level; researcher and ux_designer `backend: type: "opencode"` with `args: ["--model=ollama-cloud/kimi-k2.5:cloud"]` |
| C8 Focus | 1 | 9 hats spanning research, design, UX, implementation, QA, verification, and recovery. Multiple unrelated workflows (code dev, research, UX design) in one collection. The "CEO assistant" framing is too broad. Source: hat count and diverse responsibilities |

### 9. ElcidRalph `feature-dev-e2e.yml` — 17.0/25.5 (Strong)

| Criterion | Score | Evidence |
|-----------|:-----:|----------|
| C1 Topology | 3 | Full `events:` metadata block with descriptions for every custom topic (20 events documented). `starting_event: "work.start"`, `completion_promise: "LOOP_COMPLETE"`. Flow is traceable from the events block alone. Source: [ElcidRalph feature-dev-e2e.yml events block](https://code.amazon.com/packages/ElcidRalph/blobs/mainline/--/frontend-dev-hats/hats/feature-dev-e2e.yml) lines 23–63 |
| C2 Trigger | 2 | Builder triggers on 7 events (`design.ready`, `review.rejected`, `ux.rejected`, `debug.done`, `e2e.failed`, `visual.rejected`, `cr.fix.needed`) — large fan-in. Some events are semantically distinct rejection paths but all route to the same hat. `default_publishes` set on most hats. Source: builder triggers |
| C3 Instructions | 2 | Instructions are brief and action-oriented ("You are a fast planner. NEVER run git push."). Adequate for experienced users but lack the detailed process steps, constraints, and acceptance criteria seen in upstream presets. E2E tester has the most detailed instructions (cypress workflow). Source: planner, builder instructions |
| C4 Backpressure | 3 | Three review gates: ux_reviewer (with `max_activations: 3`), code_reviewer (with `max_activations: 3`), ux_verifier (with `max_activations: 2`). Each can reject back to builder. Bounded rejection via `max_activations`. Source: ux_reviewer, code_reviewer, ux_verifier definitions |
| C5 Completion | 2 | Planner emits `LOOP_COMPLETE` when no `[ ]` steps remain. However, the complex topology (10 hats, multiple rejection loops) creates potential dead-end risks if e2e or visual verification keeps failing beyond `max_activations`. No explicit exhaustion convergence. Source: planner instructions |
| C6 Error | 1 | `debug.needed` event exists for builder failures. `figma.blocked` for API rate limits. No dedicated recovery hat. No `.exhausted` handling beyond `max_activations` limits. Source: builder publishes, design_sync publishes |
| C7 Backend | 2 | E2E tester and UX verifier use `backend: type: "kiro-acp", agent: "gpu-frontend-pxt-dev"` — a specialized frontend agent. Other hats use the default. Intentional differentiation for domain-specific work. Source: e2e_tester and ux_verifier backend config |
| C8 Focus | 1 | 10 hats spanning planning, Figma sync, implementation, debugging, UX review, code review, E2E testing, visual verification, CR posting, and CR monitoring. Multiple distinct concerns (design sync, testing, CR management) in one file. Source: hat count and diverse responsibilities |

### 10. PcadWiki `cr-comment-actioner.yml` — 22.5/25.5 (Exemplary)

| Criterion | Score | Evidence |
|-----------|:-----:|----------|
| C1 Topology | 3 | Exhaustive event flow documentation in file header comments (paths A–G with full routing). `starting_event: "cr.start"`, `completion_promise: "LOOP_COMPLETE"`. `required_events` lists all intermediate events. Every retry loop is documented. Source: [PcadWiki cr-comment-actioner.yml](https://code.amazon.com/packages/PcadWiki/blobs/mainline/--/skills/cr-auto-action/hats/cr-comment-actioner.yml) lines 19–68 |
| C2 Trigger | 3 | Each hat has well-scoped triggers. Triager handles 4 entry points but each is a distinct re-classification scenario (documented in header). `default_publishes` set on every hat. Topic names follow clear conventions (`comments.classified`, `fixes.applied`, `build.passed`, `self_review.passed`). Source: hat trigger declarations |
| C3 Instructions | 3 | Triager instructions are extraordinarily detailed: exact bash commands, classification guidelines, scope awareness rules, scratchpad format with markdown template, multi-trigger handling (4 distinct trigger scenarios documented). Source: triager instructions (200+ lines) |
| C4 Backpressure | 3 | Multiple rejection loops: `build.failed`→Fixer, `self_review.failed`→Fixer, `dryrun.failed`→Fixer, `e2e.failed`→Fixer. Self-Reviewer runs 5-pass review before upload. Monitor polls DryRunBuild and loops back on failure. Real, functional backpressure at every stage. Source: retry loops documented in header comments |
| C5 Completion | 3 | Single Notifier hat emits `LOOP_COMPLETE` after Replier drafts replies. All 7 paths (A–G) converge to Replier→Notifier→LOOP_COMPLETE. Bounded iteration via `max_iterations: 200` and `max_runtime_seconds: 10800`. `idle_timeout_secs: 900` prevents stalls. Source: event flow paths in header |
| C6 Error | 3 | Comprehensive error handling: `build.failed`, `self_review.failed`, `dryrun.failed`, `e2e.failed` all route to Fixer for recovery. `upload.blocked.new_comments` and `upload.blocked.diff_changed` handle mid-loop interference. `replies.blocked.new_comments` handles late-arriving feedback. Watchdog for long builds (`loop.park`→`build.monitoring.resume`). Source: retry loops and blocked events in header |
| C7 Backend | 1 | No explicit `backend` overrides on any hat. Uses whatever the core config provides. Missed opportunity: triager (classification) could use a cheaper model, self-reviewer could use a different model for adversarial review. Source: absence of backend fields |
| C8 Focus | 2 | 9 hats but all serve a single workflow: processing CR reviewer comments. The scope is focused (CR automation) but the hat count is high. Some hats (Monitor, Notifier) are thin and could potentially be merged. However, each hat has a distinct responsibility in the pipeline. Source: hat count and descriptions |

## Sources

- `presets/code-assist.yml`: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/code-assist.yml
- `presets/autoresearch.yml`: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/autoresearch.yml
- `presets/debug.yml`: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/debug.yml
- `presets/research.yml`: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/research.yml
- `presets/wave-review.yml`: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/wave-review.yml
- `presets/pdd-to-code-assist.yml`: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/pdd-to-code-assist.yml
- `ralph.reviewer.yml`: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.reviewer.yml
- CEO Suite Gist: https://gist.github.com/mikeyobrien/b15d22d7979ecae7cdd3f8f9e34d7337
- ElcidRalph `feature-dev-e2e.yml`: https://code.amazon.com/packages/ElcidRalph/blobs/mainline/--/frontend-dev-hats/hats/feature-dev-e2e.yml
- PcadWiki `cr-comment-actioner.yml`: https://code.amazon.com/packages/PcadWiki/blobs/mainline/--/skills/cr-auto-action/hats/cr-comment-actioner.yml
- Rubric: docs/rubric.md (local)
- Schema reference: ../../../../skills/ralph-hats/references/schema.md
