# Hats Configuration Comparison

> **📸 Snapshot — 2026-04-21.** This document is a point-in-time research artifact captured on 2026-04-21. It is not actively maintained. External sources (GitHub repos, Amazon-internal packages) may have changed since. Scores, links, and findings reflect the state of the world on that date.

Research and comparison of Ralph-orchestrator "hats" configurations across public GitHub and Amazon internal sources.

## What Was Researched

This project catalogues and scores hat collections — YAML-defined multi-persona configurations for the [ralph-orchestrator](https://github.com/mikeyobrien/ralph-orchestrator) event-driven agent framework. Each hat defines a persona with triggers, publish events, instructions, and optional backend overrides. Collections wire hats together into topologies that route work through planning, implementation, review, and finalization phases.

## Sources Covered

- **GitHub upstream** (`mikeyobrien/ralph-orchestrator`): 8 presets, 8 top-level configs, 11 minimal/backend-only configs, 5 test scenarios
- **GitHub other**: 1 public gist (CEO Suite multi-model)
- **Amazon internal (direct Ralph usage)**: 45+ hat collections across 30+ packages found via InternalCodeSearch
- **Amazon internal (similar patterns)**: 4 non-Ralph agent orchestration systems with analogous architectures

## Catalogue Size

- **82 hat collections** inventoried total
- **10 collections** scored against an 8-criterion rubric (those with ≥3 hats and non-trivial instructions)
- **7 patterns** identified worth adopting
- **4 anti-patterns** documented to avoid

## Key Findings

1. **`code-assist.yml` is the gold standard** — scored 23.5/25.5 (Exemplary). Its 4-hat topology (planner→builder→critic→finalizer) with pessimistic `default_publishes` on the critic is the most robust pattern found.
2. **3–5 hats is the sweet spot** — collections exceeding 6 hats consistently score lower on Focus and Completion Semantics. The 11-hat `pdd-to-code-assist.yml` scored only 16.0 despite excellent instruction quality.
3. **Pessimistic defaults prevent silent failures** — top collections set `default_publishes` to the rejection event on gate hats, so LLM silence means "retry" not "pass."
4. **Amazon internal adoption is broad but shallow** — most internal collections are lightly-modified copies of upstream presets. The standout exceptions are `PcadWiki/cr-comment-actioner.yml` (22.5, novel CR automation topology) and `CoverageAICapabilities` (3 specialized presets for test coverage workflows).
5. **Separation of investigation from action** is the highest-leverage pattern for reducing wasted iterations — hats that analyze should be forbidden from modifying state.

## Deliverables

| File | Description |
|------|-------------|
| [`INVENTORY.md`](./INVENTORY.md) | Raw catalogue of all 82 hat collections with source URLs, hat counts, event topology, and notes |
| [`COMPARISON.md`](./COMPARISON.md) | Scored comparison of 10 high-quality collections, patterns to adopt, anti-patterns to avoid, and recommendations |
| [`docs/rubric.md`](./docs/rubric.md) | Full 8-criterion scoring rubric with anchors |
| [`docs/comparison/scores.md`](./docs/comparison/scores.md) | Detailed per-criterion rationale with evidence citations |
| [`docs/comparison/patterns.md`](./docs/comparison/patterns.md) | Deep analysis of 7 patterns from top collections |
| [`docs/comparison/antipatterns.md`](./docs/comparison/antipatterns.md) | Deep analysis of 4 anti-patterns from weaker collections |
| [`docs/inventory/`](./docs/inventory/) | Per-source inventory research files |
