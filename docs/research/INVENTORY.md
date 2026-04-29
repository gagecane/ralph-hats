# Hat Collection Inventory

> **📸 Snapshot — 2026-04-21.** This document is a point-in-time research artifact captured on 2026-04-21. It is not actively maintained. External sources (GitHub repos, Amazon-internal packages) may have changed since. Scores, links, and findings reflect the state of the world on that date.

Raw catalogue of every hat collection found across GitHub and Amazon internal sources.

---

## GitHub Upstream — Presets (`mikeyobrien/ralph-orchestrator`)

| Collection | Source URL | Hats | Hat Keys | starting_event | completion_promise | Notes |
|---|---|---|---|---|---|---|
| autoresearch.yml | [presets/autoresearch.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/autoresearch.yml) | 5 | strategist, implementer, benchmarker, judge, evaluator | `experiment.start` | `LOOP_COMPLETE` | Autonomous experiment loop; LLM-as-judge scoring; 8h runtime cap |
| code-assist.yml | [presets/code-assist.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/code-assist.yml) | 4 | planner, builder, critic, finalizer | `build.start` | `LOOP_COMPLETE` | Default implementation workflow; step-wave queue; strict TDD |
| debug.yml | [presets/debug.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/debug.yml) | 4 | investigator, tester, fixer, verifier | `debug.start` | `DEBUG_COMPLETE` | Scientific method debugging; hypothesize→test→fix→verify |
| research.yml | [presets/research.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/research.yml) | 2 | researcher, synthesizer | `research.start` | `RESEARCH_COMPLETE` | Read-only exploration; step-wave research plan |
| review.yml | [presets/review.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/review.yml) | 3 | reviewer, analyzer, closer | `review.start` | `REVIEW_COMPLETE` | Staged adversarial code review; one deep-analysis wave at a time |
| wave-review.yml | [presets/wave-review.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/wave-review.yml) | 3 | coordinator, reviewer, synthesizer | `review.start` | `review.complete` | Parallel fan-out/fan-in review; concurrency:3; disallowed_tools on synthesizer |
| pdd-to-code-assist.yml | [presets/pdd-to-code-assist.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/pdd-to-code-assist.yml) | 11 | inquisitor, architect, design_critic, explorer, planner, task_writer, builder, critic, finalizer, validator, committer | `design.start` | `LOOP_COMPLETE` | Full idea-to-committed-code; 3 phases (Design/Planning/Implementation); adversarial self-debate |
| hatless-baseline.yml | [presets/hatless-baseline.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/hatless-baseline.yml) | 0 | — | `task.start` | `LOOP_COMPLETE` | Control preset for testing core loop without hats |

## GitHub Upstream — Top-Level Configs (`mikeyobrien/ralph-orchestrator`)

| Collection | Source URL | Hats | Hat Keys | starting_event | completion_promise | Notes |
|---|---|---|---|---|---|---|
| ralph.yml | [ralph.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.yml) | 4 | planner, builder, reviewer, finalizer | `work.start` | `LOOP_COMPLETE` | Canonical dev loop; backpressure gates; pi backend |
| ralph.qa.yml | [ralph.qa.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.qa.yml) | 6 | planner, builder, reviewer, qa_planner, qa_tester, finalizer | `work.start` | `LOOP_COMPLETE` | QA stage between review and finalization; tmux-based testing |
| ralph.pi.yml | [ralph.pi.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.pi.yml) | 1 | default | — | `LOOP_COMPLETE` | Backend config layer only (kiro/claude-opus) |
| ralph.reviewer.yml | [ralph.reviewer.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.reviewer.yml) | 4 | scoper, verifier, reviewer, synthesizer | `review.start` | `LOOP_COMPLETE` | Read-only code review pipeline; git worktree isolation |
| ralph.m.yml | [ralph.m.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.m.yml) | 7 | explorer, builder, verifier, shipper, deployer, analyst, writer | `improve.start` | — (infinite) | Infinite improvement loop; explore→build→ship→deploy→analyze |
| ralph.bot.yml | [ralph.bot.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.bot.yml) | 3 | planner, executor, reviewer | `plan.start` | `LOOP_COMPLETE` | Human-in-the-loop Telegram bot; codex backend for executor |
| ralph.e2e.yml | [ralph.e2e.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.e2e.yml) | 4 | planner, builder, validator, committer | `build.start` | `LOOP_COMPLETE` | E2E test development; strict TDD; kiro backend |
| ralph.roo.yml | [ralph.roo.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/ralph.roo.yml) | 0 | — | — | — | Backend config only (roo via AWS Bedrock) |

