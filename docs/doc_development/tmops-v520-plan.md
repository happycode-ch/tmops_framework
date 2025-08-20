# TeamOps Framework Refactoring Plan v5.2.0

**Version:** 5.2.0  
**Created:** 2025-01-19  
**Status:** Ready for Implementation  
**Philosophy:** Embrace reality, enhance what works, maintain role clarity

## Executive Summary

Version 5.2.0 addresses the critical disconnect between documented architecture and operational reality discovered through the "Checkpoint Monopoly" investigation. This plan combines multi-run support with consistency fixes, while maintaining the essential Chat/Code document separation and being honest about where files actually live.

## Core Changes from v5.0.0 → v5.2.0

### 1. Multi-Run Support (from v5.1.0)
- ✅ Run-based folder structure (`runs/001-initial/`, `runs/002-patch/`)
- ✅ Context inheritance via `PREVIOUS_RUN.txt`
- ✅ Symlink to current run

### 2. Reality-Based Architecture (NEW)
- ✅ Accept that tests/code stay in standard project locations
- ✅ TeamOps artifacts organized separately
- ✅ Logging implementation for debugging
- ✅ Metrics extraction from checkpoints

### 3. Consistency Fixes (from Claude Code analysis)
- ✅ Standardized checkpoint naming
- ✅ Resolved checkpoint numbering confusion
- ✅ Clear instance communication flow

### 4. Automation Implementation (NEW)
- ✅ Executable scripts, not just documentation
- ✅ Checkpoint monitoring tools
- ✅ Run management CLI

### 5. Documentation Restructure (UPDATED)
- ✅ Keep role-specific documents (Chat vs Code)
- ✅ Merge redundant protocol files
- ✅ Add quickstart for onboarding
- ✅ Update existing docs, not replace them

## New Folder Structure

### Reality-Based Organization
```
.tmops/
├── tmops_docs/                    # All TeamOps documentation
│   ├── tmops_claude_chat.md     # Chat orchestration guide (UPDATED from v5.0)
│   ├── tmops_claude_code.md     # Code instance roles (UPDATED from v5.0)
│   ├── tmops_protocol.md        # Technical protocol (MERGED from 2 files)
│   └── quickstart.md             # Getting started guide (NEW)
├── tmops_tools/                   # Automation scripts (NEW)
│   ├── init_feature.sh
│   ├── monitor_checkpoints.py
│   ├── extract_metrics.py
│   └── templates/                # Checkpoint templates
└── <feature>/
    └── runs/
        ├── 001-initial/
        │   ├── TASK_SPEC.md      # Input specification
        │   ├── checkpoints/       # Inter-instance communication
        │   │   ├── 001-discovery-trigger.md
        │   │   ├── 003-tests-complete.md
        │   │   ├── 005-impl-complete.md
        │   │   └── 007-verify-complete.md
        │   ├── logs/             # Instance debug logs (NEW)
        │   │   ├── orchestrator.log
        │   │   ├── tester.log
        │   │   ├── implementer.log
        │   │   └── verifier.log
        │   ├── metrics.json      # Extracted metrics (NEW)
        │   └── SUMMARY.md        # Final output
        ├── 002-patch/            # Second run
        └── current -> 002-patch/ # Active run symlink
```

### Where Files Actually Live
```
project-root/
├── src/                          # Implementation code (standard location)
├── tests/ or test/               # Test files (standard location)
├── .tmops/                       # TeamOps orchestration only
└── wt-*/                         # Git worktrees for instances
```

## Checkpoint Standardization

### Naming Convention (FIXED)
```
NNN-phase-status.md

Where:
- NNN: Three-digit sequence (001-999)
- phase: discovery|tests|impl|verify
- status: trigger|complete|gate

Examples:
- 001-discovery-trigger.md   (Orchestrator → Tester)
- 003-tests-complete.md      (Tester → Orchestrator)
- 004-impl-trigger.md        (Orchestrator → Implementer)
- 005-impl-complete.md       (Implementer → Orchestrator)
- 006-verify-trigger.md      (Orchestrator → Verifier)
- 007-verify-complete.md     (Verifier → Orchestrator)
```

