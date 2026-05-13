# SessionStart Hook — Auto-detect pending briefs

This hook automatically detects recent transfer briefs when a new Claude Code session opens and asks Claude to offer resuming the work.

## How it works

1. When a Claude Code session starts, the hook runs `check-pending-brief.ps1`
2. The script scans:
   - A centralized briefs folder (configurable)
   - The current working directory (for `brief-*.md` files)
3. If a brief modified in the last 24h is found, the script outputs a JSON instruction that gets injected into Claude's context
4. Claude then asks the user: "I see a recent transfer brief — resume it or start fresh?"

If no recent brief exists, the hook is silent (no context pollution).

## Setup

### 1. Configure the script

Edit `check-pending-brief.ps1` and update:

```powershell
$briefsDir = 'C:/path/to/your/_briefs'   # Your centralized briefs folder
$recentHours = 24                          # How far back to look
```

### 2. Wire the hook in your settings

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "pwsh -NonInteractive -ExecutionPolicy Bypass -File \"<absolute path to check-pending-brief.ps1>\"",
            "timeout": 10,
            "statusMessage": "Checking for pending briefs..."
          }
        ]
      }
    ]
  }
}
```

If you already have other SessionStart hooks, **append** to the existing `hooks` array — do not replace it.

### 3. Test

Create a test brief in your briefs folder:

```
C:/path/to/your/_briefs/brief-test.md
```

Open a new Claude Code session. Claude should ask if you want to resume from the test brief.

## Platform notes

- This script is written for **PowerShell** (Windows / WSL with pwsh).
- For macOS/Linux with bash, the same logic can be translated to a shell script (contributions welcome).

## Why this approach

The hook injects a **system-reminder** into Claude's context using the `hookSpecificOutput.additionalContext` field. This is a first-class Claude Code mechanism — no monkey-patching, no race conditions, and the hook stays completely silent when there's nothing to report.
