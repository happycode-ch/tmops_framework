#!/bin/bash
# TeamOps v7 - Single-Command Orchestration with Subagents & Hooks
# Initialize a new feature with automated TDD workflow support

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

# Check arguments
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Feature name required${NC}"
    echo "Usage: $0 <feature-name> [initial|patch]"
    echo ""
    echo "Examples:"
    echo "  $0 user-auth initial    # Start new feature"
    echo "  $0 user-auth patch      # Add patch to existing feature"
    exit 1
fi

FEATURE=$1
RUN_TYPE=${2:-initial}  # Default to 'initial' if not specified

# Validate run type
if [ "$RUN_TYPE" != "initial" ] && [ "$RUN_TYPE" != "patch" ]; then
    echo -e "${RED}Error: Run type must be 'initial' or 'patch'${NC}"
    exit 1
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}       TeamOps v7 - Automated TDD Orchestration        ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# ===== FEATURE DIRECTORY SETUP =====
echo -e "${GREEN}Setting up feature: ${FEATURE}${NC}"

# Determine run number
if [ "$RUN_TYPE" = "initial" ]; then
    RUN_NUM="001"
    RUN_DIR="001-initial"
    
    # Check if feature already exists
    if [ -d ".tmops/$FEATURE" ]; then
        echo -e "${RED}Error: Feature $FEATURE already exists${NC}"
        echo "Use '$0 $FEATURE patch' to create a patch run"
        exit 1
    fi
