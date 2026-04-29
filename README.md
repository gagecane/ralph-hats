# CanewiwRalphConfig

Git-versioned backup of Ralph Orchestrator config — hat collections under `~/.ralph/` and MeshClaw agent skills under `~/.meshclaw/skills/` that drive Ralph usage.

## Prerequisites

Before using anything in this repo you need:

1. **Ralph Orchestrator** — the `ralph` binary. Docs: https://mikeyobrien.github.io/ralph-orchestrator

   Recommended install (see docs for macOS/Cargo/source alternatives):
   ```bash
   npm install -g @ralph-orchestrator/ralph-cli
   ralph --version   # verify
   ```

2. **An AI CLI backend** that Ralph drives. At least one of: Claude Code (recommended), Kiro, Gemini CLI, Codex, Amp, Copilot CLI, OpenCode. See Ralph's [Prerequisites](https://mikeyobrien.github.io/ralph-orchestrator/getting-started/installation/#prerequisites) section.

3. **tmux** — the loop-launch helper in `skills/ralph-loop-create/scripts/launch.sh` runs Ralph in a detached tmux session so the loop survives shell exit.
   ```bash
   sudo yum install -y tmux    # or apt/brew equivalent
   ```

4. **MeshClaw** — if you want the agent-facing skills to work. These skills describe how to author hat collections, scaffold loops, and operate running ones; they're consumed by a MeshClaw-managed agent that auto-discovers skills in `~/.meshclaw/skills/`. Without MeshClaw the `hats/` and `config.yml` are still fully usable directly.

## Setup from scratch

On a new machine, after installing the prerequisites:

```bash
# 1. Clone / sync the package
brazil ws create --name CanewiwRalphConfig-ws --versionSet live
cd CanewiwRalphConfig-ws
brazil ws use --package CanewiwRalphConfig
brazil ws sync --md
cd src/CanewiwRalphConfig

# 2. Install the Ralph config
mkdir -p ~/.ralph
ln -sfn "$(pwd)/hats"       ~/.ralph/hats
ln -sfn "$(pwd)/config.yml" ~/.ralph/config.yml

# 3. Install the MeshClaw skills (only if using MeshClaw)
mkdir -p ~/.meshclaw/skills ~/.meshclaw/workspace/prompts
for s in ralph-hats ralph-loop ralph-loop-create; do
  ln -sfn "$(pwd)/skills/$s" ~/.meshclaw/skills/$s
done
ln -sfn "$(pwd)/prompts/loop-monitor.md" ~/.meshclaw/workspace/prompts/loop-monitor.md

# 4. Smoke test
ralph --version
ls ~/.ralph/hats/*.yml
ralph run -H ~/.ralph/hats/research.yml -p "What is 2+2?" --autonomous
```

If the smoke test launches a loop and terminates on its own, you're set up. An agent told "set up these loops" with a link to this repo should be able to run the steps above end-to-end.

To detect drift between these instructions and the repo layout, run
`scripts/verify-readme.sh` — it parses the `ln -sfn` source paths above and
fails if any of them no longer exist.

To validate `hats/*.yml` against the hat schema + referential integrity
(catches typos like `even_loop:` or a `completion_promise` no hat publishes),
run `scripts/validate-hats.py`. Tests live in `scripts/test_validate_hats.py`
and the schema itself is `hats/hat.schema.json`.

## MeshClaw crons

`prompts/loop-monitor.md` is designed to be registered as a recurring MeshClaw cron job. The prompt classifies every active loop (agent-task-loop or Ralph) and sends a Slack Block Kit report.

### One-time env setup

Export your Slack user ID for owner-DM delivery (get it from Slack → profile → "Copy member ID"):

```bash
export MESHCLAW_OWNER_ID=U01234567   # your Slack user ID
```

Persist it in `~/.bashrc` or your shell profile so cron-spawned shells inherit it.

### Register the cron

Using the MeshClaw `cron_add` tool (schedules are UTC regardless of any timezone field):

```
cron_add(
  name="loop-monitor",
  message="Read /home/<user>/.meshclaw/workspace/prompts/loop-monitor.md and execute the instructions in it exactly as written.",
  cron_expr="*/20 15-23 * * 1-5"   # every 20 min, Mon–Fri 15:00–23:59 UTC (≈ 08:00–16:40 PDT)
)
```

Adjust the hour window (`15-23`) to your local workday.

### Prerequisites the prompt assumes

- MeshClaw `agent-task-loop` skill installed (for bash-harness loop semantics); not provided here.
- A writable state file path: `~/.meshclaw/workspace/loop-monitor-state.json` (auto-created as `{}` on first run).
- `tmux`, `jq`, `kill` available in the cron shell.

## Contents

### `~/.ralph/` material
- `config.yml` — Ralph global config (referenced via `RALPH_CONFIG=~/.ralph/config.yml`)
- `hats/*.yml` — hat collections (code-assist, debug, pipeline-debug, research, review, writing, autoresearch, lisamarge-pdd, pdd-implement, ticket-triage)
- `hats/README.md` — catalogue of hat collections with selection guidance
- `docs/research/` — research artifacts (inventory, comparison, rubric, scores) used while designing hats

### `~/.meshclaw/skills/` material
- `skills/ralph-hats/` — skill for creating/inspecting/validating hat collections
- `skills/ralph-loop/` — skill for operating running Ralph loops (monitor, resume, merge, debug)
- `skills/ralph-loop-create/` — skill for scaffolding new Ralph loops under `/workplace/canewiw/loops/`

### MeshClaw cron prompts
- `prompts/loop-monitor.md` — classifier + reporter for running agent-task-loop and Ralph loops. Read by a MeshClaw cron and executed verbatim. References `$MESHCLAW_OWNER_ID` (set in your shell or cron env) for Slack DM delivery.

## Usage

This is a documentation / dotfiles package — no build, no runtime consumers. Check out, sync to both targets:

```bash
brazil ws sync --md
# Ralph config
rsync -av --delete src/CanewiwRalphConfig/hats/ ~/.ralph/hats/
cp src/CanewiwRalphConfig/config.yml ~/.ralph/config.yml
# MeshClaw skills
rsync -av --delete src/CanewiwRalphConfig/skills/ ~/.meshclaw/skills/
```

Or symlink from a checkout to keep them live:

```bash
ln -sfn $(pwd)/src/CanewiwRalphConfig/hats ~/.ralph/hats
ln -sfn $(pwd)/src/CanewiwRalphConfig/config.yml ~/.ralph/config.yml
for s in ralph-hats ralph-loop ralph-loop-create; do
  ln -sfn $(pwd)/src/CanewiwRalphConfig/skills/$s ~/.meshclaw/skills/$s
done
```

## Excluded from this package

- `~/.ralph/loops.json` — runtime loop registry, machine-local
- Any `.ralph/` directories inside workspaces — loop-local state
- Other MeshClaw skills under `~/.meshclaw/skills/` unrelated to Ralph