## GitHub Upstream — Minimal Presets (`presets/minimal/`)

| Collection | Source URL | Hats | Hat Keys | starting_event | completion_promise | Notes |
|---|---|---|---|---|---|---|
| minimal/code-assist.yml | [minimal/code-assist.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/code-assist.yml) | 1 | builder | `task.start` | `LOOP_COMPLETE` | Single-hat; delegates to external SOP file |
| minimal/smoke.yml | [minimal/smoke.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/smoke.yml) | 0 | — | — | `LOOP_COMPLETE` | Smoke test; haiku model; 5min timeout |
| minimal/amp.yml | [minimal/amp.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/amp.yml) | 0 | — | — | `LOOP_COMPLETE` | Backend-only (amp) |
| minimal/builder.yml | [minimal/builder.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/builder.yml) | 0 | — | — | `LOOP_COMPLETE` | Backend-only (builder) |
| minimal/claude.yml | [minimal/claude.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/claude.yml) | 0 | — | — | `LOOP_COMPLETE` | Backend-only (claude) |
| minimal/codex.yml | [minimal/codex.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/codex.yml) | 0 | — | — | `LOOP_COMPLETE` | Backend-only (codex) |
| minimal/gemini.yml | [minimal/gemini.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/gemini.yml) | 0 | — | — | `LOOP_COMPLETE` | Backend-only (gemini) |
| minimal/kiro.yml | [minimal/kiro.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/kiro.yml) | 0 | — | — | `LOOP_COMPLETE` | Backend-only (kiro) |
| minimal/opencode.yml | [minimal/opencode.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/opencode.yml) | 0 | — | — | `LOOP_COMPLETE` | Backend-only (opencode) |
| minimal/preset-evaluator.yml | [minimal/preset-evaluator.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/preset-evaluator.yml) | 0 | — | — | `LOOP_COMPLETE` | Backend-only (preset evaluator) |
| minimal/roo.yml | [minimal/roo.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/roo.yml) | 0 | — | — | `LOOP_COMPLETE` | Backend-only (roo) |
| minimal/test.yml | [minimal/test.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/presets/minimal/test.yml) | 0 | — | — | `LOOP_COMPLETE` | Backend-only (test) |

## GitHub — Other Repos (Gists)

