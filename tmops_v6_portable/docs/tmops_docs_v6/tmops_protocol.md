<!--
📁 FILE: /home/anthonycalek/projects/tmops_framework/CODE/tmops_v6_portable/docs/tmops_docs_v6/tmops_protocol.md
🎯 PURPOSE: Technical specification for TeamOps orchestration protocol and architecture
🤖 AI-HINT: Definitive reference for framework architecture, instance roles, and coordination patterns
🔗 DEPENDENCIES: tmops_claude_chat.md, tmops_claude_code.md, instance_instructions/
📝 CONTEXT: Core protocol documentation for 4-instance and 7-instance workflows
-->

# TeamOps Orchestration Protocol - 4-Instance Architecture
**Version:** 6.0.0-manual  
**Purpose:** Definitive technical specification for TeamOps Framework  
**Architecture:** Strategic planning in Chat, 4 Code instances with human-coordinated handoffs

## Core Concept

The TeamOps framework uses 4 independent Claude Code instances where a human coordinator relays completion messages between instances. Claude Chat handles strategic planning (Task Specifications), while the 4 Code instances handle all execution with human coordination. Version 6.0 uses manual orchestration for 100% reliable handoffs.

## Orchestration Modes

### v5.x - Automated Polling (Legacy)
- Instances poll for checkpoints automatically
- Exponential backoff for efficiency
- Risk of missed checkpoints or timeouts
- Requires monitoring tools

### v6.0 - Manual Orchestration (Current)
- Human relays completion status between instances
- 100% reliable handoffs
- Better visibility and control
- Checkpoints still created for audit trail
- No polling code or timeout logic
- Can pause between phases for review

### Choosing a Mode
- **Use v6 Manual** for: Critical features, learning, debugging, production work
- **Use v5 Automated** for: Experienced users, simple features (deprecated)

## System Architecture

### Complete System Overview
```
┌─────────────────────────────────────────┐
│         Claude.ai Chat                   │
│   (Strategic Planning & Task Specs)      │
└─────────────────────────────────────────┘
                    │
                    ▼
        Creates TASK_SPEC.md
                    │
    ┌───────────────┴───────────────┐
    │                               │
    ▼                               ▼
┌─────────────────────────────────────────┐
│        4 Claude Code Instances          │
│                                         │
│  ┌──────────────┐  ┌──────────────┐   │
│  │ Orchestrator │  │    Tester    │   │
│  │  Terminal 1  │  │  Terminal 2  │   │
│  └──────────────┘  └──────────────┘   │
│                                         │
│  ┌──────────────┐  ┌──────────────┐   │
│  │ Implementer  │  │   Verifier   │   │
│  │  Terminal 3  │  │  Terminal 4  │   │
│  └──────────────┘  └──────────────┘   │
│                                         │
│   Communication: Checkpoint Files      │
│   Logging: Instance-specific logs      │
│   Metrics: Automatic extraction        │
└─────────────────────────────────────────┘
```

### Layer Responsibilities

#### Strategic Layer (Claude.ai Chat)
```
Responsibilities:
- Create Task Specifications with acceptance criteria
- Review checkpoint summaries and metrics
- Approve quality gates
- Guide multi-run iterations
- NO orchestration of instances (Orchestrator handles this)
```

#### Execution Layer (4 Claude Code Instances)
```
Responsibilities:
- Autonomous execution of assigned roles
- Communication via checkpoint files
- Logging all actions for debugging
- Metrics generation for analysis
- Git-based collaboration
```

## The 4 Instances Defined

### 1. Orchestrator Instance (wt-orchestrator)
**Purpose:** Workflow coordination and progress tracking

**Capabilities:**
- Read Task Specification from `.tmops/<feature>/runs/current/TASK_SPEC.md`
- Create trigger checkpoints for phase transitions
- Monitor for completion checkpoints
- Track timing and metrics
- Generate final SUMMARY.md with metrics

**Restrictions:**
- NO test writing
- NO implementation code
- NO code modification
- NO direct instance control

