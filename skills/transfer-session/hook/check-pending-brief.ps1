# check-pending-brief.ps1
# Detects recent transfer briefs and injects a notification into Claude Code at session start.
#
# Configure the paths below to match your local setup before using.
# Wire this script into your ~/.claude/settings.json as a SessionStart hook
# (see hook/README.md for details).

$ErrorActionPreference = 'SilentlyContinue'

# === CONFIGURATION ===
# Centralized briefs folder (adjust to your setup, or leave empty to skip)
$briefsDir = 'C:/path/to/your/_briefs'

# Also scan the current working directory for brief-*.md files
$scanCwd = $true

# How many hours back to consider a brief "recent"
$recentHours = 24
# === END CONFIGURATION ===

$found = @()

# Check centralized briefs folder
if ($briefsDir -and (Test-Path $briefsDir)) {
    $found += Get-ChildItem -Path $briefsDir -Filter 'brief-*.md' -File |
        Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-$recentHours) }
}

# Check current working directory
if ($scanCwd) {
    $cwd = Get-Location
    $found += Get-ChildItem -Path $cwd -Filter 'brief-*.md' -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-$recentHours) }
}

# Deduplicate and sort by recency
$found = $found | Sort-Object FullName -Unique | Sort-Object LastWriteTime -Descending

if ($found.Count -eq 0) {
    # No pending brief — emit nothing (the hook stays silent)
    exit 0
}

# Build the notification message
$lines = @()
$lines += "PENDING TRANSFER BRIEF DETECTED"
$lines += ""
$lines += "One or more recent transfer briefs (<${recentHours}h) were found:"
$lines += ""

foreach ($f in $found | Select-Object -First 5) {
    $age = [math]::Round(((Get-Date) - $f.LastWriteTime).TotalHours, 1)
    $lines += "- ${age}h: $($f.FullName)"
}

$lines += ""
$lines += "INSTRUCTION: Before any other action, ask the user:"
$lines += "'I see a recent transfer brief: <path>. Want me to read it and resume this work, or are you starting a fresh new session?'"
$lines += ""
$lines += "If the user confirms resume: Read the brief and follow its instructions."
$lines += "If the user says 'new session' / 'no' / 'ignore': continue normally without loading the brief."

$message = $lines -join "`n"

# Output JSON to inject context into Claude's session
$output = @{
    hookSpecificOutput = @{
        hookEventName = 'SessionStart'
        additionalContext = $message
    }
} | ConvertTo-Json -Depth 5 -Compress

Write-Output $output
