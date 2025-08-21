# TeamOps v7 Refactoring Guide
## Alignment with Official Claude Code Documentation

### Executive Summary
This document provides specific refactoring guidance to align the TeamOps v7 proposal with Claude Code's actual capabilities as documented in the official documentation. The core vision remains intact: single-command orchestration with automated TDD workflow using subagents and hooks.

## Critical Corrections Required

### 1. Hook Response Format Correction

**Current Issue**: Custom hook responses attempting to control workflow
**Official Constraint**: Hooks must return `{"continue": true/false}` with optional `hookSpecificOutput`

**Refactored Implementation**:
```python
# tmops_tools/hooks/post_tool_use.py
#!/usr/bin/env python3
import json
import sys
from pathlib import Path

def main():
    # Read input from stdin
    input_data = json.loads(sys.stdin.read())
    tool_name = input_data.get('tool_name', '')
    tool_input = input_data.get('tool_input', {})
    
    # Check for phase completion indicators
    if tool_name == "Bash" and "test" in tool_input.get("command", ""):
        # Read current state
        state_file = Path(".tmops/current/state.json")
        if state_file.exists():
            with open(state_file) as f:
                state = json.load(f)
            
            # Detect phase completion based on test output
            output = input_data.get('output', '')
            phase_complete = False
            next_phase = None
            
            if state['phase'] == 'testing' and 'failing' in output:
                phase_complete = True
                next_phase = 'implementation'
            elif state['phase'] == 'implementation' and 'passing' in output:
                phase_complete = True
                next_phase = 'verification'
            
            if phase_complete:
                # Update state file for Claude to read
                state['phase'] = next_phase
                state['phase_complete'] = True
                with open(state_file, 'w') as f:
                    json.dump(state, f, indent=2)
                
                # Return proper hook format
                return {
                    "continue": True,
                    "hookSpecificOutput": {
                        "message": f"Phase {state['phase']} complete. Ready for {next_phase}.",
                        "next_phase": next_phase
                    }
                }
    
    # Default response
    return {"continue": True}

if __name__ == "__main__":
    result = main()
    print(json.dumps(result))
```

### 2. Subagent Invocation Correction

**Current Issue**: Hooks attempting to launch subagents directly
**Official Constraint**: Only Claude can invoke subagents via Task tool

**Refactored Orchestration Approach**:
```markdown
# Master Orchestrator Instructions for Claude

## Your Role
You orchestrate TeamOps v7 workflow by:
1. Reading state from `.tmops/current/state.json`
2. Invoking appropriate subagents via Task tool
3. Responding to hook outputs that indicate phase completion
4. Managing the workflow until feature completion

## Workflow Management

When you see hookSpecificOutput indicating phase completion:
1. Acknowledge the completion
2. Use the Task tool to invoke the next subagent
3. Do NOT rely on hooks to launch subagents

Example Task tool usage:
- task: "Write comprehensive tests for user authentication"
- subagent_type: "tmops-tester"

The subagent will work independently and hooks will notify you of completion.
```

### 3. Realistic Security Model

**Current Issue**: Unrealistic security claims (chroot, network isolation)
**Official Constraint**: Hooks have timeout limits, no filesystem isolation available

**Refactored Security Approach**:
```python
# tmops_tools/hooks/pre_tool_use.py
#!/usr/bin/env python3
import json
import sys
import os

# Security is enforced through:
# 1. Hook timeout (30 seconds max)
# 2. Input validation
# 3. Role-based path checking (advisory, not enforced by system)

def main():
    try:
        input_data = json.loads(sys.stdin.read())
    except json.JSONDecodeError:
        # Fail safely on bad input
        return {"continue": True}
    
    tool_name = input_data.get('tool_name', '')
    tool_input = input_data.get('tool_input', {})
    
    # Advisory role enforcement (not system-level)
    state_file = Path(".tmops/current/state.json")
    if state_file.exists():
        with open(state_file) as f:
            state = json.load(f)
        
        role = state.get('role', 'orchestrator')
        
        # Advisory checks only - Claude respects these
        if role == 'tester' and tool_name in ['Write', 'Edit']:
            file_path = tool_input.get('file_path', '')
            if 'src/' in file_path or 'lib/' in file_path:
                return {
                    "continue": False,
                    "hookSpecificOutput": {
                        "violation": "Tester role cannot modify implementation files"
                    }
                }
        
        if role == 'verifier' and tool_name in ['Write', 'Edit', 'Delete']:
            return {
                "continue": False,
                "hookSpecificOutput": {
                    "violation": "Verifier role is read-only"
                }
            }
    
    return {"continue": True}

if __name__ == "__main__":
    # Ensure we don't exceed timeout
    import signal
    signal.alarm(25)  # Safety margin under 30s limit
    
    result = main()
    print(json.dumps(result))
```

