# Experience Memory Template

Use this for repeatable operational lessons: tool errors, CLI behavior, filesystem quirks, encoding failures, publishing mistakes, validation failures, authentication/network patterns, or workflow fixes that should be recalled before re-diagnosing from scratch.

```yaml
---
id: experience-short-stable-id
status: experience
project: project-name
scope: tool-or-workflow-domain
module: command.tool.or.path
experience_type: tool-error|environment|publishing|validation|workflow-fix
problem: concise failure or repeated situation
trigger_signals:
  - exact error text, command, path, exit code, or symptom
root_cause: why it happened
resolution: first fix to try after verifying conditions
avoid:
  - command or assumption that caused trouble
keywords:
  - exact error text
  - command name
related_files:
  - path/to/script-or-doc
validation:
  - command or evidence that proved the fix
created_at: YYYY-MM-DD
updated_at: YYYY-MM-DD
---
```

## Trigger Signals

List the exact strings and context that should retrieve this memory: error messages, command names, paths, tools, environment, OS, or failure phase.

## What Happened

Describe the observable failure without hiding the failed attempts. Keep facts separate from interpretation.

## Root Cause

State the confirmed cause. If it is only suspected, mark the record as proposed investigation instead of experience.

## Correct First Move

State what to check or do first next time. Prefer read-only checks before commands that mutate files, refs, remotes, credentials, or network state.

## Do-Not-Repeat Rule

Record the command, assumption, or workflow step that should not be repeated by default.

## Validation Evidence

List the command output, status check, test, or user confirmation that proved the resolution.

## Applicability Limits

State when this memory should not be applied, or what must be re-verified before applying it.

```text
index summary: one sentence naming the trigger, cause, fix, and strongest retrieval terms.
```