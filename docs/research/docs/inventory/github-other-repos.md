# GitHub Other Repos — Hat Collection Inventory

> **📸 Snapshot — 2026-04-21.** This document is a point-in-time research artifact captured on 2026-04-21. It is not actively maintained. External sources (GitHub repos, Amazon-internal packages) may have changed since. Scores, links, and findings reflect the state of the world on that date.

## Summary

After extensive searching, **no public GitHub repos outside `mikeyobrien/ralph-orchestrator` ship hat collections that conform to the Ralph hat schema** (YAML with `triggers:`, `publishes:`, `instructions:` under a `hats:` mapping). The Ralph hat system is currently a single-source ecosystem.

The broader "Ralph" community consists of basic loop implementations (bash scripts, PRD-driven iteration) that do NOT use the hat orchestration pattern. These are catalogued below for completeness but are NOT hat collections.

## Repos That DO Use Ralph Hats

### 1. mikeyobrien/ralph-orchestrator (upstream — excluded per task scope)

The canonical source. All hat collections found publicly trace back here. See Phase 1 upstream inventory (not this file's scope).

### 2. mikeyobrien CEO Suite Gist (multi-model hat collection)

| Field | Value |
|-------|-------|
| Source URL | https://gist.github.com/mikeyobrien/b15d22d7979ecae7cdd3f8f9e34d7337 |
| File | `ceo-suite-multimodel-sanitized.yml` |
| Hat count | 9 |
| Hat keys | `chief_of_staff`, `researcher`, `architect`, `ux_designer`, `executor`, `healer`, `verifier`, `developer`, `qa_tester` |
| `starting_event` | `assistant.plan` |
| `completion_promise` | `assistant.complete` |
| Backends | codex (default via `cli.backend: "codex"`), opencode (researcher, ux_designer via object-form `backend`), codex (executor, verifier, developer, qa_tester) |
| Event topology | Hub-and-spoke: chief_of_staff routes to specialists via `*.request`/`*.task` events; specialists report back via `*.done`/`*.blocked`; verifier gates completion |
| Notable fields | `_fragments` (YAML anchors for shared instructions), `working_directory`, `RObot` (Telegram human-in-the-loop), `memories`, `tasks`, `skills`, `guardrails`, `events` (metadata), `max_activations` on healer |
| Notes | Multi-model orchestration (Opus for planning, Kimi/OpenCode for research/UX, Codex for execution). Uses `*.exhausted` wildcard trigger on healer. All 9 hats listed above. Includes confidence-based decision protocol as YAML anchor. |

**Schema compliance notes** (cross-checked against `../../../../skills/ralph-hats/references/schema.md`):
- Uses `backend` as an object (`type` + `args`) on researcher and ux_designer — this is a runtime feature/extension NOT documented in the hat schema reference. The schema documents `backend` as a string and `backend_args`/`args` as a separate field.
- Uses `working_directory` — not in the schema reference. This may be a ralph-orchestrator runtime field, not a hat schema field.
- Uses `extra_instructions` with YAML anchor references (`*confidence_protocol`) — valid per schema.
- `max_activations: 3` on healer — valid per schema.
- `default_publishes` on healer — valid per schema (single string).

## Repos That Do NOT Use Ralph Hats (Basic Loop Implementations)

These repos implement the "Ralph Wiggum technique" (autonomous AI coding loops) but use bash scripts, PRD JSON files, or simple iteration — NOT the hat-based event orchestration schema.

### 3. snarktank/ralph

| Field | Value |
|-------|-------|
| Source URL | https://github.com/snarktank/ralph |
| Stars | 17.5k |
| Description | Original Ralph Wiggum autonomous AI agent loop |
| Hat schema? | **No** — uses Claude Code plugin (`.claude-plugin/`), skills, and flowchart-based iteration. No `triggers:`/`publishes:`/`instructions:` YAML. |

### 4. iannuttall/ralph

| Field | Value |
|-------|-------|
| Source URL | https://github.com/iannuttall/ralph |
| Stars | 890 |
| Description | Minimal, file-based agent loop for autonomous coding |
| Hat schema? | **No** — uses PRD JSON, bash scripts in `.agents/ralph/`, and skills. Loop is file-based state machine, not event-driven hats. |

### 5. subsy/ralph-tui

| Field | Value |
|-------|-------|
| Source URL | https://github.com/subsy/ralph-tui |
| Stars | ~100+ |
| Description | Terminal UI for orchestrating AI coding agents through task lists |
| Hat schema? | **No** — uses PRD JSON, task selection, and agent runner commands. TUI wrapper around basic loop, not hat orchestration. |

### 6. michaelshimeles/ralphy

| Field | Value |
|-------|-------|
| Source URL | https://github.com/michaelshimeles/ralphy |
| Stars | 2.3k |
| Description | Autonomous bash script running Claude Code, Codex, OpenCode, Cursor, Qwen & Droid in a loop |
| Hat schema? | **No** — pure bash loop script. No YAML hat definitions. |

### 7. PageAI-Pro/ralph-loop

| Field | Value |
|-------|-------|
| Source URL | https://github.com/PageAI-Pro/ralph-loop |
| Description | Long-running AI agent loop for software development tasks |
| Hat schema? | **No** — basic task-list iteration loop. |

### 8. ClaytonFarr/ralph-playbook

| Field | Value |
|-------|-------|
| Source URL | https://github.com/ClaytonFarr/ralph-playbook |
| Stars | 957 |
| Description | Comprehensive guide to running autonomous AI coding loops using the Ralph methodology |
| Hat schema? | **No** — documentation/playbook only. No hat YAML files. |

### 9. Th0rgal/open-ralph-wiggum

| Field | Value |
|-------|-------|
| Source URL | https://github.com/Th0rgal/open-ralph-wiggum |
| Stars | ~1k |
| Description | Type `ralph "prompt"` to start Open Code in a ralph loop |
| Hat schema? | **No** — bash wrapper for OpenCode/Claude/Codex. No hat YAML. |

### 10. frankbria/ralph-claude-code

| Field | Value |
|-------|-------|
| Source URL | https://github.com/frankbria/ralph-claude-code |
| Description | Autonomous AI development loop for Claude Code with intelligent exit detection |
| Hat schema? | **No** — Claude Code specific loop wrapper. |

### 11. agrimsingh/ralph-wiggum-cursor

| Field | Value |
|-------|-------|
| Source URL | https://github.com/agrimsingh/ralph-wiggum-cursor |
| Description | Cursor CLI implementation of the Ralph Wiggum autonomous iteration technique |
| Hat schema? | **No** — Cursor-specific loop implementation. |

### 12. ghuntley/how-to-ralph-wiggum

| Field | Value |
|-------|-------|
| Source URL | https://github.com/ghuntley/how-to-ralph-wiggum |
| Stars | 1.2k |
| Description | The Ralph Wiggum Technique methodology documentation |
| Hat schema? | **No** — documentation only (forked from ClaytonFarr/ralph-playbook). |

## Search Methodology

Queries used:
1. `github "ralph-cli" OR "ralph run" yaml hats triggers publishes` (web search)
2. `github "triggers:" "publishes:" "instructions:" extension:yml ralph hats` (web search)
3. `github mikeyobrien ralph-orchestrator presets hats yaml` (web search)
4. `github "builtin:code-assist" OR "builtin:research" OR "builtin:review" ralph-orchestrator yaml -mikeyobrien` (web search)
5. `github "ralph run" "-H" hats yaml collection` (web search)
6. `github ".ralph/hats" yaml triggers publishes instructions -mikeyobrien` (web search)
7. Direct inspection of all candidate repos via `web_fetch`

## Conclusion

The Ralph hat ecosystem is currently a **single-source ecosystem**. All hat collections that conform to the schema originate from `mikeyobrien/ralph-orchestrator` (presets directory) or from mikeyobrien's personal gists/configs. No third-party repos have published independent hat collections.

This means the comparison in later phases will primarily compare the upstream presets against each other and against the CEO Suite gist, rather than comparing across independent authors.

## Sources

- [mikeyobrien/ralph-orchestrator](https://github.com/mikeyobrien/ralph-orchestrator) — accessed 2026-04-20
- [CEO Suite Gist](https://gist.github.com/mikeyobrien/b15d22d7979ecae7cdd3f8f9e34d7337) — accessed 2026-04-20
- [snarktank/ralph](https://github.com/snarktank/ralph) — accessed 2026-04-20
- [iannuttall/ralph](https://github.com/iannuttall/ralph) — accessed 2026-04-20
- [subsy/ralph-tui](https://github.com/subsy/ralph-tui) — accessed 2026-04-20
- [michaelshimeles/ralphy](https://github.com/michaelshimeles/ralphy) — accessed 2026-04-20
- [PageAI-Pro/ralph-loop](https://github.com/PageAI-Pro/ralph-loop) — accessed 2026-04-20
- [ClaytonFarr/ralph-playbook](https://github.com/ClaytonFarr/ralph-playbook) — accessed 2026-04-20
- [Th0rgal/open-ralph-wiggum](https://github.com/Th0rgal/open-ralph-wiggum) — accessed 2026-04-20
- [frankbria/ralph-claude-code](https://github.com/frankbria/ralph-claude-code) — accessed 2026-04-20
- [agrimsingh/ralph-wiggum-cursor](https://github.com/agrimsingh/ralph-wiggum-cursor) — accessed 2026-04-20
- [ghuntley/how-to-ralph-wiggum](https://github.com/ghuntley/how-to-ralph-wiggum) — accessed 2026-04-20