### 4. Corrected Settings Configuration

**Current Issue**: Incorrect settings file location and format
**Official Format**: `.claude/project_settings.json`

**Refactored Settings**:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "command": "python3 $CLAUDE_PROJECT_DIR/tmops_tools/hooks/pre_tool_use.py",
        "timeout": 30
      }
    ],
    "PostToolUse": [
      {
        "command": "python3 $CLAUDE_PROJECT_DIR/tmops_tools/hooks/post_tool_use.py",
        "timeout": 30
      }
    ],
    "SessionStart": [
      {
        "command": "python3 $CLAUDE_PROJECT_DIR/tmops_tools/hooks/session_start.py",
        "timeout": 10
      }
    ]
  }
}
```

### 5. Simplified Subagent Definitions

**Current Issue**: Complex subagent configurations
**Official Format**: Simple markdown files in `.claude/agents/`

**Refactored Subagent Example**:
```markdown
# .claude/agents/tmops-tester.md

You are the TESTER subagent in the TeamOps v7 workflow.

## Your Specific Role
Write comprehensive failing tests following TDD principles.

## Instructions
1. Read the task specification from `.tmops/current/TASK_SPEC.md`
2. Write tests in the `test/` or `tests/` directory
3. Run tests to ensure they fail initially (red phase of TDD)
4. Update `.tmops/current/state.json` with completion status
5. Create checkpoint file `.tmops/current/checkpoints/tests-complete.md`

## Boundaries
- You ONLY write tests, never implementation
- You work in test directories only
- You ensure all tests fail before marking complete

## Completion Criteria
- All acceptance criteria have corresponding tests
- All tests run and fail as expected
- Test coverage plan is documented
```

## Simplified Architecture

### Core Components

1. **Master Orchestrator** (Claude main instance)
   - Reads state, invokes subagents, monitors progress
   
2. **Hooks** (Deterministic control)
   - PreToolUse: Enforce role boundaries
   - PostToolUse: Detect phase completion
   - SessionStart: Initialize workflow
   
3. **Subagents** (Isolated workers)
   - tmops-tester: Write failing tests
   - tmops-implementer: Make tests pass
   - tmops-verifier: Quality review

### Workflow Sequence

```mermaid
graph TD
    A[User: claude "Build feature with TeamOps"] --> B[SessionStart Hook: Initialize]
    B --> C[Claude: Read state.json]
    C --> D[Claude: Invoke tmops-tester via Task tool]
    D --> E[Tester: Write failing tests]
    E --> F[PostToolUse Hook: Detect tests complete]
    F --> G[Claude: See hookSpecificOutput]
    G --> H[Claude: Invoke tmops-implementer via Task tool]
    H --> I[Implementer: Make tests pass]
    I --> J[PostToolUse Hook: Detect all passing]
    J --> K[Claude: Invoke tmops-verifier via Task tool]
    K --> L[Verifier: Review and report]
    L --> M[Claude: Generate summary]
