<!--
📁 FILE: /home/anthonycalek/projects/tmops_framework/CODE/.tmops/tmops-mcp/docs/internal/04_task_specification_mcp_server.md
🎯 PURPOSE: Task specification for implementing production-ready MCP server for TeamOps automation
🤖 AI-HINT: Comprehensive task spec for MCP server development with phase-based approach and production architecture
🔗 DEPENDENCIES: 03_mcp_implementation_proposal.md, MCP protocol, TypeScript, Claude Code CLI, existing TeamOps framework
📝 CONTEXT: Implements automation layer over proven TeamOps v6 workflow patterns with git branch integration
-->

---
# Task Specification - MCP Server for TeamOps Automation
# Version: 1.2.0
# License: CC BY 4.0
# Based on: Implementation Proposal 03_mcp_implementation_proposal.md

meta:
  version: "1.2.0"
  template_name: "task_spec_tmops_mcp"
  id: "TASK-MCP-001"
  title: "MCP Server for TeamOps Automation with Production Architecture"
  type: "feature"
  priority: "P1"
  status: "ready_for_implementation"
  dri: "@development-team"
  stakeholders: ["@lead-engineer"]
  complexity: "high"
  profile: "deep"
  kind: "feature"
  
conventions:
  commit_prefix: "feat"
  branch_naming: "feature/tmops-mcp"
  changelog_required: true
---

# Task Specification: MCP Server for TeamOps Automation with Production Architecture

## LLM Instruction Prompt

> **For AI Agents:** You are implementing a production-ready MCP server that automates TeamOps workflow orchestration.
> 
> 1. **Architecture First**: Build abstractions early, implement MVP versions that scale to production without rewrites
> 2. **Phase-Based Development**: Focus on foundation, orchestration, multi-feature capability, then validation
> 3. **Provider Abstraction**: Design for multiple AI providers, implement Claude Code first
> 4. **Configuration-Driven**: YAML-based architecture enabling production deployment
> 5. **Event System Foundation**: Telemetry and monitoring hooks built-in from day 1
> 6. **Git Integration**: Create `mcp-server/` directory in current tmops-mcp branch
> 7. **Reuse Existing**: Leverage proven tmops_v6_portable shell scripts and patterns
> 8. **Manual Fallback**: Maintain ability to revert to manual orchestration

## Context

### Problem Statement
TeamOps framework requires manual coordination between Claude Code instances, creating handoff latency (5-10 min → <10 sec target) and limiting scalability to single-feature development. Current manual workflow has 95% context coherence and 99% success rate but cannot scale for production use.

### Background
- TeamOps v6 provides proven 4-instance TDD workflow (Orchestrator → Tester → Implementer → Verifier)
- Existing shell scripts in `tmops_v6_portable/tmops_tools/` handle feature initialization and coordination
- Checkpoint system uses filesystem markers in `.tmops/[feature]/runs/initial/checkpoints/`
- Manual handoffs ensure quality but limit adoption and concurrent feature development

### Related Links
- Implementation Proposal: `.tmops/tmops-mcp/docs/internal/03_mcp_implementation_proposal.md`
- MCP Documentation: https://modelcontextprotocol.io/introduction
- TeamOps Framework: `tmops_v6_portable/CLAUDE.md`

## Scope

### In Scope
- [ ] MCP server with provider abstraction layer supporting Claude Code
- [ ] Configuration-driven architecture with YAML config system
- [ ] Plugin-based phase system (orchestrator, tester, implementer, verifier)
- [ ] Event system foundation with telemetry hooks
- [ ] Checkpoint monitoring and automated phase transitions
- [ ] Multi-tenant architecture foundation (single tenant implementation)
- [ ] Error recovery with rollback capabilities
- [ ] Resource isolation between concurrent features
- [ ] Git branch integration within current feature/tmops-mcp branch

### Out of Scope
- [ ] Web dashboard (future enhancement)
- [ ] Multiple AI provider implementations beyond Claude Code
- [ ] Advanced authentication (basic config sufficient for MVP)
- [ ] Performance optimization beyond basic requirements
- [ ] Complex retry/circuit breaker patterns

