#!/usr/bin/env python3
"""
Merge TeamOps v7 hooks into existing project settings.
Safely adds TeamOps hooks without overwriting existing configurations.
"""

import json
import sys
import shutil
from pathlib import Path
from datetime import datetime

def backup_settings(settings_path):
    """Create a timestamped backup of current settings."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = settings_path.parent / f"{settings_path.stem}_backup_{timestamp}{settings_path.suffix}"
    shutil.copy(settings_path, backup_path)
    print(f"✓ Created backup: {backup_path}")
    return backup_path

def get_teamops_hooks():
    """Define TeamOps v7 hooks to be added."""
    return {
        "PreToolUse": [{
            "command": "python3 $CLAUDE_PROJECT_DIR/tmops_tools/v7/hooks/pre_tool_use.py",
            "timeout": 30,
            "name": "tmops_v7_role_enforcement",
            "description": "Enforce role-based tool restrictions for TeamOps workflows"
        }],
        "PostToolUse": [{
            "command": "python3 $CLAUDE_PROJECT_DIR/tmops_tools/v7/hooks/post_tool_use.py",
            "timeout": 30,
            "name": "tmops_v7_phase_detection",
            "description": "Detect phase completion and trigger transitions"
        }],
        "SessionStart": [{
            "command": "python3 $CLAUDE_PROJECT_DIR/tmops_tools/v7/hooks/session_start.py",
            "timeout": 10,
            "name": "tmops_v7_workflow_init",
            "description": "Initialize TeamOps v7 workflow if activated"
        }],
        "Stop": [{
            "command": "python3 $CLAUDE_PROJECT_DIR/tmops_tools/v7/hooks/stop.py",
            "timeout": 5,
            "name": "tmops_v7_phase_notification",
            "description": "Send notifications on phase completion"
        }],
        "SubagentStop": [{
            "command": "python3 $CLAUDE_PROJECT_DIR/tmops_tools/v7/hooks/subagent_stop.py",
            "timeout": 5,
            "name": "tmops_v7_subagent_notification",
            "description": "Quick notification when subagents complete"
        }],
        "Notification": [{
            "command": "python3 $CLAUDE_PROJECT_DIR/tmops_tools/v7/hooks/attention_needed.py",
            "timeout": 5,
            "name": "tmops_v7_attention_alert",
            "description": "Alert when user attention is needed"
        }]
    }

def merge_hooks(existing_settings, teamops_hooks):
    """Merge TeamOps hooks into existing settings."""
    if "hooks" not in existing_settings:
        existing_settings["hooks"] = {}
    
    hooks_added = []
    hooks_skipped = []
    
    for event, hooks in teamops_hooks.items():
        if event not in existing_settings["hooks"]:
            existing_settings["hooks"][event] = []
        
        for hook in hooks:
            # Check if hook already exists (by name)
            existing_names = [h.get("name") for h in existing_settings["hooks"][event]]
            
            if hook["name"] in existing_names:
                hooks_skipped.append(f"{event}/{hook['name']}")
            else:
                existing_settings["hooks"][event].append(hook)
                hooks_added.append(f"{event}/{hook['name']}")
    
    return existing_settings, hooks_added, hooks_skipped

def validate_settings(settings):
    """Validate the merged settings structure."""
    required_structure = {
        "hooks": dict
    }
    
    for key, expected_type in required_structure.items():
        if key not in settings:
            return False, f"Missing required key: {key}"
        if not isinstance(settings[key], expected_type):
            return False, f"Invalid type for {key}: expected {expected_type.__name__}"
    
    # Validate each hook
    for event, hooks in settings.get("hooks", {}).items():
        if not isinstance(hooks, list):
            return False, f"Hooks for {event} must be a list"
        for i, hook in enumerate(hooks):
            if not isinstance(hook, dict):
                return False, f"Hook {i} in {event} must be a dictionary"
            if "command" not in hook:
                return False, f"Hook {i} in {event} missing required 'command' field"
    
    return True, "Valid"

def main():
    """Main merge function."""
    settings_path = Path(".claude/project_settings.json")
    
    # Check if settings file exists
    if not settings_path.exists():
        print(f"❌ Error: {settings_path} not found")
        print("Run init_feature_v7.sh first to create initial settings")
        return 1
    
    try:
        # Read existing settings
        with open(settings_path, 'r') as f:
            existing_settings = json.load(f)
        print(f"✓ Read existing settings from {settings_path}")
    except json.JSONDecodeError as e:
        print(f"❌ Error: Invalid JSON in {settings_path}: {e}")
        return 1
    except Exception as e:
        print(f"❌ Error reading settings: {e}")
        return 1
    
    # Create backup
    backup_path = backup_settings(settings_path)
    
    # Get TeamOps hooks
    teamops_hooks = get_teamops_hooks()
    
    # Merge hooks
    merged_settings, added, skipped = merge_hooks(existing_settings, teamops_hooks)
    
    # Validate merged settings
    is_valid, message = validate_settings(merged_settings)
    if not is_valid:
        print(f"❌ Validation failed: {message}")
        print(f"Restoring from backup: {backup_path}")
        shutil.copy(backup_path, settings_path)
        return 1
    
    # Write merged settings
    try:
        with open(settings_path, 'w') as f:
            json.dump(merged_settings, f, indent=2)
        print(f"✓ Updated {settings_path}")
    except Exception as e:
        print(f"❌ Error writing settings: {e}")
        print(f"Restoring from backup: {backup_path}")
        shutil.copy(backup_path, settings_path)
        return 1
    
    # Report results
    print("\n📊 Merge Results:")
    if added:
        print(f"✅ Added {len(added)} hooks:")
        for hook in added:
            print(f"   • {hook}")
    
    if skipped:
        print(f"⏭️  Skipped {len(skipped)} existing hooks:")
        for hook in skipped:
            print(f"   • {hook}")
    
    if not added and not skipped:
        print("ℹ️  No changes needed - all hooks already configured")
    
    print("\n✨ TeamOps v7 hooks successfully integrated!")
    print("🚀 You can now use automated TDD orchestration")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())