<!--
📁 FILE: /home/anthonycalek/projects/tmops_framework/CODE/tmops-header-standardization/tmops_v6_portable/templates/05_task_spec_template.md
🎯 PURPOSE: Comprehensive task specification template with AI instructions and RAG support for precise requirements definition
🤖 AI-HINT: Use as base for creating detailed task specifications with acceptance criteria, constraints, and success metrics
🔗 DEPENDENCIES: Requirements gathering, user stories, acceptance criteria, TeamOps workflow
📝 CONTEXT: Core template for task specification creation following ISO/IEC standards with AI-ready structure
-->

---
# Task Specification Template - AI-Ready with RAG Support
# Version: 1.2.0
# License: CC BY 4.0
# Based on: ISO/IEC/IEEE 29148, RFC-2119, User Stories, Gherkin AC, C4 Diagrams, ADRs

meta:
  version: "1.2.0"
  template_name: "task_spec_ai_ready_minimal_rag"
  id: "TASK-XXXX"
  title: "Concise, action-oriented title"
  type: "feature|bugfix|refactor|docs|chore|spike"
  priority: "P1|P2|P3"
  status: "proposed"
  dri: "@owner_handle"
  stakeholders: ["@reviewer1"]
  complexity: "auto"  # trivial|low|medium|high|auto
  profile: "auto"     # lite|standard|deep|auto
  kind: "docs|api|bugfix|refactor|feature"
  
conventions:
  commit_prefix: "feat|fix|refactor|docs|chore|test"
  branch_naming: "task/TASK-XXXX-short-slug"
  changelog_required: false
---

# Task Specification: [TITLE]

## LLM Instruction Prompt

> **For AI Agents:** You are producing a concise, actionable Task Spec. 
> 
> 1. Read all provided materials
> 2. Detect task kind (docs, api, feature, bugfix, refactor) and infer complexity (trivial/low/medium/high)
> 3. Expand ONLY relevant sections; omit or minimize others
> 4. Use RFC-2119 wording (MUST/SHOULD/MAY) for requirements and Gherkin for acceptance criteria
> 5. Treat DoD as the success contract
> 6. **Research Requirements:**
>    - If you have web/tools access: perform targeted searches to validate claims, specs, limits, and best practices
>    - Cite 3-5 authoritative sources (prefer official docs/standards)
>    - Include citations in the "References" section
>    - If you lack web/tools access: state that limitation, list what should be verified, provide suggested queries
> 7. Never include private tokens, secrets, or PII; avoid over-quoting (≤25 words/source)
> 8. Keep output lean (≤2 pages for trivial/low complexity)
> 9. End with self-checks in "Review Checklist" and runnable eval commands in "Evaluation"

## Context

### Problem Statement
<!-- 1-3 lines describing the need and impact -->

### Background
<!-- Relevant history/constraints (brief) -->

### Related Links
- Epic: [link]
- Design: [link]
- Style Guide: [link]

## Scope

### In Scope
- [ ] Smallest set of changes needed
- [ ] Core functionality required

### Out of Scope
- [ ] Explicitly excluded work
- [ ] Future enhancements

### MVP Definition
<!-- One sentence minimal outcome -->

## Requirements

### Functional Requirements
<!-- Use MUST/SHOULD/MAY per RFC-2119 -->
- **[REQ-1]** System MUST authenticate users before allowing access
- **[REQ-2]** System SHOULD support OAuth 2.0 authentication
- **[REQ-3]** System MAY include social login providers

### Non-Functional Requirements
<!-- Only include if critical -->
- **Performance**: Response time MUST be < 200ms for 95th percentile
- **Security**: MUST implement OWASP top 10 protections
- **Observability**: MUST emit structured logs for all API calls

## Acceptance Criteria

```gherkin
Scenario: User authentication
  Given a registered user with valid credentials
  When the user submits login form
  Then the system authenticates the user
  And returns a valid JWT token
  And logs the authentication event
```

```gherkin
Scenario: Failed authentication
  Given a user with invalid credentials
  When the user attempts to login
  Then the system rejects the authentication
  And returns appropriate error message
  And increments failed login counter
```

## Interfaces

### APIs
<!-- Define API contracts if applicable -->

#### Endpoint: POST /api/auth/login
**Request:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response (200 OK):**
```json
{
  "token": "jwt-token",
  "expires_in": 3600
}
```

### Events
<!-- Define event contracts if applicable -->
- **Topic**: `auth.user.login`
- **Payload**: `{user_id, timestamp, session_id}`

## Architecture

### Component Changes
<!-- C4 component level changes -->
- AuthService → adds JWT token generation
- UserRepository → adds login attempt tracking

### Architecture Decisions
<!-- Reference or create ADRs -->
- **ADR-001**: Use JWT for stateless authentication
  - Status: Proposed
  - Path: `docs/adr/ADR-001-jwt-auth.md`

### Data Migrations
<!-- List required migrations -->
- Add `login_attempts` table
- Add index on `users.email`

## Test Plan

### Unit Tests
- [ ] JWT token generation with correct claims
- [ ] Password hashing and verification
- [ ] Rate limiting logic

### Integration Tests
- [ ] Full authentication flow
- [ ] Database transaction handling
- [ ] External OAuth provider integration

### Acceptance Tests
<!-- Mirror acceptance criteria using BDD framework -->
- [ ] All Gherkin scenarios pass

### Coverage Target
- Minimum: 80%
- Target: 90%

## Definition of Done

