---
name: ralph-loop-create
description: Create a new Ralph loop under `/workplace/canewiw/loops/` with the correct hat collection chosen from `~/.ralph/hats/README.md`, a tight `PRD.md`, and a detached tmux launch. Use when the user says "set up a ralph loop", "create a ralph loop", "start a research/debug/implementation loop", or asks to spin up a new autonomous investigation or code-assist loop. Complements the `ralph-loop` skill, which operates already-running loops.
tags: [skill, ralph, loop, automation, hat-selection]
---

# Ralph Loop — Create

## Overview
Bootstrap a brand-new Ralph loop: pick the right hat collection, write a scoped `PRD.md`, launch it in a detached tmux session, and optionally wire a webhook callback so MeshClaw is automatically notified on completion and can take next steps.

## Usage
Use when the user asks to create a new Ralph loop for any of:
- A deep-dive investigation (research / decision doc)
- A bounded code fix (single package, clear requirements)
- A bug investigation with paper-trail of hypotheses
- A pipeline failure → RCA → optional CR workflow
- A code review of a CR/PR
- A narrative document (six-pager, PR/FAQ)
- A measurable optimization (perf, coverage, bundle size)

Do NOT use for: operating already-running loops (use `ralph-loop`), editing or adding new hat collections (use `ralph-hats`), or flat task-loop style `run.sh` harnesses (use `agent-task-loop`).

## Core Concepts

### Ralph vs flat task-loop harnesses
Ralph drives a **multi-hat event topology** — each hat has a narrow role (Researcher, Synthesizer, Builder, Critic, etc.), events carry the state machine, and stale-topic detection auto-terminates thrashing loops. A flat task-loop harness (see the `agent-task-loop` skill) drives a list of tasks through `implement → review → revise` with `run.sh`.

**Choose Ralph when** the work has distinct stages with different concerns (investigate ≠ write ≠ verify). **Choose a flat task-loop when** the work is a long list of similar small tasks.

### Hat collections are pre-built
You **MUST NOT** hand-roll hat topologies. The curated collections under `~/.ralph/hats/` are validated, scored, and distilled from upstream + Amazon sources. Use them as-is. If none fit, stop and ask the user.

Read `~/.ralph/hats/README.md` to pick the right one. See [`references/hat-selection.md`](./references/hat-selection.md) for the decision tree.

### Loops live in a canonical location
All loops **MUST** be created under `/workplace/canewiw/loops/<name>/` so loop-monitor and meta-monitor find them. Names are lowercase-kebab, describe the goal, and stay under ~40 chars.

## Workflow

### 1. Understand the goal
Ask the user — or infer from context — what the loop should produce. Write it as one sentence. If you can't, stop and ask.

### 2. Pick the hat collection
Read `~/.ralph/hats/README.md`. Match the goal to its quick-selection table. See [`references/hat-selection.md`](./references/hat-selection.md) for the full decision tree, including when to prefer `research.yml` (2-hat) over `autoresearch.yml` (5-hat, optimization loops only).

Common mistake: reaching for `autoresearch.yml` because "more hats is more thorough." It's an **optimization** loop (Benchmarker / Judge / Evaluator). Do not use for qualitative investigations.

### 3. Write the PRD
Create `PRD.md` in the loop dir. The PRD is the loop's only task input — it **MUST** include:

- **Goal** — one paragraph, what the deliverable is and what it is not
- **Verified inputs** — facts known already (bug sites with file:line, commit SHAs, ticket IDs). Prevents the loop from re-deriving things.
- **Known resources** — pipelines, packages, skills, accounts, agents the loop should use
- **Credentials note** — how the agent should obtain access (`ada credentials update --provider conduit --role IibsAdminAccess-DO-NOT-DELETE --account <id>`). Mark unreachable accounts as `NEEDS HUMAN INPUT`.
- **Required sections / structure of the deliverable** — what `docs/<output>.md` (or the CR diff) must contain
- **Out of scope (hard guardrails)** — explicit list. Examples: "Do NOT write production code", "Do NOT create a CR", "Do NOT touch file X per upstream ticket's direction". Hats read this.
- **Success criteria** — objective pass/fail checks