### MVP Definition
Working MCP server that can orchestrate a complete feature development workflow end-to-end with production-ready architecture patterns, deployable in `mcp-server/` subdirectory.

## Requirements

### Functional Requirements
- **[REQ-1]** MCP server MUST implement standard MCP protocol using @modelcontextprotocol/sdk
- **[REQ-2]** System MUST provide `tmops_init_feature` tool that wraps `./tmops_v6_portable/tmops_tools/init_feature_multi.sh`
- **[REQ-3]** System MUST provide `tmops_start_orchestration` tool for automated workflow
- **[REQ-4]** System MUST provide `tmops_get_status` tool for workflow monitoring
- **[REQ-5]** System MUST monitor `.tmops/[feature]/runs/initial/checkpoints/` for phase transitions
- **[REQ-6]** System MUST support AI provider abstraction through common interface
- **[REQ-7]** System MUST implement configuration-driven architecture with YAML config
- **[REQ-8]** System MUST emit telemetry events for all workflow operations
- **[REQ-9]** System SHOULD maintain manual fallback capability at all phases
- **[REQ-10]** System MAY support concurrent feature development with resource isolation

### Non-Functional Requirements
- **Performance**: MCP tool responses MUST be < 100ms for 95th percentile
- **Reliability**: Workflow success rate MUST maintain 95%+ (current manual: 99%)
- **Scalability**: Architecture MUST support production deployment without rewrites
- **Maintainability**: Plugin architecture MUST allow custom phases without core changes
- **Security**: MUST implement secure checkpoint file handling and process isolation

## Acceptance Criteria

```gherkin
Scenario: Initialize feature via MCP
  Given an MCP server is running with TeamOps configuration
  When Claude Code invokes tmops_init_feature with feature name "test-auth"
  Then the system executes ./tmops_v6_portable/tmops_tools/init_feature_multi.sh test-auth
  And creates feature branch and .tmops directory structure
  And returns success response with next steps
  And emits telemetry event for feature initialization
```

```gherkin
Scenario: Automated workflow orchestration
  Given a feature "test-auth" has been initialized
  When Claude Code invokes tmops_start_orchestration
  Then the system spawns orchestrator Claude session with role instructions
  And monitors checkpoints for phase transitions
  And automatically triggers tester phase when orchestrator completes
  And continues through implementer and verifier phases sequentially
```

```gherkin
Scenario: Concurrent feature isolation
  Given two features "auth-api" and "user-profile" are active
  When both features are in implementation phase simultaneously
  Then each feature maintains separate state and checkpoints
  And changes to one feature do not affect the other
  And resource isolation prevents interference
```

```gherkin
Scenario: Manual fallback capability
  Given a feature workflow is in any phase
  When automation encounters an error or is disabled
  Then the system provides manual override capability
  And existing tmops_v6_portable tools continue to work
  And manual coordination can resume from current checkpoint
```

## Interfaces

### MCP Tools

#### Tool: tmops_init_feature
**Description**: Initialize TeamOps feature with branch and directory structure
**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "feature": {
      "type": "string",
      "pattern": "^[a-z0-9-]{3,20}$",
      "description": "Feature name following TeamOps naming conventions"
    },
    "runType": {
      "type": "string", 
      "enum": ["initial", "retry"],
      "default": "initial"
    }
  },
  "required": ["feature"]
}
```

**Implementation**: Executes `./tmops_v6_portable/tmops_tools/init_feature_multi.sh ${feature} ${runType}`

#### Tool: tmops_start_orchestration
**Description**: Launch 4 Claude sessions with role instructions and begin automated workflow
**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "feature": {
      "type": "string",
      "description": "Feature name to orchestrate"
    }
  },
  "required": ["feature"]
}
```

#### Tool: tmops_get_status
**Description**: Check current phase and checkpoint status for feature
**Input Schema:**
```json
{
  "type": "object", 
  "properties": {
    "feature": {
      "type": "string",
      "description": "Feature name to check status"
    }
  },
  "required": ["feature"]
}
```

### Configuration Interface

