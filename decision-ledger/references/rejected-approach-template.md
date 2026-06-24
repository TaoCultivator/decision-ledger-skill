# Rejected Approach Template

Use this for approaches that were implemented, attempted, seriously considered, or later found imperfect and should not be reused by default.

```yaml
---
id: rejected-short-stable-id
status: rejected
project: project-name
scope: feature-or-domain
module: path.or.component
problem: problem it tried to solve
approach: rejected approach in one sentence
failure_mode: why it failed or was incomplete
keywords:
  - exact term
  - alias
related_files:
  - path/to/spec-or-code
do_not_reuse: true
created_at: YYYY-MM-DD
updated_at: YYYY-MM-DD
---
```

## Rejected Approach

Describe the approach clearly enough that future discussions can recognize it.

## Why It Looked Reasonable

Record the problem it tried to solve and the benefit it appeared to offer.

## Why It Failed

State the concrete feedback, sample behavior, regression, ambiguity, or maintenance problem.

## Do-Not-Reuse Rule

State the guardrail in direct language. Include any narrow condition that would justify re-evaluation.

## Replacement Direction

If known, point to the accepted decision or proposed discussion that replaced it.
```
index summary: one sentence naming the rejected pattern and the reason it must not be reused.
```
