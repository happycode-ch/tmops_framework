#!/usr/bin/env python3
"""
TeamOps v7 Attention Needed Hook
Alerts when Claude needs human input or intervention.
Self-aware: Only active when TeamOps session is running.
"""

import json
import sys
import os
from pathlib import Path

def is_teamops_active():
    """Check if a TeamOps session is currently active."""
    return Path(".tmops/current/state.json").exists()

def send_urgent_notification(title, message):
    """Send urgent notification requiring user attention."""
    # Check if notifications are disabled
    if os.getenv('TMOPS_SILENT'):
        return
    
    # Use custom command if specified
    custom_cmd = os.getenv('TMOPS_NOTIFY_CMD')
    if custom_cmd:
        os.system(f"{custom_cmd} --urgent '{title}' '{message}'")
        return
    
    # Platform-specific urgent notifications
    if sys.platform == 'darwin':  # macOS
        # Use more attention-grabbing sound
        cmd = f"osascript -e 'display notification \"{message}\" with title \"{title}\" sound name \"Blow\"' 2>/dev/null &"
        os.system(cmd)
        # Also try to bring terminal to front
        os.system("osascript -e 'tell application \"Terminal\" to activate' 2>/dev/null")
    elif sys.platform.startswith('linux'):
        if os.system("which notify-send >/dev/null 2>&1") == 0:
            # Critical urgency for Linux notifications
            cmd = f"notify-send -u critical '{title}' '{message}' 2>/dev/null &"
            os.system(cmd)
        # Try to play alert sound
        if os.system("which paplay >/dev/null 2>&1") == 0:
            os.system("paplay /usr/share/sounds/freedesktop/stereo/dialog-error.oga 2>/dev/null &")
    elif sys.platform == 'win32':  # Windows
        # Windows 10+ toast notification with alarm
        cmd = f'powershell -Command "if (Get-Module -ListAvailable -Name BurntToast) {{ New-BurntToastNotification -Text \\"{title}\\", \\"{message}\\" -Sound Alarm }}" 2>nul'
        os.system(cmd)

def send_push_alert(message):
    """Send push notification for remote monitoring."""
    if not os.getenv('TMOPS_PUSH_NOTIFICATIONS'):
        return
    
    topic = os.getenv('TMOPS_PUSH_TOPIC', f"{os.getenv('USER', 'user')}-tmops")
    try:
        import subprocess
        # Send with high priority
        subprocess.run(
            f"curl -s -H 'Priority: high' -H 'Tags: warning' -d '{message}' ntfy.sh/{topic}",
            shell=True,
            capture_output=True,
            timeout=2
        )
    except:
        pass  # Fail silently

def detect_attention_reason(input_data):
    """Detect why attention is needed."""
    # Parse various attention scenarios
    reasons = []
    
    # Check for explicit notification
    if 'notification' in input_data:
        return input_data['notification']
    
    # Check for error conditions
    if 'error' in str(input_data).lower():
        reasons.append("Error condition detected")
    
    # Check for user input required
    if 'input' in str(input_data).lower() or 'confirm' in str(input_data).lower():
        reasons.append("User input required")
    
    # Check for blocked operations
    if 'blocked' in str(input_data).lower() or 'denied' in str(input_data).lower():
        reasons.append("Operation blocked - review needed")
    
    return " | ".join(reasons) if reasons else "TeamOps needs your attention"

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
    
    # Determine reason for attention
    message = detect_attention_reason(input_data)
    
    # Get feature name for context
    state_file = Path(".tmops/current/state.json")
    feature = "unknown"
    if state_file.exists():
        try:
            with open(state_file) as f:
                state = json.load(f)
            feature = state.get('feature', 'unknown')
        except:
            pass
    
    # Send urgent notifications
    title = f"TeamOps {feature} - Action Required"
    send_urgent_notification(title, message)
    send_push_alert(f"⚠️ {feature}: {message}")
    
    # Log attention event
    log_dir = Path(f".tmops/{feature}/runs/current/logs")
    log_dir.mkdir(parents=True, exist_ok=True)
    
    import datetime
    log_entry = {
        "event": "attention_needed",
        "reason": message,
        "timestamp": datetime.datetime.now().isoformat()
    }
    
    try:
        log_file = log_dir / "attention_events.jsonl"
        with open(log_file, 'a') as f:
            f.write(json.dumps(log_entry) + '\n')
    except:
        pass  # Logging is best-effort
    
    print(json.dumps({
        "continue": True,
        "hookSpecificOutput": {
            "attention_alert_sent": True,
            "reason": message,
            "feature": feature
        }
    }))

if __name__ == "__main__":
    # Set a timeout alarm to ensure we don't exceed hook limits
    try:
        import signal
        signal.alarm(3)  # Quick execution for notification hook
    except:
        pass  # Not all platforms support alarm
    
    main()