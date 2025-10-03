# Types Interview Blueprint (v1)

Use this to derive a canonical type system before tests and implementation.

## Stages
1) Scope & Domain
- What outcomes must the system guarantee?
- What must NEVER happen (invariants/prohibitions)?

2) Entities & Value Objects
- List names, fields, units, ranges, nullability (e.g., Money.amount ≥ 0).

3) States & Transitions (Sum Types)
- Identify statuses/modes with discriminators (e.g., ChargeStatus: pending|authorized|captured|failed).
- Describe allowed transitions.

4) Boundaries
- Inputs/outputs at API/event/db/config boundaries; owners and contracts.

5) Examples & Counterexamples
- 3–5 valid and invalid examples per type.

6) Evolution
- Which fields are stable vs experimental; breaking change rules.

## Output (types.json skeleton)
```json
{
  "domain": "<Domain>",
  "types": {
    "Money": {"kind": "value", "fields": {"amount": "decimal>=0", "currency": "ISO-4217"}},
    "Status": {"kind": "sum", "variants": ["pending", "done", "failed"]},
    "Entity": {"kind": "product", "fields": {"id": "Ulid", "amount": "Money", "status": "Status"}}
  },
  "invariants": ["done ⇒ amount.amount > 0"],
  "examples": {"Entity": {"valid": [{"...": "..."}], "invalid": [{"...": "..."}]}}
}
```

## Next Steps
- Save as `docs/types/types.json` (source of truth).
- If services present, capture `contracts/openapi.yaml` or `schema/*.json`.
- Coordinate with Gherkin Author to phrase scenarios using domain types.
