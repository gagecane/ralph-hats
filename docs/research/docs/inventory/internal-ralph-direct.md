# Internal Ralph Direct Usage — Inventory

> **📸 Snapshot — 2026-04-21.** This document is a point-in-time research artifact captured on 2026-04-21. It is not actively maintained. External sources (GitHub repos, Amazon-internal packages) may have changed since. Scores, links, and findings reflect the state of the world on that date.

Amazon-internal packages on code.amazon.com that directly use ralph-cli hat collections.

## Summary

| # | Repository | File Path | Hat Count | Hat Keys | starting_event | completion_promise | Notes |
|---|-----------|-----------|-----------|----------|----------------|-------------------|-------|
| 1 | AISkills-iamsukh | skills/faq-automation/ralph/faq-automation.yml | 7 | planner, slack-extractor, email-extractor, extraction-reviewer, enricher, synthesizer, (+ faq-reviewer implied) | work.start | LOOP_COMPLETE | Multi-source FAQ extraction pipeline with review gates |
| 2 | AISkills-iamsukh | skills/agent-builder/ralph/agent-builder.yml | 4 | researcher, designer, builder, reviewer | work.start | LOOP_COMPLETE | Agent scaffolding workflow with research phase |
| 3 | ASBXAgentOrchestration | .ralph/hats/qa-playwright.yml | 4 | planner, smoke-tester, functional-tester, reporter | qa.start | QA_COMPLETE | Playwright-based QA testing loop |
| 4 | AgentCoreInternalAgents | ralph/code-assist.yml | 5 | resumption_gate, planner, builder, critic, finalizer | resume.check | LOOP_COMPLETE | Full code-assist with resumption gate; 29KB file |
| 5 | AllDevScriptsForJfengz | ralph_workflow/build-review.yml | 2 | builder, reviewer | build.start | LOOP_COMPLETE | Minimal builder→reviewer loop |
| 6 | AllDevScriptsForJfengz | ralph_workflow/archive/plan-build-review.yml | 3 | planner, builder, reviewer | build.start | LOOP_COMPLETE | Archived 3-hat variant |
| 7 | AmazonBuilderPiExtensions | skills/ralph/hats/brazil-code-assist.yml | 4 | planner, builder, critic, finalizer | build.start | LOOP_COMPLETE | Brazil-optimized code-assist; incremental builds |
| 8 | AmazonDevicesAutoCompleteCDK | ralph.yml | 4 | planner, builder, reviewer, finalizer | work.start | LOOP_COMPLETE | Planner→Builder→Reviewer→Finalizer with kiro backend |
| 9 | AnsAiPlayground | ralph.yml | 6 | planner, builder, reviewer, qa-planner, qa-tester, finalizer | work.start | LOOP_COMPLETE | QA-extended preset with playwright-cli |
| 10 | Anti-Entropy-Package | .ralph/hats/task-tracker.yml | 4 | planner, builder, reviewer, finalizer | work.start | LOOP_COMPLETE | Task tracker app build loop |
| 11 | AudschmiAICapabilities | ralph/crux-usecase-refine.yml | 5 | author, reviewer, ranker, debater, finalizer | work.start | LOOP_COMPLETE | Use-case refinement with adversarial debater |
| 12 | AudschmiAICapabilities | ralph/crux-usecase-discovery.yml | 7 | planner, researcher, synthesizer, author, reviewer, ranker, (+ debater/finalizer) | work.start | LOOP_COMPLETE | Full research→synthesis→authoring→ranking pipeline |
| 13 | AudschmiAICapabilities | ralph/research-and-plan.yml | 6 | planner, researcher, synthesizer, author, reviewer, finalizer | work.start | LOOP_COMPLETE | Research→plan with YAGNI reviewer |
| 14 | AudschmiAICapabilities | ralph/research-and-rank.yml | 7+ | planner, researcher, synthesizer, author, reviewer, ranker, (debater, finalizer) | work.start | LOOP_COMPLETE | Research→rank with technical reviewer |
| 15 | AwsTcExperimentServiceCDK | .ralph/hats/feature-flags-user-segments.yml | 2 | builder, reviewer | build.start | LOOP_COMPLETE | Focused 2-hat for a single feature |
| 16 | AwsTcOpExLeadership | ralph.yml | 3 | validator, implementer, reviewer | work.start | LOOP_COMPLETE | Validator-first pattern: validates approach before coding |
| 17 | AwsTcRalphOrchestrator | collections/brazil-cdk.yml | 5 | analyzer, implementer, builder, tester, finalizer | cdk.start | LOOP_COMPLETE | CDK-specific: analyze→implement→build→test→finalize |
| 18 | AwsTcRalphOrchestrator | collections/brazil-cdk-deploy.yml | 7 | analyzer, implementer, builder, tester, cdk-deployer, integration-tester, (finalizer) | cdk.start | LOOP_COMPLETE | CDK with deploy + integration testing |
| 19 | AwsTcRalphOrchestrator | collections/brazil-simple.yml | 2 | builder, finalizer | build.start | LOOP_COMPLETE | Minimal 2-hat for simple Brazil tasks |
| 20 | AwsTcRalphOrchestrator | collections/brazil-python.yml | 2 | builder, finalizer | build.start | LOOP_COMPLETE | Python-specific minimal loop |
| 21 | BooksafeWebsite | ralph.yml | 6 | planner, builder, reviewer, qa-planner, qa-tester, finalizer | work.start | LOOP_COMPLETE | QA-extended preset (identical to AnsAiPlayground pattern) |
| 22 | CSDefectRepeatContactsPOC | .pi/ralph/presets/backtest.yml | 4 | analyzer, editor, poller, evaluator | analyze.task | BACKTEST_COMPLETE | Unique: iterative ML backtest loop with polling |
| 23 | CoverageAICapabilities | context/presets/integration-test-fix.yml | 5 | setup, diagnoser, fixer, validator, finalizer | setup.start | LOOP_COMPLETE | Integration test fix pipeline with Hydra |
| 24 | CoverageAICapabilities | context/presets/integration-test-assist.yml | 6 | gatekeeper, scanner, writer, critic, validator, finalizer | gate.start | LOOP_COMPLETE | Integration test writing with baseline gate |
| 25 | CoverageAICapabilities | context/presets/coverage-assist.yml | 5 | analyzer, writer, critic, verifier, finalizer | coverage.start | LOOP_COMPLETE | Coverage improvement loop |
| 26 | DCSEditorialStoreAPI | ralph.yml | 4 | planner, builder, reviewer, finalizer | work.start | LOOP_COMPLETE | Standard 4-hat with kiro backend |
| 27 | DCSEditorialStoreAPI | ralph-qa.yml | 6 | planner, builder, reviewer, qa-planner, qa-tester, finalizer | work.start | LOOP_COMPLETE | QA-extended variant |
| 28 | DSCX-VAC-Admin | ralph.yml | 6 | planner, builder, reviewer, qa-planner, qa-tester, finalizer | work.start | LOOP_COMPLETE | QA-extended preset |
| 29 | DeviceForecastingOrchestrationContext | ralph.yml | 4 | planner, builder, reviewer, finalizer | work.start | LOOP_COMPLETE | Standard 4-hat |
| 30 | DevicesConjointSurveyApplication | amzn-design-loop.yml | 3 | pmt (designer), engineer, reviewer | design.start | LOOP_COMPLETE | Unique: PMT↔Engineer adversarial design loop |
| 31 | DevicesConjointSurveyApplication | amzn-code-assist.yml | 7 | prompt-fetcher, prompt-reviewer, prompt-fixer, step-planner, step-builder, step-verifier, commit-curator | review.start | LOOP_COMPLETE | Advanced: prompt validation gate before execution |
| 32 | DmcwhertE2EAgenticPrototype | experimental/multi-service/ralph.yml | 6 | architect, backend_builder, frontend_builder, integrator, critic, finalizer | work.start | LOOP_COMPLETE | Multi-service build: sequential service construction; dead-end: finalizer publishes `task.complete` which doesn't match `completion_promise: LOOP_COMPLETE` |
| 33 | DmcwhertE2EAgenticPrototype | experimental/multi-service/ralph-debug-copilotkit.yml | 5 | diagnostician, fixer, verifier, retry_fixer, finalizer | debug.start | LOOP_COMPLETE | Debug-specific: diagnose→fix→verify cycle; dead-end: finalizer publishes `task.complete` which doesn't match `completion_promise: LOOP_COMPLETE` |
| 34 | EBanxPixStdPayDock | ralph.yml | 5 | rde_setup, builder, tester, reviewer, finalizer | rde.setup | LOOP_COMPLETE | RDE environment setup gate before development |
| 35 | ElcidRalph | frontend-dev-hats/hats/feature-dev.yml | 8 | planner, design_sync, builder, debugger, ux_reviewer, code_reviewer, finalizer, cr_monitor | work.start | LOOP_COMPLETE | Most complex: stacked branches, Figma sync, dual review, CR posting |
| 36 | ElcidRalph | frontend-dev-hats/hats/feature-dev-e2e.yml | 10 | planner, design_sync, builder, debugger, ux_reviewer, code_reviewer, e2e_tester, ux_verifier, finalizer, cr_monitor | work.start | LOOP_COMPLETE | E2E variant with Cypress + visual verification |
| 37 | ElcidRalph | frontend-dev-hats/hats/cr-fix-pass.yml | 3 | cr_reader, builder, finalizer | work.start | LOOP_COMPLETE | CR comment triage and fix loop |
| 38 | ElcidRalph | frontend-dev-hats/hats/build-fix-pass.yml | 2 | checker, fixer | work.start | LOOP_COMPLETE | Build error fix across branch stack |
| 39 | ElcidRalph | frontend-dev-hats/hats/detail-pass.yml | 3 | design_sync, builder, reviewer | work.start | DETAIL_COMPLETE | Single-step iteration with Figma sync |
| 40 | MobrienvAICapabilities | ralph/ralph.doc.yml | 6 | research_planner, researcher, structurer, writer, reviewer, editor | doc.start | DOC_COMPLETE | Amazon narrative document workflow |
| 41 | PPASCoreAICapabilities | ralph/ralph.yml | 5 | planner, builder, qa, reviewer, finalizer | work.start | LOOP_COMPLETE | PPAS-specific with QA gate; uses kiro backend per hat |
| 42 | PcadWiki | skills/cr-auto-action/hats/cr-comment-actioner.yml | 9 | triager, fixer, verifier, self_reviewer, e2e_prover, uploader, monitor, replier, notifier | cr.start | LOOP_COMPLETE | CR auto-action: classifies comments, fixes code, self-reviews, uploads revision, monitors DryRunBuild, drafts replies |
| 43 | RalphWatchSlackHook | ralph.yml | 5 | investigator, designer, builder, validator, committer | investigate.start | LOOP_COMPLETE | PDD flow for self-improvement; note: last hat publishes `commit.complete` but `completion_promise` is `LOOP_COMPLETE` (possible dead-end) |
| 44 | MandateSlayerBot | ralph.yml | 4 | planner, builder, reviewer, finalizer | work.start | LOOP_COMPLETE | Rust backend + React dashboard implementation |
## Related Packages (not hat collections)

