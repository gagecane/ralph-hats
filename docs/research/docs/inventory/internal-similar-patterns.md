# Internal Agent-Orchestration Patterns Similar to Ralph Hats

> **📸 Snapshot — 2026-04-21.** This document is a point-in-time research artifact captured on 2026-04-21. It is not actively maintained. External sources (GitHub repos, Amazon-internal packages) may have changed since. Scores, links, and findings reflect the state of the world on that date.

## 1. Agent-Task-Loop (Bash + kiro-cli State Machine)

**Source:** `/home/canewiw/.aim/packages/local/TalonAiCapabilities-1.0/skills/agent-task-loop/SKILL.md`

**Pattern:** A bash `run.sh` loop spawns fresh `kiro-cli` sessions. Each session picks one task from `tasks.md`, performs one action (implement, review, or revise), updates state markers, and exits. The next session picks up with a clean context window.

**Mapping to Ralph hats:**

| Ralph Concept | Agent-Task-Loop Equivalent |
|---|---|
| Hat (persona) | Implicit role determined by task state (`[ ]` → implementer, `[review]` → reviewer, `[revise]` → fixer) |
| Event (trigger/publish) | Task state markers: `[ ]`, `[review]`, `[revise]`, `[completed]`, `[blocked on: <id>]` |
| `event_loop.starting_event` | First `[ ]` task in priority order |
| `event_loop.completion_promise` | `<promise>COMPLETE.</promise>` written to `progress.txt` |
| `hats:` YAML config | `PROMPT.md` (the loop prompt with numbered rules) |
| Backpressure / reviewer hat | The `[review]` step in a fresh context — reviewer never saw implementation |
| `max_activations` | `[revise:N]` counter; decomposes at N=3 |
| `scratchpad.md` (inter-hat state) | `tasks.md` + `feedback.txt` (disk is state) |
| `default_publishes` | Implicit: implementer always marks `[review]`; reviewer marks `[completed]` or `[revise:N+1]` |

**Key differences from Ralph:**

- **No event routing**: Roles are determined by task state, not by event topic matching. There's no DAG of events — just a linear state machine per task.
- **Single agent, multiple roles**: The same agent spec handles all roles. Ralph uses distinct hat definitions with separate instructions.
- **Bash harness vs Rust runtime**: The outer loop is a shell script (`run.sh`), not a Rust event loop. Simpler but no TUI, no web dashboard, no MCP server mode.
- **No parallel execution**: Tasks are processed sequentially. Ralph can activate multiple hats on different events concurrently.
- **Decomposition is manual**: The agent decides to decompose based on heuristics in the prompt. Ralph's `max_activations` provides automatic backpressure.
- **No `events:` metadata**: No formal event schema — the state transitions are implicit in the prompt rules.

**Strengths over Ralph:**

- Zero dependencies (bash + kiro-cli only)
- Simpler mental model for linear workflows
- Fresh context per iteration is guaranteed by architecture (new process)
- Completion archiving (`tasks-completed.md`) prevents context bloat

---

## 2. RalphAgentCapabilities (3-Agent Architecture)

**Source:** `code.amazon.com/packages/RalphAgentCapabilities` (found via `AISkills-iamsukh` context/ralph-loop-research.md)

**Pattern:** Three AIM agents with strict separation of concerns, communicating via filesystem state (`state.json`, `tasks.md`, `evaluation-<TAG>.json`):

| Agent | Role | Tools | MCP Dependencies |
|---|---|---|---|
| `ralph` | State machine, spawns workers via bash, never writes code | `execute_bash` (restricted), `fs_read`, `thinking` | `ai-community-slack-mcp` (registered but tools not in `allowedTools`) |
| `ralph-foreman` | One-shot executor, runs one task then exits | `execute_bash`, `fs_read`, `fs_write`, `thinking`, `SkillsTool` | — |
| `ralph-evaluator` | Zero tools, reads worker conversation, outputs JSON verdict | None (no tools at all) | — |

**Mapping to Ralph hats:**

