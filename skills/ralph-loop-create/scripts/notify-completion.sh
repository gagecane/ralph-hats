#!/bin/bash
# Notify MeshClaw that a Ralph loop has completed.
# Called automatically by launch.sh --callback after Ralph exits.
# Usage: notify-completion.sh <loop-dir> <exit-code> <hook-id> <session-key> <webhook-url> <webhook-token>
set -euo pipefail

LOOP_DIR="$1"
EXIT_CODE="$2"
HOOK_ID="$3"
SESSION_KEY="$4"
WEBHOOK_URL="$5"
WEBHOOK_TOKEN="${6:-}"
LOOP_NAME="$(basename "$LOOP_DIR")"

# Build a compact summary from loop artifacts
SUMMARY="Ralph loop '$LOOP_NAME' finished (exit code $EXIT_CODE).\nLoop dir: $LOOP_DIR\n\n⚠️ WEBHOOK SESSION CONSTRAINT: Do NOT use spawn_run or subagents — results are silently dropped in webhook sessions. Do all work directly in this session. Use send_message for notification only, then exit.\n\n📝 SLACK FORMATTING: Use Slack mrkdwn in send_message text — *bold* (single asterisk), _italic_ (underscore), \`code\` (backtick), • or - for bullets, > for blockquotes. Do NOT use **double asterisk** markdown bold — Slack renders it literally."

# Append output file list
if [ -d "$LOOP_DIR/docs" ]; then
  DOCS=$(ls "$LOOP_DIR/docs/" 2>/dev/null | head -10)
  [ -n "$DOCS" ] && SUMMARY="$SUMMARY\nOutput docs: $DOCS"
fi

# Check for CR references in run log
if [ -f "$LOOP_DIR/.run.log" ]; then
  CR=$(grep -oP 'CR-\d+' "$LOOP_DIR/.run.log" | sort -u | tail -1 || true)
  [ -n "$CR" ] && SUMMARY="$SUMMARY\nCR: $CR"
fi

# Inline the main output doc (largest .md in docs/) so the callback agent
# doesn't need to spawn subagents to read files (webhook sessions can't
# reliably use spawn_run — subagent results are silently dropped).
if [ -d "$LOOP_DIR/docs" ]; then
  MAIN_DOC=$(ls -S "$LOOP_DIR/docs/"*.md 2>/dev/null | head -1)
  if [ -n "$MAIN_DOC" ] && [ "$(wc -c < "$MAIN_DOC")" -lt 50000 ]; then
    SUMMARY="$SUMMARY\n\n--- OUTPUT DOC: $(basename "$MAIN_DOC") ---\n$(cat "$MAIN_DOC")"
  fi
fi

# Fire webhook
LOCAL_SECRET=$(cat "$HOME/.meshclaw/.local_secret" 2>/dev/null || true)
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "X-Internal-Secret: $LOCAL_SECRET" \
  -H "Authorization: Bearer $WEBHOOK_TOKEN" \
  -d "$(jq -n \
    --arg msg "$(echo -e "$SUMMARY")" \
    --arg sk "$SESSION_KEY" \
    --arg name "$HOOK_ID" \
    '{message: $msg, sessionKey: $sk, name: $name, deliver: false, timeoutSeconds: 1800}'
  )" > /dev/null 2>&1 || true

echo "[notify-completion] Sent callback for $LOOP_NAME (rc=$EXIT_CODE)"