### Checkpoint Flow (CLARIFIED)
```
Orchestrator          Tester           Implementer        Verifier
     │                  │                   │                │
     ├──001-trigger────►│                   │                │
     │◄─003-complete────┤                   │                │
     ├──004-trigger─────┼──────────────────►│                │
     │◄─────────────────┼──005-complete─────┤                │
     ├──006-trigger─────┼───────────────────┼───────────────►│
     │◄─────────────────┼───────────────────┼─007-complete───┤
     └──SUMMARY.md      │                   │                │
```

**Key Clarification:** Orchestrator creates ALL trigger checkpoints (001, 004, 006). Working instances create only completion checkpoints (003, 005, 007).

## Updated Instance Prompts

### Orchestrator Prompt (ENHANCED)
```
You are the ORCHESTRATOR instance in wt-orchestrator.

PATHS:
- Read: .tmops/<feature>/runs/current/TASK_SPEC.md
- Write checkpoints: .tmops/<feature>/runs/current/checkpoints/
- Write logs: .tmops/<feature>/runs/current/logs/orchestrator.log

WORKFLOW:
1. Create 001-discovery-trigger.md for Tester
2. Wait for 003-tests-complete.md
3. Create 004-impl-trigger.md for Implementer
4. Wait for 005-impl-complete.md
5. Create 006-verify-trigger.md for Verifier
6. Wait for 007-verify-complete.md
7. Create SUMMARY.md with metrics

Log each action with timestamp.
```

### Tester Prompt (ENHANCED)
```
You are the TESTER instance in wt-tester.

PATHS:
- Tests go in: PROJECT'S STANDARD test/ or tests/ directory
- Checkpoints: .tmops/<feature>/runs/current/checkpoints/
- Logs: .tmops/<feature>/runs/current/logs/tester.log

WORKFLOW:
1. Wait for 001-discovery-trigger.md
2. Write tests in PROJECT test directory (not .tmops)
3. Verify all tests fail
4. Create 003-tests-complete.md with:
   - List of test files created
   - Test count and coverage
   - Location of tests
5. Commit tests to git

Log all actions including test creation decisions.
```

### Implementer Prompt (ENHANCED)
```
You are the IMPLEMENTER instance in wt-impl.

PATHS:
- Code goes in: PROJECT'S STANDARD src/ directory
- Checkpoints: .tmops/<feature>/runs/current/checkpoints/
- Logs: .tmops/<feature>/runs/current/logs/implementer.log

WORKFLOW:
1. Wait for 004-impl-trigger.md
2. Pull latest to get tests
3. Write implementation in PROJECT src (not .tmops)
4. Run tests until all pass
5. Create 005-impl-complete.md with:
   - Files created/modified
   - Test results (X/Y passing)
   - Performance metrics
6. Commit implementation

Log iterations and debugging steps.
```

### Verifier Prompt (ENHANCED)
```
You are the VERIFIER instance in wt-verify.

PATHS:
- Review: All project code (read-only)
- Checkpoints: .tmops/<feature>/runs/current/checkpoints/
- Logs: .tmops/<feature>/runs/current/logs/verifier.log

WORKFLOW:
1. Wait for 006-verify-trigger.md
2. Review tests and implementation
3. Check edge cases and quality
4. Create 007-verify-complete.md with findings
5. DO NOT modify any code

Log all issues found and analysis performed.
```

## Automation Scripts

### 1. Feature Initialization Script
```bash
#!/bin/bash
# tmops_tools/init_feature.sh

FEATURE=$1
RUN_TYPE=${2:-initial}  # initial or patch

# Determine run number
if [ "$RUN_TYPE" = "initial" ]; then
    RUN_NUM="001"
else
    LAST=$(ls -d .tmops/$FEATURE/runs/[0-9]* 2>/dev/null | tail -1 | grep -o '[0-9]\+')
    RUN_NUM=$(printf "%03d" $((10#$LAST + 1)))
fi

# Create structure
mkdir -p .tmops/$FEATURE/runs/$RUN_NUM-$RUN_TYPE/{checkpoints,logs}

# Link to previous if patch
if [ "$RUN_TYPE" = "patch" ]; then
    echo "../$(ls -d .tmops/$FEATURE/runs/[0-9]* | tail -2 | head -1 | xargs basename)" > .tmops/$FEATURE/runs/$RUN_NUM-$RUN_TYPE/PREVIOUS_RUN.txt
fi

# Set current symlink
rm -f .tmops/$FEATURE/runs/current
ln -s $RUN_NUM-$RUN_TYPE .tmops/$FEATURE/runs/current

# Create worktrees
git worktree add wt-orchestrator feature/$FEATURE
git worktree add wt-tester feature/$FEATURE
git worktree add wt-impl feature/$FEATURE
git worktree add wt-verify feature/$FEATURE

echo "Feature $FEATURE run $RUN_NUM-$RUN_TYPE initialized"
```

