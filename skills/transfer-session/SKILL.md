---
name: transfer-session
description: Create a structured handoff brief in markdown so a fresh Claude Code session can resume the current work with clean context. Use when the user types the magic word TRANSFER, BRIEF, or HANDOFF, or when the user explicitly asks to "prepare a brief for a new session", "hand off the context", "create a brief to resume later", or expresses that the current session has too much context and they want to restart fresh with a clean handoff.
---

# Transfer Session — Handoff Brief Generator

## When to use

The user types one of these magic keywords or expresses the intent to hand off:
- `TRANSFER`, `BRIEF`, `HANDOFF`
- "I want to open a new session for this"
- "Prepare a brief to resume later"
- "This conversation is getting too long, make me a clean handoff"

## Goal

Generate **a single markdown file** that contains everything a new Claude session (Haiku, Sonnet, or Opus) needs to resume the work **without asking any context questions**.

The brief must be:
- **Self-sufficient**: the new session should NOT have to guess anything
- **Actionable**: the first action is explicit ("Read X, then do Y")
- **Noise-free**: no debugging history, just the current state and the next step

## Procedure (follow in order)

### Step 1 — Identify the subject

Ask the user **ONE single question** if the subject isn't obvious:
> "What's this transfer about? (short title)"

If the subject is clear from the conversation, skip this step.

### Step 2 — Choose the file location

- If a project is active (folder open in IDE, recent files) → create the brief in that folder
- Otherwise → create in `<USER_BRIEFS_FOLDER>/` (default: a `_briefs/` folder in the user's workspace root)
- File name: `brief-<subject-kebab-case>.md`

### Step 3 — Generate the brief using the template below

**Use the EXACT template** (do not improvise the structure):

```markdown
# Brief — <Short subject title>

> Generated on <YYYY-MM-DD HH:MM> · Source session: <model> · Folder: <project path>

## 🎯 Objective

<1-3 sentences: WHAT to do and WHY. No fluff.>

## 📂 Project context

- **Working folder**: `<absolute path>`
- **Key files**:
  - `<path>` — <one-line role of the file>
- **n8n workflows involved** (if applicable):
  - `<workflow_id>` — <name> — <role>
- **URLs / Endpoints** (if applicable):
  - <url> — <description>

## ✅ Current state — What is DONE

- <Completed item 1>
- <Completed item 2>

## ⏳ Current state — What REMAINS to do

1. <First action to take — as specific as possible>
2. <Next action>
3. <...>

## 🧠 Decisions already made (do NOT re-discuss)

- <Decision 1> — Why: <short reason>
- <Decision 2> — Why: <short reason>

## ⚠️ Known pitfalls / To avoid

- <Pitfall 1 encountered during this session>
- <Pitfall 2>

## 📚 Memory to load at session start

Read these files BEFORE responding:
- `<path to relevant memory file>.md`
- <other relevant files>

## 🚀 First concrete action

**The new session MUST start by**: <very specific action>

Example: "Read file X, then modify line Y of file Z to add Q"

---

## 💡 For the new session

When you receive this brief, do EXACTLY this in order:
1. Read the files listed in "Memory to load"
2. Read the files listed in "Key files"
3. Confirm in 2 lines: "OK, resuming on <subject>. I will <first action>."
4. Execute the first action

**DO NOT**:
- Ask context questions (everything is in this brief)
- Redo decisions already made
- Fall back into known pitfalls
```

### Step 4 — Confirm to the user

Once the file is written, reply in **3 lines maximum**:

```
✅ Brief created: <file path>

In a new Claude Code session, simply say:
"Read <path> and start"
```

## Strict rules

### DO
- ✅ Always use the EXACT template (do not reorganize sections)
- ✅ Always use ABSOLUTE paths (not relative)
- ✅ Always include the "First concrete action" section with a clear instruction
- ✅ List relevant memory files in "Memory to load"

### DON'T
- ❌ Don't include debugging history ("we tried X, it failed, then Y, it worked")
- ❌ Don't include the full session recap — just the CURRENT STATE and NEXT STEP
- ❌ Don't include long source code — reference files instead
- ❌ Don't write vague sentences ("see previous conversation") — the new session won't have it

## Example of a successful brief

See `EXAMPLE.md` for a real concrete case.

## Automatic detection at session start (optional)

To automatically detect a pending brief when a new Claude Code session opens, see `hook/check-pending-brief.ps1` and the setup instructions in `hook/README.md`.
