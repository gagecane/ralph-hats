# GitHub Upstream Presets Inventory

> **📸 Snapshot — 2026-04-21.** This document is a point-in-time research artifact captured on 2026-04-21. It is not actively maintained. External sources (GitHub repos, Amazon-internal packages) may have changed since. Scores, links, and findings reflect the state of the world on that date.

Source: `mikeyobrien/ralph-orchestrator` — `presets/` directory on `main` branch.

## Top-Level Preset Collections

### 1. autoresearch.yml

| Field | Value |
|-------|-------|
| Source URL | https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/autoresearch.yml |
| Hat count | 5 |
| Hat keys | `strategist`, `implementer`, `benchmarker`, `judge`, `evaluator` |
| `starting_event` | `experiment.start` |
| `completion_promise` | `LOOP_COMPLETE` |
| Backend | `claude` |
| `max_iterations` | 500 |
| `max_runtime_seconds` | 28800 (8h) |
| `required_events` | `experiment.scored`, `experiment.evaluated` |
| Notable fields | `max_consecutive_failures: 5`, `idle_timeout_secs: 300`, `checkpoint_interval: 5`, `guardrails` list, `core.specs_dir` |

**Event topology:** `experiment.start` → strategist → `experiment.planned` → implementer → `experiment.ready` → benchmarker → `experiment.measured` → judge → `experiment.scored` → evaluator → `experiment.evaluated` → (loops back to strategist) or `LOOP_COMPLETE`. Also: implementer may emit `experiment.blocked` → strategist.

**Notes:** Autonomous experiment loop inspired by karpathy/autoresearch. Runs until interrupted or ideas exhausted. Uses `autoresearch.md` and `autoresearch.jsonl` for persistent state. Judge hat uses LLM-as-judge scoring with configurable rubric and weight modes (`gate`, `weighted`, `tiebreak`). Evaluator commits on KEEP, reverts on DISCARD.

---

### 2. code-assist.yml

| Field | Value |
|-------|-------|
| Source URL | https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/code-assist.yml |
| Hat count | 4 |
| Hat keys | `planner`, `builder`, `critic`, `finalizer` |
| `starting_event` | `build.start` |
| `completion_promise` | `LOOP_COMPLETE` |
| Backend | `kiro` |
| `max_iterations` | 100 |
| `max_runtime_seconds` | 14400 (4h) |
| `required_events` | `review.passed` |
| Notable fields | `checkpoint_interval: 5`, `prompt_mode: "arg"`, `guardrails` list with confidence protocol |

**Event topology:** `build.start` → planner → `tasks.ready` → builder → `review.ready` → critic → `review.passed` / `review.rejected`. On pass: finalizer → `queue.advance` (back to planner) or `LOOP_COMPLETE`. On reject: builder retries. Also: builder may emit `build.blocked`; finalizer may emit `finalization.failed` → builder.

**Notes:** Default implementation workflow. Adaptive entry point (PDD output, code task file, or rough description). Step-wave queue pattern: planner owns decomposition into numbered steps, materializes only current step's runtime tasks. Builder follows strict TDD (RED → GREEN → REFACTOR). Critic is adversarial fresh-eyes reviewer. Finalizer is whole-prompt gate checking all steps complete.

---

### 3. debug.yml

| Field | Value |
|-------|-------|
| Source URL | https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/debug.yml |
| Hat count | 4 |
| Hat keys | `investigator`, `tester`, `fixer`, `verifier` |
| `starting_event` | `debug.start` |
| `completion_promise` | `DEBUG_COMPLETE` |
| Backend | `claude` |
| `max_iterations` | 30 |
| `max_runtime_seconds` | 7200 (2h) |
| `required_events` | `hypothesis.test`, `hypothesis.confirmed`, `fix.applied`, `fix.verified` |
| Notable fields | `core.specs_dir: "./specs/"` |

**Event topology:** `debug.start` → investigator → `hypothesis.test` → tester → `hypothesis.confirmed` / `hypothesis.rejected`. On confirmed: investigator → `fix.propose` → fixer → `fix.applied` → verifier → `fix.verified` → investigator → `DEBUG_COMPLETE`. On rejected: loops back to investigator. Fixer may emit `fix.blocked`; verifier may emit `fix.failed` → fixer.

**Notes:** Scientific method for debugging. Follows hypothesize → test → narrow down cycle. Investigator explicitly forbidden from editing code during investigation phase. Tester designs falsifiable experiments. Fixer implements minimal fix + regression test. Verifier re-runs original repro path. Uses `default_publishes` on fixer (`fix.blocked`) and verifier (`fix.failed`) for pessimistic defaults.

---

### 4. research.yml

| Field | Value |
|-------|-------|
| Source URL | https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/research.yml |
| Hat count | 2 |
| Hat keys | `researcher`, `synthesizer` |
| `starting_event` | `research.start` |
| `completion_promise` | `RESEARCH_COMPLETE` |
| Backend | `claude` |
| `max_iterations` | 20 |
| `max_runtime_seconds` | 3600 (1h) |
| `required_events` | `research.finding` |
| Notable fields | `core.specs_dir: ".agents/scratchpad/"` |