| # | Repository | File Path | Notes |
|---|-----------|-----------|-------|
| 45 | CodexAISkillSet | skills/ralph/SKILL.md | Ralph skill reference with CLI docs |
| 46 | BhupeshAIAgents | skills/ralph-setup/references/hat-templates.md | Hat template reference |
| 47 | PcadCloudDesktopAnsibleSetup | setup-1.ansible.yml | Infrastructure: installs ralph-cli via cargo |

## Notable Patterns Observed

1. **Standard 4-hat pattern** (most common): planner → builder → reviewer → finalizer. Used by ~15 repos.
2. **QA-extended 6-hat**: Adds qa-planner + qa-tester between reviewer and finalizer. Used by ~6 repos.
3. **Research pipelines**: planner → researcher → synthesizer → author → reviewer → finalizer. Used by AudschmiAICapabilities (3 variants).
4. **Frontend-specific**: Adds design_sync (Figma), ux_reviewer, debugger, cr_monitor. ElcidRalph is the most sophisticated.
5. **Minimal 2-hat**: builder → finalizer (or builder → reviewer). For simple tasks.
6. **Domain-specific gates**: RDE setup gate (EBanxPixStdPayDock), prompt validation gate (DevicesConjointSurveyApplication), resumption gate (AgentCoreInternalAgents).
7. **Iterative experiment loops**: analyzer → editor → poller → evaluator (CSDefectRepeatContactsPOC backtest).

