# Workflow

## 1. Clarify Scope

Before touching anything, lock in four facts:

- Is this audit-only, estimate-only, or execution?
- What data must be preserved?
- Are hibernation changes allowed?
- Are software removals allowed?

If the user gives a target like `30 GB free` or `33 GB free`, keep that as the stopping condition.

## 2. Audit the Drive

Collect at least:

- drive totals for `C:`
- root-level largest directories and files
- common reclaimable paths
- app-data heavy hitters
- system files that affect policy decisions

Useful categories:

- `C:\Windows`
- `C:\Users`
- `C:\Program Files`
- `C:\Program Files (x86)`
- `C:\pagefile.sys`
- `C:\hiberfil.sys`
- `C:\Windows\MEMORY.DMP`
- `%LOCALAPPDATA%\Temp`
- browser caches
- updater caches
- removable app-local data approved by the user

## 3. Build a Tiered Estimate

Use three tiers.

### Safe

Examples:

- user temp files
- browser caches
- updater installer caches
- old logs
- old memory dumps when the user is not debugging crashes

### Conditional

Examples:

- disabling hibernation to remove `hiberfil.sys`
- uninstalling or removing local data for user-approved apps
- clearing app-local caches that may reset login state or rebuild indexes

### High-Risk

Examples:

- changing or deleting `pagefile.sys`
- deleting system folders because they are large
- removing mixed app-data trees without understanding the app
- deleting chat or attachment stores without explicit approval

## 4. Execute In Batches

Preferred order:

1. safe items
2. re-measure drive free space
3. conditional items that are explicitly approved
4. re-measure after each batch
5. stop when the target is reached

## 5. Verify

After each execution batch:

- re-check `C:` free space
- verify protected apps are still running or launchable when practical
- inspect whether deleted cache folders were recreated automatically
- explain what changed and what remained intentionally untouched

## 6. Record Everything

At minimum write:

- `records/build-log.md`
- `records/conversation-log.md`
- `records/retro.md`
- one HTML report in `reports/`

Each phase record should include:

- objective
- commands or actions used
- measured before/after space
- blockers
- next step
- progress percentage