**Checkpoints:**
- Creates: 001-discovery-trigger, 004-impl-trigger, 006-verify-trigger, SUMMARY
- Reads: 003-tests-complete, 005-impl-complete, 007-verify-complete

### 2. Tester Instance (wt-tester)
**Purpose:** Test creation and discovery

**Capabilities:**
- Explore codebase structure (read-only)
- Write comprehensive failing tests in PROJECT test directory
- Verify tests fail initially
- Document test strategy and coverage

**Restrictions:**
- NO implementation code
- NO fixing tests to pass
- NO modifying existing code
- Tests MUST go in project's test/ or tests/ directory

**Checkpoints:**
- Reads: 001-discovery-trigger
- Creates: 003-tests-complete

### 3. Implementer Instance (wt-impl)
**Purpose:** Feature implementation

**Capabilities:**
- Read test requirements from PROJECT test directory
- Write feature code in PROJECT src directory
- Run tests iteratively until passing
- Refactor and optimize as needed

**Restrictions:**
- NO test modification
- NO test creation
- NO changing test expectations
- Code MUST go in project's src/ directory

**Checkpoints:**
- Reads: 004-impl-trigger
- Creates: 005-impl-complete

### 4. Verifier Instance (wt-verify)
**Purpose:** Quality assurance and review

**Capabilities:**
- Review all code (tests and implementation)
- Identify edge cases and issues
- Assess security and performance
- Document quality metrics

**Restrictions:**
- NO code modification
- NO fixes or patches
- Read-only analysis only
- Document findings only

**Checkpoints:**
- Reads: 006-verify-trigger
- Creates: 007-verify-complete

## Communication Protocol

### Checkpoint Flow Diagram (v5.2.0 Standardized)
```
Orchestrator          Tester           Implementer        Verifier
     │                  │                   │                │
     ├──001-trigger────►│                   │                │
     │                  │                   │                │
     │◄─003-complete────┤                   │                │
     │                  │                   │                │
     ├──004-trigger─────┼──────────────────►│                │
     │                  │                   │                │
     │◄─────────────────┼──005-complete─────┤                │
     │                  │                   │                │
     ├──006-trigger─────┼───────────────────┼───────────────►│
     │                  │                   │                │
     │◄─────────────────┼───────────────────┼─007-complete───┤
     │                  │                   │                │
     └──SUMMARY.md      │                   │                │
         + metrics.json │                   │                │
```

### Checkpoint Naming Convention (v5.2.0)
```
NNN-phase-status.md
│   │     │
│   │     └── Status: trigger, complete, gate
│   └───────── Phase: discovery, tests, impl, verify
└───────────── Number: 001-007 (odd=trigger, even reserved)

Examples:
001-discovery-trigger.md   # Orchestrator → Tester
003-tests-complete.md      # Tester → Orchestrator
004-impl-trigger.md        # Orchestrator → Implementer
005-impl-complete.md       # Implementer → Orchestrator
006-verify-trigger.md      # Orchestrator → Verifier
007-verify-complete.md     # Verifier → Orchestrator
```

### Checkpoint Format Template
```markdown
# Checkpoint: NNN-phase-status.md
**From:** [Instance Role]
**To:** [Target Instance or Orchestrator]
**Timestamp:** 2025-01-19 HH:MM:SS
**Feature:** <feature-name>
**Run:** 001-initial (or 002-patch)

## Content
[Phase-specific content]

## Metrics (if applicable)
- Tests written: N
- Coverage: X%
- Files modified: N
- Performance: Xms

## Next Action
[What the receiving instance should do]

## Gate Status (if applicable)
[AUTO_APPROVED | AWAITING_HUMAN_REVIEW]
```

## Implementation Details

### Directory Structure (v5.2.0 Reality-Based)

