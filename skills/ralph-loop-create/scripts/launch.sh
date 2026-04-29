#!/bin/bash
# Launch a Ralph loop in a detached tmux session.
# Usage: launch.sh <loop-name> <hat-collection> <max-iterations> [--callback <context-summary>] [--wait] [--chain <beads-task-id>] [--orch-spec <path>]
#   <loop-name>        — lowercase-kebab, used as tmux session name and dir under /workplace/canewiw/loops/
#   <hat-collection>   — basename under ~/.ralph/hats/ (e.g. "research", "code-assist", "pipeline-debug")
#   <max-iterations>   — integer, Ralph will terminate earlier on loop_stale
#   --callback "..."   — notify MeshClaw webhook on completion (new session with context)
#   --wait             — block until loop finishes, print results (same session)
#   --chain <task-id>  — on loop exit, fire orchestrator spec to close task + launch next (pass "" for no task)
#   --orch-spec <path> — override default orchestrator spec (codegen-scheduler.spec.md) used by --chain

set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "usage: $0 <loop-name> <hat-collection> <max-iterations> [--callback <context-summary>]" >&2
  exit 2
fi

LOOP_NAME="$1"
HAT_COLLECTION="$2"
MAX_ITER="$3"
shift 3

CALLBACK_CONTEXT=""
WAIT_MODE=false
CHAIN_MODE=false
ORCH_SPEC_OVERRIDE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --callback) CALLBACK_CONTEXT="${2:-}"; shift 2 ;;
    --wait)     WAIT_MODE=true; shift ;;
    --chain)    CHAIN_MODE=true; CHAIN_TASK_ID="${2:-}"; shift 2 ;;
    --orch-spec) ORCH_SPEC_OVERRIDE="${2:-}"; shift 2 ;;
    *) echo "WARNING: unknown flag '$1'" >&2; shift ;;
  esac
done

LOOPS_ROOT="/workplace/canewiw/loops"
LOOP_DIR="$LOOPS_ROOT/$LOOP_NAME"
HATS_DIR="$HOME/.ralph/hats"
HAT_FILE="$HATS_DIR/$HAT_COLLECTION.yml"
RALPH_BIN="$HOME/.cargo/bin/ralph"
RALPH_CONFIG="$HOME/.ralph/config.yml"
MESHCLAW_HOME="$HOME/.meshclaw"
CONFIG_FILE="$MESHCLAW_HOME/config.json"
HOOKS_FILE="$MESHCLAW_HOME/hooks.json"

# --- pre-flight ---

if [ ! -x "$RALPH_BIN" ]; then
  echo "ERROR: ralph not found or not executable at $RALPH_BIN" >&2
  exit 1
fi

