# Self-Reflection And Self-Iteration Protocol

Use this when the user asks to improve the ledger workflow, when agent self-reflection discovers a reusable gap, or at the start of a substantial project discussion when the newest project research review is older than seven days.

## Trigger Check

1. Classify the trigger source as `user-feedback`, `agent-observed`, `validation-failure`, or `external-review`.
2. If the trigger is agent-observed, capture the evidence before editing: missed signal, incorrect routing, skipped CLI/tool, over-broad context load, weak validation, or unclear accepted/rejected boundary.
3. Treat model reasoning as a hypothesis only. Confirm it through this protocol before proposing a skill, ledger, or spec change.
4. Look for `docs/decision-ledger/research-reviews/` or the project-equivalent folder.
5. Find the newest dated review file.
6. Check this date using only filenames, index entries, or short metadata before opening full review files.
7. If no review exists or the newest review is older than seven days, offer or perform a refresh according to the user's instruction and available network tools.
8. Do not claim automatic scheduling unless an external scheduler actually exists. If a host system provides a scheduler, use it only to create proposed review notes, not to auto-adopt rule changes.

## Source Scope

For agent-observed or user-feedback triggers, prefer local evidence from the current task: conversation signals, selected or skipped skills/CLIs, compact ledger hits, project rules, command output, and validation results. A model-generated idea is not evidence by itself.

For external-review triggers, prefer authoritative and primary sources:

- Authoritative paper platforms or publisher pages for papers on retrieval, RAG, ranking, long context, decision memory, and summarization.
- Official engineering or documentation pages from major model, search, or tool providers.
- Official docs for retrieval frameworks only when implementation behavior matters.

Avoid using low-evidence blog posts as the sole reason to change the workflow.

## Search Topics

Use targeted searches instead of broad browsing:

- hybrid search BM25 dense retrieval RAG reranking
- metadata filtering vector search prefilter recall false negatives
- reciprocal rank fusion hybrid retrieval
- contextual retrieval BM25 embeddings reranking
- hierarchical retrieval summaries RAPTOR
- long context lost in the middle retrieval evidence
- decision log knowledge management rejected approaches

## Review Output

Create a proposed research review note, not an accepted rule change:

```yaml
---
id: research-review-YYYY-MM-DD-retrieval-workflow
status: proposed
project: project-name
scope: decision-ledger-self-iteration
problem: improve retrieval, routing, self-reflection, or decision-memory workflow
keywords:
  - retrieval
  - skill-routing
  - cli-routing
  - self-reflection
  - self-audit
  - reranking
  - context budget
created_at: YYYY-MM-DD
updated_at: YYYY-MM-DD
---
```

## Findings

For each finding, include:

- trigger source: user-feedback, agent-observed, validation-failure, or external-review
- evidence and date observed or accessed
- workflow step used to verify the hypothesis
- what changed in user, project, or external evidence
- whether it affects retrieval, indexing, skill routing, CLI routing, templates, validation, or spec sync
- confidence level
- proposed change, if any

## Adoption Rule

Do not update the skill or project specs automatically. Do not adopt changes from model intuition alone. Ask the user before adopting any change. If adopted, move the relevant item into an accepted decision and update the skill or project docs in the same pass.