---
name: decision-ledger
description: Maintain and retrieve compact project decision ledgers, route relevant skills/CLI tools, and perform evidence-based self-reflection/self-audit on retrieval or routing gaps for implementation discussions, proposed approaches, accepted decisions, rejected approaches, post-feedback corrections, and specification updates. Use before discussing or changing project behavior when the user mentions 沟通纪要, 废案, 方案复盘, 规范沉淀, 不要重犯, 检索历史结论, 决策记录, skill routing, CLI routing, tool selection, self-iteration, self-reflection, self-audit, 自我反思, implementation discussion, rejected approach, or decision log.
---

# Decision Ledger

## Purpose

Use this skill to keep project communication and implementation decisions searchable without loading full history into context. It separates discussion, accepted decisions, and rejected approaches so future work can reuse what was proven and avoid repeating failed ideas.

## Non-Negotiables

- Search first; do not read the whole ledger unless the user explicitly asks for a full audit.
- Prefer project-owned records over skill-owned records. Keep this skill small; store growing project history in the target repo or project knowledge base.
- Treat rejected approaches as guardrails. If a rejected record matches the current problem, surface it before proposing a similar path.
- Treat proposed notes as unverified. Do not promote them into formal project specs until implementation and validation are complete.
- Do not change code or specs during discussion-only turns. Record or propose wording only after the user asks.
- When updating formal specs, remove or rewrite conflicting old guidance in the same pass.
- Treat user-identified omissions as first-class self-iteration input. Preserve attribution; do not present user-proposed improvements as agent-discovered conclusions.
- Actively self-audit substantial turns for missed ledger hits, bad skill/CLI routing, context waste, weak validation, and unclear accepted/rejected boundaries; do not wait for the user to find every gap.
- Self-reflection and self-iteration must follow this skill workflow. Do not invent rule changes from model intuition alone; ground every proposed change in user feedback, ledger retrieval, project rules, command or validation evidence, or authoritative external sources.

## Ledger Layout

Prefer this project-local structure when no project convention exists:

```text
docs/decision-ledger/
├── index.jsonl
├── proposed/
├── accepted/
├── rejected/
└── research-reviews/
```

Use `index.jsonl` as the first retrieval target. Each line should summarize one note and point to the full file:

```json
{"id":"short-stable-id","status":"proposed|accepted|rejected","project":"project-name","scope":"feature-or-domain","module":"path.or.component","problem":"problem statement","symptoms":["observable symptom"],"keywords":["term","alias"],"related_files":["path/to/file"],"summary":"one or two sentences","path":"docs/decision-ledger/proposed/short-stable-id.md","updated_at":"YYYY-MM-DD"}
```

The full note should use one of the templates in `references/`:

- `references/discussion-memo-template.md` for discussion-only conclusions.
- `references/accepted-decision-template.md` after implementation and validation.
- `references/rejected-approach-template.md` for attempted or considered approaches that should not be reused by default.
- `references/weekly-self-iteration.md` when improving this ledger workflow from user feedback, agent-observed gaps, or external authoritative sources.

## Retrieval Workflow

1. Extract query keys from the user request: project, feature, module, file path, function name, symptom, metric, sample name, decision status, and exact terms.
2. Locate the project ledger. Start with `docs/decision-ledger/index.jsonl`; if absent, search for `decision-ledger`, `DECISION_INDEX`, `rejected`, `accepted`, `沟通纪要`, and `废案`.
3. Apply metadata filters before reading note bodies: project, scope, module, status, related files, and date when available.
4. Run exact keyword search with `rg` or `scripts/ledger_search.py` against the index. Exact search protects technical names, file paths, sample names, and numeric anchors.
5. If a semantic index exists, run vector or embedding search over index summaries only, then fuse with keyword hits. Do not embed or inject full note bodies by default.
6. Rank results in this order: matching rejected records, accepted records, proposed records, research reviews.
7. Open only the top 1-3 full notes unless the user asks for broader coverage or the hits conflict.
8. If no strong hit exists, say that no relevant ledger entry was found and proceed as a new discussion.

