# Repository Guidelines

## Project Structure & Module Organization

- `tmops_v6_portable/` — portable toolkit entrypoint.
  - `tmops_tools/` shell and Python utilities (common helpers in `tmops_v6_portable/tmops_tools/lib/common.sh`).
  - `templates/`, `docs/`, `instance_instructions/` — role guides and templates.
- `.tmops/<feature>/runs/<run>/` — feature workspace (task spec, `checkpoints/`, `logs/`, `metrics.json`). Managed by scripts; treat as generated artifacts.
- `.docs/`, `.notes/` — project-level notes and images.

## Build, Test, and Development Commands

- Initialize feature (creates `.tmops` structure and `feature/<name>` branch):
  - `./tmops_v6_portable/tmops_tools/init_feature_multi.sh <feature> [initial]`
- Optional preflight (refine specification first):
  - `./tmops_v6_portable/tmops_tools/init_preflight.sh <feature>`
- List/switch/cleanup helpers:
  - `./tmops_v6_portable/tmops_tools/list_features.sh`
  - `./tmops_v6_portable/tmops_tools/cleanup_safe.sh <feature> [safe|full]`
- Metrics and monitoring (Python 3.6+):
  - `./tmops_v6_portable/tmops_tools/extract_metrics.py <feature> --format both`
  - `./tmops_v6_portable/tmops_tools/monitor_checkpoints.py <feature> orchestrator list`
- Smoke test (run from `tmops_v6_portable/`):
  - `./tmops_v6_portable/test_teamops.sh`

## Coding Style & Naming Conventions

- Bash: use `set -euo pipefail`, reuse `log_*` and helpers from `lib/common.sh`; keep scripts idempotent and safe-by-default.
- Python: follow PEP 8 with type hints where practical; prefer stdlib.
- Feature names: `^[a-z0-9-]{3,20}$`; branches: `feature/<name>`.
- Checkpoints: `NNN-phase-status.md` in `.tmops/<feature>/runs/current/checkpoints/` (e.g., `003-tests-complete.md`).

## Testing Guidelines

- Prefer fast CLI checks and script-based tests that fail on non‑zero exit.
- Use `test_teamops.sh` as a pattern; place additional `test_*.sh` in `tmops_v6_portable/` and keep them idempotent.
- Validate flows by inspecting `.tmops/<feature>/runs/current/` and by running metrics extraction.

## Commit & Pull Request Guidelines

- Use Conventional Commits: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`; short imperative subject, optional body.
- PRs include: scope/goal, linked issues, reproduction commands, and before/after notes (log snippets or directory tree when helpful).

## Security & Configuration Tips

- Dependencies: `git`, `flock`, `mktemp`, Python 3.6+.
- Run scripts from `tmops_v6_portable/` unless noted; tools auto-detect project root.
- Use `cleanup_safe.sh` cautiously; prefer `safe` mode and rely on built‑in backups.