#### tmops-mcp.config.yaml
```yaml
server:
  name: "tmops-mcp"
  version: "1.0.0"
  workspace_id: "default"

providers:
  claude_code:
    enabled: true
    command: "claude"
    args: ["-p", "--resume", "--output-format", "json"]
    instructions_dir: "./tmops_v6_portable/instance_instructions"

features:
  concurrent_limit: 1
  default_phases: ["orchestrator", "tester", "implementer", "verifier"]
  checkpoint_timeout: 300

telemetry:
  enabled: true
  level: "info"
  outputs:
    console: true
    file: "./logs/tmops.log"

paths:
  tmops_tools: "./tmops_v6_portable/tmops_tools"
  checkpoints: ".tmops/{feature}/runs/initial/checkpoints"
  instructions: "./tmops_v6_portable/instance_instructions"
```

## Architecture

### Project Structure (Git Integration)
```
# In current feature/tmops-mcp branch
mcp-server/                        # New MCP server implementation
├── src/
│   ├── server.ts                  # Main MCP server entry point
│   ├── providers/                 # AI provider abstractions
│   │   ├── index.ts
│   │   ├── claude-code.ts
│   │   └── provider.interface.ts
│   ├── phases/                    # Orchestration phases (plugin system)
│   │   ├── index.ts
│   │   ├── orchestrator.ts
│   │   ├── tester.ts
│   │   ├── implementer.ts
│   │   └── verifier.ts
│   ├── config/                    # Configuration system
│   │   ├── index.ts
│   │   └── config.interface.ts
│   ├── telemetry/                # Event/logging system
│   │   ├── index.ts
│   │   └── telemetry.interface.ts
│   └── tools/                    # MCP tool implementations
│       ├── index.ts
│       ├── init-feature.ts       # Wraps init_feature_multi.sh
│       ├── start-orchestration.ts
│       └── get-status.ts
├── config/
│   └── tmops-mcp.config.yaml     # Production-ready config
├── tests/                         # Unit and integration tests
├── package.json                   # Dependencies and scripts
├── tsconfig.json                  # TypeScript config
└── README.md                      # Setup and usage docs

# Existing structure (unchanged)
tmops_v6_portable/                 # Existing framework (DO NOT MODIFY)
├── tmops_tools/                   # Shell scripts to be wrapped
├── instance_instructions/         # Role instructions to be used
└── ...                           # Rest of framework

.tmops/tmops-mcp/                  # Current feature workspace
├── docs/internal/
│   ├── 03_mcp_implementation_proposal.md
│   └── 04_task_specification_mcp_server.md  # This file
└── runs/initial/TASK_SPEC.md      # Original preflight template
```

### Component Architecture

#### Component: MCP Server Core
- **Responsibility**: Handle MCP protocol, tool registry, middleware
- **Implementation**: Single-tenant with multi-tenant hooks
- **Dependencies**: @modelcontextprotocol/sdk, configuration system

#### Component: AI Provider Abstraction Layer  
- **Interface**: `AIProvider` with session management methods
- **MVP**: Claude Code provider only
- **Production Scale**: OpenAI, Anthropic API support
- **Key Methods**: `createSession()`, `resumeSession()`, `destroySession()`

#### Component: Plugin-Based Phase System
- **Interface**: `OrchestrationPhase` with validate/execute/rollback
- **MVP**: 4 standard phases using existing instance instructions
- **Extension**: Custom phases via plugin registry

#### Component: Configuration Management
- **Format**: YAML with environment variable support
- **Scope**: Provider selection, feature limits, telemetry config
- **Production**: Multi-tenant workspace configuration

## Implementation Plan

### Phase 1: Foundation with Production Hooks
**Goal**: Working MCP server with scalable architecture patterns

**Deliverables:**
- [ ] TypeScript project setup with MCP SDK in `mcp-server/`
- [ ] Configuration system loading YAML files
- [ ] Provider abstraction with Claude Code implementation
- [ ] Basic telemetry system with console/file output
- [ ] `tmops_init_feature` tool wrapping shell script
- [ ] Unit tests for core components

**Success Criteria**: Can initialize features via MCP tool calls

### Phase 2: Core Orchestration
**Goal**: Automated workflow orchestration with error recovery

