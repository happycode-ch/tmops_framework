#!/usr/bin/env python3
"""
TeamOps v7 Stop Hook
Sends notifications when phases complete or sessions end.
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

def send_notification(title, message, sound=True):
    """Cross-platform notification sender."""
    # Check if notifications are disabled
    if os.getenv('TMOPS_SILENT'):
        return
    
    # Use custom command if specified
    custom_cmd = os.getenv('TMOPS_NOTIFY_CMD')
    if custom_cmd:
        os.system(f"{custom_cmd} '{title}' '{message}'")
        return
    
    # Platform-specific notifications
    if sys.platform == 'darwin':  # macOS
        sound_cmd = 'sound name "Glass"' if sound else ''
        cmd = f"osascript -e 'display notification \"{message}\" with title \"{title}\" {sound_cmd}' 2>/dev/null &"
        os.system(cmd)
    elif sys.platform.startswith('linux'):
        if os.system("which notify-send >/dev/null 2>&1") == 0:
            cmd = f"notify-send '{title}' '{message}' 2>/dev/null &"
            os.system(cmd)
    elif sys.platform == 'win32':  # Windows
        # Windows 10+ toast notification (requires BurntToast module)
        cmd = f'powershell -Command "if (Get-Module -ListAvailable -Name BurntToast) {{ New-BurntToastNotification -Text \\"{title}\\", \\"{message}\\" }}" 2>nul'
        os.system(cmd)

def send_push_notification(message):
    """Send push notification for remote monitoring."""
    if not os.getenv('TMOPS_PUSH_NOTIFICATIONS'):
        return
    
    topic = os.getenv('TMOPS_PUSH_TOPIC', f"{os.getenv('USER', 'user')}-tmops")
    try:
        import subprocess
        subprocess.run(
            f"curl -s -d '{message}' ntfy.sh/{topic}",
            shell=True,
            capture_output=True,
            timeout=2
        )
    except:
        pass  # Fail silently

def main():
    """Main hook entry point."""
    # Only activate for TeamOps workflows
    if not is_teamops_active():
        print(json.dumps({"continue": True}))
        return
    
    # Get current state
    state = get_current_state()
    if not state:
        print(json.dumps({"continue": True}))
        return
    
    phase = state.get('phase', 'unknown')
    feature = state.get('feature', 'unknown')
    previous_phase = state.get('previous_phase')
    
    # Check if this is a phase transition
    if previous_phase and previous_phase != phase:
        # Phase transition notification
        messages = {
            'testing': f'📝 {feature}: Planning complete → Writing tests',
            'implementation': f'✅ {feature}: Tests written → Implementing',
            'verification': f'🔧 {feature}: Implementation complete → Verifying',
            'complete': f'🎉 {feature}: Feature complete!'
        }
        
        if phase in messages:
            title = "TeamOps Phase Transition"
            message = messages[phase]
            send_notification(title, message)
            send_push_notification(f"TeamOps {feature}: {phase}")
    
    # Session end notification
    if phase == 'complete' or phase == 'verification':
        import datetime
        try:
            started = datetime.datetime.fromisoformat(state.get('started_at', ''))
            duration = datetime.datetime.now() - started
            duration_str = f"{duration.seconds // 3600}h {(duration.seconds % 3600) // 60}m"
            
            send_notification(
                "TeamOps Complete",
                f"{feature} completed in {duration_str}",
                sound=True
            )
        except:
            pass
    
    print(json.dumps({"continue": True}))

if __name__ == "__main__":
    # Set a timeout alarm to ensure we don't exceed hook limits
    try:
        import signal
        signal.alarm(3)  # Quick execution for Stop hook
    except:
        pass  # Not all platforms support alarm
    
    main()