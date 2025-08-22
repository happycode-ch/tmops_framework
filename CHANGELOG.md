# Changelog

All notable changes to the TeamOps Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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