else
    # Find the last run number for patch
    if [ ! -d ".tmops/$FEATURE/runs" ]; then
        echo -e "${RED}Error: No initial run found for feature $FEATURE${NC}"
        echo "Run '$0 $FEATURE initial' first"
        exit 1
    fi
    
    LAST=$(ls -d .tmops/$FEATURE/runs/[0-9]* 2>/dev/null | tail -1 | grep -o '[0-9]\+' | head -1)
    if [ -z "$LAST" ]; then
        echo -e "${RED}Error: Could not determine last run number${NC}"
        exit 1
    fi
    
    RUN_NUM=$(printf "%03d" $((10#$LAST + 1)))
    RUN_DIR="$RUN_NUM-patch"
fi

# Create directory structure
echo "Creating directory structure..."
mkdir -p .tmops/$FEATURE/runs/$RUN_DIR/{checkpoints,logs,artifacts}

# Create context link for patch runs
if [ "$RUN_TYPE" = "patch" ]; then
    PREV_RUN=$(ls -d .tmops/$FEATURE/runs/[0-9]* | tail -2 | head -1 | xargs basename)
    echo "../$PREV_RUN" > .tmops/$FEATURE/runs/$RUN_DIR/PREVIOUS_RUN.txt
    echo -e "${YELLOW}Linked to previous run: $PREV_RUN${NC}"
fi

# Update current symlink
echo "Setting current run symlink..."
rm -f .tmops/$FEATURE/runs/current
ln -s $RUN_DIR .tmops/$FEATURE/runs/current

# Also create a project-level current symlink
rm -f .tmops/current
ln -s $FEATURE/runs/current .tmops/current

# ===== TASK SPECIFICATION =====
if [ "$RUN_TYPE" = "initial" ]; then
    echo "Creating task specification template..."
    cat > .tmops/$FEATURE/runs/$RUN_DIR/TASK_SPEC.md << 'EOF'
# Task Specification: [Feature Name]

## Objective
[Describe the main goal of this feature in 1-2 sentences]

## Acceptance Criteria
- [ ] [Specific, testable criterion 1]
- [ ] [Specific, testable criterion 2]
- [ ] [Specific, testable criterion 3]

## Technical Requirements
### Functionality
- [Core functionality requirement]
- [Integration requirement]

### Error Handling
- [How errors should be handled]
- [Required error messages]

### Performance
- [Any performance requirements]

## Constraints
- [Technology constraints]
- [Compatibility requirements]
- [Security requirements]

## Expected Deliverables
1. **Tests**: Comprehensive test suite in `test/` or `tests/`
2. **Implementation**: Feature code in `src/` or appropriate directory
3. **Documentation**: Updated README or docs if needed

## Example Usage
```javascript
// Show how the feature will be used
const result = newFeature(params);
```

## Notes
[Any additional context, references, or considerations]
EOF
    echo -e "${GREEN}✓ Created TASK_SPEC.md template${NC}"
fi

# ===== V7 FRAMEWORK SETUP =====
echo ""
echo -e "${YELLOW}Setting up TeamOps v7 automation framework...${NC}"

# 1. Install subagents (one-time per project)
if [ ! -d ".claude/agents" ]; then
    mkdir -p .claude/agents
fi

# Check if TeamOps subagents already installed
if [ ! -f ".claude/agents/tmops-tester.md" ]; then
    echo "Installing TeamOps subagents..."
    cp "$SCRIPT_DIR/agents/"*.md .claude/agents/
    echo -e "${GREEN}✓ Installed 3 TeamOps subagents${NC}"
else
    echo -e "${GREEN}✓ TeamOps subagents already installed${NC}"
fi

# 2. Configure hooks (one-time per project)
if [ ! -f ".claude/project_settings.json" ]; then
    # Fresh install - copy template
    echo "Creating project settings with TeamOps hooks..."
    cp "$SCRIPT_DIR/templates/project_settings_v7.json" .claude/project_settings.json
    echo -e "${GREEN}✓ Created project settings with TeamOps hooks${NC}"
else
    # Check if TeamOps hooks already present
    if ! grep -q "tmops_tools/v7/hooks" .claude/project_settings.json 2>/dev/null; then
        echo -e "${YELLOW}Adding TeamOps hooks to existing project settings...${NC}"
        python3 "$SCRIPT_DIR/merge_hooks.py"
        echo -e "${GREEN}✓ Merged TeamOps hooks into project settings${NC}"
    else
        echo -e "${GREEN}✓ TeamOps hooks already configured${NC}"
    fi
fi

# 3. Initialize state for THIS feature (per-feature setup)
echo "Initializing workflow state..."
cat > .tmops/$FEATURE/runs/$RUN_DIR/state.json << EOF
{
  "feature": "$FEATURE",
  "run": "$RUN_DIR",
  "phase": "planning",
  "role": "orchestrator",
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "phase_complete": false,
  "version": "v7",
  "workflow_type": "automated",
  "run_type": "$RUN_TYPE"
}
EOF
echo -e "${GREEN}✓ Created initial state.json${NC}"

# 4. Create initial checkpoint
cat > .tmops/$FEATURE/runs/$RUN_DIR/checkpoints/000-initialized.md << EOF
# Initialization Checkpoint

**Feature:** $FEATURE
**Run:** $RUN_DIR
**Type:** $RUN_TYPE
**Created:** $(date '+%Y-%m-%d %H:%M:%S')
**Framework:** TeamOps v7 (Automated)

## Status
- Directory structure created
- Subagents installed
- Hooks configured
- State initialized

## Next Steps
1. Edit \`.tmops/$FEATURE/runs/current/TASK_SPEC.md\` with your requirements
2. Run: \`claude "Build $FEATURE feature using TeamOps v7"\`
3. Claude will automatically orchestrate the TDD workflow

## Automation Features
- Automatic phase transitions
- Role-based access control
- Progress notifications
- Zero manual coordination
EOF
echo -e "${GREEN}✓ Created initialization checkpoint${NC}"

# ===== GIT SETUP =====
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Add .claude to .gitignore if not already there
    if ! grep -q "^.claude/$" .gitignore 2>/dev/null; then
        echo ".claude/" >> .gitignore
        echo -e "${GREEN}✓ Added .claude/ to .gitignore${NC}"
    fi
    
    # Create feature branch if on initial run
    if [ "$RUN_TYPE" = "initial" ]; then
        CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        if [ "$CURRENT_BRANCH" != "feature/$FEATURE" ]; then
            if git show-ref --verify --quiet refs/heads/feature/$FEATURE; then
                echo -e "${YELLOW}Feature branch already exists${NC}"
            else
                echo "Creating feature branch..."
                git checkout -b feature/$FEATURE
                echo -e "${GREEN}✓ Created branch: feature/$FEATURE${NC}"
            fi
        fi
    fi
fi

# ===== FINAL SUMMARY =====
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}              TeamOps v7 Setup Complete!                ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Feature:${NC} $FEATURE"
echo -e "${BLUE}Run:${NC} $RUN_DIR"
echo -e "${BLUE}Location:${NC} .tmops/$FEATURE/runs/$RUN_DIR/"
echo ""

if [ "$RUN_TYPE" = "initial" ]; then
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Edit the task specification:"
    echo -e "   ${BLUE}vim .tmops/$FEATURE/runs/current/TASK_SPEC.md${NC}"
    echo ""
    echo "2. Start the automated workflow:"
    echo -e "   ${BLUE}TMOPS_V7_ACTIVE=1 claude \"Build $FEATURE feature using TeamOps v7\"${NC}"
    echo ""
    echo "Claude will automatically:"
    echo "  • Invoke tester subagent to write failing tests"
    echo "  • Detect test completion and invoke implementer"
    echo "  • Make all tests pass"
    echo "  • Run verifier for quality review"
    echo "  • Send notifications at each phase"
else
    echo -e "${YELLOW}Patch run created!${NC}"
    echo "Previous run context linked for continuity."
    echo ""
    echo "To continue development:"
    echo -e "   ${BLUE}TMOPS_V7_ACTIVE=1 claude \"Continue $FEATURE feature using TeamOps v7\"${NC}"
fi

echo ""
echo -e "${GREEN}Key Benefits of v7:${NC}"
echo "  ✓ Single Claude instance (no worktrees)"
echo "  ✓ Automatic phase transitions"
echo "  ✓ Role-based isolation via subagents"
echo "  ✓ Progress notifications"
echo "  ✓ Zero manual coordination"
echo ""
echo -e "${GREEN}Happy coding with TeamOps v7! 🚀${NC}"