See [`references/prd-template.md`](./references/prd-template.md) for a skeleton.

### 4. Choose where to run

**You MUST ask the user** whether to run the loop locally or on dsk2 (the secondary dev desktop) before launching. Present the choice:

```
Where should I run this loop?
[OPTIONS: Local | dsk2 (remote)]
```

**When to suggest dsk2:**
- The primary machine is already running multiple loops or heavy builds
- The loop is long-running (research 35+ iter, autoresearch 50+ iter)
- The user explicitly asks to offload

**When to suggest local:**
- The loop needs MCP tools that only work locally (callback webhooks, chain orchestration)
- Short loops (< 15 min) where `--wait` is preferred
- The user wants `--callback` or `--chain` (not supported on dsk2)

If the user doesn't have a preference, default to **local** — it has full feature support (callbacks, chaining, loop-monitor discovery).

### 5. Launch

Use [`scripts/launch.sh`](./scripts/launch.sh) for **local** execution, or `remote_ralph` for **dsk2** execution. Both run `ralph doctor` pre-flight and validate the hat collection.

**You SHOULD always launch with `--callback`** so MeshClaw is automatically notified when the loop finishes and can take next steps (read output, post to tickets/CRs, notify user, chain follow-up loops).

#### With callback (default — use this)

Pass `--callback` with a context summary that tells the callback session what to do when the loop finishes. The script handles hook registration and webhook wiring internally — no `register_hook` MCP call needed.

```bash
~/.meshclaw/skills/ralph-loop-create/scripts/launch.sh \
  <loop-name> \
  <hat-collection> \
  <max-iterations> \
  --callback "Loop <name> completed. Call send_message with a 3-5 bullet summary of the inlined output doc. Do NOT spawn subagents or run shell commands."
```

The script:
1. Reads `hooks.webhook_token` from `~/.meshclaw/config.json`
2. Writes hook context to `~/.meshclaw/hooks.json` (same format as `register_hook`)
3. Launches Ralph in tmux
4. On Ralph exit, `notify-completion.sh` POSTs to the local webhook with exit code, output docs, and CR references
5. MeshClaw starts a new session with the saved context summary and acts on the results

**⚠️ Callback session limitation:** Webhook-created sessions have no Slack thread and are destroyed after the first LLM turn. Subagents spawned via `spawn_run` will have results silently dropped. Shell commands and multi-step orchestration are unreliable. **Use callbacks for notification only** — call `send_message` with a summary and exit. Leave orchestration (launching follow-up loops, updating tickets) to cron jobs or dashboard sessions.

The main output doc is inlined in the webhook payload (< 50KB), so the callback agent already has the content — no need to read files.

**Context summary tips** — write as **notification-only** instructions:
- `"Loop fixing TALON-2430 finished. Summarize the inlined output doc in 3-5 bullets and call send_message to notify the user."`
- `"Research loop for DDB throttling finished. Call send_message with: loop name, exit code, and a 3-sentence summary of the inlined output doc."`
- `"Loop <name> completed. Call send_message with the key findings from the inlined output. Do NOT spawn subagents, launch loops, or run shell commands."`

**Prerequisite:** `hooks.webhook_token` must be set in `~/.meshclaw/config.json` (one-time setup). Generate with: `python3 -c "import secrets; print(secrets.token_urlsafe(32))"` and set via `meshclaw config set hooks.webhook_token <token>`.

#### Without callback (fire-and-forget)

Omit `--callback`. Loop-monitor cron will still discover and report on the loop, but MeshClaw won't automatically act on the results.

```bash
~/.meshclaw/skills/ralph-loop-create/scripts/launch.sh \
  <loop-name> \
  <hat-collection> \
  <max-iterations>
```

#### With `--wait` (same session, synchronous)

Blocks until the loop finishes, then prints results inline. The calling session stays alive and gets the output directly — no new session, no context loss. Best for short loops (< 30 min) where you want the same agent to read the results and take next steps.

```bash
~/.meshclaw/skills/ralph-loop-create/scripts/launch.sh \
  <loop-name> \
  <hat-collection> \
  <max-iterations> \
  --wait
```

