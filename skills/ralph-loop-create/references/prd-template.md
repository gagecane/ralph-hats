# PRD.md Template

Every Ralph loop **MUST** have a `PRD.md` at the loop root. The hats read it as the single source of task truth. Write it well and you save iterations.

Replace the bracketed placeholders. Delete any section that genuinely does not apply, but keep at least Goal, Required deliverable, Out of scope, and Success criteria.

---

```markdown
# [Short Title]

## Goal
One paragraph: what the deliverable is, in plain language. If code, name the files. If a doc, name the document and its audience. If a decision, state the question.

**Out of scope** (called out up front): [one or two items if any]

## Verified inputs (do not re-derive)

Everything the loop should take as given. Prevents re-investigation.

- Bug site: `/absolute/path/to/File.ext` line N — [what is there]
- Commit: `<sha>` — [what it changed]
- Ticket: [TALON-XXXX](https://taskei...) — [what it says]
- Related prior-loop output: `/absolute/path/to/prior/loop/docs/whatever.md`

## Known resources

Pipelines, packages, skills, agents the loop should use.

- **Primary package**: `/absolute/path/to/package/` — [what it is, why it matters]
- **Pipeline**: https://pipelines.amazon.com/pipelines/Name — [what it is used for]
- **Agent**: `talon-dev` — has read access to [resource list]
- **MCP tools available**: [list only if non-obvious, e.g., TaskeiGetTask, ReadInternalWebsites, CRRevisionCreator]

## Credentials

Describe how the agent obtains access. Do NOT embed account IDs blindly.

- Account IDs can be discovered from the pipeline configs listed above.
- Credential command pattern: `ada credentials update --provider conduit --role IibsAdminAccess-DO-NOT-DELETE --account <id>`
- If an account is unreachable, mark the affected claim `NEEDS HUMAN INPUT` rather than guessing.

## Required structure of the deliverable

### If the deliverable is a document
Enumerate the exact sections it must contain and what each must answer. Every claim must cite one of: file:line, command output, ticket link, or `NEEDS HUMAN INPUT`.

### If the deliverable is a CR
Enumerate the files that may be modified, the commit message format, the reviewer expectations, and any repo-specific rules (e.g., FCE's 1-commit-per-CR CRUX rule).

## Workflow hints (optional)
If the investigation has natural waves or the code change has a clear ordering, list them here. The Synthesizer / Gatekeeper decides actual flow — hints are not directives.

## Out of scope (hard guardrails)
The loop **MUST NOT**:
- [e.g., Write production code]
- [e.g., Create a CR]
- [e.g., Run `git push` or `git commit` on package X]
- [e.g., Modify file Y per upstream ticket's "What NOT to change" section]
- [e.g., File Taskei tickets — recommend only]

## Success criteria
Concrete checks the final output must pass. Think "definition of done."

- `docs/<name>.md` exists with all required sections
- Every claim cited or marked `NEEDS HUMAN INPUT`
- [domain-specific check, e.g., "brazil-build release passes"]
- [domain-specific check, e.g., "A single named recommendation, not a list of options"]
```

---

## Notes

- Keep it under ~150 lines. Longer PRDs rarely help; they just push context.
- The "Out of scope (hard guardrails)" section is the single most important bug-prevention tool. Skipping it causes the loop to drift.
- If you find yourself writing "and also" a lot, the loop scope is probably too broad. Split it.