## Repos with Reusable Collections (not project-specific)

| Repository | Purpose | Collections |
|-----------|---------|-------------|
| ElcidRalph | Generic frontend dev hats | feature-dev, feature-dev-e2e, cr-fix-pass, build-fix-pass, detail-pass |
| AwsTcRalphOrchestrator | Brazil/CDK collections | brazil-cdk, brazil-cdk-deploy, brazil-simple, brazil-python |
| AmazonBuilderPiExtensions | Brazil-optimized code-assist | brazil-code-assist |
| AgentCoreInternalAgents | Upstream-quality code-assist | code-assist (with resumption gate) |
| CoverageAICapabilities | Test coverage presets | coverage-assist, integration-test-assist, integration-test-fix |
| AudschmiAICapabilities | Research/planning presets | research-and-plan, research-and-rank, crux-usecase-discovery, crux-usecase-refine |
| MobrienvAICapabilities | Document writing | ralph.doc (Amazon narrative workflow) |

## Unusual Schema Fields (not in canonical schema.md)

| Field | Where Found | Notes |
|-------|-------------|-------|
| `timeout` | AwsTcRalphOrchestrator (brazil-cdk.yml, brazil-cdk-deploy.yml) | Per-hat timeout in seconds; not in schema.md |
| `aggregate.mode: "wait_for_all"` | AISkills-iamsukh (faq-automation.yml, synthesizer hat) | Waits for all upstream events before triggering; not in schema.md |
| `required_events` | PcadWiki (cr-comment-actioner.yml) | In event_loop section; schema says only `starting_event` and `completion_promise` are valid hats overlay keys |
| `checkpoint_interval` | PcadWiki (cr-comment-actioner.yml), RalphWatchSlackHook (ralph.yml) | In event_loop section; not a documented hats overlay key |
| `idle_timeout_secs` | Multiple repos (Anti-Entropy-Package, JourneysDPBuilder, etc.) | In event_loop; likely a core config field placed in hats file |
| `max_iterations` / `max_runtime_seconds` | Many repos place these in hats files | Schema says keep these in core config, not hats files |
| `single_task` | PcadWiki (cr-comment-actioner.yml, fixer hat, line 529) | Per-hat boolean; not in schema.md's valid hat fields list (`name`, `description`, `triggers`, `publishes`, `instructions`, `default_publishes`, `extra_instructions`, `backend`, `backend_args`, `max_activations`, `disallowed_tools`) |