After the loop finishes, the script prints exit code, output docs, and CR references. The agent can then read the output files and continue working in the same session.

**Tradeoff:** `--callback` frees the session immediately (agent can do other work), but a new session handles the results. `--wait` keeps the session occupied but preserves full conversation context.

#### Remote execution (dsk2)

Use `remote_ralph` at `~/.local/bin/remote_ralph` to offload loops to the secondary dev desktop. The loop dir is created locally as usual, then synced and launched on dsk2 via SSH.

```bash
remote_ralph launch <loop-name> <hat-collection> <max-iterations>
```

This does: push loop dir → verify hats on dsk2 → `ralph doctor` on dsk2 → start tmux session on dsk2.

**Monitoring remote loops:**

| Command | What it does |
|---|---|
| `remote_ralph status [name]` | List running loops / show details for one |
| `remote_ralph log <name> [N]` | Tail .run.log on dsk2 (default 50 lines) |
| `remote_ralph attach <name>` | Attach to dsk2 tmux session |
| `remote_ralph finish <name>` | Block until loop exits, then auto-pull results |
| `remote_ralph pull <name>` | Pull results from dsk2 → primary |
| `remote_ralph kill <name>` | Kill the dsk2 tmux session |

**Limitations vs local `launch.sh`:**
- **No `--callback`** — webhook machinery is primary-box-only. Use `remote_ralph finish` to block-and-pull, or poll with `remote_ralph status`.
- **No `--chain`** — beads orchestration runs locally. Pull results first, then chain manually.
- **No loop-monitor discovery** — the loop-monitor cron watches local tmux sessions only. Use `remote_ralph status` instead.

**Typical remote workflow:**
1. Create loop + PRD locally under `/workplace/canewiw/loops/<name>/`
2. `remote_ralph launch <name> <hats> <iters>`
3. Check progress: `remote_ralph log <name>` or `remote_ralph status <name>`
4. When done: `remote_ralph pull <name>` to get results locally
5. Read output at `/workplace/canewiw/loops/<name>/docs/`

#### What launch.sh does

1. Verifies `PRD.md` exists in `/workplace/canewiw/loops/<loop-name>/`
2. If `--callback`: reads webhook token from config, writes hook context to `hooks.json`
3. Runs `ralph doctor` → writes `.ralph-doctor.log`, aborts on non-zero exit
4. Runs `ralph hats validate -H ~/.ralph/hats/<collection>.yml`
5. Starts `tmux new-session -d -s <loop-name>` running `ralph run`
6. On Ralph exit: writes `.ralph-exited` sentinel, fires callback webhook if `--callback` was passed, fires orchestrator spec if `--chain` was passed

### 6. Report back
After launch, confirm to the user:
- Loop directory (absolute path)
- tmux session name
- Hat collection chosen and why
- Max iterations budget
- Deliverable location (`docs/<name>.md` or the CR it will produce)
- How loop-monitor will discover it (tmux + `.ralph/current-loop-id`)
- Callback status: whether `--callback` was wired, and what the callback session will do on completion
- **Execution host:** local or dsk2, and how to check status

## Guardrails

- **You MUST** read `~/.ralph/hats/README.md` before every hat choice. Do not pick from memory.
- **You MUST** use `/workplace/canewiw/loops/<name>/` as the loop root. Other locations are invisible to loop-monitor.
- **You MUST** write a `PRD.md` before launching. Empty or placeholder PRDs waste iterations.
- **You MUST** include explicit out-of-scope guardrails in the PRD if the loop must NOT write code, must NOT create a CR, or must NOT touch specific files.
- **You MUST NOT** hand-roll new hat collections inline. If none fit, stop and propose adding one via the `ralph-hats` skill.
- **You MUST NOT** launch outside tmux. The monitor and the `ralph-loop` skill both assume a tmux session.
- **You MUST** ask the user where to run (local or dsk2) before launching. Do not assume local. See step 4.
- **You SHOULD** use the `talon-dev` agent (global config default) unless the task needs a different context. Verify via `/home/canewiw/.ralph/config.yml` or a per-hat override.
- **You SHOULD** set `--max-iterations` generously (25–50 for research, 15–30 for code-assist). Ralph terminates early on `loop_stale`, so budget headroom is free. The hard ceiling is wall-clock time, not iterations.
- **You SHOULD** always use `--callback` when launching loops. Write the context summary as **notification-only** instructions — `send_message` with a summary, nothing else. Leave orchestration to crons or dashboard sessions. Skip callback only if the user explicitly says fire-and-forget.