Use `scripts/ledger_search.py` for a local, dependency-free first pass:

```bash
python path/to/decision-ledger/scripts/ledger_search.py --index docs/decision-ledger/index.jsonl --query "fixed delay rejected approach" --top 5
```


## Skill Routing Workflow

Use this before selecting tools for a substantial discussion or implementation:

1. Extract task signals from the current request: artifact type, domain, file extension, target platform, external service, browser need, API/provider, implementation phase, and whether the user is only discussing or explicitly asking for changes.
2. Check the active skill list or host-provided skill metadata first. Match by `name` and `description`; do not open every `SKILL.md`.
3. If project rules exist, search the project ledger and the project's tool rules index for the same task signals before reading detailed tool guidance.
4. Pick the smallest set of relevant skills or CLIs. Prefer one primary skill plus narrowly needed helpers over broad multi-skill loading.
5. During implementation or technical discussion, actively consider whether a CLI can improve the work: use project CLIs, test runners, linters, package managers, browser/automation CLIs, release tools, or discovery tools when they provide concrete evidence, faster inspection, safer validation, or access to state that plain reasoning cannot verify. Do not invoke a CLI just because one exists; match it to the current goal and sandbox/authentication constraints.
6. For each selected CLI, identify the exact purpose before use: inspect, search, generate, validate, reproduce, debug, publish, or install. Prefer read-only or dry-run commands first when risk is unclear, use full paths or confirm PATH when needed, and request escalation for network, credential, package install, or out-of-workspace writes.
7. Read the full `SKILL.md` only for selected skills, then follow their progressive disclosure rules for references, scripts, and assets.
8. If no active skill covers the task, search for a suitable skill before falling back to general tools. Do not rely on only one discovery channel: try `find-skills` first when available, then check curated install lists, known public Agent Skills repositories, source repositories such as GitHub paths, project/team skill folders, and relevant official docs. Use `skill-installer`, a source repository path, or the project-approved installation flow when installation is appropriate and the user agrees. Validate third-party skills against the Agent Skills spec and review provenance before use. If discovery is unavailable or no suitable skill exists, use the project's fallback tool rules, then general tools. State that no matching skill was found if the choice matters.
9. If multiple skills or CLIs could apply, explain the routing choice briefly using impact, side effects, required authentication, and verification needs.
10. Record routing failures, bad tool choices, or later feedback as rejected approaches so future discussions avoid repeating them.

Keep routing lightweight. Skill routing is a map, not a warehouse: use metadata and compact indexes first, then open only the few selected instructions needed for the current work.
## Discussion-To-Spec Workflow

Use this state flow:

1. Discussion: capture the problem, symptoms, candidate theory, risks, and open questions as a proposed note.
2. Implementation approval: wait for explicit user permission before changing code or formal specs.
3. Implementation: make the scoped change and validate it using the project rules.
4. Acceptance: convert the proposed note into an accepted decision only after validation succeeds.
5. Spec sync: update the formal spec files that own the behavior, and delete or rewrite contradictory old wording.
6. Rejection: when feedback shows an approach is wrong, partial, or too risky, write a rejected approach note with why it failed and when, if ever, it may be reconsidered.

## Rejected Approach Rules

When a current proposal resembles a rejected record:

- State the prior failure briefly.
- Explain whether the current problem differs materially.
- Do not reuse the rejected path unless the user explicitly asks to re-evaluate it or new evidence removes the prior failure condition.
- If the approach is reused after re-evaluation, update the rejected record with the exception instead of silently bypassing it.

## Context Budget Rules