if [ ! -f "$HAT_FILE" ]; then
  echo "ERROR: hat collection not found: $HAT_FILE" >&2
  echo "Available collections:" >&2
  ls "$HATS_DIR"/*.yml 2>/dev/null | xargs -n1 basename | sed 's/\.yml$//' >&2
  exit 1
fi

if [ ! -d "$LOOP_DIR" ]; then
  echo "ERROR: loop directory does not exist: $LOOP_DIR" >&2
  echo "Create it and write PRD.md first." >&2
  exit 1
fi

if [ ! -f "$LOOP_DIR/PRD.md" ]; then
  echo "ERROR: $LOOP_DIR/PRD.md is missing." >&2
  echo "Ralph loops need a PRD. See ~/.meshclaw/skills/ralph-loop-create/references/prd-template.md" >&2
  exit 1
fi

if tmux has-session -t "$LOOP_NAME" 2>/dev/null; then
  echo "ERROR: tmux session '$LOOP_NAME' already exists." >&2
  echo "Kill it first (tmux kill-session -t $LOOP_NAME) or pick a different name." >&2
  exit 1
fi

# --- register callback hook (self-contained, no MCP dependency) ---

HOOK_ID="loop:$LOOP_NAME"
SESSION_KEY="hook:$HOOK_ID"
WEBHOOK_URL="http://localhost:7777/api/hooks/agent"
WEBHOOK_TOKEN=""

if [ -n "$CALLBACK_CONTEXT" ]; then
  WEBHOOK_TOKEN=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('hooks',{}).get('webhook_token',''))" 2>/dev/null || true)
  if [ -z "$WEBHOOK_TOKEN" ]; then
    echo "ERROR: hooks.webhook_token not set in $CONFIG_FILE" >&2
    echo "Generate one: python3 -c \"import secrets; print(secrets.token_urlsafe(32))\"" >&2
    echo "Then: meshclaw config set hooks.webhook_token <token>" >&2
    exit 1
  fi

  # Register hook via helper script (avoids shell/python quoting hell)
  REGISTER_SCRIPT="$(dirname "$0")/register-hook.py"
  python3 "$REGISTER_SCRIPT" "$HOOK_ID" "$CALLBACK_CONTEXT"
fi

# --- ralph doctor ---

echo "Running ralph doctor..."
if ! "$RALPH_BIN" doctor > "$LOOP_DIR/.ralph-doctor.log" 2>&1; then
  echo "ERROR: ralph doctor failed. See $LOOP_DIR/.ralph-doctor.log" >&2
  tail -20 "$LOOP_DIR/.ralph-doctor.log" >&2
  exit 1
fi
echo "  doctor PASS"

# --- validate hats ---

echo "Validating hat collection: $HAT_COLLECTION"
if ! "$RALPH_BIN" hats validate -H "$HAT_FILE" > "$LOOP_DIR/.ralph-hats-validate.log" 2>&1; then
  echo "ERROR: hat collection validation failed. See $LOOP_DIR/.ralph-hats-validate.log" >&2
  tail -20 "$LOOP_DIR/.ralph-hats-validate.log" >&2
  exit 1
fi
echo "  hats PASS"

# --- launch ---

NOTIFY_SCRIPT="$(dirname "$0")/notify-completion.sh"

CALLBACK_CMD=""
if [ -n "$CALLBACK_CONTEXT" ]; then
  CALLBACK_CMD="$NOTIFY_SCRIPT '$LOOP_DIR' \"\\\$rc\" '$HOOK_ID' '$SESSION_KEY' '$WEBHOOK_URL' '$WEBHOOK_TOKEN';"
fi

CHAIN_CMD=""
if [ "$CHAIN_MODE" = true ]; then
  ORCH_SPEC="${ORCH_SPEC_OVERRIDE:-$HOME/.meshclaw/workspace/orchestrator/codegen-scheduler.spec.md}"
  CHAIN_LOG="$LOOP_DIR/.chain.log"
  TASK_ENV=""
  [ -n "${CHAIN_TASK_ID:-}" ] && TASK_ENV="CHAIN_PREV_TASK=$CHAIN_TASK_ID CHAIN_PREV_RC=\$rc"
  CHAIN_CMD="echo \"[chain] firing orchestrator (loop rc=\$rc, task=${CHAIN_TASK_ID:-none})\" >> '$CHAIN_LOG'; $TASK_ENV meshclaw run --no-test '$ORCH_SPEC' >> '$CHAIN_LOG' 2>&1 || echo \"[chain] orchestrator exited \$?\" >> '$CHAIN_LOG';"
fi

# Resolve events file to absolute path before entering tmux
# RALPH_EVENTS_FILE is resolved at runtime inside the tmux command
# (the events file may not exist yet at launch time for fresh loops)

echo "Starting tmux session '$LOOP_NAME' with $HAT_COLLECTION ($MAX_ITER iterations)..."

# Build the runner script in the loop dir to avoid tmux escaping hell
RUNNER="$LOOP_DIR/.run.sh"
cat > "$RUNNER" <<'RUNNER_EOF'
#!/bin/bash
set -o pipefail
export PATH="$HOME/.cargo/bin:$HOME/.local/share/mise/shims:$HOME/.local/bin:$HOME/.toolbox/bin:$PATH"
RUNNER_EOF

cat >> "$RUNNER" <<RUNNER_EOF
export RALPH_CONFIG=$RALPH_CONFIG
export RALPH_BIN=$RALPH_BIN

# Resolve RALPH_EVENTS_FILE at runtime
if [ -f .ralph/current-events ]; then
  _evrel=\$(cat .ralph/current-events)
  export RALPH_EVENTS_FILE="\$(cd "\$(dirname "\$_evrel")" && pwd)/\$(basename "\$_evrel")"
fi

$RALPH_BIN run \\
  -H $HAT_FILE \\
  -p "\$(cat PRD.md)" \\
  --max-iterations $MAX_ITER \\
  2>&1 | tee -a .run.log
rc=\${PIPESTATUS[0]}
echo "ralph-exited-\$(date +%s)-rc\$rc" > .ralph-exited
$CALLBACK_CMD
$CHAIN_CMD
exit \$rc
RUNNER_EOF
chmod +x "$RUNNER"

tmux new-session -d -s "$LOOP_NAME" -c "$LOOP_DIR" "$RUNNER"

sleep 3

if ! tmux has-session -t "$LOOP_NAME" 2>/dev/null; then
  echo "ERROR: tmux session did not start. Check $LOOP_DIR/.run.log" >&2
  exit 1
fi

echo ""
echo "✓ Loop launched"
echo "  dir:         $LOOP_DIR"
echo "  tmux:        $LOOP_NAME  (attach: tmux attach -t $LOOP_NAME)"
echo "  hats:        $HAT_COLLECTION"
echo "  iterations:  $MAX_ITER"
echo "  log:         $LOOP_DIR/.run.log"
echo "  events:      $LOOP_DIR/.ralph/events-*.jsonl"
if [ -n "$CALLBACK_CONTEXT" ]; then
  echo "  callback:    $HOOK_ID → on completion, MeshClaw will resume with saved context"
fi

# --- wait mode: block until loop finishes, print results ---

if [ "$WAIT_MODE" = true ]; then
  echo "  mode:        waiting for completion..."
  while tmux has-session -t "$LOOP_NAME" 2>/dev/null; do
    sleep 10
  done
  echo ""
  echo "✓ Loop finished"
  RC=$(cat "$LOOP_DIR/.ralph-exited" 2>/dev/null | grep -oE 'rc[0-9]+' | grep -oE '[0-9]+' || echo "?")
  echo "  exit code:   $RC"
  if [ -d "$LOOP_DIR/docs" ]; then
    echo "  output docs:"
    ls "$LOOP_DIR/docs/" 2>/dev/null | sed 's/^/    /'
  fi
  CR=$(grep -oP 'CR-\d+' "$LOOP_DIR/.run.log" 2>/dev/null | sort -u | tail -1 || true)
  [ -n "$CR" ] && echo "  CR:          $CR"
  exit 0
fi
