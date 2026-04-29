# GitHub Upstream — Top-Level Ralph Configs

> **📸 Snapshot — 2026-04-21.** This document is a point-in-time research artifact captured on 2026-04-21. It is not actively maintained. External sources (GitHub repos, Amazon-internal packages) may have changed since. Scores, links, and findings reflect the state of the world on that date.

Analysis of each `ralph*.yml` file in the root of `mikeyobrien/ralph-orchestrator`.

---

## 1. `ralph.yml`

- **Source:** https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.yml
- **Number of hats:** 4
- **Hat keys:** `planner`, `builder`, `reviewer`, `finalizer`
- **Backend(s):** `pi` (top-level `cli.backend`)
- **`event_loop.starting_event`:** `work.start`
- **`event_loop.completion_promise`:** `LOOP_COMPLETE`
- **Event topology:**
  - `work.start` → planner
  - `subtask.done` → planner
  - `subtask.ready` → builder
  - `review.changes_requested` → builder
  - `all_steps.done` → reviewer
  - `implementation.done` → reviewer
  - `review.approved` → finalizer
  - finalizer → `LOOP_COMPLETE`
- **Notable schema fields beyond standard:**
  - `cli` (top-level runtime config — not a hats-file field per schema)
  - `core` with `specs_dir`, `guardrails` (runtime config)
  - `backpressure.gates` (runtime config — gates with `name`, `command`, `on_fail`)
  - `skills` (runtime config)
  - `RObot` (runtime config)
- **Notes:** This is a full runtime config, not a pure hats overlay. Mixes hat definitions with runtime settings (`max_iterations`, `max_runtime_seconds`, `guardrails`, `backpressure`, `skills`). The planner/builder/reviewer/finalizer pipeline is the canonical Ralph development loop. Builder uses `cargo test -p <crate>` for targeted verification. Reviewer has an "Acceptance Test Integrity" gate that blocks synthetic/stub evidence.

---

## 2. `ralph.qa.yml`

- **Source:** https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.qa.yml
- **Number of hats:** 6
- **Hat keys:** `planner`, `builder`, `reviewer`, `qa_planner`, `qa_tester`, `finalizer`
- **Backend(s):** None specified per-hat (inherits from CLI default)
- **`event_loop.starting_event`:** `work.start`
- **`event_loop.completion_promise`:** `LOOP_COMPLETE`
- **Event topology:**
  - `work.start` → planner
  - `subtask.done` → planner
  - `qa.issues_found` → planner
  - `subtask.ready` → builder
  - `review.changes_requested` → builder
  - `all_steps.done` → reviewer
  - `implementation.done` → reviewer
  - `review.approved` → qa_planner
  - `qa-test.done` → qa_planner
  - `qa-test.ready` → qa_tester
  - `qa.passed` → finalizer
  - finalizer → `LOOP_COMPLETE`
- **Notable schema fields beyond standard:**
  - `core.scratchpad` (runtime config)
  - `core.guardrails` (runtime config)
- **Notes:** Extends the base pipeline with a QA stage between review and finalization. QA planner diffs `origin/main`, classifies changes by impact (event loop, TUI, config), builds a targeted test plan with max 10 targets, and drives execution via tmux splits. Hard stop after 3 QA rounds. Non-impacting changes (docs-only) skip QA automatically. The `qa_tester` hat writes minimal YAML configs to `/tmp/ralph-qa/` and runs `ralph run` against them — a form of integration testing within the orchestrator itself.

---

## 3. `ralph.pi.yml`

- **Source:** https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.pi.yml
- **Number of hats:** 1
- **Hat keys:** `default`
- **Backend(s):** `pi` with args `--provider kiro --model claude-opus-4.6 --thinking high` (per-hat `backend` override)
- **`event_loop.starting_event`:** Not specified
- **`event_loop.completion_promise`:** `LOOP_COMPLETE` (via `event_loop`)
- **Event topology:** Minimal — single hat, no inter-hat routing
- **Notable schema fields beyond standard:**
  - Hat-level `backend` uses object form: `type: pi`, `args: [...]`
- **Notes:** A backend configuration file, not a workflow. Single "default" hat with a specific model/provider. Used as a `-c` config layer (e.g., `ralph run -c ralph.pi.yml`) to set the backend for other hat overlays. The `event_loop.max_iterations: 15` acts as a safety cap.

---

## 4. `ralph.reviewer.yml`

