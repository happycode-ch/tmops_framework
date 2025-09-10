# Changelog

All notable changes to the TeamOps Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [6.4.2] - 2025-09-10

### Added
- **Enhanced Documentation Structure**: Expanded docs folder organization
  - Added `archive/` subdirectory for superseded and historical documentation
  - Added `images/` subdirectory for screenshots, diagrams, and visual assets
  - Updated both `lib/common.sh` and `init_feature_multi.sh` to create new folders

### Fixed
- **Template File Naming Convention**: Added explicit naming instructions to all templates
  - All 11 templates (00-10) now include bash commands for generating correct filenames
  - Format: `[template_num]_[date]_[time]_[feature_name]_[template_type].md`
  - Example: `05_2025-09-09_213607_visual_component_capture_task_spec.md`
  - Includes date generation: `$(date +%Y-%m-%d)` and time: `$(date +%H%M%S)`
  - Helps AI agents correctly name files when saving completed templates

## [6.4.1] - 2025-09-03

### Fixed
- **Path Ambiguity Bug**: Eliminated navigation delays in instance instructions
  - Replaced symlink-dependent paths (`runs/current/`) with direct paths (`runs/initial/`)
  - Updated all 7 instance instruction files (4 standard + 3 preflight workflow)
  - Maintains backward compatibility while removing dependency on symlink indirection
  - Resolves ~1 minute delays when instances navigate workspace directories
  - PR: https://github.com/happycode-ch/tmops_framework/pull/12

## [6.4.0] - 2025-09-03

### Added
- **Project-Level CLAUDE.md**: Comprehensive development context file for Claude Code interactions
  - Development-focused guidance for framework development vs framework usage
  - Practical commands based on actual workflow patterns from settings.local.json
  - Shell scripting conventions with mandatory shellcheck requirements
  - Git workflow procedures and changelog management guidance
  - Quality gates and pre-commit checklist for framework development
- **Preflight Workflow System**: 7-instance workflow for complex features requiring specification refinement
  - **Sequential Scripts Architecture**: Separate `init_preflight.sh` for 3-instance preflight workflow
  - **Smart Handoff System**: Automatic detection of preflight-refined specifications in main workflow
  - **Preflight Instance Instructions**: Self-contained package for 3 specialized preflight instances:
    - `02_preflight_researcher.md` - Research & discovery of existing patterns and technical context
    - `03_preflight_analyzer.md` - Deep technical analysis and implementation planning
    - `04_preflight_specifier.md` - Quality control with rejection authority for refined specifications
  - **Shared Function Library**: `tmops_tools/lib/common.sh` with 24 centralized functions
    - Atomic checkpoint creation with proper error handling
    - Lock file management to prevent concurrent executions
    - Consistent path resolution across all scripts
    - Feature validation and branch management utilities
- **Enhanced Main Workflow**: `init_feature_multi.sh` now features smart detection
  - Automatically detects and uses preflight-refined specifications
  - Zero additional user commands required for workflow transition
  - Maintains backward compatibility with standard 4-instance workflow
- **Quality Validation**: All scripts pass shellcheck with comprehensive error handling
  - `set -euo pipefail` for strict error handling across all new scripts
  - Atomic file operations for checkpoint creation
  - Comprehensive logging with color-coded output

### Changed
- **Dual Workflow Documentation**: Updated all documentation to reflect workflow options
  - **README.md**: Enhanced with preflight workflow guidance and decision criteria
  - **CLAUDE.md**: Added comprehensive preflight context following framework best practices
  - **Root README.md**: Updated architecture diagrams showing both standard and preflight workflows
- **Workflow Selection Guidance**: Clear criteria for when to use standard vs preflight workflows
  - Standard (4-instance): Direct implementation for straightforward features
  - Preflight (7-instance): Research → Analysis → Specification → Implementation for complex features

### Technical Architecture
- **Sequential Scripts vs Integrated Flag**: Chose separate scripts for better separation of concerns
- **Marker-Based Detection**: Elegant solution using `grep` patterns for refined specification identification
- **Unified Workspace**: Uses existing `.tmops/[feature]/runs/initial/` structure for compatibility
- **Zero-Friction Handoff**: Automatic detection eliminates manual coordination between workflows

### Quality Assurance
- **Shellcheck Validation**: All preflight scripts pass with zero errors (1 expected info message)
- **Integration Testing**: Complete workflow scenarios validated with test workspaces
- **Error Handling**: Comprehensive error handling with atomic operations and lock file management
- **Documentation Consistency**: Maintained consistency across all framework documentation files

## [6.3.1] - 2025-09-01

### Added
- **CLAUDE.md Framework Context File**: Comprehensive context file for Claude Code instances
  - Framework-specific guidance and best practices
  - Complete command reference and workflows
  - Orchestration protocol documentation
  - TDD enforcement and architectural patterns

## [6.3.0] - 2025-09-01

