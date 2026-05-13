# Example of a successful brief

This is a real (anonymized) brief generated during an actual session, to use as a reference.

---

```markdown
# Brief — Add LinkedIn Stats tab to CEO Dashboard

> Generated on 2026-05-13 23:55 · Source session: Opus · Folder: <PROJECT_ROOT>/dashboard-project/

## 🎯 Objective

Add a **📊 LinkedIn** tab in the CEO Dashboard that shows view/impression statistics of posts published via the LinkedIn automation workflow.

## 📂 Project context

- **Working folder**: `<PROJECT_ROOT>/dashboard-project/`
- **Key files**:
  - `dashboard-ceo.html` — The dashboard to modify (add LinkedIn tab)
- **n8n workflows involved**:
  - `<WORKFLOW_ID_DASHBOARD_API>` — Dashboard Data API — Webhook source for dashboard data
  - `<WORKFLOW_ID_LAS_1A>` — Daily Post Generation — Publishes LinkedIn posts daily
- **URLs / Endpoints**:
  - `<YOUR_N8N_URL>/webhook/dashboard-data` — Dashboard webhook
- **Sheets**:
  - LinkedIn Posts: `<SHEET_ID>` (tab `Posts`)

## ✅ Current state — What is DONE

- CEO Dashboard operational with a Site tab (Umami analytics integrated)
- Dashboard Data API workflow functional and deployed
- Daily Post Generation workflow publishes LinkedIn posts daily to the Posts sheet
- Memory file `reference_n8n_session.md` up to date with n8n 2.20+ rules

## ⏳ Current state — What REMAINS to do

1. **Audit Daily Post Generation**: read the workflow (`<WORKFLOW_ID_LAS_1A>`) and identify which columns currently exist in the Posts sheet (post_id, url, views, impressions?)
2. **If no stats are stored yet**: set up collection (via scraping tool or LinkedIn native API)
3. **Integrate into dashboard webhook**: add `linkedin_stats` source in workflow `<WORKFLOW_ID_DASHBOARD_API>` (new HTTP Sheets + Parse nodes, then injection in Serialize)
4. **Add dashboard tab**: `📊 LinkedIn` tab in the `MY ACTIVITY` group of `dashboard-ceo.html` with KPIs, view evolution chart, posts table
5. **Deploy**: `scp dashboard-ceo.html <VPS>:/var/www/<USER>/dashboard/index.html`

## 🧠 Decisions already made (do NOT re-discuss)

- Dashboard served by nginx on VPS (not local) — Why: avoids browser cache issues
- Single n8n webhook feeds all dashboard sections — Why: simple architecture, single refresh
- Data stored in Google Sheets (no DB) — Why: existing project convention
- Dashboard style: dark theme with CSS variables, KPIs in grid, inline SVG charts — Why: no external dependency, lightweight

## ⚠️ Known pitfalls / To avoid

- **n8n 2.20+ rejects `binaryMode` in settings** — always filter before PUT: `{k:v for k,v in settings.items() if k != 'binaryMode'}`
- **HTTP Request URLs may reset to `localhost` after n8n upgrade** — always verify after a version bump
- **JS code in Code nodes**: NEVER pass via bash heredoc — always use a Python file with raw strings `r"""..."""`
- **After PUT workflow**: new UUID for modified Code nodes + `deactivate` → 3s → `reactivate` mandatory
- **Parallel connections in n8n**: 2 HTTP in parallel → 1 downstream Code node only receives the 1st → chain sequentially
- **Internal Docker URLs**: use Docker DNS names (e.g. `<service-name>:<port>`), not `localhost` nor IPs

## 📚 Memory to load at session start

Read these files BEFORE responding:
- `<USER_HOME>/.claude/projects/<sanitized-cwd>/memory/reference_n8n_session.md` — Critical n8n rules + SSH access
- `<USER_HOME>/.claude/projects/<sanitized-cwd>/memory/project_dashboard.md` — Dashboard CEO context
- `<USER_HOME>/.claude/projects/<sanitized-cwd>/memory/project_linkedin_automation.md` — LinkedIn automation context

## 🚀 First concrete action

**The new session MUST start by**: Fetching the Daily Post Generation workflow via the n8n API directly from SSH:

```bash
ssh <VPS_ALIAS> "curl -s '<YOUR_N8N_URL>/api/v1/workflows/<WORKFLOW_ID_LAS_1A>' \
  -H 'X-N8N-API-KEY: <API_KEY>' | python3 -c \"
import json,sys
wf=json.load(sys.stdin)
for n in wf.get('nodes',[]):
    if 'sheet' in n['type'].lower() or 'Posts' in n.get('name',''):
        print(n['name'], '→', n.get('parameters',{}).get('operation','?'))
\""
```

Then read the Posts sheet to see existing columns.

---

## 💡 For the new session

When you receive this brief, do EXACTLY this in order:
1. Read the files listed in "Memory to load"
2. Read `dashboard-ceo.html` (tabs + renderSite sections) to understand the structure
3. Confirm in 2 lines: "OK, resuming on LinkedIn Stats tab. I will read the Daily Post Generation workflow and the Posts sheet."
4. Execute the first action

**DO NOT**:
- Ask questions about dashboard architecture (everything is here)
- Redo decisions on storage (Sheets, not DB)
- Fall back into already-documented n8n 2.20+ pitfalls
- Try the n8n MCP first and waste time when it fails — go straight to API via SSH
```

---

## What makes this brief effective

1. **Self-sufficient**: the new session has all IDs, URLs, paths
2. **Explicit first action**: no need to think about where to start
3. **Locked decisions**: avoids loops like "are you sure we should do it this way?"
4. **Pitfalls listed**: the new session doesn't fall into the same traps
5. **Short confirmation**: 2 lines, then action — no fluff