| Ralph Concept | RalphAgentCapabilities Equivalent |
|---|---|
| Hat | Separate AIM agent (distinct `.agent-spec.json`) |
| Event routing | Orchestrator spawns worker via `kiro-cli --no-interactive`; worker's stop hook forks evaluator as background process; orchestrator polls for `evaluation-<TAG>.done` sentinel file |
| Backpressure | Evaluator outputs JSON verdict (`evaluation-<TAG>.json`); orchestrator re-spawns worker on rejection |
| `completion_promise` | All tasks in `tasks.md` marked done; orchestrator transitions to `completed` phase and archives run |
| `scratchpad.md` | `~/.kiro/ralph-loop/runs/<run-id>/` state directory |
| `max_activations` | Orchestrator controls iteration count |

**Key differences from Ralph:**

- **Process-level isolation**: Each "hat" is a separate OS process with its own agent spec. Ralph hats share a single process. (The 3-agent architecture is also confirmed in the AIM Orchestrator UI PoC registry — `AimOrchestratorUIPoc/packages/server/data/agent-map.json` lists `RalphAgentCapabilities` with agents: `ralph-evaluator`, `ralph-worker`, `ralph-orchestrator`.)
- **Hook-driven evaluation**: The worker's stop hook forks the evaluator as a background process. The orchestrator polls for the `evaluation-<TAG>.done` sentinel file rather than triggering evaluation synchronously.
- **File locking**: Uses `ralph-flock` (mkdir-based locks) for concurrent state access. Ralph uses single-threaded event dispatch.
- **Hooks-driven**: Uses AIM hooks (`agentSpawn`, `stop`, `preToolUse`, `postToolUse`) for lifecycle management. Ralph uses event subscriptions.

---

## 3. KiroCliRalph (Bun/TypeScript Loop)

**Source:** `code.amazon.com/packages/KiroCliRalph` (referenced in `AISkills-iamsukh` context/ralph-loop-research.md)

**Pattern:** A Bun/TypeScript CLI (`ralph-for-kiro`) that wraps kiro-cli in a loop with `--no-interactive` + `--trust-all-tools`. Reads kiro-cli's SQLite DB to detect completion promises (`<promise>COMPLETE</promise>` by default, configurable via `--completion-promise`).

**Commands:** `init`, `loop`, `cancel`

**Mapping to Ralph hats:**

| Ralph Concept | KiroCliRalph Equivalent |
|---|---|
| `event_loop` | TypeScript loop driver with min/max iterations |
| `completion_promise` | `<promise>COMPLETE</promise>` detected in SQLite DB |
| Hat definitions | Not present — single-agent loop, no persona switching |
| Event routing | Not present — relies on prompt instructions for role behavior |

**Key difference:** This is a loop harness only — it provides the iteration/termination mechanics but not the multi-persona orchestration. Conceptually equivalent to `run.sh` in agent-task-loop but implemented in TypeScript with SQLite introspection.

---

## 4. AWSGrafanaGenAIPowerUser (Worker/Verifier Subagent Pattern)

**Source:** `code.amazon.com/packages/AWSGrafanaGenAIPowerUser` — `skills/ralph-loop/SKILL.md`, `agent-sops/ralph-loop-setup.sop.md`

**Pattern:** Worker/Verifier pattern using kiro-cli subagents. Uses `prd.json` for story definitions. An orchestrating agent picks stories, delegates to a Worker subagent to implement, then a Verifier subagent to independently test. Rejected stories go back to the Worker. The loop runs until all stories pass or max iterations are reached.

**Mapping to Ralph hats:**

| Ralph Concept | Equivalent |
|---|---|
| Builder hat | Worker subagent |
| Reviewer hat | Verifier subagent |
| `hats:` config | `prd.json` story definitions |
| Event routing | Subagent delegation via `use_subagent` tool |

**Key difference:** Uses kiro-cli's native `use_subagent` tool for parallelism rather than an external event loop. No YAML config — orchestration logic lives in the parent agent's prompt.

---

## 5. Agent-Task-Loop vs Ralph: Structural Comparison