### Added
- **Comprehensive Template System**: Created 8 AI-ready markdown templates for complete development workflow
  - `00_research_template.md` - Prior art and feasibility analysis
  - `01_plan_template.md` - Strategic planning and resource allocation
  - `02_discovery_template.md` - Codebase analysis and gap identification
  - `03_proposal_template.md` - Solution design with alternatives
  - `04_implementation_template.md` - Change documentation and verification
  - `05_task_spec_template.md` - Detailed task specifications (existing, enhanced)
  - `06_summary_template.md` - Project retrospectives and ROI analysis
  - `07_review_template.md` - Final acceptance and go/no-go decisions
- **Documentation Structure**: New `docs/internal/` and `docs/external/` folders for each feature
  - Internal folder for AI-generated documentation
  - External folder for human-created documentation
- **Enhanced Script Features**:
  - `init_feature_multi.sh` now creates docs directories automatically
  - `list_features.sh` displays documentation file counts
  - `switch_feature.sh` shows internal/external docs status

### Changed
- **Documentation Organization**: Reorganized project documentation structure
  - Moved historical documentation to `.docs/` directory
  - Created `tmops_v6_portable/templates/` for all template files
  - Removed example files from `tmops_v6_portable/` root
- **Script Improvements**:
  - Updated all tmops_tools scripts to support new docs structure
  - `cleanup_safe.sh` properly handles new documentation folders

### Fixed
- **GitIgnore Updates**: Properly configured ignore patterns
  - `.tmops/` directory remains private for development
  - `.docs/` directory for historical documentation
  - Templates directory now tracked in git

## [6.2.2] - 2025-08-22

### Changed
- **README Documentation Update**: Significantly enhanced README.md to emphasize sequential workflow
- Improved coordination flow documentation with clear step-by-step instructions
- Added emphasis on "only one instance works at a time" principle
- Updated troubleshooting section with common path-related issues
- Enhanced architecture documentation highlighting sequential execution model

### Added
- Comprehensive development report creation (`2025_08_22-path_resolution_issues-REPORT.md`)
- System architecture documentation with technical implementation details
- Best practices section for both users and developers
- Self-improvement strategy documentation

### Fixed
- Cleaned up test artifacts and branches (test-hello, test/cleanup_feature.sh, test/test_system_v5, test/tmops_v6_portable)

## [6.2.1] - 2025-08-22

### Added
- Development report documenting system architecture and best practices
- Comprehensive path resolution documentation
- Self-improvement strategy using TeamOps on itself

### Fixed
- Path resolution in `init_feature_multi.sh` now works from any directory
- Path resolution in `cleanup_safe.sh` now uses consistent PROJECT_ROOT
- Updated scripts to use absolute paths internally while showing clear paths to users

### Changed
- All scripts now use unified PROJECT_ROOT calculation
- Documentation updated to emphasize working directory importance

## [6.2.0] - 2025-08-22

### Changed
- **BREAKING**: Removed worktree architecture completely
- Simplified to single feature branch approach
- All instances now work from root project directory
- Renamed to "Simplified Edition"

### Fixed
- Navigation complexity eliminated
- Instance coordination simplified
- Reduced setup time from minutes to seconds

### Updated
- All instance instructions for single-branch workflow
- README to reflect simplified approach
- Test script renamed to `test_teamops.sh`

## [6.1.0] - 2025-08-21

### Added
- Multi-feature support - work on multiple features simultaneously
- Safe cleanup system with two-tier protection
- Feature tracking via `.tmops/FEATURES.txt`
- Backup system before cleanup operations
- `list_features.sh` to show all active features
- `switch_feature.sh` to display feature information

### Changed
- Scripts renamed for clarity (init_feature_multi.sh)
- Worktree naming includes feature name
- Each feature gets dedicated worktrees

### Fixed
- Cleanup now handles uncommitted changes gracefully
- Better error messages for missing directories
- Improved git branch handling

## [6.0.0] - 2025-08-20

### Added
- Initial portable TeamOps v6 release
- 4-instance orchestration model (Orchestrator, Tester, Implementer, Verifier)
- Manual coordination protocol
- Checkpoint-based communication system
- Comprehensive instance instructions
- Test-Driven Development workflow
- `INSTALL.sh` for easy deployment
- Metric extraction system
- Performance monitoring tools

### Core Features
- Branch-based development
- Symlink structure for run management
- Checkpoint markdown files for phase transitions
- Logging system for each instance
- Git integration for version control

## [5.0.0] - 2025-08-15

### Previous Version
- Original TeamOps implementation
- Single-instance coordination
- Basic TDD support

---

## Migration Notes

### From v6.1 to v6.2
1. Run cleanup on any existing features with worktrees
2. Update to latest version
3. Re-initialize features with new simplified approach
4. All instances now work from root directory (no more worktree navigation)

### From v6.0 to v6.1
1. Clean up old single-feature worktrees
2. Update scripts to multi-feature versions
3. Features now tracked in `.tmops/FEATURES.txt`

### From v5.x to v6.x
1. Complete architectural change
2. Move to 4-instance model
3. Adopt manual coordination protocol
4. See migration guide in docs/