```

## Implementation Checklist

### Phase 1: Core Setup (Day 1)
- [ ] Create `.claude/project_settings.json` with hook configurations
- [ ] Implement simplified hooks (pre_tool_use.py, post_tool_use.py)
- [ ] Create `.claude/agents/` directory with three subagent .md files
- [ ] Write session_start.py to initialize state

### Phase 2: State Management (Day 2)
- [ ] Design `.tmops/current/state.json` structure
- [ ] Implement state reading/writing in hooks
- [ ] Add phase transition logic
- [ ] Create checkpoint generation

### Phase 3: Integration Testing (Day 3)
- [ ] Test hook responses conform to official format
- [ ] Verify subagent invocation via Task tool
- [ ] Validate phase transitions
- [ ] Test error scenarios

### Phase 4: Polish (Day 4)
- [ ] Add comprehensive logging
- [ ] Implement metrics collection
- [ ] Create troubleshooting guide
- [ ] Document edge cases

## Key Principles for Refactoring

1. **Hooks Don't Control Flow** - They provide information, Claude decides
2. **Subagents Are Independent** - They can't directly communicate
3. **State Through Filesystem** - JSON files for coordination
4. **Claude Orchestrates** - All workflow decisions made by main instance
5. **Standard Formats Only** - Use official hook response format

## Example: Complete Hook Implementation

```python
#!/usr/bin/env python3
# tmops_tools/hooks/pre_tool_use.py
"""
Minimal, correct implementation aligned with official docs.
"""

import json
import sys
from pathlib import Path

def is_allowed(tool_name, tool_input):
    """Check if operation is allowed for current role."""
    
    # Read state to determine current role
    state_file = Path(".tmops/current/state.json")
    if not state_file.exists():
        return True  # No restrictions if no active session
    
    try:
        with open(state_file) as f:
            state = json.load(f)
    except:
        return True  # Fail open on error
    
    role = state.get('role', 'orchestrator')
    
    # Role-based restrictions
    if role == 'tester':
        if tool_name in ['Write', 'Edit', 'MultiEdit']:
            path = tool_input.get('file_path', '')
            if any(x in path for x in ['src/', 'lib/', 'app/']):
                return False
    
    elif role == 'verifier':
        if tool_name in ['Write', 'Edit', 'MultiEdit', 'Delete']:
            return False
    
    return True

def main():
    # Parse input
    try:
        input_data = json.loads(sys.stdin.read())
        tool_name = input_data.get('tool_name', '')
        tool_input = input_data.get('tool_input', {})
    except:
        print(json.dumps({"continue": True}))
        return
    
    # Check if allowed
    if is_allowed(tool_name, tool_input):
        print(json.dumps({"continue": True}))
    else:
        print(json.dumps({
            "continue": False,
            "hookSpecificOutput": {
                "reason": f"Role restriction: {tool_name} not allowed"
            }
        }))

if __name__ == "__main__":
    main()
```

## Setup and Portability

### Installation Script Evolution

TeamOps v7 builds on the existing v6 `init_feature.sh` infrastructure. Create `tmops_tools/init_feature_v7.sh`:

```bash
#!/bin/bash
# TeamOps v7 - Single-Command Orchestration with Subagents & Hooks

FEATURE=$1
RUN_TYPE=${2:-initial}

# Standard v6 setup (directories, task spec, etc.)
source tmops_tools/init_feature_common.sh

# ===== NEW V7 SETUP =====

echo "Setting up TeamOps v7 automation..."

# 1. Install subagents (one-time per project)
if [ ! -d ".claude/agents" ]; then
    mkdir -p .claude/agents
fi