**Event topology:** `research.start` → researcher → `research.finding` → synthesizer → `research.followup` (back to researcher) or `RESEARCH_COMPLETE`.

**Notes:** Read-only exploration. No code changes, no commits. Uses step-wave research plan with numbered question groups. Researcher gathers 3–6 evidence points per wave then emits. Synthesizer decides if gaps remain (followup) or question is answered (complete). Emphasizes high-fidelity evidence via real harnesses (Playwright, tmux, CLI).

---

### 5. review.yml

| Field | Value |
|-------|-------|
| Source URL | https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/review.yml |
| Hat count | 3 |
| Hat keys | `reviewer`, `analyzer`, `closer` |
| `starting_event` | `review.start` |
| `completion_promise` | `REVIEW_COMPLETE` |
| Backend | `claude` |
| `max_iterations` | 15 |
| `max_runtime_seconds` | 3600 (1h) |
| `required_events` | `review.section`, `analysis.complete` |
| Notable fields | `core.specs_dir: ".agents/scratchpad/"` |

**Event topology:** `review.start` → reviewer → `review.section` → analyzer → `analysis.complete` → closer → `review.followup` (back to reviewer for next risk area) or `REVIEW_COMPLETE`.

**Notes:** Staged adversarial code review. Reviewer does bounded primary pass identifying top risk areas. Analyzer performs deep adversarial analysis on one risk at a time. Closer decides if more waves needed or review is complete. Step-wave pattern: only one deep-analysis wave open at a time. Output format: Critical Issues / Suggestions / Nitpicks / Positive Notes.

---

### 6. wave-review.yml

| Field | Value |
|-------|-------|
| Source URL | https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/wave-review.yml |
| Hat count | 3 |
| Hat keys | `coordinator`, `reviewer`, `synthesizer` |
| `starting_event` | `review.start` |
| `completion_promise` | `review.complete` |
| Backend | `claude` |
| `max_iterations` | 20 |
| `max_runtime_seconds` | 3600 (1h) |
| `required_events` | (none specified) |
| Notable fields | `concurrency: 3` on reviewer hat, `timeout: 600` on reviewer, `aggregate: { mode: wait_for_all, timeout: 300 }` on synthesizer, `disallowed_tools` on synthesizer |

**Event topology:** `review.start` → coordinator → (wave emit) multiple `review.perspective` → reviewer (×3 parallel) → `review.done` → synthesizer (waits for all) → `review.complete`.

**Notes:** Parallel specialized review using `ralph wave emit`. Coordinator dispatches 2+ specialized reviewers (e.g., Rust, Frontend, Docs, Security) as a wave. Reviewers run concurrently (concurrency: 3). Synthesizer aggregates all findings after all reviewers complete. Uses `disallowed_tools: ["Read", "Glob", "Grep", "Edit"]` on synthesizer to force pure aggregation. Demonstrates fan-out/fan-in pattern.

---

### 7. pdd-to-code-assist.yml

| Field | Value |
|-------|-------|
| Source URL | https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/pdd-to-code-assist.yml |
| Hat count | 11 |
| Hat keys | `inquisitor`, `architect`, `design_critic`, `explorer`, `planner`, `task_writer`, `builder`, `critic`, `finalizer`, `validator`, `committer` |
| `starting_event` | `design.start` |
| `completion_promise` | `LOOP_COMPLETE` |
| Backend | `claude` |
| `max_iterations` | 150 |
| `max_runtime_seconds` | 14400 (4h) |
| `required_events` | `design.approved`, `plan.ready`, `tasks.ready`, `implementation.ready`, `validation.passed` |
| Notable fields | `checkpoint_interval: 5`, `prompt_mode: "arg"`, `guardrails` list with confidence protocol and source preservation |

**Event topology:** `design.start` → inquisitor ↔ architect (Q&A loop via `question.asked` / `answer.proposed`) → `requirements.complete` → architect → `design.drafted` → design_critic → `design.approved` / `design.rejected`. On approved: explorer → `context.ready` → planner → `plan.ready` → task_writer → `tasks.ready` → builder → `review.ready` → critic → `review.passed` / `review.rejected`. On pass: finalizer → `queue.advance` (back to task_writer) or `implementation.ready` → validator → `validation.passed` / `validation.failed`. On pass: committer → `LOOP_COMPLETE`.

**Notes:** Full idea-to-committed-code pipeline. Largest preset (11 hats). Three phases: Design (inquisitor/architect/critic), Planning (explorer/planner/task_writer), Implementation (builder/critic/finalizer/validator/committer). Uses adversarial self-debate pattern. Confidence-based decision protocol (0–100 scoring). Broken windows detection. Mermaid diagrams required in design. Given-When-Then acceptance criteria. Intentionally positioned as "advanced, fun example" — slower and more expensive than code-assist.

