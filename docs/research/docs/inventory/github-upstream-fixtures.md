# GitHub Upstream Fixtures & Examples — Inventory

> **📸 Snapshot — 2026-04-21.** This document is a point-in-time research artifact captured on 2026-04-21. It is not actively maintained. External sources (GitHub repos, Amazon-internal packages) may have changed since. Scores, links, and findings reflect the state of the world on that date.

## Summary

Searched `mikeyobrien/ralph-orchestrator` for hat collections outside the main `presets/*.yml` files. Found test scenario YAML files in `crates/ralph-core/tests/scenarios/` that define hat-like structures for integration testing, but these use a **test-specific schema** (not the standard hat overlay schema). No standalone hat collection files were found in `examples/`, `.ralph/`, `crates/*/tests/fixtures/`, `bench/`, or `.eval/`.

## Locations Searched

| Path | Contents | Hat Collections? |
|------|----------|-----------------|
| `crates/ralph-core/tests/scenarios/` | 5 YAML test scenario files | ⚠️ Test schema only (see below) |
| `crates/ralph-core/tests/fixtures/` | JSONL session recordings, `kiro/`, `kiro-acp/`, `rpc-v1/`, `skills/` subdirs | No |
| `crates/ralph-e2e/` | E2E test harness (generates configs in Rust code) | No (programmatic) |
| `examples/` | `hooks/` dir, `cli_tool.md`, `simple-task.md` | No |
| `.ralph/` | `agent/`, `specs/`, `tasks/` subdirs | No |
| `.eval/` | `.gitignore` only | No |
| `bench/` | `tasks/` dir, `tasks.json`, `.gitignore` | No |
| `cassettes/` | `e2e/`, `event-routing/` (JSONL recordings) | No |
| `presets/minimal/` | Backend-specific runtime configs (12 files) | Embedded hats in full configs (not overlay files) |

## Test Scenario Files (Non-Standard Schema)

These files live at `crates/ralph-core/tests/scenarios/` and test Ralph's event loop behavior. They use a **test harness schema** that differs from the user-facing hat overlay schema.

### Schema Differences from Standard Hats

| Standard Hat Field | Test Scenario Equivalent | Notes |
|---|---|---|
| `triggers` | `subscribes_to` | Different key name |
| `publishes` | (implicit from `expected.events`) | Not declared on hat |
| `instructions` | (not present) | Test uses `mock_responses` instead |
| `name` / `description` | (top-level only) | Not per-hat |
| N/A | `mock_responses` | Test-only: scripted LLM outputs |
| N/A | `expected` | Test-only: assertions block |
| N/A | `config` | Test-only: runtime config inline |

### File: `default_publishes.yml`

- **Source**: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/crates/ralph-core/tests/scenarios/default_publishes.yml
- **Purpose**: Tests fallback mechanism when a hat doesn't emit an expected event
- **Hat count**: 1 (`builder`)
- **Hat keys**: `builder`
- **Event topology**: `build.task` → (default inject) `build.done` → `LOOP_COMPLETE`
- **Notable**: Demonstrates `default_publishes` injection — the hat "forgets" to publish, and Ralph injects the default event

### File: `mixed_backends.yml`

- **Source**: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/crates/ralph-core/tests/scenarios/mixed_backends.yml
- **Purpose**: Tests per-hat backend resolution (different hats use different CLI backends)
- **Hat count**: 2 (`builder`, `reviewer`)
- **Hat keys**: `builder`, `reviewer`
- **Event topology**: `build.task` → `build.done` → `review.complete` → `LOOP_COMPLETE`
- **Backends**: `claude` (builder), `kiro` with `agent: reviewer` (reviewer)
- **Notable**: Shows structured `backend` field as object (`type: kiro`, `agent: reviewer`) — this is a test-schema extension, not standard hat schema. Standard schema uses `backend` as a string.

### File: `multi_hat.yml`

