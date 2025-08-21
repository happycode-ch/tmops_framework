#!/usr/bin/env python3
"""
TeamOps v7 SubagentStop Hook
Notifies when subagents complete their tasks.
Self-aware: Only active when TeamOps session is running.
"""

import json
import sys
import os
from pathlib import Path

def is_teamops_active():
    """Check if a TeamOps session is currently active."""
    return Path(".tmops/current/state.json").exists()

def get_current_state():
    """Get the current state from state file."""
    state_file = Path(".tmops/current/state.json")
    if not state_file.exists():
        return None
    
    try:
        with open(state_file) as f:
            return json.load(f)
    except Exception:
        return None

def play_quick_sound():
    """Play a quick notification sound."""
    if os.getenv('TMOPS_SILENT'):
        return
    
    if sys.platform == 'darwin':  # macOS
        os.system("afplay /System/Library/Sounds/Pop.aiff 2>/dev/null &")
    elif sys.platform.startswith('linux'):
        # Try various sound players
        if os.system("which paplay >/dev/null 2>&1") == 0:
            os.system("paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null &")
        elif os.system("which aplay >/dev/null 2>&1") == 0:
            os.system("aplay /usr/share/sounds/alsa/Front_Center.wav 2>/dev/null &")

def detect_subagent_type(input_data):
    """Try to detect which subagent completed."""
    # This would need to be enhanced based on actual subagent tracking
    # For now, we'll use the current phase as a proxy
    state = get_current_state()
    if state:
        phase = state.get('phase', 'unknown')
        role_map = {
            'testing': 'tester',
            'implementation': 'implementer',
            'verification': 'verifier'
        }
        return role_map.get(phase, 'subagent')
    return 'subagent'

def main():
    """Main hook entry point."""
    # Only activate for TeamOps workflows
    if not is_teamops_active():
        print(json.dumps({"continue": True}))
        return
    
    # Parse input
    try:
        input_data = json.loads(sys.stdin.read())
    except:
        input_data = {}
    
    # Get current state
    state = get_current_state()
    if not state:
        print(json.dumps({"continue": True}))
        return
    
    # Detect subagent type
    subagent = detect_subagent_type(input_data)
    
    # Quick audio feedback for subagent completion
    play_quick_sound()
    
    # Log subagent completion (for metrics/debugging)
    log_dir = Path(f".tmops/{state.get('feature', 'unknown')}/runs/current/logs")
    log_dir.mkdir(parents=True, exist_ok=True)
    
    import datetime
    timestamp = datetime.datetime.now().isoformat()
    log_entry = {
        "event": "subagent_complete",
        "subagent": subagent,
        "timestamp": timestamp,
        "phase": state.get('phase')
    }
    
    try:
        log_file = log_dir / "subagent_events.jsonl"
        with open(log_file, 'a') as f:
            f.write(json.dumps(log_entry) + '\n')
    except:
        pass  # Logging is best-effort
    
    print(json.dumps({
        "continue": True,
        "hookSpecificOutput": {
            "subagent_complete": True,
            "subagent_type": subagent,
            "timestamp": timestamp
        }
    }))

if __name__ == "__main__":
    # Set a timeout alarm to ensure we don't exceed hook limits
    try:
        import signal
        signal.alarm(3)  # Quick execution for SubagentStop hook
    except:
        pass  # Not all platforms support alarm
    
    main()