---

### 8. hatless-baseline.yml

| Field | Value |
|-------|-------|
| Source URL | https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/hatless-baseline.yml |
| Hat count | 0 |
| Hat keys | (none) |
| `starting_event` | `task.start` |
| `completion_promise` | `LOOP_COMPLETE` |
| Backend | `claude` |
| `max_iterations` | 20 |
| `max_runtime_seconds` | 900 (15min) |
| `required_events` | (none) |
| Notable fields | Uses reserved `task.start` trigger (intentional for baseline testing) |

**Event topology:** Single-agent loop. Ralph works directly without hat delegation.

**Notes:** Control preset for testing core Ralph loop without hats. Hidden from normal builtin listings. Validates event loop, completion detection, and basic tool use in isolation.

---

## `presets/minimal/` Subdirectory

The `minimal/` subdirectory contains stripped-down runtime configurations, primarily for backend-specific testing. Files: `amp.yml`, `builder.yml`, `claude.yml`, `code-assist.yml`, `codex.yml`, `gemini.yml`, `kiro.yml`, `opencode.yml`, `preset-evaluator.yml`, `roo.yml`, `smoke.yml`, `test.yml`.

### minimal/code-assist.yml (representative example)

| Field | Value |
|-------|-------|
| Source URL | https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/code-assist.yml |
| Hat count | 1 |
| Hat keys | `builder` |
| `starting_event` | (not specified — uses default `task.start`) |
| `completion_promise` | `LOOP_COMPLETE` |
| Backend | `claude` |
| `max_iterations` | 100 |
| `max_runtime_seconds` | 28800 (8h) |
| Notable fields | `idle_timeout_secs: 1800`, references external SOP file `.sops/code-assist.sop.md` |

**Notes:** Single-hat minimal config. Builder hat triggers on `build.task` and `task.start`. Instructions delegate to an external SOP file rather than inlining the full workflow. Demonstrates the pattern of keeping hat instructions thin by referencing external docs.

### minimal/smoke.yml (representative example)

| Field | Value |
|-------|-------|
| Source URL | https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/smoke.yml |
| Hat count | 0 |
| Hat keys | (none) |
| `completion_promise` | `LOOP_COMPLETE` |
| Backend | `custom` (claude with haiku model) |
| `max_iterations` | 10 |
| `max_runtime_seconds` | 300 (5min) |
| Notable fields | `idle_timeout_secs: 60`, custom backend command with `--dangerously-skip-permissions` |

**Notes:** Smoke test config using cheap Haiku model. No hats — tests core loop only. Short timeouts for fast CI feedback.

---

## Summary Statistics

| Category | Count |
|----------|-------|
| Top-level preset YAML files | 8 |
| Files with hats (real collections) | 7 |
| Hatless configs | 1 (hatless-baseline) |
| `minimal/` configs | 12 |
| Total unique hat keys across top-level presets | 26 |
| Largest collection | pdd-to-code-assist (11 hats) |
| Smallest real collection | research (2 hats) |

## Schema Compliance Notes

Cross-checked against `../../../../skills/ralph-hats/references/schema.md`:

- All presets use valid hat fields: `name`, `description`, `triggers`, `publishes`, `instructions`, `default_publishes`, `backend`, `disallowed_tools`
- `wave-review.yml` uses additional fields not in the schema reference: `concurrency`, `timeout`, `aggregate` (on the reviewer and synthesizer hats). These appear to be Ralph-native extensions for parallel execution.
- `backend_args` / `args` field (documented in schema) is not used in any top-level preset but is used in `minimal/smoke.yml` via the `cli.args` pattern.
- `extra_instructions` (documented in schema) is not used in any preset.
- `max_activations` (documented in schema) is not used in any preset.
- All `event_loop` overlays use only `starting_event` and `completion_promise` as documented.
- Several presets include `event_loop` fields beyond the hats-file overlay scope (`max_iterations`, `required_events`, `max_runtime_seconds`, etc.) — these are full config files, not pure hats overlays.

## Sources

- https://github.com/mikeyobrien/ralph-orchestrator/tree/main/presets — accessed 2026-04-20
- https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/presets/autoresearch.yml — accessed 2026-04-20
- https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/presets/code-assist.yml — accessed 2026-04-20
- https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/presets/debug.yml — accessed 2026-04-20
- https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/presets/research.yml — accessed 2026-04-20
- https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/presets/review.yml — accessed 2026-04-20
- https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/presets/wave-review.yml — accessed 2026-04-20
- https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/presets/pdd-to-code-assist.yml — accessed 2026-04-20
- https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/presets/hatless-baseline.yml — accessed 2026-04-20
- https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/presets/minimal/code-assist.yml — accessed 2026-04-20
- https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/presets/minimal/smoke.yml — accessed 2026-04-20