| Dimension | Ralph Hats | Agent-Task-Loop |
|---|---|---|
| Config format | YAML (`hats:` + `event_loop:`) | Markdown (`PROMPT.md` + `tasks.md`) |
| Runtime | Rust binary (`ralph-cli`) | Bash script (`run.sh`) + `kiro-cli` |
| Persona definition | Explicit per-hat `instructions:` | Single prompt with conditional rules |
| State transitions | Event publish/subscribe | File-based markers (`[ ]` → `[review]` → `[completed]`) |
| Parallelism | Multiple hats can fire on different events | Sequential only |
| Backpressure | Reviewer hat publishes reject event | `[revise:N]` counter, decompose at N=3 |
| Fresh context | Per-hat activation (each hat runs as a fresh `kiro-cli chat --no-interactive --trust-all-tools` subprocess — confirmed by [ralph-adapters kiro backend](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/crates/ralph-adapters/src/cli_backend.rs)) | Per-iteration (new OS process) |
| Completion | `LOOP_COMPLETE` event | `<promise>COMPLETE.</promise>` in file |
| Dependencies | `ralph-cli` binary + backend | `bash` + `kiro-cli` (zero extra deps) |
| Observability | TUI, web dashboard, `.ralph/` diagnostics | `progress.txt` append-only log |
| Error recovery | `.ralph/` state + `ralph resume` | `.last-output.log` + git status check |

---

## 6. Patterns NOT Found Internally

The following searches returned no results for non-Ralph event-driven multi-persona patterns:

- `"agent_task_loop" OR "agent-task-loop" fp:*.md` — 0 results (the skill is local-only, not published to code.amazon.com)
- No internal framework was found that independently invented the `triggers:`/`publishes:` event-driven hat pattern without being a Ralph consumer.
- All internal repos using `event_loop` + `completion_promise` in YAML are Ralph consumers (they use `ralph-cli` as the runtime).

**Conclusion:** Within Amazon internal code, the event-driven multi-persona orchestration pattern is exclusively implemented via `ralph-orchestrator`. Alternative approaches (agent-task-loop, RalphAgentCapabilities 3-agent, KiroCliRalph) use different mechanisms (file markers, process spawning, SQLite introspection) but converge on the same core ideas: fresh context per role, backpressure via review gates, and a completion promise for termination.

## Sources

- [RalphAgentCapabilities README.md](https://code.amazon.com/packages/RalphAgentCapabilities/blobs/mainline/--/README.md) — accessed 2026-04-20
- [RalphAgentCapabilities AGENTS.md](https://code.amazon.com/packages/RalphAgentCapabilities/blobs/mainline/--/AGENTS.md) — accessed 2026-04-20
- [AWSGrafanaGenAIPowerUser skills/ralph-loop/SKILL.md](https://code.amazon.com/packages/AWSGrafanaGenAIPowerUser/blobs/mainline/--/skills/ralph-loop/SKILL.md) — accessed 2026-04-20
- [AWSGrafanaGenAIPowerUser agent-sops/ralph-loop-setup.sop.md](https://code.amazon.com/packages/AWSGrafanaGenAIPowerUser/blobs/mainline/--/agent-sops/ralph-loop-setup.sop.md) — accessed 2026-04-20
- [AISkills-iamsukh context/ralph-loop-research.md](https://code.amazon.com/packages/AISkills-iamsukh/blobs/mainline/--/context/ralph-loop-research.md) — accessed 2026-04-20
- [AimOrchestratorUIPoc packages/server/data/agent-map.json](https://code.amazon.com/packages/AimOrchestratorUIPoc/blobs/mainline/--/packages/server/data/agent-map.json) — accessed 2026-04-20
- Local file: `/home/canewiw/.aim/packages/local/TalonAiCapabilities-1.0/skills/agent-task-loop/SKILL.md` — accessed 2026-04-20
- [ralph-orchestrator crates/ralph-adapters/src/cli_backend.rs](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/crates/ralph-adapters/src/cli_backend.rs) — accessed 2026-04-20
- InternalCodeSearch queries: `"triggers" "publishes" "instructions" fp:*.yml`, `ralph-cli OR ralph-orchestrator`, `"event_loop" "completion_promise" fp:*.yml`, `"RalphAgentCapabilities"` — accessed 2026-04-20
