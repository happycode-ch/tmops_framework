#!/bin/bash
# Validate hello-v7 test feature
# Tests that the hello-v7 example works correctly

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}         TeamOps v7 - hello-v7 Validation Test          ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check if hello-v7 exists
if [ ! -d ".tmops/hello-v7" ]; then
    echo -e "${RED}✗ hello-v7 feature not found${NC}"
    echo "Run: ./tmops_tools/v7/init_feature_v7.sh hello-v7 initial"
    exit 1
fi

echo -e "${GREEN}✓ hello-v7 feature found${NC}"

# Check TASK_SPEC exists and is configured
if [ ! -f ".tmops/hello-v7/runs/current/TASK_SPEC.md" ]; then
    echo -e "${RED}✗ TASK_SPEC.md not found${NC}"
    exit 1
fi

if grep -q "Hello World API" .tmops/hello-v7/runs/current/TASK_SPEC.md; then
    echo -e "${GREEN}✓ TASK_SPEC.md properly configured${NC}"
else
    echo -e "${YELLOW}⚠ TASK_SPEC.md may not be configured${NC}"
fi

# Check state file
if [ -f ".tmops/hello-v7/runs/current/state.json" ]; then
    echo -e "${GREEN}✓ State file exists${NC}"
    
    # Display current state
    echo ""
    echo "Current State:"
    python3 -c "
import json
with open('.tmops/hello-v7/runs/current/state.json') as f:
    state = json.load(f)
    print(f\"  Feature: {state.get('feature', 'unknown')}\")
    print(f\"  Phase: {state.get('phase', 'unknown')}\")
    print(f\"  Role: {state.get('role', 'unknown')}\")
"
else
    echo -e "${RED}✗ State file not found${NC}"
    exit 1
fi

# Check expected files
echo ""
echo "Checking expected outputs..."

if [ -f ".tmops/hello-v7/expected/hello.test.js" ]; then
    echo -e "${GREEN}✓ Expected test file present${NC}"
else
    echo -e "${RED}✗ Expected test file missing${NC}"
fi

if [ -f ".tmops/hello-v7/expected/hello.js" ]; then
    echo -e "${GREEN}✓ Expected implementation present${NC}"
else
    echo -e "${RED}✗ Expected implementation missing${NC}"
fi

if [ -f ".tmops/hello-v7/expected/verification-report.md" ]; then
    echo -e "${GREEN}✓ Expected verification report present${NC}"
else
    echo -e "${RED}✗ Expected verification report missing${NC}"
fi

# Check Node.js setup
echo ""
echo "Checking Node.js configuration..."

if [ -f "package.json" ]; then
    if grep -q "tmops-hello-v7" package.json; then
        echo -e "${GREEN}✓ package.json configured for hello-v7${NC}"
    else
        echo -e "${YELLOW}⚠ package.json exists but may not be for hello-v7${NC}"
    fi
else
    echo -e "${RED}✗ package.json not found${NC}"
fi

# Check Claude configuration
echo ""
echo "Checking Claude Code configuration..."

if [ -f ".claude/project_settings.json" ]; then
    echo -e "${GREEN}✓ Claude project settings exist${NC}"
    
    # Check for TeamOps hooks
    if grep -q "tmops_v7" .claude/project_settings.json; then
        echo -e "${GREEN}✓ TeamOps v7 hooks configured${NC}"
    else
        echo -e "${RED}✗ TeamOps v7 hooks not found${NC}"
    fi
else
    echo -e "${RED}✗ Claude project settings not found${NC}"
fi

if [ -d ".claude/agents" ]; then
    agent_count=$(ls .claude/agents/tmops-*.md 2>/dev/null | wc -l)
    if [ "$agent_count" -eq 3 ]; then
        echo -e "${GREEN}✓ All 3 TeamOps subagents installed${NC}"
    else
        echo -e "${YELLOW}⚠ Found $agent_count subagents (expected 3)${NC}"
    fi
else
    echo -e "${RED}✗ Subagents directory not found${NC}"
fi

# Test hook validation
echo ""
echo "Testing hook functionality..."

# Test that hooks are executable
if [ -x "tmops_tools/v7/hooks/pre_tool_use.py" ]; then
    echo -e "${GREEN}✓ Hooks are executable${NC}"
else
    echo -e "${RED}✗ Hooks are not executable${NC}"
    echo "Run: chmod +x tmops_tools/v7/hooks/*.py"
fi

# Simple hook response test
echo '{"tool_name":"Test","tool_input":{}}' | python3 tmops_tools/v7/hooks/pre_tool_use.py > /tmp/hook_test.json 2>/dev/null
if grep -q '"continue"' /tmp/hook_test.json 2>/dev/null; then
    echo -e "${GREEN}✓ Hook response format valid${NC}"
else
    echo -e "${RED}✗ Hook response format invalid${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    Validation Summary                  ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"

echo ""
echo -e "${GREEN}Ready to test hello-v7 workflow!${NC}"
echo ""
echo "To run the full workflow:"
echo -e "${BLUE}TMOPS_V7_ACTIVE=1 claude \"Build hello-v7 feature using TeamOps v7\"${NC}"
echo ""
echo "The workflow should:"
echo "1. Invoke tester to write failing tests"
echo "2. Detect test completion and invoke implementer"
echo "3. Make tests pass and invoke verifier"
echo "4. Generate verification report"
echo ""
echo -e "${YELLOW}Note: Compare actual outputs with files in .tmops/hello-v7/expected/${NC}"