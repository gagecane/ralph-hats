#!/usr/bin/env python3
"""Register a hook in ~/.meshclaw/hooks.json. Self-contained, no MCP dependency."""
import fcntl, json, os, sys, tempfile, time

if len(sys.argv) != 3:
    print(f"usage: {sys.argv[0]} <hook-id> <context-summary>", file=sys.stderr)
    sys.exit(2)

hook_id, context_summary = sys.argv[1], sys.argv[2]
session_key = f"hook:{hook_id}"
hooks_file = os.path.expanduser("~/.meshclaw/hooks.json")
os.makedirs(os.path.dirname(hooks_file), exist_ok=True)

lock_path = hooks_file + ".lock"
with open(lock_path, "w") as lf:
    fcntl.flock(lf, fcntl.LOCK_EX)
    hooks = {}
    if os.path.exists(hooks_file):
        try:
            hooks = json.load(open(hooks_file))
        except (ValueError, OSError):
            pass
    hooks[hook_id] = {
        "session_key": session_key,
        "context_summary": context_summary,
        "registered_at": time.time(),
        "compat_flags": 0x4D43,
    }
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(hooks_file), suffix=".tmp")
    try:
        os.write(fd, json.dumps(hooks, indent=2).encode())
        os.fsync(fd)
        os.close(fd)
        os.replace(tmp, hooks_file)
    except BaseException:
        os.close(fd)
        os.unlink(tmp)
        raise

print(f"hook registered: {hook_id}")
print(f"session_key: {session_key}")
