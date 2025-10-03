# BDD Interview Blueprint (v1)

Use this structured interview to elicit rules, examples, and non‑functional criteria, then draft declarative Gherkin.

## Stages
1) Scope & Outcomes
- What user outcome must be true when this is done?
- What must NEVER happen (invariants)?
- What behavior must remain unchanged (back‑compat)?

2) Rules (Example Mapping)
- List atomic rules that govern the behavior.
- For each rule, provide 2–3 contrasting examples (edge/error included).

3) Data & Oracles
- Inputs, preconditions, and data shapes that matter.
- How do we decide PASS vs FAIL (oracle) without peeking at implementation?

4) NFRs
- Performance targets (latency/throughput)?
- Security/privacy constraints (authZ, PII, residency)?
- Reliability/availability expectations?

5) Draft Gherkin
- One behavior per scenario; minimal Given/When/Then.
- Declarative steps (intent), no UI click/typing.
- Add tags (see taxonomy below).

6) Review
- Apply the checklist; capture open questions.

## Tag Taxonomy (recommended)
- `@req-<ID>` e.g., `@req-KITA-12`
- `@feat-<slug>` e.g., `@feat-directory-search`
- `@persona-<role>` e.g., `@persona-parent`
- `@device-<type>` e.g., `@device-mobile`
- `@legal-<reg>` e.g., `@legal-FADP`
- `@risk-P<level>` e.g., `@risk-P2`
- Optional NFR: `@nfr-<domain>-<metric>-<op>-<value>` e.g., `@nfr-perf-p95-lte-2000ms`

## Minimal Gherkin Skeleton
```gherkin
@req-ACCT-123 @feat-payments @persona-user @device-mobile @risk-P2
Feature: <business capability>

  Rule: <domain rule>
  Scenario: <one behavior>
    Given <preconditions>
    When <action>
    Then <observable outcome>
```

## Review Checklist
- Single behavior per scenario; clear Then oracle.
- Declarative steps, not UI mechanics.
- Tags present: req/feat/persona; add NFR/legal when relevant.
- Include at least one edge/error example per rule.