- Inject summaries and paths first, not full notes.
- Prefer 1-3 relevant records over broad history.
- Quote only the fields needed for the current decision.
- Use full notes only for exact wording, validation evidence, or conflict resolution.
- If the index grows noisy, propose improving metadata, splitting scopes, or adding a semantic summary index before increasing context size.


## Record Maintenance

When creating or updating any ledger note:

- Update `index.jsonl` in the same pass as the full note.
- Keep the index summary short enough to inspect without opening the full note.
- Include exact technical anchors when they matter: file paths, function names, parameter names, sample names, error text, and user-facing terms.
- Include synonyms and Chinese wording that future users are likely to search for.
- Change `status` deliberately: `proposed` for discussion, `accepted` after validation, `rejected` after a failed or imperfect approach is identified.
- When a record supersedes another record, link both records instead of deleting history.

## Portable Use

This workflow is not Codex-specific. In another agent, IDE, local script, or knowledge system, preserve the same behavior:

- Load only the skill workflow or equivalent instructions first.
- Search a compact index before reading full records.
- Use the platform's equivalent of file search, keyword search, metadata filters, semantic search, web search, and validation tools.
- Keep growing project history outside the skill so the skill remains portable.
- Do not claim a weekly or automatic refresh exists unless the host system actually runs a scheduler.

## Self-Reflection And Self-Iteration

Treat improvement of this skill as process-bound self-reflection, not model creativity. Self-reflection can come from user feedback, proactive agent self-audit, missed triggers, bad routing choices, validation failures, or external research.

- Run a brief self-reflection after selecting ledger records, skills, or CLIs, and again before finalizing substantial work.
- Ask whether a relevant rejected/accepted record was missed, whether a better skill or CLI should have been used, whether context loading was broader than necessary, whether validation exposed a weak rule, and whether the current discussion reveals a reusable improvement.
- Treat model reasoning as hypothesis generation only. Before proposing a rule change, run the relevant workflow step: search compact ledgers or project rules, inspect the selected skill sections, use command output or validation results when applicable, or check authoritative external sources for research-driven changes.
- When the agent discovers a gap, record it as agent-observed with evidence: request signal, missed/incorrect rule, workflow step used, command or validation result when applicable, and proposed minimal fix. The user should not have to notice every omission.
- If evidence is missing or weak, keep the item as an open question or proposed investigation; do not update the skill, project ledger, or formal spec from intuition alone.
- When the user identifies a missing behavior, record it as user feedback or user-proposed improvement. Preserve the source of the idea in the note or final summary.
- Route missing CLI/tool participation, failed skill selection, repeated overloading of context, unclear accepted/rejected boundaries, and insufficient validation into this self-iteration loop.
- Keep changes proposed until the user approves them and validation passes; then update the skill, project ledger, or formal spec as appropriate.
- Do not claim a weekly or automatic refresh exists unless the host system actually runs a scheduler.

For detailed self-reflection records or external review, follow `references/weekly-self-iteration.md` when an agent-observed gap is found, a user asks to improve the workflow, or a project weekly review is due:

- For substantial project discussions, check the newest research review date using the index or review filenames before deciding whether a refresh is due.
- If the latest review is older than seven days, search authoritative paper platforms or official technical sources for retrieval, ranking, decision-memory, RAG, and long-context evidence.
- Summarize only findings that change the workflow.
- Record them as proposed improvements, not as automatic rule changes.
- Ask for approval before updating this skill or a project spec.

## Three-Pass Closure

For substantial ledger or skill changes, run three passes before finalizing:

1. Build and check: implement the requested workflow, then compare it against the current conversation and project rules.
2. Self-reflect and tighten: look for missed ledger hits, rejected approaches, skill/CLI routing gaps, over-broad context loading, validation weaknesses, omissions, ambiguity, and scope creep; verify proposed improvements through the skill workflow instead of relying on intuition.
3. Finalize and check: validate file structure, frontmatter, searchability, and examples; report what was created, what was self-discovered, and what remains intentionally out of scope.