- **Source:** https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.reviewer.yml
- **Number of hats:** 4
- **Hat keys:** `scoper`, `verifier`, `reviewer`, `synthesizer`
- **Backend(s):** `claude` (top-level `cli.backend`)
- **`event_loop.starting_event`:** `review.start`
- **`event_loop.completion_promise`:** `LOOP_COMPLETE`
- **Event topology:**
  - `review.start` → scoper
  - `scope.ready` → verifier
  - `verification.done` → reviewer
  - `review.done` → synthesizer
  - `review.blocked` → synthesizer
  - synthesizer → `LOOP_COMPLETE`
- **Notable schema fields beyond standard:**
  - `event_loop.prompt_file` (runtime config)
  - `core.specs_dir`, `core.guardrails` (runtime config)
- **Notes:** A read-only code review pipeline. The scoper checks out a PR in a git worktree (never modifying the main workspace HEAD), identifies blast radius and test coverage gaps. The verifier runs `cargo test --workspace` and `cargo clippy`, plus live TUI verification via tmux when TUI code changed — emits `review.blocked` if tmux unavailable (no skip allowed). The reviewer reads the diff with verification context and produces a verdict. The synthesizer compiles a final report and cleans up the worktree. Strong guardrail: "DO NOT modify any source code — this is a read-only review."

---

## 5. `ralph.m.yml`

- **Source:** https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.m.yml
- **Number of hats:** 7
- **Hat keys:** `explorer`, `builder`, `verifier`, `shipper`, `deployer`, `analyst`, `writer`
- **Backend(s):** `pi` with args `--provider minimax --model MiniMax-M2.5 --thinking high`
- **`event_loop.starting_event`:** `improve.start`
- **`event_loop.completion_promise`:** None (intentionally infinite — no `completion_promise`)
- **Event topology:**
  - `improve.start` → explorer
  - `analyzed` → explorer
  - `idea.code` → builder
  - `verification.failed` → builder
  - `idea.content` → writer
  - `content.verification.failed` → writer (implied by verifier publishes)
  - `build.complete` → verifier
  - `content.complete` → verifier
  - `verified` → shipper
  - `round.shipped` → deployer
  - `deployed` → analyst
  - `deploy.skipped` → analyst
  - `analyzed` → explorer (loops back)
- **Notable schema fields beyond standard:**
  - `event_loop.checkpoint_interval` (runtime config)
  - `cli.prompt_mode`, `cli.args` (runtime config)
  - `skills.enabled`, `skills.dirs` (runtime config)
  - `core.guardrails` (runtime config)
- **Notes:** An infinite improvement loop — no `completion_promise`, runs until manually cancelled. Cycle: Explorer searches X/web for ideas → Builder implements → Verifier gates quality (agentic, not just test runner) → Shipper commits → Deployer ships to prod (Fly.io/Railway/Vercel) → Analyst gathers metrics → loops back to Explorer. Has a sophisticated product vision framework with 5 tiers (Frontier/Core/Surface/Ecosystem/Business), dogfooding rules, and market research integration. The `writer` hat handles content rounds (landing pages, docs, blog posts). The `verifier` hat is notably thorough — uses tmux IEx sessions, playwriter for web UI, and requires 3+ edge cases beyond happy path.

---

## 6. `ralph.bot.yml`

- **Source:** https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.bot.yml
- **Number of hats:** 3
- **Hat keys:** `planner`, `executor`, `reviewer`
- **Backend(s):** `claude` (top-level `cli.backend`); `executor` and `reviewer` override with `backend.type: "codex"`
- **`event_loop.starting_event`:** `plan.start`
- **`event_loop.completion_promise`:** `LOOP_COMPLETE`
- **Event topology:**
  - `plan.start` → planner
  - `human.response` → planner
  - `human.interact` → (blocks for Telegram response)
  - `work.start` → executor
  - `work.done` → reviewer
  - reviewer → `plan.start` (loop) or `human.interact`
- **Notable schema fields beyond standard:**
  - `event_loop.cooldown_delay_seconds` (runtime config)
  - `event_loop.checkpoint_interval` (runtime config)
  - `RObot.enabled`, `RObot.timeout_seconds`, `RObot.checkin_interval_seconds` (runtime config)
  - `tasks.enabled`, `memories.enabled`, `memories.inject`, `memories.budget` (runtime config)
  - `skills.enabled`, `skills.dirs` (runtime config)
- **Notes:** A human-in-the-loop Telegram bot. The planner sends status updates and questions via `ralph tools interact progress`, then blocks waiting for human response. The executor uses `codex` backend (cheaper/faster) for task execution. The reviewer also uses `codex`. Unique features: `cooldown_delay_seconds: 5` for rate limiting, `memories` system with auto-inject and budget, `RObot` (periodic check-in). The loop never self-terminates — "The LOOP is never complete unless the human explicitly tells you."

