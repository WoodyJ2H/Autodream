# 🧠 Autodream — AI Memory Consolidation for Claude Code

An n8n workflow that automatically consolidates your [Claude Code memory files](https://docs.anthropic.com/en/docs/claude-code/memory) every night using Claude AI.

## What it does

Every night at 3am, Autodream:
1. Scans a Google Drive folder containing your `.md` memory files
2. Sends each file to Claude (Sonnet) for consolidation — removing redundancies, fixing contradictions, improving clarity
3. Rewrites only the files that actually changed
4. Sends you an email report summarizing what was updated

## Why

Claude Code has a persistent memory system stored as markdown files. Over time, these files accumulate redundant or contradictory information. Autodream keeps them clean automatically so Claude always has accurate, up-to-date context.

## Workflows

| File | Description |
|------|-------------|
| `autodream-memory-consolidation.json` | Main workflow — scheduler, file listing, email report |
| `autodream-process-one-file.json` | Sub-workflow — reads, calls Claude, writes back |

## Prerequisites

- n8n instance (self-hosted or cloud)
- Google Drive folder with your `.md` memory files
- Anthropic API key ([console.anthropic.com](https://console.anthropic.com))
- Gmail account

## Setup

### Step 1 — Import workflows

Import both JSON files into n8n in this order:
1. `autodream-process-one-file.json` first
2. `autodream-memory-consolidation.json` second

### Step 2 — Create credentials in n8n

- **Google Drive OAuth2 API** — connect your Google account
- **Anthropic API** — paste your API key
- **Gmail OAuth2** — connect your Gmail account

### Step 3 — Configure the main workflow

Open `Autodream - Memory Consolidation` and:

1. **List Memory Files node** — replace `YOUR_GOOGLE_DRIVE_FOLDER_ID` with your folder ID
   > Find it in the URL: `drive.google.com/drive/folders/YOUR_ID_HERE`

2. **Process One File node** — replace `YOUR_SUBWORKFLOW_ID` with the ID of the sub-workflow
   > Find it in the URL when you open the sub-workflow: `your-n8n.com/workflow/THIS_ID`

3. **Send Summary Email & Send Error Email nodes** — replace `YOUR_EMAIL@gmail.com`

### Step 4 — Assign credentials

In both workflows, open each HTTP Request node and assign the correct credential.

### Step 5 — Activate

1. Activate `Autodream - Process One File` first
2. Then activate `Autodream - Memory Consolidation`

## Memory file format

Autodream works with any `.md` file. It preserves YAML frontmatter if present:

```markdown
---
name: My memory file
description: What this file contains
type: user
---

Content of the memory file...
```

> **Note:** Files named `MEMORY.md` are automatically excluded (used as an index file).

## Customization

### Change the schedule

Edit the cron expression in the **Schedule Trigger** node:
- `0 0 3 * * *` → every night at 3am (default)
- `0 0 6 * * 1` → every Monday at 6am

### Change the Claude model

Edit the `model` field in the **Call Claude** node JSON body:
- `claude-sonnet-4-6` (default — good balance)
- `claude-haiku-4-5-20251001` (faster, cheaper)
- `claude-opus-4-6` (more thorough, more expensive)

### Exclude more files

Edit the **Prepare Files** node code:
```javascript
const files = $input.first().json.files.filter(
  f => f.name !== 'MEMORY.md' && f.name !== 'another-file.md'
);
```

## Email report example

Subject: `🧠 Autodream - 3 file(s) updated - 28/03/2026`

The email lists each file with:
- What was changed (bullet points)
- A brief observation from Claude

## License

MIT

---

Built with [n8n](https://n8n.io) + [Claude](https://anthropic.com) by [@WoodyJ2H](https://github.com/WoodyJ2H)