| Collection | Source URL | Hats | Hat Keys | starting_event | completion_promise | Notes |
|---|---|---|---|---|---|---|
| CEO Suite (multi-model) | [gist: ceo-suite-multimodel-sanitized.yml](https://gist.github.com/mikeyobrien/b15d22d7979ecae7cdd3f8f9e34d7337) | 9 | chief_of_staff, researcher, architect, ux_designer, executor, healer, verifier, developer, qa_tester | `assistant.plan` | `assistant.complete` | Hub-and-spoke; multi-model (Opus/Kimi/Codex); *.exhausted wildcard; max_activations on healer |

## GitHub — Test Scenarios (non-standard schema, not scoreable)

| Collection | Source URL | Hats | Hat Keys | starting_event | completion_promise | Notes |
|---|---|---|---|---|---|---|
| default_publishes.yml | [scenarios/default_publishes.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/crates/ralph-core/tests/scenarios/default_publishes.yml) | 1 | builder | `build.task` | `LOOP_COMPLETE` | Tests default_publishes injection |
| mixed_backends.yml | [scenarios/mixed_backends.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/crates/ralph-core/tests/scenarios/mixed_backends.yml) | 2 | builder, reviewer | `build.task` | `LOOP_COMPLETE` | Tests per-hat backend resolution |
| multi_hat.yml | [scenarios/multi_hat.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/crates/ralph-core/tests/scenarios/multi_hat.yml) | 2 | builder, reviewer | `build.task` | `LOOP_COMPLETE` | Tests multi-hat event routing |
| orphaned_events.yml | [scenarios/orphaned_events.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/crates/ralph-core/tests/scenarios/orphaned_events.yml) | 1 | builder | `unknown.event` | `LOOP_COMPLETE` | Tests orphan event fallback handling |
| solo_mode.yml | [scenarios/solo_mode.yml](https://github.com/mikeyobrien/ralph-orchestrator/blob/main/crates/ralph-core/tests/scenarios/solo_mode.yml) | 0 | — | — | `LOOP_COMPLETE` | Tests hatless operation |

## Amazon Internal — Direct Ralph Usage

| Collection | Source (code.amazon.com) | Hats | Hat Keys | starting_event | completion_promise | Notes |
|---|---|---|---|---|---|---|
| faq-automation.yml | AISkills-iamsukh: skills/faq-automation/ralph/faq-automation.yml | 7 | planner, slack-extractor, email-extractor, extraction-reviewer, enricher, synthesizer, faq-reviewer | `work.start` | `LOOP_COMPLETE` | Multi-source FAQ extraction with review gates |
| agent-builder.yml | AISkills-iamsukh: skills/agent-builder/ralph/agent-builder.yml | 4 | researcher, designer, builder, reviewer | `work.start` | `LOOP_COMPLETE` | Agent scaffolding with research phase |
| qa-playwright.yml | ASBXAgentOrchestration: .ralph/hats/qa-playwright.yml | 4 | planner, smoke-tester, functional-tester, reporter | `qa.start` | `QA_COMPLETE` | Playwright-based QA testing |
| code-assist.yml | AgentCoreInternalAgents: ralph/code-assist.yml | 5 | resumption_gate, planner, builder, critic, finalizer | `resume.check` | `LOOP_COMPLETE` | Code-assist with resumption gate; 29KB |
| build-review.yml | AllDevScriptsForJfengz: ralph_workflow/build-review.yml | 2 | builder, reviewer | `build.start` | `LOOP_COMPLETE` | Minimal builder→reviewer |
| plan-build-review.yml | AllDevScriptsForJfengz: ralph_workflow/archive/plan-build-review.yml | 3 | planner, builder, reviewer | `build.start` | `LOOP_COMPLETE` | Archived 3-hat variant |
| brazil-code-assist.yml | AmazonBuilderPiExtensions: skills/ralph/hats/brazil-code-assist.yml | 4 | planner, builder, critic, finalizer | `build.start` | `LOOP_COMPLETE` | Brazil-optimized code-assist |
| ralph.yml | AmazonDevicesAutoCompleteCDK: ralph.yml | 4 | planner, builder, reviewer, finalizer | `work.start` | `LOOP_COMPLETE` | Standard 4-hat; kiro backend |
| ralph.yml | AnsAiPlayground: ralph.yml | 6 | planner, builder, reviewer, qa-planner, qa-tester, finalizer | `work.start` | `LOOP_COMPLETE` | QA-extended preset |
| task-tracker.yml | Anti-Entropy-Package: .ralph/hats/task-tracker.yml | 4 | planner, builder, reviewer, finalizer | `work.start` | `LOOP_COMPLETE` | Task tracker app build |
| crux-usecase-refine.yml | AudschmiAICapabilities: ralph/crux-usecase-refine.yml | 5 | author, reviewer, ranker, debater, finalizer | `work.start` | `LOOP_COMPLETE` | Use-case refinement with adversarial debater |
| crux-usecase-discovery.yml | AudschmiAICapabilities: ralph/crux-usecase-discovery.yml | 7 | planner, researcher, synthesizer, author, reviewer, ranker, debater/finalizer | `work.start` | `LOOP_COMPLETE` | Full research→synthesis→authoring→ranking |
| research-and-plan.yml | AudschmiAICapabilities: ralph/research-and-plan.yml | 6 | planner, researcher, synthesizer, author, reviewer, finalizer | `work.start` | `LOOP_COMPLETE` | Research→plan with YAGNI reviewer |
| research-and-rank.yml | AudschmiAICapabilities: ralph/research-and-rank.yml | 7+ | planner, researcher, synthesizer, author, reviewer, ranker, debater, finalizer | `work.start` | `LOOP_COMPLETE` | Research→rank with technical reviewer |
| feature-flags.yml | AwsTcExperimentServiceCDK: .ralph/hats/feature-flags-user-segments.yml | 2 | builder, reviewer | `build.start` | `LOOP_COMPLETE` | Focused 2-hat for single feature |
| ralph.yml | AwsTcOpExLeadership: ralph.yml | 3 | validator, implementer, reviewer | `work.start` | `LOOP_COMPLETE` | Validator-first pattern |
| brazil-cdk.yml | AwsTcRalphOrchestrator: collections/brazil-cdk.yml | 5 | analyzer, implementer, builder, tester, finalizer | `cdk.start` | `LOOP_COMPLETE` | CDK-specific pipeline |
| brazil-cdk-deploy.yml | AwsTcRalphOrchestrator: collections/brazil-cdk-deploy.yml | 7 | analyzer, implementer, builder, tester, cdk-deployer, integration-tester, finalizer | `cdk.start` | `LOOP_COMPLETE` | CDK with deploy + integration testing |
| brazil-simple.yml | AwsTcRalphOrchestrator: collections/brazil-simple.yml | 2 | builder, finalizer | `build.start` | `LOOP_COMPLETE` | Minimal 2-hat for simple Brazil tasks |
| brazil-python.yml | AwsTcRalphOrchestrator: collections/brazil-python.yml | 2 | builder, finalizer | `build.start` | `LOOP_COMPLETE` | Python-specific minimal loop |
| ralph.yml | BooksafeWebsite: ralph.yml | 6 | planner, builder, reviewer, qa-planner, qa-tester, finalizer | `work.start` | `LOOP_COMPLETE` | QA-extended preset |
| backtest.yml | CSDefectRepeatContactsPOC: .pi/ralph/presets/backtest.yml | 4 | analyzer, editor, poller, evaluator | `analyze.task` | `BACKTEST_COMPLETE` | Iterative ML backtest loop with polling |
| integration-test-fix.yml | CoverageAICapabilities: context/presets/integration-test-fix.yml | 5 | setup, diagnoser, fixer, validator, finalizer | `setup.start` | `LOOP_COMPLETE` | Integration test fix with Hydra |
| integration-test-assist.yml | CoverageAICapabilities: context/presets/integration-test-assist.yml | 6 | gatekeeper, scanner, writer, critic, validator, finalizer | `gate.start` | `LOOP_COMPLETE` | Integration test writing with baseline gate |
| coverage-assist.yml | CoverageAICapabilities: context/presets/coverage-assist.yml | 5 | analyzer, writer, critic, verifier, finalizer | `coverage.start` | `LOOP_COMPLETE` | Coverage improvement loop |
| ralph.yml | DCSEditorialStoreAPI: ralph.yml | 4 | planner, builder, reviewer, finalizer | `work.start` | `LOOP_COMPLETE` | Standard 4-hat; kiro backend |
| ralph-qa.yml | DCSEditorialStoreAPI: ralph-qa.yml | 6 | planner, builder, reviewer, qa-planner, qa-tester, finalizer | `work.start` | `LOOP_COMPLETE` | QA-extended variant |
| ralph.yml | DSCX-VAC-Admin: ralph.yml | 6 | planner, builder, reviewer, qa-planner, qa-tester, finalizer | `work.start` | `LOOP_COMPLETE` | QA-extended preset |
| ralph.yml | DeviceForecastingOrchestrationContext: ralph.yml | 4 | planner, builder, reviewer, finalizer | `work.start` | `LOOP_COMPLETE` | Standard 4-hat |
| amzn-design-loop.yml | DevicesConjointSurveyApplication: amzn-design-loop.yml | 3 | pmt, engineer, reviewer | `design.start` | `LOOP_COMPLETE` | PMT↔Engineer adversarial design loop |
| amzn-code-assist.yml | DevicesConjointSurveyApplication: amzn-code-assist.yml | 7 | prompt-fetcher, prompt-reviewer, prompt-fixer, step-planner, step-builder, step-verifier, commit-curator | `review.start` | `LOOP_COMPLETE` | Prompt validation gate before execution |
| multi-service/ralph.yml | DmcwhertE2EAgenticPrototype: experimental/multi-service/ralph.yml | 6 | architect, backend_builder, frontend_builder, integrator, critic, finalizer | `work.start` | `LOOP_COMPLETE` | Multi-service build; dead-end bug (finalizer publishes task.complete) |
| ralph-debug-copilotkit.yml | DmcwhertE2EAgenticPrototype: experimental/multi-service/ralph-debug-copilotkit.yml | 5 | diagnostician, fixer, verifier, retry_fixer, finalizer | `debug.start` | `LOOP_COMPLETE` | Debug-specific; dead-end bug (same issue) |
| ralph.yml | EBanxPixStdPayDock: ralph.yml | 5 | rde_setup, builder, tester, reviewer, finalizer | `rde.setup` | `LOOP_COMPLETE` | RDE environment setup gate |
| feature-dev.yml | ElcidRalph: frontend-dev-hats/hats/feature-dev.yml | 8 | planner, design_sync, builder, debugger, ux_reviewer, code_reviewer, finalizer, cr_monitor | `work.start` | `LOOP_COMPLETE` | Stacked branches, Figma sync, dual review, CR posting |
| feature-dev-e2e.yml | ElcidRalph: frontend-dev-hats/hats/feature-dev-e2e.yml | 10 | planner, design_sync, builder, debugger, ux_reviewer, code_reviewer, e2e_tester, ux_verifier, finalizer, cr_monitor | `work.start` | `LOOP_COMPLETE` | E2E variant with Cypress + visual verification |
| cr-fix-pass.yml | ElcidRalph: frontend-dev-hats/hats/cr-fix-pass.yml | 3 | cr_reader, builder, finalizer | `work.start` | `LOOP_COMPLETE` | CR comment triage and fix |
| build-fix-pass.yml | ElcidRalph: frontend-dev-hats/hats/build-fix-pass.yml | 2 | checker, fixer | `work.start` | `LOOP_COMPLETE` | Build error fix across branch stack |
| detail-pass.yml | ElcidRalph: frontend-dev-hats/hats/detail-pass.yml | 3 | design_sync, builder, reviewer | `work.start` | `DETAIL_COMPLETE` | Single-step iteration with Figma sync |
| ralph.doc.yml | MobrienvAICapabilities: ralph/ralph.doc.yml | 6 | research_planner, researcher, structurer, writer, reviewer, editor | `doc.start` | `DOC_COMPLETE` | Amazon narrative document workflow |
| ralph.yml | PPASCoreAICapabilities: ralph/ralph.yml | 5 | planner, builder, qa, reviewer, finalizer | `work.start` | `LOOP_COMPLETE` | PPAS-specific with QA gate; kiro backend per hat |
| cr-comment-actioner.yml | PcadWiki: skills/cr-auto-action/hats/cr-comment-actioner.yml | 9 | triager, fixer, verifier, self_reviewer, e2e_prover, uploader, monitor, replier, notifier | `cr.start` | `LOOP_COMPLETE` | CR auto-action: classify→fix→self-review→upload→monitor→reply |
| ralph.yml | RalphWatchSlackHook: ralph.yml | 5 | investigator, designer, builder, validator, committer | `investigate.start` | `LOOP_COMPLETE` | PDD flow for self-improvement; possible dead-end |
| ralph.yml | MandateSlayerBot: ralph.yml | 4 | planner, builder, reviewer, finalizer | `work.start` | `LOOP_COMPLETE` | Rust backend + React dashboard |

## Amazon Internal — Similar Patterns (Non-Ralph)

| Pattern | Source | Mechanism | Mapping to Ralph |
|---|---|---|---|
| Agent-Task-Loop | Local: TalonAiCapabilities skills/agent-task-loop | Bash loop + kiro-cli; file-based state markers (`[ ]`→`[review]`→`[completed]`) | Roles implicit from task state; no event routing; sequential only |
| RalphAgentCapabilities (3-Agent) | code.amazon.com/packages/RalphAgentCapabilities | 3 AIM agents (orchestrator/worker/evaluator); process-level isolation; hook-driven evaluation | Each "hat" is a separate OS process; file-based state; mkdir locks |
| KiroCliRalph | code.amazon.com/packages/KiroCliRalph | Bun/TypeScript loop; SQLite introspection for completion detection | Loop harness only; no multi-persona orchestration |
| AWSGrafanaGenAIPowerUser | code.amazon.com/packages/AWSGrafanaGenAIPowerUser | Worker/Verifier subagent pattern via `use_subagent` tool | No YAML config; orchestration in parent agent prompt |

## Sources

- [mikeyobrien/ralph-orchestrator presets/](https://github.com/mikeyobrien/ralph-orchestrator/tree/main/presets) — accessed 2026-04-20
- [mikeyobrien/ralph-orchestrator root configs](https://github.com/mikeyobrien/ralph-orchestrator/tree/main) — accessed 2026-04-20
- [CEO Suite Gist](https://gist.github.com/mikeyobrien/b15d22d7979ecae7cdd3f8f9e34d7337) — accessed 2026-04-20
- [mikeyobrien/ralph-orchestrator test scenarios](https://github.com/mikeyobrien/ralph-orchestrator/tree/main/crates/ralph-core/tests/scenarios) — accessed 2026-04-20
- Amazon internal repos via InternalCodeSearch — accessed 2026-04-20 (see docs/inventory/internal-ralph-direct.md for full list)
- Amazon internal similar patterns — accessed 2026-04-20 (see docs/inventory/internal-similar-patterns.md for full list)
