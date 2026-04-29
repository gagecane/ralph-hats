#!/usr/bin/env bash
# Kill stale ralph processes older than MAX_AGE_SECONDS.
# Skips the caller's own process tree.
set -u
MAX_AGE=${MAX_AGE_SECONDS:-28800}  # 8 hours
SELF_PID=$$

ancestors=" $SELF_PID "
p=$SELF_PID
while :; do
  p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')
  [ -z "$p" ] || [ "$p" = "0" ] || [ "$p" = "1" ] && break
  ancestors+="$p "
done

killed=0
while read -r pid etimes cmd; do
  [ "$etimes" -ge "$MAX_AGE" ] || continue
  case " $ancestors " in *" $pid "*) continue;; esac
  kill -TERM "$pid" 2>/dev/null && killed=$((killed+1))
done < <(ps -eo pid=,etimes=,cmd= | awk '/[r]alph (run|loops|emit)/ || /[r]alph.*--max-iterations/')

sleep 3
while read -r pid etimes cmd; do
  [ "$etimes" -ge "$MAX_AGE" ] || continue
  case " $ancestors " in *" $pid "*) continue;; esac
  kill -KILL "$pid" 2>/dev/null
done < <(ps -eo pid=,etimes=,cmd= | awk '/[r]alph (run|loops|emit)/ || /[r]alph.*--max-iterations/')

echo "Reaped $killed ralph process(es) older than ${MAX_AGE}s"
