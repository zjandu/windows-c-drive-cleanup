# Safety Matrix

## Safe By Default

| Item | Why it is usually safe | Notes |
|---|---|---|
| `%LOCALAPPDATA%\Temp` | Temporary files are expected to be disposable | Best after closing heavy apps |
| Browser caches | Rebuilt automatically | Some apps recreate cache immediately |
| Updater installer caches | Usually redundant downloaded installers | Confirm app is not actively updating |
| Old crash dumps | Useful only when debugging crashes | Ask if user is currently diagnosing BSOD/app crashes |
| Old plain-text logs | Usually disposable | Keep only if needed for incident analysis |

## Conditional: Needs Explicit Approval

| Item | Why approval is required | Notes |
|---|---|---|
| `hiberfil.sys` | Requires disabling hibernation | Changes power behavior |
| App-local data trees | May mix cache with real state | Example: WeChat DevTools, Electron app data |
| App uninstall/removal | User intent must be explicit | Prefer official uninstaller first |
| OneDrive or cloud caches | May affect sync behavior | Do not assume disposable |

## High-Risk: Do Not Treat As Routine Cleanup

| Item | Why it is high-risk | Notes |
|---|---|---|
| `pagefile.sys` | Tied to virtual memory and crash dump policy | Never sell this as easy free space |
| `System Volume Information` | Restore and system metadata | Requires separate policy discussion |
| `Recovery` | Recovery environment artifacts | Not routine cleanup |
| Large Windows folders | Size does not imply safe deletion | Use supported cleanup tools only |
| WeChat chat/attachment data | User content | Preserve unless explicitly disposable |
| Project workspaces | Real work product | Preserve by default |

## Special Rule For Mixed App Data

When a directory mixes cache with real state:

- inspect first
- identify subfolders
- explain the uncertainty
- get explicit approval for the app or subtree
- verify the app still works after cleanup
