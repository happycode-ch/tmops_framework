# TeamOps v6 Portable Package

## 🎯 Purpose
A complete, self-contained TeamOps v6 package that can be copied to ANY git project and set up in under 3 minutes.

## 📦 What's Included

### Core Components (19 files, 268K total)
- **tmops_tools/** - 4 automation scripts (init, cleanup, metrics, monitoring)
- **docs/tmops_docs_v6/** - Complete v6 documentation (6 files)
- **instance_instructions/** - 4 role-specific Claude Code instructions
- **Setup guides** - README_QUICK_START, COPY_PASTE_GUIDE, TEST_HELLO
- **INSTALL.sh** - Automated installer script

## 🚀 Ultra-Simple Deployment

### Option 1: Direct Copy
```bash
cp -r tmops_v6_portable/ /path/to/your/project/
cd /path/to/your/project/
./tmops_tools/init_feature_v6.sh my-feature initial
```

### Option 2: Automated Install
```bash
cd /path/to/your/project/
./tmops_v6_portable/INSTALL.sh
./tmops_tools/init_feature_v6.sh my-feature initial
```

## ⚡ 30-Second Test
```bash
# After copying to your project:
./tmops_tools/init_feature_v6.sh test-feature initial
# Should create .tmops/ structure and 4 git worktrees
ls -la wt-*
# Should show: wt-orchestrator, wt-tester, wt-impl, wt-verify
```

## 📋 Requirements
- Git repository
- `src/` and `test/` (or `tests/`) directories
- 4 Claude Code CLI instances
- Unix-like environment

## 🎓 Key Advantages
- **Zero dependencies** on tmops_framework repo
- **Completely portable** - works in any git project
- **All documentation included** - no external references needed
- **Pre-split instructions** - just copy-paste into Claude Code
- **Tested and verified** - includes TEST_PACKAGE.sh validator

## 📖 Documentation Map
- **Quick Start**: README_QUICK_START.md (3-minute setup)
- **Full Protocol**: docs/tmops_docs_v6/tmops_protocol.md
- **Instance Details**: docs/tmops_docs_v6/tmops_claude_code.md
- **Hello World Example**: TEST_HELLO.md
- **Troubleshooting**: COPY_PASTE_GUIDE.md

## ✅ Verification
Run `./TEST_PACKAGE.sh` to verify all components are present and correct.

---

This package represents TeamOps v6 in its most efficient, deployable form - ready for real-world testing in any project.