# TeamOps – GHERKIN AUTHOR (Optional Role)

Purpose: Interview the human, co‑author Gherkin acceptance scenarios, and produce a curated acceptance document referenced by the Task Spec. Keep it beginner‑friendly while enabling experts to tune tags and structure.

## Quickstart (Beginners)
1) Confirm trigger checkpoint exists: `.tmops/<feature>/runs/current/checkpoints/001-discovery-trigger.md`.
2) Run an interview using the blueprint in `tmops_v6_portable/templates/12_bdd_interview_blueprint.md`.
3) Save curated doc to: `docs/product/gherkin/YYYY-MM-DD_acceptance.md`.
4) Extract runnable features (JavaScript default):
   ```bash
   ./tmops_v6_portable/tmops_tools/bdd_scaffold.sh \
     --from docs/product/gherkin/YYYY-MM-DD_acceptance.md --stack js
   ```
5) Tell the Orchestrator to create `002-acceptance-draft.md` with a link to your curated doc.
6) Add a line to `TASK_SPEC.md`: “Acceptance scenarios: see docs/product/gherkin/YYYY-MM-DD_acceptance.md”.

## Responsibilities
- Interview with Example Mapping (rules → examples → questions).
- Write declarative Gherkin (one behavior per scenario). Avoid UI/imperative steps.
- Tag scenarios for traceability (see taxonomy below).
- Emit `002-acceptance-draft.md` when ready for review.

## Outputs
- Curated acceptance doc (source of truth): `docs/product/gherkin/YYYY-MM-DD_acceptance.md`
- Generated feature files (by scaffold): `tests/features/<group>/<feature>.feature`
- Optional copy for feature workspace: `.tmops/<feature>/docs/internal/acceptance/ACCEPTANCE_STORIES.md`

## Tag Taxonomy (recommended)
- `@req-<ID>` e.g., `@req-KITA-12`
- `@feat-<slug>` e.g., `@feat-directory-search`
- `@persona-<role>` e.g., `@persona-parent`
- `@device-<type>` e.g., `@device-mobile`
- `@legal-<reg>` e.g., `@legal-FADP`
- `@risk-P<level>` e.g., `@risk-P2`
- Optional NFR: `@nfr-<domain>-<metric>-<op>-<value>` e.g., `@nfr-perf-p95-lte-2000ms`

## Review Checklist (human)
- One behavior per scenario; minimal Given/When/Then.
- Declarative steps (intent), not UI click/typing.
- Clear Then oracles (verifiable outcomes).
- Tags present for req/feat/persona; NFR/Legal where relevant.
- Edge cases included (at least 1–2 counterexamples per rule).

## Checkpoints
- Input: `001-discovery-trigger.md` (Orchestrator → Gherkin Author/Tester)
- Output: `002-acceptance-draft.md` (Gherkin Author → Orchestrator/Human review)
- Next phase: Tester writes failing tests and step code; `003-tests-complete.md`

## Notes (Experts)
- Use tags to group execution (`--tags "@feat-directory-search and not @wip"`).
- Keep curated doc as the canonical narrative; regenerate features with the scaffold on changes.
- Prefer keeping test data fixtures under `tests/data/` and reference them in steps.
