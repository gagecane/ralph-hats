# Comparison Candidates

> **📸 Snapshot — 2026-04-21.** This document is a point-in-time research artifact captured on 2026-04-21. It is not actively maintained. External sources (GitHub repos, Amazon-internal packages) may have changed since. Scores, links, and findings reflect the state of the world on that date.

10 collections selected for diversity of pattern, scale, and origin. Excludes toy examples (<3 hats) except `research.yml` which demonstrates the minimal-viable-collection pattern.

## Selected Collections

| # | Collection | Source | Hats | Rationale |
|---|-----------|--------|------|-----------|
| 1 | `presets/code-assist.yml` | [GitHub upstream](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/code-assist.yml) | 4 | Canonical implementation workflow; step-wave queue + TDD; most-adopted pattern internally |
| 2 | `presets/autoresearch.yml` | [GitHub upstream](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/autoresearch.yml) | 5 | Autonomous experiment loop with LLM-as-judge scoring; unique cyclic topology |
| 3 | `presets/debug.yml` | [GitHub upstream](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/debug.yml) | 4 | Scientific method for debugging; strong `default_publishes` usage for pessimistic defaults |
| 4 | `presets/research.yml` | [GitHub upstream](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/research.yml) | 2 | Minimal-viable-collection pattern; proves 2 hats can be effective with tight discipline |
| 5 | `presets/wave-review.yml` | [GitHub upstream](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/wave-review.yml) | 3 | Fan-out/fan-in parallel execution; `concurrency` + `aggregate` extensions; `disallowed_tools` |
| 6 | `presets/pdd-to-code-assist.yml` | [GitHub upstream](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/pdd-to-code-assist.yml) | 11 | Largest preset; full idea-to-code pipeline; adversarial self-debate; tests scalability limits |
| 7 | `ralph.reviewer.yml` | [GitHub upstream](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.reviewer.yml) | 4 | Read-only review pipeline; strong guardrails; git worktree isolation pattern |
| 8 | CEO Suite Gist | [GitHub gist](https://gist.github.com/mikeyobrien/b15d22d7979ecae7cdd3f8f9e34d7337) | 9 | Multi-model hub-and-spoke; `max_activations` on healer; `*.exhausted` wildcard recovery |
| 9 | ElcidRalph `feature-dev-e2e.yml` | [code.amazon.com/packages/ElcidRalph](https://code.amazon.com/packages/ElcidRalph/blobs/mainline/--/frontend-dev-hats/hats/feature-dev-e2e.yml) | 10 | Most complex internal collection; Figma sync, dual review (UX + code), Cypress E2E, CR posting |
| 10 | PcadWiki `cr-comment-actioner.yml` | [code.amazon.com/packages/PcadWiki](https://code.amazon.com/packages/PcadWiki/blobs/mainline/--/skills/cr-auto-action/hats/cr-comment-actioner.yml) | 9 | CR automation pipeline; 9 hats with triager→fixer→verifier→self_reviewer→e2e_prover→uploader→monitor→replier→notifier; unique domain |

## Excluded (with reason)

| Collection | Reason |
|-----------|--------|
| `ralph.m.yml` (7 hats, infinite loop) | No `completion_promise` — intentionally infinite; can't score completion semantics meaningfully |
| `ralph.qa.yml` (6 hats) | Superset of `ralph.yml` which is itself a subset of `code-assist.yml`; redundant pattern |
| `ralph.bot.yml` (3 hats) | Human-in-the-loop Telegram bot; interesting but too domain-specific and never self-terminates |
| AudschmiAICapabilities research-and-rank (7 hats) | Similar research pipeline pattern to autoresearch; would duplicate the "research" archetype |
| CoverageAICapabilities integration-test-assist (6 hats) | Standard gate→scan→write→review→validate pattern; well-executed but not structurally novel vs code-assist |
| DevicesConjointSurveyApplication amzn-code-assist (7 hats) | Prompt validation gate is interesting but collection has dead-end risk (commit-curator → ?) |
| CSDefectRepeatContactsPOC backtest (4 hats) | Unique ML pattern but too domain-specific; only 4 hats with narrow applicability |
| `presets/review.yml` (3 hats) | Superseded by `wave-review.yml` which demonstrates the same domain with more advanced patterns |

## Sources

- docs/inventory/github-upstream-presets.md
- docs/inventory/github-upstream-toplevel.md
- docs/inventory/github-upstream-fixtures.md
- docs/inventory/github-other-repos.md
- docs/inventory/internal-ralph-direct.md
- docs/inventory/internal-similar-patterns.md
- docs/rubric.md