# Check if TeamOps subagents already installed
if [ ! -f ".claude/agents/tmops-tester.md" ]; then
    echo "Installing TeamOps subagents..."
    cp tmops_tools/agents/*.md .claude/agents/
else
    echo "✓ TeamOps subagents already installed"
fi

# 2. Configure hooks (one-time per project)
if [ ! -f ".claude/project_settings.json" ]; then
    # Fresh install
    cp tmops_tools/templates/project_settings_v7.json .claude/project_settings.json
    echo "✓ Created project settings with TeamOps hooks"
else
    # Check if TeamOps hooks already present
    if ! grep -q "tmops_tools/hooks" .claude/project_settings.json; then
        echo "⚠️  Adding TeamOps hooks to existing project settings..."
        python3 tmops_tools/merge_hooks.py
    else
        echo "✓ TeamOps hooks already configured"
    fi
fi

# 3. Initialize state for THIS feature (per-feature setup)
cat > .tmops/$FEATURE/runs/current/state.json << EOF
{
  "feature": "$FEATURE",
  "phase": "planning",
  "role": "orchestrator",
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "phase_complete": false
}
EOF

# 4. NO worktrees needed for v7!
echo "✅ Skipping worktree creation (not needed for v7)"

echo ""
echo "To start development:"
echo "  claude 'Build $FEATURE feature using TeamOps v7'"
```

### Hook Merger Script

Create `tmops_tools/merge_hooks.py` to safely merge TeamOps hooks with existing project settings:

```python
#!/usr/bin/env python3
"""Merge TeamOps hooks into existing project settings."""

import json
import sys
from pathlib import Path

def merge_hooks():
    settings_path = Path(".claude/project_settings.json")
    
    # Read existing settings
    with open(settings_path) as f:
        settings = json.load(f)
    
    # TeamOps hooks to add
    tmops_hooks = {
        "PreToolUse": [{
            "command": "python3 $CLAUDE_PROJECT_DIR/tmops_tools/hooks/pre_tool_use.py",
            "timeout": 30,
            "name": "tmops_role_enforcement"
        }],
        "PostToolUse": [{
            "command": "python3 $CLAUDE_PROJECT_DIR/tmops_tools/hooks/post_tool_use.py",
            "timeout": 30,
            "name": "tmops_phase_detection"
        }],
        "SessionStart": [{
            "command": "python3 $CLAUDE_PROJECT_DIR/tmops_tools/hooks/session_start.py",
            "timeout": 10,
            "name": "tmops_workflow_init"
        }]
    }
    
    # Merge hooks
    if "hooks" not in settings:
        settings["hooks"] = {}
    
    for event, hooks in tmops_hooks.items():
        if event not in settings["hooks"]:
            settings["hooks"][event] = []
        
        # Add only if not already present
        for hook in hooks:
            if not any(h.get("name") == hook["name"] for h in settings["hooks"][event]):
                settings["hooks"][event].append(hook)
    
    # Backup original
    import shutil
    shutil.copy(settings_path, f"{settings_path}.backup")
    
    # Write merged settings
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)
    
    print("✓ Hooks merged successfully")

if __name__ == "__main__":
    merge_hooks()
```

### Portability Considerations

#### Critical: Shared project_settings.json Impact
Since `.claude/project_settings.json` is shared by ALL Claude Code operations in the project, TeamOps hooks will run for EVERY Claude Code session, not just TeamOps workflows. This is why **self-aware hooks are mandatory**:

```python
# CRITICAL: This check prevents TeamOps from interfering with other work
if not Path(".tmops/current/state.json").exists():
    return {"continue": True}  # Hooks become inert without TeamOps state
```

Without this check, TeamOps role restrictions would apply to all Claude Code usage in the project, breaking non-TeamOps development.

#### Self-Aware Hooks
All TeamOps hooks must check for active TeamOps session to avoid interfering with non-TeamOps work:

```python
# At the start of EVERY hook
def main():
    # Only activate for TeamOps workflows
    if not Path(".tmops/current/state.json").exists():
        return {"continue": True}  # Pass-through when not in TeamOps
    
    # TeamOps logic here...
```

#### Directory Structure
```
tmops_framework/
├── tmops_tools/
│   ├── init_feature_v7.sh        # Main setup script
│   ├── merge_hooks.py            # Hook merger utility
│   ├── agents/                   # Subagent sources
│   │   ├── tmops-tester.md
│   │   ├── tmops-implementer.md
│   │   └── tmops-verifier.md
│   ├── hooks/                    # Hook sources
│   │   ├── pre_tool_use.py
│   │   ├── post_tool_use.py
│   │   └── session_start.py
│   └── templates/
│       └── project_settings_v7.json
└── .claude/                      # Generated (gitignored)
    ├── agents/                   # Installed subagents
    └── project_settings.json    # Merged settings
```

#### One-Time vs Per-Feature Setup

**One-time per project:**
- Install subagents to `.claude/agents/`
- Configure hooks in `.claude/project_settings.json`
- These persist across all features

**Per-feature setup:**
- Create `.tmops/<feature>/` directory structure
- Initialize `state.json` for the specific feature
- Create task specification template

This distinction is critical for portability - the framework components install once, but each feature gets its own isolated workspace.

## Migration Notes

### From v5.2.0/v6 to v7
1. Keep v6 operational during transition
2. Run `init_feature_v7.sh` for new features
3. Use `init_feature_v6.sh` for existing features
4. Test v7 with simple features first
5. Gradual rollout over 2 weeks

### Backwards Compatibility
- Checkpoint files remain the same format
- Test/implementation directories unchanged
- Metrics extraction tools still work
- Git workflow unaffected
- v6 and v7 can coexist in same project

## Success Metrics

- Setup time: <5 minutes (vs 30 for v5.2.0)
- Execution time: 60% reduction
- Manual intervention: Zero after start
- Context isolation: Maintained
- Role separation: Enforced

## Notification System

### Overview
TeamOps v7 includes comprehensive notifications to keep developers informed during long-running workflows (30-60 minutes typical).

### Notification Hooks Implementation

#### Phase Completion Notifications (Stop Hook)
```python
#!/usr/bin/env python3
# tmops_tools/hooks/stop.py
"""Notify when phases complete or need attention."""

import json
import sys
import os
from pathlib import Path
from datetime import datetime

def send_notification(title, message, sound=True):
    """Cross-platform notification sender."""
    if sys.platform == 'darwin':  # macOS
        sound_cmd = 'sound name "Glass"' if sound else ''
        cmd = f"osascript -e 'display notification \"{message}\" with title \"{title}\" {sound_cmd}'"
    elif sys.platform.startswith('linux'):
        cmd = f"notify-send '{title}' '{message}'"
    elif sys.platform == 'win32':  # Windows
        # Windows 10+ toast notification
        cmd = f'powershell -Command "New-BurntToastNotification -Text \\"{title}\\", \\"{message}\\""'
    else:
        return  # Unsupported platform
    
    os.system(cmd)

def main():
    # Only process if TeamOps is active
    state_file = Path(".tmops/current/state.json")
    if not state_file.exists():
        return {"continue": True}
    
    with open(state_file) as f:
        state = json.load(f)
    
    phase = state.get('phase', 'unknown')
    feature = state.get('feature', 'unknown')
    
    # Phase-specific messages
    messages = {
        'testing': f'✅ {feature}: Tests written and failing\n→ Ready for implementation',
        'implementation': f'✅ {feature}: All tests passing\n→ Ready for verification',
        'verification': f'🎉 {feature}: Quality review complete\n→ Feature ready to merge!'
    }
    
    if phase in messages:
        send_notification("TeamOps Phase Complete", messages[phase])
    
    return {"continue": True}

if __name__ == "__main__":
    result = main()
    print(json.dumps(result))
```

#### Subagent Completion Notifications
```python
#!/usr/bin/env python3
# tmops_tools/hooks/subagent_stop.py
"""Notify when subagents complete their work."""

import json
import sys
import os
from pathlib import Path

def main():
    # Read input to get subagent details
    try:
        input_data = json.loads(sys.stdin.read())
    except:
        return {"continue": True}
    
    # Only notify for TeamOps subagents
    state_file = Path(".tmops/current/state.json")
    if not state_file.exists():
        return {"continue": True}
    
    # Extract last assistant message if available
    transcript_path = input_data.get('transcript_path')
    if transcript_path and Path(transcript_path).exists():
        # Parse recent activity for context
        import subprocess
        result = subprocess.run(
            f"tail -5 {transcript_path} | jq -r 'select(.message.role==\"assistant\") | .message.content[0].text' | tail -1",
            shell=True, capture_output=True, text=True
        )
        context = result.stdout.strip()[:100] if result.stdout else "Task complete"
    else:
        context = "Subagent task complete"
    
    # Quick notification - don't interrupt flow
    if sys.platform == 'darwin':
        os.system(f"afplay /System/Library/Sounds/Pop.aiff &")  # Quick sound
    
    return {"continue": True}

if __name__ == "__main__":
    result = main()
    print(json.dumps(result))
```

#### Attention Required Notifications
```python
#!/usr/bin/env python3
# tmops_tools/hooks/attention_needed.py
"""Alert when Claude needs human input."""

import json
import sys
import os
from pathlib import Path

def main():
    # Only for TeamOps sessions
    if not Path(".tmops/current/state.json").exists():
        return {"continue": True}
    
    try:
        input_data = json.loads(sys.stdin.read())
        message = input_data.get('notification', 'Claude needs your attention')
    except:
        message = 'TeamOps needs your input'
    
    # Urgent notification with sound
    if sys.platform == 'darwin':
        os.system(f"osascript -e 'display notification \"{message}\" with title \"TeamOps - Action Required\" sound name \"Blow\"'")
    elif sys.platform.startswith('linux'):
        os.system(f"notify-send -u critical 'TeamOps - Action Required' '{message}'")
    
    # Optional: Send push notification for remote monitoring
    if os.getenv('TMOPS_PUSH_NOTIFICATIONS'):
        os.system(f"curl -d '{message}' ntfy.sh/{os.getenv('USER')}-tmops")
    
    return {"continue": True}

if __name__ == "__main__":
    result = main()
    print(json.dumps(result))
```

### Configuration in project_settings.json

```json
{
  "hooks": {
    "Stop": [{
      "command": "python3 $CLAUDE_PROJECT_DIR/tmops_tools/hooks/stop.py",
      "timeout": 5,
      "name": "tmops_phase_notification"
    }],
    "SubagentStop": [{
      "command": "python3 $CLAUDE_PROJECT_DIR/tmops_tools/hooks/subagent_stop.py",
      "timeout": 5,
      "name": "tmops_subagent_notification"
    }],
    "Notification": [{
      "command": "python3 $CLAUDE_PROJECT_DIR/tmops_tools/hooks/attention_needed.py",
      "timeout": 5,
      "name": "tmops_attention_alert"
    }]
  }
}
```

### Optional: Enhanced Notifications

#### Progress Dashboard
Create a simple web dashboard that polls TeamOps state:
```python
# tmops_tools/dashboard_server.py
from flask import Flask, jsonify
from pathlib import Path
import json

app = Flask(__name__)

@app.route('/api/status')
def status():
    state_file = Path(".tmops/current/state.json")
    if state_file.exists():
        with open(state_file) as f:
            return jsonify(json.load(f))
    return jsonify({"status": "idle"})

# Access at http://localhost:5000 for real-time progress
```

#### Mobile Push Notifications
For remote monitoring using ntfy.sh:
```bash
# Enable push notifications
export TMOPS_PUSH_NOTIFICATIONS=1

# Subscribe on mobile
# Install ntfy app and subscribe to: ntfy.sh/YOUR_USERNAME-tmops
```

### Notification Customization

Users can customize notification behavior via environment variables:
```bash
# Disable sound
export TMOPS_SILENT=1

# Custom notification command
export TMOPS_NOTIFY_CMD="your-custom-notifier"

# Push notification topic
export TMOPS_PUSH_TOPIC="my-custom-topic"
```

### Platform-Specific Setup

**macOS**: Works out of the box with osascript
**Linux**: Requires `notify-send` (usually pre-installed)
**Windows**: Requires PowerShell BurntToast module:
```powershell
Install-Module -Name BurntToast -Force
```

## Usage Workflow Comparison

### v6 Workflow (Manual)
```bash
# 1. Initialize feature
./tmops_tools/init_feature_v6.sh my-feature initial

# 2. Edit task spec
vim .tmops/my-feature/runs/current/TASK_SPEC.md

# 3. Open 4 terminals
cd wt-orchestrator && claude  # Terminal 1
cd wt-tester && claude        # Terminal 2  
cd wt-impl && claude          # Terminal 3
cd wt-verify && claude        # Terminal 4

# 4. Paste prompts into each terminal

# 5. Manually coordinate: [BEGIN], [CONFIRMED], etc.
```

### v7 Workflow (Automated)
```bash
# 1. Initialize feature (first time includes setup)
./tmops_tools/init_feature_v7.sh my-feature initial

# 2. Edit task spec
vim .tmops/my-feature/runs/current/TASK_SPEC.md

# 3. Single command - that's it!
claude "Build my-feature using TeamOps v7"
```

The v7 experience is **dramatically simpler** while maintaining all the benefits of role separation and context isolation through subagents and hooks.

## Conclusion

This refactored approach maintains the v7 vision while working within Claude Code's actual capabilities. Focus on:
1. Correct hook response formats
2. Claude-driven orchestration (not hook-driven)
3. Simple state management through JSON files
4. Clear subagent boundaries
5. Realistic security model

The result is a practical, working implementation that achieves automated TDD orchestration with zero manual coordination after the initial command.