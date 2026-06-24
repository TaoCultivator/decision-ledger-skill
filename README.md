# Decision Ledger Skill

`decision-ledger` is an Agent Skill for evidence-based project decisions. It helps agents retrieve compact decision records, surface rejected approaches before repeating them, route relevant skills and CLI tools, and run process-bound self-reflection before updating rules or specifications.

This skill is designed for projects where implementation discussions, accepted decisions, rejected approaches, and post-feedback corrections need to remain searchable without loading full conversation history into context.

## What It Does

- Searches compact project decision ledgers before opening full notes.
- Separates `proposed`, `accepted`, and `rejected` decisions.
- Treats rejected approaches as guardrails for future work.
- Routes relevant skills and CLI tools before substantial discussions or implementation.
- Keeps context usage low by opening only the most relevant records.
- Supports evidence-based self-reflection and self-iteration without relying on model intuition alone.

## Install

Copy the `decision-ledger/` folder into a skills directory supported by your agent.

For Codex user-level skills:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex\skills" | Out-Null
Copy-Item -Recurse -Force .\decision-ledger "$env:USERPROFILE\.codex\skills\decision-ledger"
```

On macOS or Linux:

```bash
mkdir -p ~/.codex/skills
cp -R decision-ledger ~/.codex/skills/
```

For project-local Agent Skills compatible clients:

```text
.agents/skills/decision-ledger/
```

After installing, restart the agent session if your client only discovers skills at startup.

## Recommended Project Ledger Layout

```text
docs/decision-ledger/
├── index.jsonl
├── proposed/
├── accepted/
├── rejected/
└── research-reviews/
```

The `index.jsonl` file is the first retrieval target. Full notes should stay in the status folders and be opened only when needed for exact wording, validation evidence, or conflict resolution.

## Search Helper

The bundled search script searches only the compact index:

```bash
python decision-ledger/scripts/ledger_search.py --index docs/decision-ledger/index.jsonl --query "right cursor rejected approach" --top 5
```

It is dependency-free and safe to use as a first pass before loading full notes.

## Validate

Use the Agent Skills reference validator when available:

```bash
skills-ref validate ./decision-ledger
```

Also check the bundled script:

```bash
python -m py_compile decision-ledger/scripts/ledger_search.py
```

## Safety Model

This skill does not make autonomous rule changes. Self-reflection and self-iteration must follow the skill workflow: gather evidence from user feedback, ledger retrieval, project rules, command or validation output, or authoritative external sources; keep weak findings as proposed investigations; and ask for approval before updating the skill, ledger, or formal project specs.

## Maintainer Workflow

This repository is the public mirror for a locally installed `decision-ledger` skill. After changing the local installed skill, run the sync script from this repository:

```powershell
.\tools\sync_publish.ps1 -Push
```

The script copies the local skill from `$env:USERPROFILE\.codex\skills\decision-ledger`, removes generated Python caches, rewrites local absolute examples into public placeholders, runs validation, checks for private paths, commits changes, creates the next patch tag, and pushes `main` plus the tag.

Use an explicit version when needed:

```powershell
.\tools\sync_publish.ps1 -Version v0.1.2 -Push
```

Remote pushes require normal Git/GitHub authentication. In sandboxed agent sessions, run this publish step with elevated permissions because it uses network access and credential storage.
## License

Apache-2.0. See [LICENSE](LICENSE).
