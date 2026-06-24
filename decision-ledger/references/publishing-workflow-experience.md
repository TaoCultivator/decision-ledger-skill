# Publishing Workflow Experience

Use this when maintaining a public skill mirror, moving a git repository across drives, syncing a local skill into a publishable copy, or debugging repeated GitHub/PowerShell/Windows publish failures.

```yaml
---
id: experience-skill-publish-windows-2026-06-24
status: experience
project: decision-ledger-skill
scope: publishing-workflow
module: tools/sync_publish.ps1
experience_type: publishing
problem: Windows skill publishing hit repeated git, PowerShell copy, encoding, cache, and network issues
trigger_signals:
  - dubious ownership
  - safe.directory
  - Author identity unknown
  - current directory is not a git repository
  - Copy-Item copied directory contents to the wrong level
  - SKILL.md missing after sync
  - Get-ChildItem -Include removed too much
  - UnicodeDecodeError gbk
  - __pycache__ contains local path
  - github.com port 443 timeout
root_cause: Several failures came from environment-specific behavior rather than repository content.
resolution: Check known experience first, verify current conditions with read-only commands, then apply the narrow fix.
avoid:
  - Do not use py_compile for public validation if generated caches may be committed.
  - Do not trust PowerShell Copy-Item directory semantics when exact target shape matters.
  - Do not use Get-ChildItem -Include for destructive cleanup without explicit extension filtering.
  - Do not treat a single GitHub network timeout as failed publication if API verification can confirm state.
keywords:
  - safe.directory
  - Copy-Item
  - UnicodeDecodeError
  - GBK
  - __pycache__
  - py_compile
  - gh repo create
  - skill publishing
  - sync_publish.ps1
validation:
  - Skill is valid!
  - AST_OK
  - GitHub tag verified through gh api
created_at: 2026-06-24
updated_at: 2026-06-24
---
```

## Trigger Signals

Recall this experience when publishing or syncing a skill on Windows and errors mention Git ownership, missing `SKILL.md`, PowerShell copy behavior, Python encoding, generated `__pycache__`, GitHub CLI repo creation, or GitHub network timeout.

## What Happened

A public skill mirror was created and moved from a project workspace to a dedicated skills-development directory. The process hit several unrelated operational failures:

- Git refused to operate because the repository had dubious ownership. Use per-command `git -c safe.directory=<repo>` rather than changing global config by default.
- Git commit failed because local user identity was missing. Set repository-local `user.name` and `user.email` instead of guessing global identity.
- `gh repo create --source . --push` misread the safe-directory repository as not being a git repository. Create the remote first, then push with explicit git commands.
- `py_compile` generated `__pycache__` containing local absolute paths. For publish validation, use AST parsing or remove caches before scanning and committing.
- `Copy-Item` produced the wrong target shape during sync. When `SKILL.md` must land at an exact path, create the target directory and copy `SKILL.md` explicitly with `File.Copy`.
- `Get-ChildItem -Include` in cleanup removed more than intended. Use explicit extension filtering such as `Where-Object { $_.Extension -in @(".pyc", ".pyo") }` before `Remove-Item`.
- Python validation failed with `UnicodeDecodeError` under Windows GBK defaults. Set `PYTHONUTF8=1` before running validators over UTF-8 Markdown.
- `git ls-remote` timed out after publication. Verify the remote tag with `gh api repos/<owner>/<repo>/git/ref/tags/<tag>` before assuming the push failed.

## Correct First Move

Before step-by-step debugging, search experience memory for the exact error text and command name. Then run read-only checks such as:

```powershell
git -c safe.directory=<repo> status --short --branch
git -c safe.directory=<repo> log --oneline -2
gh repo view <owner>/<repo> --json url,visibility
gh api repos/<owner>/<repo>/git/ref/tags/<tag>
Test-Path -LiteralPath <expected-file>
```

## Do-Not-Repeat Rule

Do not re-discover these as unrelated mysteries. Treat them as known Windows/Git/PowerShell publishing failure modes and verify whether the trigger signals match before choosing the remembered fix.

## Validation Evidence

The final successful workflow produced:

- valid skill structure
- AST script check
- clean private-path scan
- successful commit and push
- verified GitHub public repository and tag

## Applicability Limits

This memory is strongest for Windows PowerShell, GitHub CLI, local skill publishing, and public mirror synchronization. Re-check assumptions on Linux/macOS, different shells, different Git credential setups, or repositories that intentionally require global Git configuration.