#### TeamOps Orchestration Structure
```
.tmops/
├── <feature>/
│   └── runs/
│       ├── 001-initial/           # First run
│       │   ├── TASK_SPEC.md      # Requirements
│       │   ├── checkpoints/       # Communication
│       │   │   ├── 001-discovery-trigger.md
│       │   │   ├── 003-tests-complete.md
│       │   │   ├── 004-impl-trigger.md
│       │   │   ├── 005-impl-complete.md
│       │   │   ├── 006-verify-trigger.md
│       │   │   ├── 007-verify-complete.md
│       │   │   └── SUMMARY.md
│       │   ├── logs/              # Instance logs
│       │   │   ├── orchestrator.log
│       │   │   ├── tester.log
│       │   │   ├── implementer.log
│       │   │   └── verifier.log
│       │   └── metrics.json      # Extracted metrics
│       ├── 002-patch/             # Patch run (if needed)
│       │   └── PREVIOUS_RUN.txt  # Link to 001-initial
│       └── current -> 002-patch/ # Symlink to active run
```

#### Project Code Structure (Where Files Actually Go)
```
project-root/
├── src/                    # Implementation code HERE
│   ├── services/
│   ├── models/
│   └── utils/
├── test/ or tests/         # Test files HERE
│   ├── unit/
│   ├── integration/
│   └── fixtures/
├── wt-orchestrator/        # Git worktree (branch: feature/<name>-orchestrator)
├── wt-tester/             # Git worktree (branch: feature/<name>-tester)
├── wt-impl/               # Git worktree (branch: feature/<name>-impl)
└── wt-verify/             # Git worktree (branch: feature/<name>-verify)
```

### Instance Initialization

#### Automated Setup (v5.2.0)
```bash
# Initialize feature with automation
./tmops_tools/init_feature.sh <feature> initial

# This creates:
# - Directory structure
# - Git worktrees
# - Initial checkpoints
# - TASK_SPEC template
```

#### Manual Terminal Setup
```bash
# Terminal 1: Orchestrator
cd wt-orchestrator && claude
# Load prompt from tmops_claude_code.md

# Terminal 2: Tester
cd wt-tester && claude
# Load prompt from tmops_claude_code.md

# Terminal 3: Implementer
cd wt-impl && claude
# Load prompt from tmops_claude_code.md

# Terminal 4: Verifier
cd wt-verify && claude
# Load prompt from tmops_claude_code.md
```

## Polling and Monitoring

### Checkpoint Polling Strategy
```python
# Exponential backoff algorithm
initial_wait = 2  # seconds
max_wait = 10    # seconds
multiplier = 1.5

while not checkpoint_exists:
    sleep(current_wait)
    current_wait = min(current_wait * multiplier, max_wait)
```

### Using Monitor Tool (v5.2.0)
```bash
# Wait for checkpoint
python tmops_tools/monitor_checkpoints.py <feature> <role> wait "pattern"

# List all checkpoints
python tmops_tools/monitor_checkpoints.py <feature> <role> list

# Get run information
python tmops_tools/monitor_checkpoints.py <feature> <role> info
```

## Logging Protocol (v5.2.0)

### Log Format
```
[YYYY-MM-DD HH:MM:SS.mmm] [LEVEL] Message
```

### Required Log Events
1. Instance initialization
2. Checkpoint creation/detection
3. File operations (read/write)
4. Test execution results
5. Git operations
6. Errors and warnings
7. Phase completion

### Log File Locations
```
.tmops/<feature>/runs/current/logs/
├── orchestrator.log
├── tester.log
├── implementer.log
└── verifier.log
```

## Metrics Extraction (v5.2.0)

### Automatic Metrics Collection
```bash
# Extract metrics after completion
python tmops_tools/extract_metrics.py <feature> --format both
```

### Metrics Structure
```json
{
  "feature": "feature-name",
  "timestamp": "2025-01-19T10:45:00",
  "run_directory": "001-initial",
  "phases": {
    "testing": {
      "tests_written": 15,
      "coverage_percent": 87
    },
    "implementation": {
      "tests_passing": 15,
      "pass_rate": 100
    },
    "verification": {
      "issues_found": 0,
      "quality_assessment": "high"
    }
  },
  "timeline": [...],
  "summary": {
    "success": true,
    "total_tests": 15,
    "test_pass_rate": 100
  }
}
```

