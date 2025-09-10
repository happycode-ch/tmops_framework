#!/usr/bin/env bash
# TeamOps Shared Function Library
# Common functions used across all TeamOps scripts

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Error handling
error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

# Validate feature name (consistent with existing validation)
validate_feature_name() {
    local feature="$1"
    if [[ ! "$feature" =~ ^[a-z0-9-]{3,20}$ ]]; then
        error_exit "Feature names must be 3-20 characters long, only lowercase letters, numbers, and hyphens. Example: auth-api, user-login, payment-v2"
    fi
}

# Get project paths (consistent with existing scripts)
get_project_paths() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
    PORTABLE_DIR="$(cd "$script_dir/.." && pwd)"
    PROJECT_ROOT="$(cd "$PORTABLE_DIR/.." && pwd)"
    TMOPS_DIR="$PROJECT_ROOT/.tmops"
    
    # Set instructions directory based on what exists (exported for use by other scripts)
    if [[ -d "$PORTABLE_DIR/instance_instructions" ]]; then
        export INSTRUCTIONS_DIR="$PORTABLE_DIR/instance_instructions"
    else
        export INSTRUCTIONS_DIR="$PORTABLE_DIR/docs/tmops_docs_v6"
    fi
}

# Atomic checkpoint creation with proper error handling
create_checkpoint() {
    local checkpoint_path="$1"
    local status="${2:-complete}"
    local message="${3:-Checkpoint created}"
    local details="${4:-}"
    
    if [[ -z "$checkpoint_path" ]]; then
        error_exit "Checkpoint path required"
    fi
    
    # Create checkpoint directory if it doesn't exist
    local checkpoint_dir
    checkpoint_dir="$(dirname "$checkpoint_path")"
    mkdir -p "$checkpoint_dir"
    
    # Use temporary file for atomic operation
    local tmp_file
    tmp_file=$(mktemp)
    {
        echo "TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
        echo "STATUS=$status"
        echo "MESSAGE=$message"
        if [[ -n "$details" ]]; then
            echo "DETAILS=$details"
        fi
    } > "$tmp_file"
    
    # Atomic move
    if ! mv "$tmp_file" "$checkpoint_path"; then
        rm -f "$tmp_file"
        error_exit "Failed to create checkpoint: $checkpoint_path"
    fi
    
    log_success "Created checkpoint: $(basename "$checkpoint_path")"
}

# Check if checkpoint exists and is valid
checkpoint_exists() {
    local checkpoint_path="$1"
    [[ -f "$checkpoint_path" && -s "$checkpoint_path" ]]
}

# Read checkpoint status
get_checkpoint_status() {
    local checkpoint_path="$1"
    if checkpoint_exists "$checkpoint_path"; then
        grep "^STATUS=" "$checkpoint_path" | cut -d'=' -f2-
    else
        echo "not_found"
    fi
}

# Ensure feature branch exists and is checked out
ensure_feature_branch() {
    local feature="$1"
    local branch_name="feature/$feature"
    
    log_info "Setting up feature branch: $branch_name"
    
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        log_info "Checking out existing branch: $branch_name"
        git checkout "$branch_name" || error_exit "Failed to checkout branch: $branch_name"
    else
        log_info "Creating new branch: $branch_name"
        git checkout -b "$branch_name" || error_exit "Failed to create branch: $branch_name"
    fi
}

# Create feature directory structure
create_feature_structure() {
    local feature="$1"
    local run_type="${2:-initial}"
    
    get_project_paths
    
    local feature_dir="$TMOPS_DIR/$feature"
    local run_dir="$feature_dir/runs/$run_type"
    
    # Create directory structure
    mkdir -p "$run_dir"/{checkpoints,logs}
    mkdir -p "$feature_dir/docs"/{internal,external,archive,images}
    
    # Create current symlink
    ln -sfn "runs/$run_type" "$feature_dir/current"
    
    log_success "Created feature structure: $feature_dir"
    
    # Return paths for caller
    echo "FEATURE_DIR=$feature_dir"
    echo "RUN_DIR=$run_dir"
}

# Lock file management for preventing concurrent runs
acquire_lock() {
    local feature="$1"
    local lock_type="${2:-general}"
    
    get_project_paths
    mkdir -p "$TMOPS_DIR"
    local lock_file="$TMOPS_DIR/$feature.$lock_type.lock"
    
    # Use file descriptor 200 for locking
    exec 200>"$lock_file"
    if ! flock -n 200; then
        error_exit "Another $lock_type process is already running for feature '$feature'"
    fi
    
    # Set trap to clean up lock file on exit
    trap 'rm -f '"$lock_file" EXIT
    log_info "Acquired lock for $lock_type process on feature: $feature"
}

# Track feature in FEATURES.txt
track_feature() {
    local feature="$1"
    local status="${2:-active}"
    local branch="${3:-feature/$feature}"
    
    get_project_paths
    mkdir -p "$TMOPS_DIR"
    echo "$feature:$status:$(date -Iseconds):$branch" >> "$TMOPS_DIR/FEATURES.txt"
}

# Check if refined spec exists (for smart handoff)
has_refined_spec() {
    local feature="$1"
    get_project_paths
    local spec_path="$TMOPS_DIR/$feature/runs/initial/TASK_SPEC.md"
    
    if [[ -f "$spec_path" ]]; then
        # Check if it's a preflight-refined spec (contains specific marker)
        if grep -q "Created by preflight workflow" "$spec_path" 2>/dev/null || 
           grep -q "Refined by preflight" "$spec_path" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Print formatted header
print_header() {
    local title="$1"
    local width=47
    
    echo "═══════════════════════════════════════════════"
    printf "  %-${width}s\n" "$title"
    echo "═══════════════════════════════════════════════"
    echo ""
}

# Validate required tools are available
check_dependencies() {
    local tools=("git" "flock" "mktemp")
    local missing=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing+=("$tool")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        error_exit "Missing required tools: ${missing[*]}"
    fi
}