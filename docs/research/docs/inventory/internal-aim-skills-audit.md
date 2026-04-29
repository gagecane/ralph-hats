# Internal AIM Skills Audit — Ralph Hat Schema Matches

> **📸 Snapshot — 2026-04-21.** This document is a point-in-time research artifact captured on 2026-04-21. It is not actively maintained. External sources (GitHub repos, Amazon-internal packages) may have changed since. Scores, links, and findings reflect the state of the world on that date.

## Summary

**No YAML files matching the Ralph hat schema (containing `triggers:` + `publishes:`) were found** in any AIM package or skill directory on this host.

## Directories Scanned

### `/home/canewiw/.aim/packages/`

| Package | Latest Event ID | File Types Found | Hat-Schema Match |
|---------|----------------|-----------------|-----------------|
| AIPowerUserCapabilities-1.0 | eventId-6446127837 | `.json` (agent-specs), `.md` (skills, SOPs, context) | ❌ No |
| AmazonBuilderCoreAIAgents-1.0 | eventId-6446418849 | `.md` (skills, references) | ❌ No |
| MeshClawAICapabilities-1.0 | eventId-6446055020 | `.md` (skills), `.py`/`.sh` (scripts) | ❌ No |
| AtlasAICapabilities-1.0 | eventId-6446428865 | binary hooks, context | ❌ No |
| local/TalonAiCapabilities-1.0 | N/A | `.md` (skills), `.py`/`.sh` (scripts) | ❌ No |

### `/home/canewiw/.aim/skills/`

| Skill Directory | Contents | Hat-Schema Match |
|----------------|----------|-----------------|
| local/ralph-hats | SKILL.md, references/{schema,examples,commands}.md, agents/openai.yaml | ❌ No (reference docs *about* the schema, not hat collections) |
| local/ralph-loop | SKILL.md, references/{commands,diagnostics}.md, agents/openai.yaml | ❌ No (operational skill, not a hat collection) |
| local/agent-task-loop → /workplace/canewiw/TalonAiCapabilities/src/TalonAiCapabilities/skills/agent-task-loop | SKILL.md | ❌ No |
| AIPowerUserCapabilities/ (57 skills) | SKILL.md per skill, scripts/, references/ | ❌ No |
| ScheduledCoverageBooster/coverage-boost | SKILL.md | ❌ No |

## Search Methodology

1. **YAML file scan**: `find /home/canewiw/.aim/ -name "*.yml" -o -name "*.yaml"` — found only 2 files: `ralph-hats/agents/openai.yaml` and `ralph-loop/agents/openai.yaml`. Both are AIM skill interface definitions (containing `interface:`, `display_name:`, `policy:`), not Ralph hat collections.

2. **Co-occurrence grep**: Searched all files under `/home/canewiw/.aim/packages/` and `/home/canewiw/.aim/skills/` for files containing both `triggers:` and `publishes:`. Only matches were the ralph-hats reference documentation files (`schema.md`, `examples.md`) which describe the schema but are not hat collections themselves.

3. **Event-driven pattern search**: Searched for `event_loop`, `starting_event`, `completion_promise` across all of `.aim/`. Only matches were binary files in AtlasAICapabilities hooks (irrelevant).

## Conceptually Related Patterns (Non-Ralph)

### AIM Agent Specs (`.agent-spec.json`)

AIM uses a different orchestration paradigm. Agent specs define:
- `name`, `schemaVersion`, `clientConfig` (tool permissions, allowed commands)
- `skills` (loaded capabilities)
- `context` (injected documents)
- Subagent delegation via `spawn_run(agent="<name>")`

This is **request-response delegation**, not event-driven pub/sub. There is no equivalent of `triggers:` (subscribe to topic) or `publishes:` (emit to topic). Routing is either explicit (user picks agent) or intent-classified (MeshClaw agent-router).

Source: `/home/canewiw/.aim/packages/AIPowerUserCapabilities-1.0/eventId-6446127837/agents/gpu-multiagent.agent-spec.json`

### MeshClaw Agent Router

Three-layer routing (keyword regex → embedding similarity → LLM conductor) that classifies user intent and delegates to specialist agents. Conceptual mapping to Ralph:

| Ralph Concept | MeshClaw Equivalent | Difference |
|--------------|--------------------|-----------| 
| Hat `triggers:` | Keyword patterns + embedding index | Ralph subscribes to named events; MeshClaw classifies free-text intent |
| Hat `publishes:` | No equivalent | MeshClaw agents don't emit events to other agents |
| `event_loop` | Session lifecycle | No explicit event graph; single request-response per delegation |
| `completion_promise` | No equivalent | No multi-agent workflow completion signal |

Source: `/home/canewiw/.aim/packages/MeshClawAICapabilities-1.0/eventId-6446055020/skills/agent-router/SKILL.md`

## Conclusion

The AIM ecosystem on this host uses a fundamentally different orchestration model from Ralph hats. AIM agents are invoked via direct delegation or intent classification, not event-driven pub/sub. No hat collections or hat-schema-compatible YAML exist in any AIM package or skill directory.