## Multi-Run Support (v5.2.0)

### Run Types
1. **Initial Run** (`001-initial`)
   - Fresh feature implementation
   - Complete Task Spec required
   - All phases executed

2. **Patch Run** (`002-patch`, `003-patch`, etc.)
   - Builds on previous run
   - Inherits context via PREVIOUS_RUN.txt
   - May skip phases if not needed

### Context Inheritance
```bash
# PREVIOUS_RUN.txt contains:
../001-initial

# Instances can access:
- Previous TASK_SPEC.md
- Previous checkpoints
- Previous metrics
- Previous logs
```

## Quality Gates

### Gate Types
1. **Automatic Gates**
   - Test coverage threshold (default: 80%)
   - All tests passing
   - No security vulnerabilities
   - Performance within limits

2. **Human Review Gates**
   - After test creation
   - After implementation
   - Before final merge

### Gate Format in Checkpoints
```markdown
## GATE: Automated Check
Test Coverage: 87% (PASS - threshold 80%)
Security Scan: Clean (PASS)
Performance: 45ms avg (PASS - threshold 200ms)
Status: AUTO_APPROVED

## GATE: Human Review Required
All automated checks passed.
Awaiting human approval to proceed.
Status: AWAITING_APPROVAL
```

## Git Workflow

### Branch Strategy
```
main
  └── feature/<feature-name>
       ├── wt-orchestrator (branch: feature/<name>-orchestrator)
       ├── wt-tester (branch: feature/<name>-tester)
       ├── wt-impl (branch: feature/<name>-impl)
       └── wt-verify (branch: feature/<name>-verify)
```

### Commit Convention
```
# Tester
test: add failing tests for <feature>

# Implementer
feat: implement <feature> to pass tests

# Orchestrator (if needed)
docs: update SUMMARY for <feature>
```

## Error Handling

### Instance Recovery
1. Check last checkpoint created/read
2. Verify git status and branch
3. Review instance log for errors
4. Resume from last known good state

### Common Issues and Solutions
| Issue | Solution |
|-------|----------|
| Checkpoint not found | Verify path and permissions |
| Tests in wrong location | Must be in PROJECT/test/ |
| Code in wrong location | Must be in PROJECT/src/ |
| Git sync issues | Pull latest, check branch |
| Polling timeout | Check other instance logs |

## Performance Guidelines

### Timing Expectations
- Instance initialization: < 30 seconds
- Checkpoint detection: < 10 seconds (with backoff)
- Test writing phase: 5-15 minutes
- Implementation phase: 10-30 minutes
- Verification phase: 5-10 minutes
- Total feature time: 30-60 minutes typical

### Resource Usage
- Each instance: Independent process
- Polling: Exponential backoff to reduce load
- Logging: Asynchronous writes
- Git operations: Atomic commits

## Security Considerations

### Checkpoint Security
- Checkpoints are plain text (no secrets)
- Use git-ignored files for sensitive data
- Validate checkpoint format before processing

### Code Review Security
- Verifier checks for:
  - Hardcoded credentials
  - SQL injection vulnerabilities
  - XSS vulnerabilities
  - Insecure dependencies

## Protocol Versioning

### Version History
- v5.0.0: Initial 4-instance architecture
- v5.2.0: Reality-based paths, logging, metrics, multi-run

### Backward Compatibility
- v5.2.0 maintains checkpoint structure from v5.0.0
- Adds optional logging and metrics
- Clarifies file locations without breaking changes

## Success Criteria

### Feature Completion Requires
1. ✅ All acceptance criteria have passing tests
2. ✅ Tests in correct project directory
3. ✅ Implementation in correct project directory
4. ✅ All instances completed successfully
5. ✅ Metrics extracted and positive
6. ✅ Quality gates passed
7. ✅ SUMMARY.md generated

### Quality Indicators
- High test coverage (>80%)
- All tests passing
- No security issues found
- Performance within requirements
- Clean code structure
- Proper error handling

---
*TeamOps Protocol v5.2.0 - Complete Technical Specification*