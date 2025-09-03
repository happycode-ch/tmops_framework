#!/usr/bin/env bash
# 📁 FILE: /home/anthonycalek/projects/tmops_framework/CODE/tmops_v6_portable/tmops_tools/init_preflight.sh
# 🎯 PURPOSE: Preflight initialization script for 3-instance specification refinement workflow (research, analysis, specification)
# 🤖 AI-HINT: Use to initialize preflight workflow for comprehensive specification development before main TeamOps execution
# 🔗 DEPENDENCIES: lib/common.sh, git, preflight instance instructions, preflight templates
# 📝 CONTEXT: Separate 3-instance workflow for thorough specification refinement before 4-instance development workflow
# TeamOps Preflight Initialization Script
# Separate 3-instance workflow for specification refinement

set -euo pipefail

# Source shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Check dependencies
check_dependencies

# Parse arguments
FEATURE="${1:-}"
RUN_TYPE="${2:-initial}"

if [[ -z "$FEATURE" ]]; then
    error_exit "Usage: $0 <feature-name> [run-type]"
fi

# Validate feature name
validate_feature_name "$FEATURE"

# Get project paths
get_project_paths

# Acquire lock to prevent concurrent preflight runs
acquire_lock "$FEATURE" "preflight"

print_header "TeamOps Preflight Initialization"

log_info "Feature: $FEATURE"
log_info "Run Type: $RUN_TYPE"
log_info "Branch: feature/$FEATURE"
echo ""

# Check for conflicting main workflow
MAIN_SPEC_PATH="$TMOPS_DIR/$FEATURE/runs/$RUN_TYPE/TASK_SPEC.md"
if [[ -f "$MAIN_SPEC_PATH" ]] && ! has_refined_spec "$FEATURE"; then
    log_warn "Found existing basic task spec. Preflight will create a refined version."
    log_warn "The refined spec will replace the basic one for main workflow handoff."
    echo ""
fi

# Create feature directory structure
log_info "Creating feature workspace..."
eval "$(create_feature_structure "$FEATURE" "$RUN_TYPE")"

# Ensure feature branch exists
ensure_feature_branch "$FEATURE"

# Create initial preflight task spec template
TASK_SPEC_PATH="$RUN_DIR/TASK_SPEC.md"

if [[ ! -f "$TASK_SPEC_PATH" ]] || ! has_refined_spec "$FEATURE"; then
    log_info "Creating preflight task specification template..."
    
    cat > "$TASK_SPEC_PATH" << EOF
# Task Specification: $FEATURE
Version: 1.0.0 (Preflight Template)
Created: $(date -I)
Status: Preflight Refinement Required
Refined by preflight workflow: In Progress

## Initial Requirements (To be refined by preflight instances)

### User Story Template
As a [user type]
I want [functionality]  
So that [business value]

### Initial Acceptance Criteria (To be expanded)
- [ ] [High-level requirement 1]
- [ ] [High-level requirement 2] 
- [ ] [High-level requirement 3]

### Technical Context (To be analyzed)
- Use existing project structure
- Follow project conventions
- Maintain test coverage
- Consider performance implications
- Evaluate security requirements

### Research Areas for Preflight
- [ ] Similar implementations in codebase
- [ ] Related libraries and frameworks
- [ ] Integration points and dependencies
- [ ] Testing strategies and patterns
- [ ] Potential risks and mitigations

### Implementation Analysis Needed
- [ ] Architecture and design patterns
- [ ] Code organization and structure
- [ ] Data models and interfaces
- [ ] Error handling and edge cases
- [ ] Performance and scalability considerations

### Specification Requirements
- [ ] Detailed functional requirements
- [ ] Comprehensive acceptance criteria
- [ ] Technical implementation plan
- [ ] Test plan and validation strategy
- [ ] Definition of done checklist

---
**PREFLIGHT STATUS:** This specification requires refinement through the 3-instance preflight workflow before main TeamOps implementation.

**Next Steps:**
1. Research & Discovery Instance: Investigate and document findings
2. Implementation Analysis Instance: Analyze technical approach
3. Task Specification Instance: Create final refined specification

**Handoff:** Refined specification will be placed at this location for automatic detection by main TeamOps workflow.
EOF
    
    log_success "Created preflight task specification template"
else
    log_info "Using existing task specification"
fi

# Create preflight-specific checkpoint directory structure
PREFLIGHT_CHECKPOINTS="$RUN_DIR/checkpoints"
mkdir -p "$PREFLIGHT_CHECKPOINTS"

# Create preflight logging directory
PREFLIGHT_LOGS="$RUN_DIR/logs"
mkdir -p "$PREFLIGHT_LOGS"

# Track feature (mark as preflight)
track_feature "$FEATURE" "preflight" "feature/$FEATURE"

# Create initial status file
{
    echo "FEATURE=$FEATURE"
    echo "STATUS=initialized"
    echo "STARTED=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo "PHASE=ready_for_research"
} > "$RUN_DIR/.preflight_status"

print_header "✅ Preflight '$FEATURE' Initialized!"

echo "Preflight workspace created at:"
echo "  📁 $RUN_DIR"
echo ""
echo "Task specification template:"
echo "  📝 $TASK_SPEC_PATH"
echo ""
echo "Next steps - Open 3 Claude Code instances in ROOT directory:"
echo "  cd $PROJECT_ROOT  # Go to root project directory"
echo ""
echo "Terminal setup:"
echo "  Terminal 1: claude  # For Preflight Researcher"
echo "  Terminal 2: claude  # For Preflight Analyzer" 
echo "  Terminal 3: claude  # For Preflight Specifier"
echo ""
echo "Copy preflight instance instructions from $INSTRUCTIONS_DIR/:"
echo "  • 02_preflight_researcher.md → researcher terminal"
echo "  • 03_preflight_analyzer.md → analyzer terminal"
echo "  • 04_preflight_specifier.md → specifier terminal"
echo ""
echo "Start preflight workflow:"
echo "  You → Researcher: '[BEGIN]: Start research for $FEATURE'"
echo ""
echo "After preflight completes, run main workflow:"
echo "  ./tmops_tools/init_feature_multi.sh $FEATURE"
echo "  (Will automatically detect and use refined specification)"
echo ""
echo "═══════════════════════════════════════════════"