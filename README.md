# Autodream — Memory & Context tools for Claude Code

> Two open-source tools to make Claude Code sessions survive over time:
> - **Autodream** — nightly memory consolidation via n8n + Google Drive + Claude API
> - **Transfer Session** — clean handoff between sessions via a magic keyword (`TRANSFER`)

Both solve the same underlying problem: **how does an AI agent keep its context across time?**

---

## 1. Autodream — Nightly memory consolidation

### What it does

Every night at 3am, Autodream:
1. Lists all `.md` memory files in your Google Drive "Claude Memory" folder
2. Sends each file to Claude Sonnet for consolidation (removes redundancy, fixes contradictions, improves clarity)
3. Rewrites the file on Drive **only if changes were made**
4. Sends you an email summary (modified / unchanged files)

---

## Architecture

```
[Schedule 3am] → [List Drive files] → [Process One File x N]
  → [Read file from Drive]
  → [Claude Sonnet consolidation]
  → [Write back to Drive if changed]
→ [Email summary]
[Error Trigger] → [Error email]
```

**Two workflows:**
- `autodream-memory-consolidation.json` — Main orchestrator
- `autodream-process-one-file.json` — Sub-workflow (called once per file)

---

## Requirements

- n8n instance (self-hosted or cloud)
- Google Drive OAuth2 credential
- Anthropic API credential
- Gmail OAuth2 credential
- A Google Drive folder containing your Claude Code memory `.md` files

---

## Setup

### 1. Import the workflows

Import both JSON files into your n8n instance in this order:
1. `autodream-process-one-file.json` (sub-workflow — import first to get its ID)
2. `autodream-memory-consolidation.json` (main workflow)

### 2. Configure the main workflow

In `autodream-memory-consolidation.json`, update:

| Node | Field | Value |
|---|---|---|
| List Memory Files | URL | Replace `YOUR_GOOGLE_DRIVE_FOLDER_ID` with your Drive folder ID |
| Process One File | Workflow ID | Replace `YOUR_SUBWORKFLOW_ID` with the ID of the imported sub-workflow |
| Send Summary Email | Send To | Replace `YOUR_EMAIL@gmail.com` with your email |
| Send Error Email | Send To | Replace `YOUR_EMAIL@gmail.com` with your email |

### 3. Set credentials

On every HTTP Request node that calls Google Drive or Gmail, select your OAuth2 credentials.
On the Call Claude node, select your Anthropic API credential.

### 4. Activate

Activate the sub-workflow first, then the main workflow.

---

## Bug fix — v1.1 (2026-04-26)

**Critical fix:** The `Write File` node in the sub-workflow had `specifyBody: raw` configured but **no body field set**. This caused Drive to receive an empty body, silently overwriting consolidated files with blank content.

Fixed: `body` is now correctly set to `={{ $json.newContent }}` (the consolidated content returned by Claude).

If you imported a previous version, open the sub-workflow, find the **Write File** node, and set the body field to `={{ $json.newContent }}`.

---

## Sync back to local (recommended)

Autodream writes consolidated files to Drive, but Claude Code reads from your local `~/.claude/projects/.../memory/` directory. To close the loop, sync Drive back to local at each session start.

Create a PowerShell script and a `SessionStart` hook in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "pwsh -NonInteractive -ExecutionPolicy Bypass -File \"path/to/sync-memory-from-drive.ps1\"",
        "timeout": 30,
        "statusMessage": "Syncing memory from Drive..."
      }]
    }]
  }
}
```

---

## Schedule

Default: `0 0 3 * * *` (3am daily). Modify the Schedule Trigger node to change the frequency.

---

## Error handling

Both workflows have an Error Trigger node that sends an email alert on failure. Configure the `errorWorkflow` setting in n8n to point to a dedicated error handler if needed.

---

---

## 2. Transfer Session — Clean handoff between sessions

### The problem

A Claude Code session eventually accumulates too much context: explored errors, dead-ends, abandoned attempts. The conversation slows down, the agent loses focus, and you can't realistically "downgrade" the model (Opus → Sonnet → Haiku) to save cost because the new model would start cold.

### The solution

A magic keyword — `TRANSFER` — that generates a structured markdown brief. The brief contains exactly what the next session needs:

- Objective (what to do, why)
- Project context (files, workflows, URLs)
- Current state (what's done, what remains)
- Locked decisions (don't re-discuss these)
- Known pitfalls (don't fall back into these)
- Memory files to load
- First concrete action

A `SessionStart` hook can optionally detect a recent brief when a new session opens and offer to resume.

### Setup

The skill lives in [`skills/transfer-session/`](./skills/transfer-session/). It works as a standard Claude Code skill — Claude triggers it automatically when the user types `TRANSFER`, `BRIEF`, or `HANDOFF`.

To enable the auto-detection hook at session start, see [`skills/transfer-session/hook/README.md`](./skills/transfer-session/hook/README.md).

---

## License

MIT