### 2. Checkpoint Monitor
```python
#!/usr/bin/env python3
# tmops_tools/monitor_checkpoints.py

import os
import time
import json
from pathlib import Path
from datetime import datetime

class CheckpointMonitor:
    def __init__(self, feature, instance_role):
        self.feature = feature
        self.role = instance_role
        self.checkpoint_dir = Path(f".tmops/{feature}/runs/current/checkpoints")
        self.log_file = Path(f".tmops/{feature}/runs/current/logs/{role}.log")
        
    def wait_for_checkpoint(self, checkpoint_pattern, timeout=300):
        """Poll for checkpoint with exponential backoff"""
        start = time.time()
        wait_time = 2
        
        while time.time() - start < timeout:
            for checkpoint in self.checkpoint_dir.glob(checkpoint_pattern):
                self.log(f"Found trigger: {checkpoint.name}")
                return checkpoint.read_text()
            
            time.sleep(wait_time)
            wait_time = min(wait_time * 1.5, 10)  # Exponential backoff, max 10s
            
        raise TimeoutError(f"No checkpoint matching {checkpoint_pattern} after {timeout}s")
    
    def create_checkpoint(self, name, content):
        """Create a checkpoint file with proper formatting"""
        checkpoint = self.checkpoint_dir / name
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        formatted_content = f"""# Checkpoint: {name}
**From:** {self.role}
**Timestamp:** {timestamp}

{content}
"""
        checkpoint.write_text(formatted_content)
        self.log(f"Created checkpoint: {name}")
        
    def log(self, message):
        """Write to instance log file"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        self.log_file.parent.mkdir(parents=True, exist_ok=True)
        with open(self.log_file, 'a') as f:
            f.write(f"[{timestamp}] {message}\n")

# Usage example
if __name__ == "__main__":
    import sys
    monitor = CheckpointMonitor(sys.argv[1], sys.argv[2])
    # monitor.wait_for_checkpoint("001-discovery-trigger.md")
```

### 3. Metrics Extractor
```python
#!/usr/bin/env python3
# tmops_tools/extract_metrics.py

import json
import re
from pathlib import Path
from datetime import datetime

def extract_metrics(feature):
    """Extract metrics from all checkpoints into metrics.json"""
    
    checkpoint_dir = Path(f".tmops/{feature}/runs/current/checkpoints")
    metrics = {
        "feature": feature,
        "timestamp": datetime.now().isoformat(),
        "phases": {}
    }
    
    # Parse each checkpoint for metrics
    for checkpoint in sorted(checkpoint_dir.glob("*.md")):
        content = checkpoint.read_text()
        
        # Extract test metrics
        if "tests-complete" in checkpoint.name:
            tests_match = re.search(r"Tests written: (\d+)", content)
            coverage_match = re.search(r"Coverage: (\d+)%", content)
            if tests_match:
                metrics["phases"]["testing"] = {
                    "tests_written": int(tests_match.group(1)),
                    "coverage": int(coverage_match.group(1)) if coverage_match else 0
                }
        
        # Extract implementation metrics
        elif "impl-complete" in checkpoint.name:
            passing_match = re.search(r"Passing: (\d+)/(\d+)", content)
            if passing_match:
                metrics["phases"]["implementation"] = {
                    "tests_passing": int(passing_match.group(1)),
                    "tests_total": int(passing_match.group(2))
                }
    
    # Save metrics
    metrics_file = Path(f".tmops/{feature}/runs/current/metrics.json")
    metrics_file.write_text(json.dumps(metrics, indent=2))
    
    return metrics

if __name__ == "__main__":
    import sys
    extract_metrics(sys.argv[1])
```

## Implementation Checklist

### Phase 1: Foundation (Day 1)
- [ ] Create `tmops_tools/` directory with scripts
- [ ] Implement multi-run folder structure
- [ ] Update all documentation with correct paths
- [ ] Fix checkpoint naming inconsistencies

### Phase 2: Automation (Day 2)
- [ ] Test `init_feature.sh` script
- [ ] Deploy checkpoint monitor
- [ ] Implement metrics extraction
- [ ] Create checkpoint templates

