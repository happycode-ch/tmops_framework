#!/bin/bash
# tmops_tools/init_feature_v6.sh
# TeamOps v6 Manual Orchestration - Feature Initializer
# Initialize a new feature with multi-run support and git worktrees

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Feature name required${NC}"
    echo "Usage: $0 <feature-name> [initial|patch]"
    exit 1
fi

FEATURE=$1
RUN_TYPE=${2:-initial}  # Default to 'initial' if not specified

# Validate run type
if [ "$RUN_TYPE" != "initial" ] && [ "$RUN_TYPE" != "patch" ]; then
    echo -e "${RED}Error: Run type must be 'initial' or 'patch'${NC}"
    exit 1
fi

echo -e "${GREEN}Initializing feature: ${FEATURE}${NC}"
echo -e "${YELLOW}Run type: ${RUN_TYPE}${NC}"

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
mkdir -p .tmops/$FEATURE/runs/$RUN_DIR/{checkpoints,logs}

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

# Create initial TASK_SPEC template if it's an initial run
if [ "$RUN_TYPE" = "initial" ]; then
    cat > .tmops/$FEATURE/runs/$RUN_DIR/TASK_SPEC.md << 'EOF'
# Task Specification: [Feature Name]

## Objective
[Describe the main goal of this feature]

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Technical Requirements
- [Requirement 1]
- [Requirement 2]

## Constraints
- [Any limitations or boundaries]

## Expected Deliverables
1. Tests in `test/` or `tests/` directory
2. Implementation in `src/` directory
3. Documentation updates if needed

## Notes
[Any additional context or considerations]
EOF
    echo -e "${GREEN}Created TASK_SPEC.md template${NC}"
fi

# Check if we're in a git repository
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Get current branch
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    
    # Create feature branch if it doesn't exist
    if ! git show-ref --verify --quiet refs/heads/feature/$FEATURE; then
        echo "Creating feature branch..."
        git checkout -b feature/$FEATURE
    else
        echo -e "${YELLOW}Feature branch already exists${NC}"
    fi
    
    # Create worktrees
    echo "Setting up git worktrees..."
    
    for INSTANCE in orchestrator tester impl verify; do
        WT_PATH="wt-$INSTANCE"
        
        if [ -d "$WT_PATH" ]; then
            echo -e "${YELLOW}Worktree $WT_PATH already exists, removing...${NC}"
            git worktree remove "$WT_PATH" --force 2>/dev/null || true
        fi
        
        echo "Creating worktree: $WT_PATH"
        git worktree add "$WT_PATH" feature/$FEATURE
    done
    
    # Return to original branch if we created a new one
    if [ "$CURRENT_BRANCH" != "feature/$FEATURE" ]; then
        git checkout "$CURRENT_BRANCH"
    fi
else
    echo -e "${YELLOW}Warning: Not in a git repository. Skipping worktree creation.${NC}"
fi

# Create initial checkpoint trigger if it's an initial run
if [ "$RUN_TYPE" = "initial" ]; then
    cat > .tmops/$FEATURE/runs/$RUN_DIR/checkpoints/000-init.md << EOF
# Initialization Checkpoint

**Feature:** $FEATURE
**Run:** $RUN_DIR
**Created:** $(date '+%Y-%m-%d %H:%M:%S')
**Status:** Ready to start

## Next Steps
1. Update TASK_SPEC.md with your requirements
2. Launch 4 Claude Code instances with appropriate prompts
3. Orchestrator will create 001-discovery-trigger.md to begin

## Instance Prompts Location (v6 Manual)
- Chat prompt: docs/tmops_docs_v6/tmops_claude_chat.md
- Code prompts: docs/tmops_docs_v6/tmops_claude_code.md
EOF
fi

# Summary
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}    TeamOps v6 - Manual Orchestration Framework${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Feature: $FEATURE"
echo "Run: $RUN_DIR"
echo "Location: .tmops/$FEATURE/runs/$RUN_DIR/"
echo ""
echo -e "${YELLOW}IMPORTANT: This is v6 with MANUAL orchestration${NC}"
echo "You will coordinate handoffs between instances."
echo "No automated polling - 100% reliable!"
echo ""

if [ "$RUN_TYPE" = "initial" ]; then
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Edit .tmops/$FEATURE/runs/current/TASK_SPEC.md"
    echo "2. Launch 4 Claude Code instances in worktrees:"
    echo "   - cd wt-orchestrator && claude"
    echo "   - cd wt-tester && claude"
    echo "   - cd wt-impl && claude"
    echo "   - cd wt-verify && claude"
    echo "3. Use prompts from docs/tmops_docs_v6/tmops_claude_code.md"
    echo "4. Follow manual coordination workflow:"
    echo "   - Wait for each instance to report WAITING"
    echo "   - Send [BEGIN] to start each phase"
    echo "   - Relay [CONFIRMED] messages between instances"
else
    echo -e "${YELLOW}Patch run created with context from previous run${NC}"
    echo "Use v6 manual coordination for reliable execution"
fi

echo ""
echo -e "${GREEN}Ready to start TeamOps v6 Manual Workflow!${NC}"