- **Source**: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/crates/ralph-core/tests/scenarios/multi_hat.yml
- **Purpose**: Tests event routing between multiple hats with Ralph coordinating
- **Hat count**: 2 (`builder`, `reviewer`)
- **Hat keys**: `builder`, `reviewer`
- **Event topology**: `build.task` → `build.done` → `review.complete` → `LOOP_COMPLETE`
- **Notable**: Canonical builder→reviewer pipeline pattern

### File: `orphaned_events.yml`

- **Source**: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/crates/ralph-core/tests/scenarios/orphaned_events.yml
- **Purpose**: Tests Ralph's fallback handling of events with no hat subscriber
- **Hat count**: 1 (`builder`)
- **Hat keys**: `builder`
- **Event topology**: `unknown.event` → (Ralph handles) → `LOOP_COMPLETE`
- **Notable**: Demonstrates that Ralph itself is the fallback handler for unrouted events. Uses `ralph_handled` assertion field.

### File: `solo_mode.yml`

- **Source**: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/crates/ralph-core/tests/scenarios/solo_mode.yml
- **Purpose**: Tests Ralph operating with no hats at all
- **Hat count**: 0 (empty `hats: {}`)
- **Hat keys**: (none)
- **Event topology**: → `LOOP_COMPLETE`
- **Notable**: Proves Ralph can complete a loop without any hats defined

## `presets/minimal/code-assist.yml` (Embedded Hat in Full Config)

- **Source**: https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/code-assist.yml
- **Purpose**: Minimal backend-specific runtime config with embedded hat definition
- **Hat count**: 1 (`builder`)
- **Hat keys**: `builder`
- **Event topology**: `build.task` / `task.start` → `build.done` / `build.blocked`
- **Backend**: `claude`
- **Notable**: This is a full runtime config (includes `event_loop`, `cli`, `core` sections) with a `hats:` section embedded. Uses standard hat fields (`name`, `description`, `triggers`, `publishes`, `instructions`). The `triggers` field includes `task.start` which violates the reserved trigger rule in schema.md — likely acceptable because this is the "code-assist" builtin where Ralph delegates `task.start` to the builder.

## Conclusion

The upstream repo does **not** contain standalone hat collection files outside `presets/`. The test scenarios use a different schema designed for deterministic testing (mock responses, assertions). The `presets/minimal/` directory contains full runtime configs with embedded hats, not hat overlay files.

For the comparison task, the test scenarios are **not suitable as hat collections to score** — they're test infrastructure. The real hat collections in this repo are exclusively in `presets/*.yml` (the supported builtins: `autoresearch`, `code-assist`, `debug`, `research`, `review`, `pdd-to-code-assist`, `wave-review`, `hatless-baseline`).

## Sources

- [crates/ralph-core/tests/scenarios/ directory](https://github.com/mikeyobrien/ralph-orchestrator/tree/main/crates/ralph-core/tests/scenarios) — accessed 2026-04-20
- [crates/ralph-core/tests/fixtures/ directory](https://github.com/mikeyobrien/ralph-orchestrator/tree/main/crates/ralph-core/tests/fixtures) — accessed 2026-04-20
- [presets/ directory](https://github.com/mikeyobrien/ralph-orchestrator/tree/main/presets) — accessed 2026-04-20
- [presets/minimal/ directory](https://github.com/mikeyobrien/ralph-orchestrator/tree/main/presets/minimal) — accessed 2026-04-20
- [presets/minimal/code-assist.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/code-assist.yml) — accessed 2026-04-20
- [presets/wave-review.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/wave-review.yml) — accessed 2026-04-20
- [crates/ralph-e2e/ README](https://github.com/mikeyobrien/ralph-orchestrator/tree/main/crates/ralph-e2e) — accessed 2026-04-20
- [examples/ directory](https://github.com/mikeyobrien/ralph-orchestrator/tree/main/examples) — accessed 2026-04-20
- [.ralph/ directory](https://github.com/mikeyobrien/ralph-orchestrator/tree/main/.ralph) — accessed 2026-04-20
- [cassettes/event-routing/ directory](https://github.com/mikeyobrien/ralph-orchestrator/tree/main/cassettes/event-routing) — accessed 2026-04-20