## Common Mistakes

### Picking autoresearch for a qualitative investigation
`autoresearch.yml` requires a benchmark command and a primary metric with known direction. If the deliverable is a written recommendation, use `research.yml` instead.

### Omitting "out of scope" guardrails
Without explicit `do NOT` rules, the loop may drift into writing code, creating CRs, or touching unrelated files. Every PRD **SHOULD** have a dedicated Out of Scope section.

### Launching without `ralph doctor`
A failed doctor means the loop will crash early. Always run the pre-flight (the launch script does this by default).

### Loop name collides with existing directory
`/workplace/canewiw/loops/` may already contain a loop with that name (completed or otherwise). Pick a distinct name — appending a version suffix (`-v2`, `-rev3`) is common.

### Hardcoded credentials or account IDs in the PRD
Never embed AWS account IDs or credentials. Reference pipelines or tell the loop how to discover them (`ada credentials update ...`). Use `NEEDS HUMAN INPUT` for truly unknown items.

## Quick Reference

| Want to... | Collection | Typical iterations |
|---|---|---|
| Deep-dive investigation → decision doc | `research` | 25–50 |
| Bounded code fix with TDD | `code-assist` | 15–30 |
| Validate plan decomposition for a large change (PDD authoring, no code) | `lisamarge-pdd` | 10–20 |
| Bug RCA with paper trail | `debug` | 15–25 |
| Pipeline failure → RCA → optional CR | `pipeline-debug` | 20–35 |
| Code review of a CR | `review` | 10–20 |
| Six-pager / PR-FAQ / architecture doc | `writing` | 20–40 |
| Measurable perf / coverage optimization | `autoresearch` | 50–200 |

For the full decision tree and anti-patterns, see [`references/hat-selection.md`](./references/hat-selection.md).

### Launch modes

| Mode | Flag | Session behavior | Best for |
|---|---|---|---|
| Callback | `--callback "instructions"` | New session acts on results | Long loops (> 30 min), chained workflows |
| Chain | `--chain <task-id>` | On exit, fires orchestrator spec to close task + launch next | Beads-driven task graphs |
| Chain (custom spec) | `--chain <id> --orch-spec <path>` | Same as Chain, but uses a specific spec instead of the default `codegen-scheduler.spec.md` | Projects with their own orchestrator spec (e.g. TalonTriage) |
| Wait | `--wait` | Same session blocks, gets results inline | Short loops (< 30 min), full context needed |
| Fire-and-forget | _(none)_ | Session ends, loop-monitor reports | Background work you'll check manually |
| Remote (dsk2) | `remote_ralph launch` | Runs on secondary host, pull results when done | Offloading CPU, long-running loops |

**Do NOT combine `--callback` and `--chain`.** The orchestrator spec (step 5) already sends a Slack DM summary via `send_message`. Adding `--callback` would send a duplicate notification. Use `--callback` only for standalone loops without chaining. `run-next.sh` already follows this rule — it passes only `--chain` when launching chained tasks.

### Beads integration (loop chaining)

When `--chain <beads-task-id>` is passed, launch.sh appends a post-exit command to the tmux session that runs `meshclaw run` on the project's orchestrator spec. The orchestrator agent:

1. Closes the completed beads task (via `bd close`)
2. Harvests new tasks from ideation backlogs
3. Grooms stale tasks (7d inactive → auto-close)
4. Picks the next ready task from `bd ready` and launches it
5. Sends a Slack DM summary via `send_message`

Each project has its own `.beads/` directory (per-project isolation). `bd` auto-discovers it from CWD.

