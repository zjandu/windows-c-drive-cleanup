# C盘清理 / Windows C Drive Cleanup

一个基于真实 Windows 清理案例沉淀出来的开源 skill 项目，用来让任意 AI 在 **先审计、再分级、后执行、全程留痕** 的前提下，安全地研究和清理 Windows `C:` 盘空间。

## This Repo Does

- Audit a Windows `C:` drive before touching anything
- Estimate reclaimable space in tiers: safe, conditional, high-risk
- Execute only approved cleanup items
- Preserve explicitly protected app data such as WeChat chat history
- Keep markdown records and an HTML report after each phase
- Stop once the user target is reached instead of over-cleaning

## Real Validation Snapshot

This repository was derived from a real session on `2026-03-20`.

- Initial free space on `C:`: `27.69 GB`
- Final free space on `C:`: `33.13 GB`
- Net gain: `5.44 GB`
- Protected during execution:
  - WeChat chat-related data
  - `pagefile.sys`
- Approved actions actually used:
  - Disable hibernation
  - Remove local WeChat DevTools data
  - Clear user temp files
  - Remove updater installer caches
  - Clear Chrome caches

## Repository Layout

```text
C盘清理/
├── README.md
├── LICENSE
├── .gitignore
├── examples/
│   └── any-ai-prompt.md
├── records/
│   ├── build-log.md
│   ├── conversation-log.md
│   └── retro.md
├── reports/
│   └── project-overview.html
└── skill/
    └── windows-c-drive-cleanup/
        ├── SKILL.md
        ├── agents/
        │   └── openai.yaml
        ├── references/
        │   ├── workflow.md
        │   ├── safety-matrix.md
        │   └── command-library.md
        └── scripts/
            ├── audit_c_drive.ps1
            └── cleanup_targets.ps1
```

## How To Use With Any AI

1. Give the AI this repository or the `skill/windows-c-drive-cleanup/` folder.
2. Ask it to read `SKILL.md` first.
3. Tell it whether the task is:
   - audit only
   - estimate only
   - actual cleanup
4. Tell it what must be protected.
5. Tell it the free-space target.
6. Require it to update `records/` and `reports/` after each phase.

You can start from [examples/any-ai-prompt.md](./examples/any-ai-prompt.md).

## Safety Model

Safe by default:

- temp folders
- browser caches
- updater installer caches
- old crash dumps when not debugging
- removable app-local caches when the user explicitly approves

Do not treat these as safe by default:

- `pagefile.sys`
- `System Volume Information`
- `Recovery`
- Windows core directories
- chat histories, attachments, synced cloud data, project workspaces
- app data that mixes cache with real user state

## Open-Source Status

This repository is prepared as an open-source project locally:

- open-source license included
- git repository can be initialized
- reusable skill structure included
- scripts and references included

If you want a public GitHub release, you still need a reachable GitHub account plus authentication on this machine.
