# Hat Selection — Decision Tree

Read `~/.ralph/hats/README.md` first. This reference adds selection rationale and anti-patterns beyond the README's quick-selection table.

## Decision tree

```
What is the deliverable?

├── A written analysis / decision document
│   └── Is the question well-scoped or does it require multiple investigation waves?
│       ├── Multiple waves, citations matter → research.yml
│       └── Single pass, pure lookup → often overkill, consider doing it manually
│
├── Code changes with tests
│   ├── A known fix with clear acceptance criteria → code-assist.yml
│   ├── A large change whose decomposition itself is risky → lisamarge-pdd.yml → code-assist.yml
│   ├── A bug with unknown root cause → debug.yml
│   └── A pipeline failure that may or may not need a CR → pipeline-debug.yml
│
├── A code review of someone else's CR → review.yml
│
├── A narrative document (six-pager, PR-FAQ, arch doc) → writing.yml
│
└── Optimization toward a measurable metric (benchmark-driven) → autoresearch.yml
    └── Only if: benchmark command exists, primary metric has direction, OK running hours
```

## When the 2-hat research collection is enough

`research.yml` (Researcher → Synthesizer) works for most qualitative investigations because:
- Synthesizer defaults to `research.followup` (another wave), not completion — erring toward thoroughness
- Researcher is forbidden from modifying code or speculating without citations
- Multiple waves naturally map to sections of a final deliverable

## Why `autoresearch.yml` is usually the wrong choice

Its 5 hats are Strategist → Implementer → **Benchmarker → Judge → Evaluator**. It exists to run tens-to-hundreds of experimental iterations against a measurable metric.

Do NOT pick it because "more hats feels more thorough." Signs you should NOT use autoresearch:
- The deliverable is a written recommendation, not a tuned implementation
- There is no benchmark command that can distinguish "better" from "worse"
- The work is qualitative (architecture review, prioritization, RCA)
- You expect <10 iterations of real work

Use `research.yml` for investigation; use `autoresearch.yml` only for genuine optimization loops.

## When to pick `lisamarge-pdd.yml` as a pre-stage

`lisamarge-pdd.yml` is a **2-hat Planner ↔ Reviewer loop that produces a `PDD.md`** (no code). It is designed to run *before* `code-assist.yml` for work where decomposition is the risky part.

Pick it when:
- The work spans multiple files/packages/phases and prior loops thrashed on bad subtasking
- You want a reviewable plan artifact before any code is written
- You want to front-load decomposition cost on cheap planner tokens

Do NOT pick it for:
- Small-to-medium work — `code-assist.yml`'s in-loop Planner is sufficient
- Work that still needs exploration — run `research.yml` / `debug.yml` first, then `lisamarge-pdd.yml`, then `code-assist.yml`

Handoff: the Reviewer writes `APPROVED.md` when all ChangeSpecs pass the 4 gates (Specificity, Context Constraint, Containment, Stability). Launch `code-assist.yml` next against `PDD.md`.

## When to pick `pipeline-debug.yml` vs `debug.yml`

Both cover bug investigation. The difference is the final two hats.

- **`debug.yml`** (4 hats) — ends at Verifier. You want RCA + a local fix verified locally. No CR submission.
- **`pipeline-debug.yml`** (6 hats) — adds a **Reproducer** stage that insists on reproducing the failure in a Brazil workspace (the biggest filter against wrong hypotheses) and a **Gatekeeper + Submitter** pair that only submits a CR when confidence is high enough, with graceful degradation to RCA-only.

Pick `pipeline-debug.yml` when the failure came from a pipeline and the agent should be allowed to try to fix it. Pick `debug.yml` when the bug came from a local environment or you specifically want RCA only.

## Anti-patterns

### Picking a collection by hat count
More hats ≠ better outcome. Each extra hat adds ceremony, more events, more chances for thrash. The 2-hat `research.yml` beats `autoresearch.yml` for investigation work.

### Mixing collections
Do not combine two hat files. Ralph loads one `-H` argument. If the goal spans two clearly different phases, run two sequential loops instead.

### Hand-rolling a new topology for a one-off
If the curated collections don't fit, stop and talk to the user. A one-off hat topology is a maintenance liability. Use the `ralph-hats` skill to propose a new curated collection only when the use case is recurring.

### Loading a writing collection for a lookup
`writing.yml` has 6 hats and enforces Amazon writing standards at every gate. Overkill for a Slack post or short summary. Use it only for six-pagers, PR-FAQs, or architecture docs substantial enough to justify 6 stages.

## Reference: the full collection catalog

See `~/.ralph/hats/README.md` for:
- Per-collection scores (rubric: 8 criteria, 25.5 max)
- "Use when" and "Do not use when" bullets
- Upstream sources and distillation notes