**Deliverables:**
- [ ] Phase plugin system with 4 standard phases
- [ ] Checkpoint monitoring with `chokidar` file watching
- [ ] Automated phase transitions based on checkpoint files
- [ ] Claude session management with `claude --resume`
- [ ] Error recovery and rollback capabilities
- [ ] `tmops_start_orchestration` and `tmops_get_status` tools

**Success Criteria**: Can orchestrate complete feature workflow end-to-end

### Phase 3: Multi-Feature Foundation
**Goal**: Concurrent workflow capability with resource isolation

**Deliverables:**
- [ ] Resource isolation between concurrent features
- [ ] State management scaling to multiple features
- [ ] Concurrent feature limit enforcement
- [ ] Integration tests for multi-feature scenarios

**Success Criteria**: Can handle 2+ features simultaneously without interference

### Phase 4: Production Validation
**Goal**: Production readiness demonstration

**Deliverables:**
- [ ] End-to-end test with real feature development
- [ ] Performance benchmarking vs manual workflow
- [ ] Documentation for production deployment
- [ ] Security review and hardening

**Success Criteria**: Meets all acceptance criteria and performance targets

## Test Plan

### Unit Tests
- [ ] MCP tool registration and input validation
- [ ] Configuration loading and environment variable substitution
- [ ] Provider interface compliance and error handling
- [ ] Phase plugin system functionality
- [ ] Telemetry event emission and formatting
- [ ] Checkpoint file monitoring and parsing

### Integration Tests
- [ ] End-to-end feature initialization via MCP
- [ ] Checkpoint monitoring triggering phase transitions
- [ ] Claude Code session management lifecycle
- [ ] Multi-feature resource isolation verification
- [ ] Error injection and recovery scenarios (see Error Scenarios section)
- [ ] Manual fallback functionality

### Error Injection Tests (Specific Scenarios)
**Critical Error Scenarios:**
- [ ] **Claude CLI Process Crash**:
  - Scenario: Kill `claude --resume` process during orchestrator phase
  - Expected: System detects failure within 30s, creates recovery checkpoint
  - Rollback: Resume from last valid checkpoint with manual override option
  
- [ ] **Corrupted Checkpoint Files**:
  - Scenario: Inject malformed JSON/YAML into checkpoint files
  - Expected: File validation catches corruption, rejects transition
  - Rollback: Fall back to previous valid checkpoint, alert operator
  
- [ ] **Filesystem Permission Errors**:
  - Scenario: Remove write permissions on `.tmops/[feature]/` directory
  - Expected: Graceful degradation with clear error messages
  - Rollback: Manual intervention guide provided to fix permissions
  
- [ ] **Git Branch Conflicts**:
  - Scenario: External process modifies feature branch during workflow
  - Expected: Detect conflicts, pause workflow, request manual resolution
  - Rollback: Stash changes, return to clean state for manual conflict resolution
  
- [ ] **Resource Exhaustion**:
  - Scenario: Launch more concurrent features than system limit
  - Expected: Queue additional requests, respect configured limits
  - Rollback: Graceful queuing system with clear status reporting

**Rollback Procedures by Phase:**
- **Orchestrator Phase**: Reset to initial state, preserve TASK_SPEC.md
- **Tester Phase**: Preserve created tests, reset to orchestrator checkpoint  
- **Implementer Phase**: Preserve tests, rollback implementation code changes
- **Verifier Phase**: Preserve all code/tests, rollback summary/metrics only

### Acceptance Tests
- [ ] All Gherkin scenarios implemented and passing
- [ ] Performance requirements validated (<100ms tool responses)
- [ ] Reliability targets met (95%+ success rate)
- [ ] Manual fallback works at all phases
- [ ] Concurrent feature development verified

### Coverage Target
- Minimum: 85% (high complexity feature requirement)
- Target: 90%

## Definition of Done

### Technical Requirements
- [ ] All acceptance criteria passing
- [ ] Unit test coverage ≥85%
- [ ] Integration tests covering all major workflows
- [ ] TypeScript compilation with no errors or warnings
- [ ] ESLint and Prettier formatting applied
- [ ] All MCP tools respond within performance targets

