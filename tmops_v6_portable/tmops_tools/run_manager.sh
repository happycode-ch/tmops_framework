#!/usr/bin/env bash
# 📁 FILE: tmops_v6_portable/tmops_tools/run_manager.sh
# 🎯 PURPOSE: Manage TeamOps runs (new, clear/archive, switch, list) per feature
# 🤖 AI-HINT: Use to iterate safely with archived handoffs/logs and optional fresh specs
# 🔗 DEPENDENCIES: git, bash, tmops_tools/lib/common.sh
# 📝 CONTEXT: Complements init scripts with multi-run support without forcing branch changes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

usage() {
  cat << EOF
Usage: $0 <feature> <command> [options]

Commands:
  list                                  List all runs and mark current
  new [--name <run>] [--spec new|copy] \
      [--from <run|current|none>]       Create a new run, optionally with fresh spec
  clear [--what checkpoints|logs|both] \
        [--desc "reason"]              Archive current run artifacts and clear
  switch --name <run>                   Switch current to an existing run

Examples:
  $0 data-enrichment list
  $0 data-enrichment new --name cycle-20251002-1145 --spec new
  $0 data-enrichment clear --what both --desc "Reset after bugfix"
  $0 data-enrichment switch --name cycle-20251002-1145
EOF
}

FEATURE="${1:-}"
SUBCMD="${2:-}"
if [[ -z "$FEATURE" || -z "$SUBCMD" ]]; then
  usage; exit 1
fi

get_project_paths
FEATURE_DIR="$TMOPS_DIR/$FEATURE"
RUNS_DIR="$FEATURE_DIR/runs"
CURRENT_LINK="$FEATURE_DIR/current"

ensure_feature_dirs() {
  mkdir -p "$RUNS_DIR"
}

current_run_name() {
  if [[ -L "$CURRENT_LINK" ]]; then
    local target
    target="$(readlink "$CURRENT_LINK")" # e.g., runs/<name>
    basename "$target"
  elif [[ -d "$CURRENT_LINK" ]]; then
    basename "$CURRENT_LINK"
  else
    echo "" # none
  fi
}

archive_path_for() {
  local cur_run="$1"
  local ts
  ts="$(date +%Y%m%d-%H%M%S)"
  echo "$FEATURE_DIR/.archive/${ts}-${cur_run}"
}