- [ ] All acceptance criteria pass in CI
- [ ] Documentation updated where relevant
- [ ] No P1/P2 security findings
- [ ] Monitoring/alerts added for new paths
- [ ] PR reviewed and approved
- [ ] Performance benchmarks met
- [ ] Deployment runbook updated

## Risks & Dependencies

### Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| OAuth provider downtime | High | Implement fallback to local auth |
| JWT secret rotation | Medium | Plan rotation strategy |

### Dependencies
- External: OAuth provider APIs
- Internal: User service v2.0+
- Secrets: JWT signing key

## Rollout Strategy

### Feature Flag
- Name: `auth_jwt_enabled`
- Default: false

### Deployment Plan
```
1. Deploy with flag disabled
2. Enable for 10% internal users (1 hour)
3. Enable for 50% all users (24 hours)
4. Full rollout
```

### Rollback Plan
<!-- How to disable/rollback quickly -->
1. Disable feature flag
2. If critical: revert deployment
3. Notify stakeholders via #incidents

## Observability

### Metrics
- `auth_login_attempts_total{status="success|failure"}`
- `auth_token_generation_duration_seconds`
- `auth_active_sessions_gauge`

### Logs
```json
{
  "event": "user_login",
  "user_id": "uuid",
  "timestamp": "iso8601",
  "success": boolean,
  "method": "local|oauth"
}
```

### Alerts
- `AuthenticationFailureRate > 10%` for 5 minutes
- `TokenGenerationLatency > 500ms` for 10 minutes

## Security & Privacy

### Threat Model
- **T1**: Brute force attacks → Rate limiting
- **T2**: Token theft → Short expiry + refresh tokens
- **T3**: Session hijacking → Secure cookie flags

### Security Controls
- Rate limiting: 5 attempts per minute
- Password policy: min 12 chars, complexity rules
- Token expiry: 1 hour access, 7 day refresh

### Data Handling
- **PII**: User email (encrypted at rest)
- **Retention**: Login logs for 90 days
- **Compliance**: GDPR Article 32

## LLM Execution

### Autonomy Level
`constrained` <!-- constrained|guided|autonomous -->

### Allowed Tools
- git, bash, pytest
- npm, node, docker
- Language-specific tools as needed

### Repository Access
**Read Paths:**
- `src/`, `tests/`, `docs/`

**Write Paths:**
- `src/`, `tests/`, `docs/`, `docs/adr/`

### Constraints
- Do NOT change public API unless explicitly allowed
- Prefer small, reversible commits
- Preserve existing exports and behavior unless in scope
- Run tests before committing

### Evaluation Commands
```bash
# Run these to validate implementation
pytest -q tests/auth/
npm test --silent || true
npx markdownlint docs/**/*.md || true
```

### Expected Deliverables
- [ ] Code changes in src/
- [ ] Tests in tests/
- [ ] Documentation updates
- [ ] ADR if architectural decisions made

## Research & References

### Research Requirements
**Minimum sources**: 3  
**Maximum sources**: 6  
**Preferred domains**: 
- ietf.org, iso.org, ieee.org
- developer.mozilla.org, docs.python.org
- Official framework/library docs

### Citations
<!-- Format: [ID] Title - Publisher, Version/Date; URL; Accessed YYYY-MM-DD -->

1. **[RFC-6749]** The OAuth 2.0 Authorization Framework - IETF, 2012; https://tools.ietf.org/html/rfc6749; Accessed 2024-01-15
2. **[JWT-RFC7519]** JSON Web Token (JWT) - IETF, 2015; https://tools.ietf.org/html/rfc7519; Accessed 2024-01-15
3. **[OWASP-AUTH]** Authentication Cheat Sheet - OWASP, 2024; https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html; Accessed 2024-01-15

**Claims Supported**: [REQ-1], [REQ-2], Security Controls section

## Assumptions & Open Questions

### Assumptions
- Users have modern browsers supporting JWT
- OAuth providers maintain 99.9% uptime
- Existing user table can be modified

### Open Questions
- [ ] Which OAuth providers to support initially?
- [ ] Should we implement refresh token rotation?
- [ ] Rate limit strategy: per IP or per user?

## Review Checklist

### Self-Review
- [ ] All requirements have acceptance criteria
- [ ] Security considerations addressed
- [ ] Performance requirements defined
- [ ] Rollback plan documented
- [ ] Dependencies clearly stated

### Validation Rules
<!-- Automated checks for this spec -->
- If `kind == 'docs'`: Documentation paths only
- If `kind == 'api'`: API contracts defined
- If `complexity == 'trivial'`: Omit architecture section
- If `profile == 'lite'`: Max 2 pages

---

## Expansion Profiles

### Profile Selection Guide

#### Lite Profile (≤2 pages)
**Use for**: Documentation, trivial bugs, small refactors  
**Includes**: Meta, Context, Scope, Requirements, AC, DoD  
**Omits**: Architecture, Rollout, Observability details

#### Standard Profile (≤4 pages)
**Use for**: Features, APIs, medium complexity  
**Includes**: All lite + Interfaces, Test Plan, Risks  
**Expands**: Requirements, Testing sections

#### Deep Profile (≤8 pages)
**Use for**: Critical features, architectural changes  
**Includes**: Everything  
**Expands**: All sections with detailed specifications

### Auto-Detection Rules
```yaml
if kind == 'docs': use 'lite'
if kind == 'bugfix' and complexity == 'trivial': use 'lite'
if kind == 'api': use 'standard' minimum
if kind == 'feature' and complexity == 'high': use 'deep'
if security_impact == true: use 'deep'
```

---

*Template Version: 1.2.0 | Based on ISO/IEC/IEEE 29148:2018 | CC BY 4.0 License*