### Quality Gates
- [ ] Manual fallback capability verified at all phases
- [ ] Resource isolation between features confirmed
- [ ] Error recovery and rollback functionality tested
- [ ] Security review completed (input validation, process isolation)
- [ ] Performance benchmarking shows improvement over manual workflow

### Documentation
- [ ] README.md with setup and usage instructions in `mcp-server/`
- [ ] Configuration documentation with all options explained
- [ ] Architecture documentation updated
- [ ] Deployment guide for production readiness
- [ ] Troubleshooting guide for common issues

### Production Readiness
- [ ] Configuration system supports environment-specific settings
- [ ] Provider abstraction layer demonstrated with clean interfaces
- [ ] Event system foundation suitable for production telemetry
- [ ] Multi-tenant architecture hooks implemented
- [ ] Changelog entry added describing the new capability

## Risks & Dependencies

### Critical Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| Claude Code headless API instability | High | Provider abstraction, comprehensive manual fallback |
| MCP protocol breaking changes | Medium | Pin SDK versions, implement adapter patterns |
| Context contamination in automated mode | High | Rigorous session isolation, extensive testing |
| Performance degradation vs manual | Medium | Benchmarking, timeout configuration, optimization |

### Dependencies
**External:**
- Claude Code CLI with stable headless mode support
- @modelcontextprotocol/sdk TypeScript package
- Node.js runtime environment

**Internal:**
- Existing tmops_v6_portable framework and shell scripts
- Git repository with feature branch capability
- Current feature/tmops-mcp branch for development

## Security Considerations

### Security Controls
- Input validation for all MCP tool parameters using JSON schemas
- Process isolation between concurrent features
- Secure checkpoint file validation and parsing
- Configuration file access restrictions
- Session management security with timeout controls

### Threat Model
- **T1**: Malicious feature names → Regex validation, sanitization
- **T2**: Checkpoint file injection → File validation, sandboxed parsing  
- **T3**: Resource exhaustion → Concurrent limits, timeouts
- **T4**: Process injection → Secure subprocess execution

### Security Testing Requirements

**Penetration Testing Scenarios:**
- [ ] **Input Fuzzing**:
  - Fuzz all MCP tool parameters with malformed JSON, oversized strings, special characters
  - Test feature names with SQL injection patterns, XSS payloads, shell metacharacters
  - Validate configuration YAML with malicious payloads, nested bombs, type confusion
  
- [ ] **Process Boundary Testing**:
  - Attempt to escape subprocess execution via command injection
  - Test symlink attacks on checkpoint file paths
  - Verify process isolation between concurrent features
  