---

## 7. `ralph.e2e.yml`

- **Source:** https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.e2e.yml
- **Number of hats:** 4
- **Hat keys:** `planner`, `builder`, `validator`, `committer`
- **Backend(s):** `kiro` (top-level `cli.backend`)
- **`event_loop.starting_event`:** `build.start`
- **`event_loop.completion_promise`:** `LOOP_COMPLETE`
- **Event topology:**
  - `build.start` → planner
  - `tasks.ready` → builder
  - `validation.failed` → builder
  - `task.complete` → builder (self-loop for next task)
  - `implementation.ready` → validator
  - `validation.passed` → committer
  - committer → `commit.complete` (note: no hat triggers on this — potential dead-end without `LOOP_COMPLETE` emission)
- **Notable schema fields beyond standard:**
  - `event_loop.checkpoint_interval` (runtime config)
  - `cli.prompt_mode` (runtime config)
  - `core.scratchpad` (runtime config — isolated scratchpad path)
  - `core.specs_dir`, `core.guardrails` (runtime config)
- **Notes:** E2E test development orchestrator. The planner detects input type (PDD directory, single code task file, or rough description) and bootstraps context. The builder follows strict TDD: RED → GREEN → REFACTOR. The validator checks YAGNI/KISS principles plus manual E2E execution. The committer creates conventional commits. Uses `kiro` backend. Notable: the `builder` hat self-triggers on `task.complete` to pick up the next task — a pattern for sequential multi-task processing without returning to the planner each time.

---

## 8. `ralph.roo.yml`

- **Source:** https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.roo.yml
- **Number of hats:** 0
- **Hat keys:** (none)
- **Backend(s):** `roo` with args `--provider bedrock --aws-profile roo-bedrock --aws-region us-east-1 --model anthropic.claude-opus-4-6 --max-tokens 100000 --reasoning-effort medium`
- **`event_loop.starting_event`:** Not specified
- **`event_loop.completion_promise`:** Not specified
- **Event topology:** None — pure backend config
- **Notable schema fields beyond standard:**
  - `cli.pty_mode` (runtime config)
  - `cli.idle_timeout_secs` (runtime config)
- **Notes:** A backend configuration layer only — no hats, no event loop topology. Configures the `roo` backend to use Claude Opus 4.6 via AWS Bedrock. Intended to be composed with other configs via `-c ralph.roo.yml -c presets/pdd-to-code-assist.yml`. The `idle_timeout_secs: 60` accommodates Opus's slower response times.

---

## Summary Table

| Config | Hats | Starting Event | Completion Promise | Primary Pattern |
|--------|------|----------------|-------------------|-----------------|
| `ralph.yml` | 4 | `work.start` | `LOOP_COMPLETE` | Plan → Build → Review → Finalize |
| `ralph.qa.yml` | 6 | `work.start` | `LOOP_COMPLETE` | Plan → Build → Review → QA → Finalize |
| `ralph.pi.yml` | 1 | (none) | `LOOP_COMPLETE` | Backend config (single default hat) |
| `ralph.reviewer.yml` | 4 | `review.start` | `LOOP_COMPLETE` | Scope → Verify → Review → Synthesize |
| `ralph.m.yml` | 7 | `improve.start` | (none — infinite) | Explore → Build → Verify → Ship → Deploy → Analyze → loop |
| `ralph.bot.yml` | 3 | `plan.start` | `LOOP_COMPLETE` | Human-in-the-loop via Telegram |
| `ralph.e2e.yml` | 4 | `build.start` | `LOOP_COMPLETE` | TDD: Plan → Build (RED→GREEN→REFACTOR) → Validate → Commit |
| `ralph.roo.yml` | 0 | (none) | (none) | Backend config only (no hats) |

## Sources

- [ralph.yml](https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.yml) — accessed 2026-04-20
- [ralph.qa.yml](https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.qa.yml) — accessed 2026-04-20
- [ralph.pi.yml](https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.pi.yml) — accessed 2026-04-20
- [ralph.reviewer.yml](https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.reviewer.yml) — accessed 2026-04-20
- [ralph.m.yml](https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.m.yml) — accessed 2026-04-20
- [ralph.bot.yml](https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.bot.yml) — accessed 2026-04-20
- [ralph.e2e.yml](https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.e2e.yml) — accessed 2026-04-20
- [ralph.roo.yml](https://raw.githubusercontent.com/mikeyobrien/ralph-orchestrator/main/ralph.roo.yml) — accessed 2026-04-20
