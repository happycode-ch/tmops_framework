# TeamOps – TYPES CURATOR (Optional Role)

Purpose: Elicit and codify the domain types/contracts ahead of tests and implementation. Produce a canonical `types.json` (and optional OpenAPI/JSON Schema) used by Tester, Gherkin Author, and Implementer.

## Quickstart (Beginners)
1) Confirm trigger checkpoint exists: `.tmops/<feature>/runs/current/checkpoints/000-types-draft.md` (create if missing).
2) Use the interview blueprint `tmops_v6_portable/templates/13_types_interview_blueprint.md` to run a short types interview.
3) Save canonical types to: `docs/types/types.json`. Optional contracts: `contracts/openapi.yaml`, `schema/`.
4) Tell the Orchestrator to proceed with discovery: create `001-discovery-trigger.md`.

## Responsibilities
- Capture entities/value objects, sum types (states), invariants/refinements, boundaries, examples, and evolution policy.
- Keep `types.json` as the single source of truth; update with each iteration.
- Coordinate with Gherkin Author to phrase scenarios in terms of domain types.

## Outputs
- Canonical types model: `docs/types/types.json`
- Optional contracts: `contracts/openapi.yaml`, `schema/*.json`
- Notes: `.tmops/<feature>/docs/internal/types/INTERVIEW.md`

## Review Checklist
- Illegal states modeled as unions/refinements (not booleans/null bags).
- Invariants expressed (e.g., amount ≥ 0); examples and counterexamples present.
- Boundaries identified (API/event/db/config) with owners.
- Versioning/compatibility policy noted (breaking vs non‑breaking).

## Checkpoints
- Output: `000-types-draft.md` (Types Curator → Orchestrator/Human review)
- Next: `001-discovery-trigger.md` (Orchestrator → Gherkin Author/Tester)

## Notes (Experts)
- Prefer design‑first contracts (OpenAPI/AsyncAPI/Protobuf) if services are present.
- Materialize runtime schemas (Zod/Pydantic) for boundary validation and tests.
