#!/bin/bash
# TeamOps Portable Installation Script
# Copies TeamOps to your project and makes it ready to use

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}    TeamOps Portable Installation${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    echo "Please run this script from the root of your git project"
    exit 1
fi

# Check for required directories
echo "Checking project structure..."

# Check for source directory
if [[ ! -d "src" ]]; then
    echo -e "${YELLOW}Warning: No 'src' directory found${NC}"
    echo "TeamOps expects a 'src' directory for implementation files"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 1
    fi
fi

# Check for test directory
if [[ ! -d "test" ]] && [[ ! -d "tests" ]]; then
    echo -e "${YELLOW}Warning: No 'test' or 'tests' directory found${NC}"
    echo "TeamOps expects a test directory for test files"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 1
    fi
fi

# Check if TeamOps already exists
if [[ -d "tmops_tools" ]] || [[ -d "tmops_v6_portable" ]]; then
    echo -e "${YELLOW}Warning: TeamOps files already exist in this project${NC}"
    read -p "Overwrite existing files? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 1
    fi
fi

# Get the script directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy files to current directory
echo "Installing TeamOps files..."

# Copy tmops_tools directory
echo "  Copying tmops_tools..."
cp -r "$SCRIPT_DIR/tmops_tools" .

# Copy instance_instructions directory
echo "  Copying instance_instructions..."
cp -r "$SCRIPT_DIR/instance_instructions" .

# Copy docs directory if it exists
if [[ -d "$SCRIPT_DIR/docs/tmops_docs_v6" ]]; then
    echo "  Copying docs/tmops_docs_v6..."
    mkdir -p docs
    cp -r "$SCRIPT_DIR/docs/tmops_docs_v6" docs/
fi

# Copy documentation
echo "  Copying documentation..."
cp "$SCRIPT_DIR/README_QUICK_START.md" .
cp "$SCRIPT_DIR/COPY_PASTE_GUIDE.md" .

# Create this INSTALL.sh in the project too
echo "  Copying INSTALL.sh..."
cp "$SCRIPT_DIR/INSTALL.sh" .

# Copy TEST_HELLO.md if it exists
if [[ -f "$SCRIPT_DIR/TEST_HELLO.md" ]]; then
    echo "  Copying TEST_HELLO.md..."
    cp "$SCRIPT_DIR/TEST_HELLO.md" .
fi

# Make scripts executable
echo "Making scripts executable..."
chmod +x tmops_tools/*.sh
chmod +x tmops_tools/*.py

# Verify installation
echo ""
echo "Verifying installation..."

# Check if files were copied
files_to_check=(
    "tmops_tools/init_feature_multi.sh"
    "tmops_tools/cleanup_safe.sh"
    "tmops_tools/extract_metrics.py"
    "tmops_tools/monitor_checkpoints.py"
    "instance_instructions/01_orchestrator.md"
    "instance_instructions/02_tester.md"
    "instance_instructions/03_implementer.md"
    "instance_instructions/04_verifier.md"
    "README_QUICK_START.md"
    "COPY_PASTE_GUIDE.md"
)

all_good=true
for file in "${files_to_check[@]}"; do
    if [[ -f "$file" ]]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo -e "  ${RED}✗${NC} $file"
        all_good=false
    fi
done

# Check if scripts are executable
if [[ -x "tmops_tools/init_feature_multi.sh" ]]; then
    echo -e "  ${GREEN}✓${NC} Scripts are executable"
else
    echo -e "  ${YELLOW}⚠${NC} Scripts may not be executable"
fi

echo ""
if [[ "$all_good" == true ]]; then
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}    Installation Complete!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Initialize your first feature (from tmops_v6_portable dir):"
    echo -e "   ${YELLOW}cd tmops_v6_portable${NC}"
    echo -e "   ${YELLOW}./tmops_tools/init_feature_multi.sh hello-world${NC}"
    echo ""
    echo "2. Follow the Quick Start guide:"
    echo -e "   ${YELLOW}cat README_QUICK_START.md${NC}"
    echo ""
    echo "3. Launch 4 Claude Code instances in ROOT directory:"
    echo -e "   ${YELLOW}cd ..  # Go back to project root${NC}"
    echo -e "   ${YELLOW}claude  # In 4 separate terminals${NC}"
    echo ""
    echo "4. Edit task spec and start:"
    echo -e "   ${YELLOW}vim ../.tmops/hello-world/runs/current/TASK_SPEC.md${NC}"
else
    echo -e "${RED}Installation completed with warnings${NC}"
    echo "Some files may be missing. Check the errors above."
fi

echo ""
echo "For support, see:"
echo "- README_QUICK_START.md (5-step setup)"
echo "- COPY_PASTE_GUIDE.md (detailed examples)"