### Phase 3: Documentation (Day 3)
- [ ] Update tmops_claude_chat.md with v5.2.0 orchestration changes
- [ ] Update tmops_claude_code.md with enhanced instance prompts
- [ ] Merge two protocol files into single tmops_protocol.md
- [ ] Create quickstart.md guide
- [ ] Document reality of where files live

### Phase 4: Testing (Day 4)
- [ ] Run complete feature with new structure
- [ ] Verify logging works
- [ ] Test metrics extraction
- [ ] Validate multi-run support

## Migration from v5.0.0

### Documentation Migration
```bash
# Update existing documents
cd .tmops
mkdir tmops_docs
cp tmops_docs_v4/tmops_claude_chat_4-inst.md tmops_docs/tmops_claude_chat.md
cp tmops_docs_v4/tmops_claude_code_4-inst.md tmops_docs/tmops_claude_code.md

# Merge protocol files
cat tmops_docs_v4/tmops_4-inst_protocol.md > tmops_docs/tmops_protocol.md
echo "\n## Additional Protocol Details\n" >> tmops_docs/tmops_protocol.md
cat tmops_docs_v4/tmops_orchestration_protocol_4-inst.md >> tmops_docs/tmops_protocol.md

# Archive old versions
mv tmops_docs_v4 tmops_docs_archive
```

### For Existing Features
```bash
# Migrate existing feature to new structure
cd .tmops/<feature>
mkdir -p runs/001-initial
mv TASK_SPEC.md checkpoints SUMMARY.md runs/001-initial/ 2>/dev/null
ln -s 001-initial runs/current
```

### For New Features
```bash
# Use new initialization script
./tmops_tools/init_feature.sh <feature-name> initial
```

## Success Metrics

### Operational Metrics
- Setup time: < 2 minutes (from 10+ minutes)
- Checkpoint detection: < 2 seconds (from 10 seconds)
- Zero missed checkpoints
- Complete audit trail via logs

### Quality Metrics
- No conflicting documentation
- All scripts executable and tested
- Instance role clarity: 100%
- User satisfaction increase

## What We're NOT Doing

### Deliberately Excluded
1. **NOT moving test/code files to .tmops/** - They stay in standard locations
2. **NOT creating outputs/ folder** - Unnecessary complexity
3. **NOT implementing complex gates/** - Checkpoint enhancement sufficient
4. **NOT building MCP server yet** - Future enhancement

### Deferred to v6.0
- Web dashboard
- MCP server implementation
- Real-time monitoring UI
- Advanced gate workflows

## Key Improvements Over v5.0.0

1. **Honesty** - Documentation matches reality
2. **Automation** - Scripts replace manual steps
3. **Debugging** - Logs provide visibility
4. **Consistency** - Standardized naming throughout
5. **Multi-run** - Support for iterative development
6. **Metrics** - Automatic extraction and tracking
7. **Role Clarity** - Maintained Chat/Code document separation
8. **Reduced Redundancy** - Merged duplicate protocol files

## Quick Reference Card

### For Claude Chat
```
1. Load tmops_claude_chat.md for orchestration guidance
2. Create TASK_SPEC.md in runs/current/
3. Provide instance prompts from tmops_claude_code.md
4. Monitor metrics.json for progress
```

### For Claude Code Instances
```
Load tmops_claude_code.md for your role:
Orchestrator: Create triggers (001,004,006), read completions (003,005,007)
Tester: Write tests in project test/, create 003
Implementer: Write code in project src/, create 005
Verifier: Review only, create 007
ALL: Log to .tmops/<feature>/runs/current/logs/<role>.log
```

### For Humans
```
1. Run: ./tmops_tools/init_feature.sh <feature> [initial|patch]
2. Launch 4 terminals with provided prompts
3. Monitor: tail -f .tmops/<feature>/runs/current/logs/*.log
4. Extract: ./tmops_tools/extract_metrics.py <feature>
```

## Conclusion

Version 5.2.0 represents a pragmatic evolution of TeamOps that:
- Accepts the reality of where files naturally live
- Adds only the organizational features that provide value
- Automates everything that can be automated
- Provides clear, honest documentation

This version bridges the gap between architectural vision and operational reality, creating a framework that actually works as documented.

---

**Next Step:** Begin Phase 1 implementation with script creation and folder structure setup.