**Setting up a new project:**
```bash
~/.meshclaw/workspace/orchestrator/new-project.sh /workplace/canewiw/MyProject
```
This initializes beads and generates a project-specific orchestrator spec from the template. Then create tasks and launch:
```bash
cd /workplace/canewiw/MyProject
bd create "Task title" -p 1 --type task -d "Description. Hat: code-assist, 20 iter. Loop: my-loop-name"
~/.meshclaw/workspace/orchestrator/run-next.sh /workplace/canewiw/MyProject
```

**Prerequisites:**
- Beads installed (`bd --version`)
- Project initialized via `new-project.sh` (or manually: `bd init --stealth` + spec from template)
- Tasks created with `Loop:`, `Hat:`, and `<N> iter` metadata in their description

**Kill switch:** Create `.chain-stop` in the project dir to halt the chain:
```bash
touch /workplace/canewiw/MyProject/.chain-stop   # stop
rm /workplace/canewiw/MyProject/.chain-stop      # resume
```

**Orchestrator scripts** live in `~/.meshclaw/workspace/orchestrator/`:
| Script | Purpose |
|---|---|
| `new-project.sh` | Init beads + generate spec for a new project |
| `spec-template.md` | Template with `{{PROJECT_DIR}}` placeholders (ideation-driven) |
| `spec-template-curated.md` | Template for curated queues (no harvest/ideation) |
| `bd-ensure.sh` | Init `.beads/` if missing (idempotent) |
| `harvest.sh` | Pull tasks from ideation backlog into beads graph |
| `groom.sh` | Close tasks untouched for 7+ days |
| `pick-next.sh` | Return next ready task with Loop/Hat/iter metadata |
| `run-next.sh` | Build PRD from beads task description, launch loop |

**Per-project ideation PRD template** — optional. If a file named `<project-name-lowercase>-ideation.prd.template.md` exists in the orchestrator dir, `run-next.sh` uses it instead of the generic PRD when auto-launching an ideation loop. The token `{{NAME}}` is replaced with the loop name. Use this to point ideation at specific research deliverables, hotpatches, or code paths for your project.

### Writing orchestrator specs

A spec is a markdown file that `meshclaw run --no-test` feeds to a kiro-cli agent as a task. The agent has full MCP tool access including `send_message` (Slack DM), shell execution, and file I/O.

**How it works:**
1. `launch.sh --chain` appends a `CHAIN_CMD` to the tmux session
2. When ralph exits, `CHAIN_CMD` runs: `CHAIN_PREV_TASK=<id> CHAIN_PREV_RC=$rc meshclaw run --no-test <spec>`
3. `meshclaw run` spawns kiro-cli, passes the spec as the task prompt
4. The agent executes the steps, calling MCP tools as needed
5. Env vars `CHAIN_PREV_TASK` and `CHAIN_PREV_RC` are inherited — the agent can read them via shell commands

**Spec structure:**
```markdown
# Task: <project> orchestrator cycle

<One-line description of what this cycle does.>

## Notifications
Use `send_message` for ALL status updates.

## Kill Switch
Check if <project-dir>/.chain-stop exists. If so, send_message and stop.

## Steps
1. Close previous task (if CHAIN_PREV_TASK is set)
2. <project-specific steps: harvest, groom, etc.>
3. Pick and launch next task via run-next.sh
4. Send summary via send_message
```

**Two templates are provided:**

| Template | Use when | File |
|---|---|---|
| `spec-template.md` | Project discovers work via ideation loops (harvest → groom → pick) | Default |
| `spec-template-curated.md` | Tasks are manually created — no ideation, no harvest | `--curated` flag |

Generate with: `new-project.sh /path/to/project [--curated]`

**Customizing specs:** After generation, edit the spec directly. Common customizations:
- Add project-specific steps (e.g., run linters, update dashboards)
- Change groom threshold (default 7 days)
- Add `NO_IDEATION=1` to `run-next.sh` call to disable auto-ideation (or switch to the `--curated` template)
- Point ideation at specific inputs by creating `<project>-ideation.prd.template.md` in the orchestrator dir
- Add conditional logic ("if no tasks were launched, send_message and stop")
