# Product Acceptance (Gherkin) – Curated Source

This folder stores curated acceptance documents that contain Gherkin code blocks for product-level features.

Recommended naming: `YYYY-MM-DD_acceptance.md`

Quickstart

1) Create/update a curated doc here with ```gherkin scenarios.
2) Extract runnable features:
   ```bash
   ./tmops_v6_portable/tmops_tools/bdd_scaffold.sh \
     --from docs/product/gherkin/YYYY-MM-DD_acceptance.md --stack js
   ```
3) Run tests:
   ```bash
   npx cucumber-js tests/features
   ```
4) Link the curated doc in the Task Spec.

Notes
- Keep scenario steps declarative (intent), not UI actions.
- Tag scenarios for traceability (e.g., @req-*, @feat-*, @persona-*).
- Test data fixtures should live under `tests/data/`.

Advanced
- Optional Gherkin Author role instructions: `tmops_v6_portable/instance_instructions/02a_gherkin_author.md`
- Use tags to filter runs: `npx cucumber-js --tags "@feat-directory-search and not @wip"`
- Bind steps to runtime schemas (Zod/Pydantic) for input validation before executing behavior.