- [ ] **Authentication/Authorization**:
  - Test MCP tool access without proper configuration
  - Attempt cross-feature access (feature A accessing feature B's data)
  - Validate session management prevents session hijacking

**Input Validation Testing:**
```yaml
# Test vectors for feature name validation
malicious_inputs:
  - "'; rm -rf /; #"           # Command injection
  - "../../../etc/passwd"      # Path traversal  
  - "\x00\x01\x02"           # Binary data
  - "A" * 1000               # Buffer overflow attempt
  - "feature-${EVIL_VAR}"     # Environment variable injection
  - "<script>alert('xss')</script>"  # XSS payload
```

**File System Security Tests:**
- [ ] Verify checkpoint files are written with restricted permissions (600)
- [ ] Test behavior when .tmops directory has unusual ownership/permissions
- [ ] Validate sandboxed parsing rejects files with dangerous content
- [ ] Test symlink attacks cannot access files outside project boundary

**Session Security Tests:**
- [ ] Verify Claude sessions cannot access other features' data
- [ ] Test timeout mechanisms prevent runaway processes  
- [ ] Validate session cleanup occurs properly on failures
- [ ] Test resistance to session ID prediction/hijacking

**Configuration Security:**
- [ ] Test behavior with world-writable configuration files
- [ ] Verify sensitive data (if any) is not logged in plain text
- [ ] Test environment variable injection via configuration
- [ ] Validate configuration schema prevents dangerous settings

## LLM Execution Guidelines

### Autonomy Level
`constrained` - Implement within defined architecture patterns

### Repository Access
**Read Paths:**
- `tmops_v6_portable/` (framework to be wrapped)
- `.tmops/tmops-mcp/` (current feature workspace)
- Existing codebase for integration patterns

**Write Paths:**  
- `mcp-server/` (new implementation)
- `.tmops/tmops-mcp/docs/` (documentation updates)
- Test files and configuration

### Implementation Constraints
- Do NOT modify existing tmops_v6_portable framework files
- Use existing shell scripts via subprocess calls, don't reimplement
- Preserve all existing manual workflow capabilities
- Follow TypeScript best practices and MCP SDK patterns
- Maintain git branch structure within feature/tmops-mcp

### Validation Commands
```bash
# Development and testing
cd mcp-server
npm install
npm run build
npm test
npm run lint

# Integration validation
cd ..
./tmops_v6_portable/tmops_tools/init_feature_multi.sh test-validation
# Test MCP server against real workflow
```

## Success Metrics

### Phase Success Criteria
| Phase | Success Criteria |
|-------|-----------------|
| Phase 1 | Can initialize features via MCP tools, provider abstraction working |
| Phase 2 | End-to-end workflow automation functional, error recovery tested |
| Phase 3 | Multiple concurrent features working without interference |
| Phase 4 | Production deployment ready, performance targets met |

### Key Performance Indicators
- **Automation Speed**: Handoff time reduced from 5-10 min to <10 sec
- **Reliability**: Maintain 95%+ workflow success rate
- **Scalability**: Support 2+ concurrent features reliably  
- **Response Time**: MCP tool responses <100ms 95th percentile
- **Manual Fallback**: 100% capability preservation

### Performance Benchmarking Requirements

**Baseline Metrics (Manual Workflow):**
- Feature initialization: 2-3 minutes (including branch creation, TASK_SPEC setup)
- Phase handoff coordination: 5-10 minutes per transition (human coordination time)
- End-to-end workflow: 45-120 minutes for simple features
- Context coherence: 95% (measured by verifier acceptance rate)
- Success rate: 99% (features that complete without manual intervention)

**Target Metrics (Automated MCP):**
- **Feature Initialization**: <30 seconds (90% improvement)
  - `tmops_init_feature` tool: <5 seconds response time
  - Shell script execution: <25 seconds total time
  
- **Phase Transitions**: <10 seconds per handoff (95% improvement)
  - Checkpoint detection: <2 seconds after file creation
  - Session spawning: <5 seconds for `claude --resume`
  - Instruction delivery: <3 seconds per phase
  
- **End-to-End Workflow**: <30 minutes for simple features (50% improvement)
  - Orchestrator phase: <5 minutes (plan creation)
  - Tester phase: <10 minutes (test writing and validation)
  - Implementer phase: <10 minutes (minimal code to pass tests)
  - Verifier phase: <5 minutes (quality review and summary)

**Specific Latency Targets by Operation:**
- MCP tool registration: <50ms
- Configuration loading: <100ms  
- Provider session creation: <2000ms
- Checkpoint file parsing: <10ms per file
- Status queries: <50ms
- Error recovery initiation: <500ms

**Reliability Targets:**
- Session management: 99.5% success rate (handle CLI crashes gracefully)
- Checkpoint integrity: 100% (validation catches all corruption)
- Resource isolation: 100% (no cross-feature contamination)
- Manual fallback: 100% (always available at any phase)

## Future Evolution Path

### Production Scaling (Post-MVP)
- **Phase 1 → 2**: Add OpenAI/Anthropic API providers
- **Phase 2 → 3**: Web-based monitoring dashboard  
- **Phase 3 → Production**: Multi-tenant authentication, advanced telemetry

### Extension Points Built In
- Provider plugin system for new AI services
- Phase plugin system for custom workflows
- Event system for monitoring and alerting
- Configuration system for deployment flexibility

---

**Implementation Priority**: P1 - Strategic capability for TeamOps production readiness
**Estimated Complexity**: High - Novel architecture with production foundation requirements
**Success Definition**: Production-ready MCP server demonstrating automated TeamOps orchestration with manual fallback preservation

*Task Specification v1.2.0 | Based on MCP Implementation Proposal | Production Architecture Foundation*