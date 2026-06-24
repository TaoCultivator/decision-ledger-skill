# Accepted Decision Template

Use this only after implementation and validation are complete.

```yaml
---
id: short-stable-id
status: accepted
project: project-name
scope: feature-or-domain
module: path.or.component
problem: concise problem statement
solution: adopted approach in one sentence
keywords:
  - exact term
related_files:
  - path/to/spec
  - path/to/code
validation:
  - command or evidence
supersedes:
  - old-id-if-any
created_at: YYYY-MM-DD
updated_at: YYYY-MM-DD
---
```

## Decision

State the final adopted behavior or process.

## Reasoning

Explain why this approach was chosen over the alternatives that were discussed.

## Implementation Boundary

List what changed and what did not change.

## Validation Evidence

Record commands, sample files, screenshots, or review evidence. Include dates when relevant.

## Spec Synchronization

List formal documents updated and any contradictory old wording removed or rewritten.

## Follow-Up Watchpoints

List symptoms that would indicate the decision needs re-evaluation.
```
index summary: one sentence naming the accepted behavior and its strongest retrieval terms.
```