## Sources

- code.amazon.com/packages/AISkills-iamsukh — `InternalCodeSearch` query: `"ralph hat"`, `triggers: fp:*.yml AND publishes: fp:*.yml AND instructions:`
- code.amazon.com/packages/ASBXAgentOrchestration — `InternalCodeSearch` query: `"ralph hat"`
- code.amazon.com/packages/AgentCoreInternalAgents — `InternalCodeSearch` query: `triggers: fp:*.yml AND publishes: fp:*.yml AND instructions:`
- code.amazon.com/packages/AllDevScriptsForJfengz — `InternalCodeSearch` query: `triggers: fp:*.yml AND publishes: fp:*.yml AND instructions:`
- code.amazon.com/packages/AmazonBuilderPiExtensions — `InternalCodeSearch` query: `"-H builtin:"`
- code.amazon.com/packages/AmazonDevicesAutoCompleteCDK — `InternalCodeSearch` query: `triggers: fp:*.yml AND publishes: fp:*.yml AND instructions:`
- code.amazon.com/packages/AnsAiPlayground — `InternalCodeSearch` query: `ralph.yml fp:*.yml AND event_loop`
- code.amazon.com/packages/Anti-Entropy-Package — `InternalCodeSearch` query: `ralph.yml fp:*.yml AND event_loop`
- code.amazon.com/packages/AudschmiAICapabilities — `InternalCodeSearch` query: `triggers: fp:*.yml AND publishes: fp:*.yml AND instructions:`
- code.amazon.com/packages/AwsTcExperimentServiceCDK — `InternalCodeSearch` query: `triggers: fp:*.yml AND publishes: fp:*.yml AND instructions:`
- code.amazon.com/packages/AwsTcOpExLeadership — `InternalCodeSearch` query: `"ralph hat"`, `triggers: fp:*.yml AND publishes: fp:*.yml AND instructions:`
- code.amazon.com/packages/AwsTcRalphOrchestrator — `InternalCodeSearch` query: `"-H builtin:"`, `triggers: fp:*.yml AND publishes: fp:*.yml AND instructions:`
- code.amazon.com/packages/BooksafeWebsite — `InternalCodeSearch` query: `ralph.yml fp:*.yml AND event_loop`
- code.amazon.com/packages/CSDefectRepeatContactsPOC — `InternalCodeSearch` query: `triggers: fp:*.yml AND publishes: fp:*.yml AND instructions:` (page 2)
- code.amazon.com/packages/CoverageAICapabilities — `InternalCodeSearch` query: `triggers: fp:*.yml AND publishes: fp:*.yml AND instructions:` (page 2)
- code.amazon.com/packages/DCSEditorialStoreAPI — `InternalCodeSearch` query: `"-H builtin:"`, `triggers: fp:*.yml AND publishes: fp:*.yml AND instructions:` (page 2)
- code.amazon.com/packages/DSCX-VAC-Admin — `InternalCodeSearch` query: `ralph.yml fp:*.yml AND event_loop`
- code.amazon.com/packages/DeviceForecastingOrchestrationContext — `InternalCodeSearch` query: `"-H builtin:"`, `ralph.yml fp:*.yml AND event_loop`
- code.amazon.com/packages/DevicesConjointSurveyApplication — `InternalCodeSearch` query: `triggers: fp:*.yml AND publishes: fp:*.yml AND instructions:` (page 2); verified `commit-curator` key via `commit-curator repo:DevicesConjointSurveyApplication fp:amzn-code-assist.yml` (line 644)
- code.amazon.com/packages/DmcwhertE2EAgenticPrototype — `InternalCodeSearch` query: `ralph.yml fp:*.yml AND event_loop`, `triggers: fp:*.yml AND publishes: fp:*.yml AND instructions:` (page 2)
- code.amazon.com/packages/EBanxPixStdPayDock — `InternalCodeSearch` query: `triggers: fp:*.yml AND publishes: fp:*.yml AND instructions:` (page 2)
- code.amazon.com/packages/ElcidRalph — `InternalCodeSearch` query: `ralph hats repo:ElcidRalph`; verified `ux_verifier` via `ux_verifier repo:ElcidRalph fp:feature-dev-e2e.yml` (line 229); verified `cr_monitor` via `cr_monitor repo:ElcidRalph fp:feature-dev-e2e.yml` (line 281)
- code.amazon.com/packages/MobrienvAICapabilities — `InternalCodeSearch` query: `ralph.yml fp:*.yml AND event_loop`; verified hat keys via `triggers: repo:MobrienvAICapabilities fp:ralph.doc.yml` (6 hats: research_planner, researcher, structurer, writer, reviewer, editor)
- code.amazon.com/packages/PPASCoreAICapabilities — `InternalCodeSearch` query: `ralph.yml fp:*.yml AND event_loop`; verified hat keys via `triggers: repo:PPASCoreAICapabilities fp:ralph.yml` (5 hats: planner, builder, qa, reviewer, finalizer)
- code.amazon.com/packages/PcadWiki — `InternalCodeSearch` query: `ralph.yml fp:*.yml AND event_loop`; verified hat keys via `triggers: repo:PcadWiki fp:cr-comment-actioner.yml` (9 hats: triager, fixer, verifier, self_reviewer, e2e_prover, uploader, monitor, replier, notifier)
- code.amazon.com/packages/RalphWatchSlackHook — `InternalCodeSearch` query: `ralph.yml fp:*.yml AND event_loop`; verified hat keys via `triggers: repo:RalphWatchSlackHook fp:ralph.yml` (5 hats: investigator, designer, builder, validator, committer); verified `completion_promise: LOOP_COMPLETE` via `completion_promise repo:RalphWatchSlackHook fp:ralph.yml` (line 12)
- code.amazon.com/packages/MandateSlayerBot — `InternalCodeSearch` query: `ralph.yml fp:*.yml AND event_loop`; verified hat keys via `triggers: repo:MandateSlayerBot fp:ralph.yml` (4 hats: planner, builder, reviewer, finalizer)
- code.amazon.com/packages/PcadCloudDesktopAnsibleSetup — `InternalCodeSearch` query: `ralph-cli fp:*.yml`
- code.amazon.com/packages/CodexAISkillSet — `InternalCodeSearch` query: `"ralph hat"`
- code.amazon.com/packages/BhupeshAIAgents — `InternalCodeSearch` query: `"ralph hat"`
