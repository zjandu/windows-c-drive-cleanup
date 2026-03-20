---
name: windows-c-drive-cleanup
description: Safely audit and clean a Windows C drive, estimate reclaimable space in tiers, execute only approved cleanup, preserve protected app data such as chat histories, and keep markdown plus HTML records. Use for requests like "清理C盘", "free up C drive space", "estimate max reclaimable space", or "clean a Windows system drive without breaking apps".
---

# Windows C Drive Cleanup

Use this skill for Windows system-drive cleanup tasks where safety matters more than raw aggression.

## What This Skill Must Do

- Audit first, never guess
- Split reclaimable space into `safe`, `conditional`, and `high-risk`
- Protect user-named data and app state
- Execute only the approved subset
- Re-measure after every batch
- Keep records in markdown and HTML
- Stop once the target is reached

## Required Workflow

1. Clarify the task mode.
   - `audit only`
   - `estimate only`
   - `execute cleanup`
2. Clarify hard protection boundaries.
   - protected apps
   - protected data folders
   - forbidden system changes
3. Clarify the target.
   - current free space goal
   - ideal stretch goal
4. Read [references/safety-matrix.md](references/safety-matrix.md).
5. Read [references/workflow.md](references/workflow.md).
6. Read [references/command-library.md](references/command-library.md) when you are actually running commands on Windows.
7. If PowerShell is available, prefer `scripts/audit_c_drive.ps1` for repeatable auditing.
8. If execution is approved, use `scripts/cleanup_targets.ps1` for low-risk cleanup batches when possible.

## Hard Rules

- Never fabricate sizes, deletions, or command outcomes.
- Never delete before real measurement.
- Never treat `pagefile.sys` as safe cleanup.
- Never delete Windows core directories, `System Volume Information`, `Recovery`, or unknown system folders as a shortcut.
- Never disable hibernation, uninstall software, or remove app-local data without explicit approval.
- Never delete chat history, attachments, cloud sync data, or project workspaces unless the user explicitly names them as disposable.
- If an admin-only command fails, report the failure and request real elevation instead of pretending it worked.
- After every phase, update records and report progress as a real percentage.

## Minimum Deliverables

Always provide:

- current drive totals
- top space consumers
- tiered reclaim estimate
- executed actions
- post-cleanup free space
- remaining opportunities
- risks you intentionally avoided
- updated records under `records/`
- updated HTML report under `reports/`

## When To Stop

Stop when any one is true:

- target free space is reached
- only high-risk actions remain
- the next actions would break user constraints
- the next actions need a new approval boundary