cmd_list() {
  ensure_feature_dirs
  local cur
  cur="$(current_run_name)"
  echo "Feature: $FEATURE"
  echo "Runs under: $RUNS_DIR"
  if [[ ! -d "$RUNS_DIR" ]]; then
    echo "  (no runs)"; return 0
  fi
  for d in "$RUNS_DIR"/*; do
    [[ -d "$d" ]] || continue
    local name
    name="$(basename "$d")"
    if [[ "$name" == "$cur" ]]; then
      echo "  • $name [CURRENT]"
    else
      echo "  • $name"
    fi
  done
}

cmd_new() {
  ensure_feature_dirs
  local name="cycle-$(date +%Y%m%d-%H%M)"
  local spec_mode="copy"   # new|copy
  local from_ref="current"  # run name|current|none
  local desc=""
  shift 2 || true
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --name) name="$2"; shift 2;;
      --spec) spec_mode="$2"; shift 2;;
      --from) from_ref="$2"; shift 2;;
      --desc) desc="$2"; shift 2;;
      *) shift;;
    esac
  done

  acquire_lock "$FEATURE" "run-manager"

  local new_dir="$RUNS_DIR/$name"
  if [[ -d "$new_dir" ]]; then
    error_exit "Run already exists: $name"
  fi
  mkdir -p "$new_dir"/{checkpoints,logs}

  # Handle spec creation/copy
  local spec_path="$new_dir/TASK_SPEC.md"
  if [[ "$spec_mode" == "new" ]]; then
    cat > "$spec_path" << EOF
# Task Specification: $FEATURE
Version: 1.0.0
Created: $(date -I)
Status: Active

## Context
This run was initialized as a new sub-scope/spec.

## User Story
As a ...
I want ...
So that ...

## Acceptance Criteria
- [ ] Requirement 1
- [ ] Requirement 2

## Notes
$desc
EOF
  else
    # copy mode
    local source_spec=""
    if [[ "$from_ref" == "current" ]]; then
      source_spec="$FEATURE_DIR/current/TASK_SPEC.md"
    elif [[ "$from_ref" == "none" ]]; then
      source_spec=""
    else
      source_spec="$RUNS_DIR/$from_ref/TASK_SPEC.md"
    fi
    if [[ -n "$source_spec" && -f "$source_spec" ]]; then
      cp "$source_spec" "$spec_path"
    else
      # fallback to new
      cat > "$spec_path" << EOF
# Task Specification: $FEATURE
Version: 1.0.0
Created: $(date -I)
Status: Active

## Context
This run has a fresh spec because source wasn't found.

## Notes
$desc
EOF
    fi
  fi

  # Update PREVIOUS_RUN and current symlink
  local prev
  prev="$(current_run_name)"
  if [[ -n "$prev" ]]; then
    echo "$prev" > "$RUNS_DIR/PREVIOUS_RUN.txt" 2>/dev/null || true
  fi
  ln -sfn "runs/$name" "$CURRENT_LINK"
  log_success "Created run: $name"
  echo "Current → $name"
}

cmd_clear() {
  ensure_feature_dirs
  local what="both"   # checkpoints|logs|both
  local desc=""
  shift 2 || true
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --what) what="$2"; shift 2;;
      --desc) desc="$2"; shift 2;;
      *) shift;;
    esac
  done

  local cur
  cur="$(current_run_name)"
  if [[ -z "$cur" ]]; then
    error_exit "No current run to clear"
  fi

  acquire_lock "$FEATURE" "run-manager"
  local cur_dir="$RUNS_DIR/$cur"
  local archive_dir
  archive_dir="$(archive_path_for "$cur")"
  mkdir -p "$archive_dir"

  # Archive and clear selected artifacts
  if [[ "$what" == "checkpoints" || "$what" == "both" ]]; then
    if [[ -d "$cur_dir/checkpoints" ]]; then
      mkdir -p "$archive_dir/checkpoints"
      cp -r "$cur_dir/checkpoints/"* "$archive_dir/checkpoints/" 2>/dev/null || true
      rm -f "$cur_dir/checkpoints/"* 2>/dev/null || true
    fi
  fi
  if [[ "$what" == "logs" || "$what" == "both" ]]; then
    if [[ -d "$cur_dir/logs" ]]; then
      mkdir -p "$archive_dir/logs"
      cp -r "$cur_dir/logs/"* "$archive_dir/logs/" 2>/dev/null || true
      rm -f "$cur_dir/logs/"* 2>/dev/null || true
    fi
  fi

  {
    echo "FEATURE=$FEATURE"
    echo "RUN=$cur"
    echo "WHAT=$what"
    echo "DESC=$desc"
    echo "ARCHIVED=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  } > "$archive_dir/ARCHIVE_META.txt"

  log_success "Archived and cleared: $what for run $cur"
  echo "Archive: $archive_dir"
}

cmd_switch() {
  ensure_feature_dirs
  local name=""
  shift 2 || true
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --name) name="$2"; shift 2;;
      *) shift;;
    esac
  done
  if [[ -z "$name" ]]; then
    error_exit "--name <run> is required for switch"
  fi
  if [[ ! -d "$RUNS_DIR/$name" ]]; then
    error_exit "Run not found: $name"
  fi
  local prev
  prev="$(current_run_name)"
  if [[ -n "$prev" ]]; then
    echo "$prev" > "$RUNS_DIR/PREVIOUS_RUN.txt" 2>/dev/null || true
  fi
  ln -sfn "runs/$name" "$CURRENT_LINK"
  log_success "Switched current run → $name"
}

case "$SUBCMD" in
  list)   cmd_list ;;
  new)    cmd_new "$@" ;;
  clear)  cmd_clear "$@" ;;
  switch) cmd_switch "$@" ;;
  *) usage; exit 1 ;;
esac

