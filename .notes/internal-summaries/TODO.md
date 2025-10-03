# TeamOps To‑Do (Q4 2025)

Owner: Anthony Calek (@happycode)  
Scope: tmops framework, CLI, docs, packaging

## Release & Packaging
- [ ] Publish npm package `@happycode/tmops` v0.1.0
- [ ] Add GitHub Release notes + tag `v0.1.0`
- [ ] Add CI job: publish to npm on tag push (manual approve)
- [ ] Validate `npx @happycode/tmops demo-gherkin` on macOS/Linux/Windows (Git Bash)

## CLI & UX
- [ ] `tmops init --interactive`: add optional prompts for run‑type, feature name validation
- [ ] `tmops bdd-scaffold --interactive`: remember last answers (simple JSON cache)
- [ ] `tmops doctor`: detect Windows Shell and surface Git Bash guidance; add Python toolchain advisory
- [ ] Add `tmops --version` and `tmops --help` grouped examples

## BDD / Gherkin Flow
- [ ] Optional gherkin lint (style checks; advisory only)
- [ ] Step stub templates per stack (js/python) with example matchers
- [ ] Simple sample data fixtures under `tests/data/` for demo

## Docs & Onboarding
- [ ] README: add short video/GIF of 5‑minute demo
- [ ] docs/product/gherkin/README: add “good scenario” vs “imperative anti‑pattern” examples
- [ ] instance_instructions: cross‑link Gherkin Author → Tester → Implementer hand‑off

## Cross‑Platform & Portability
- [ ] Reduce bash dependency (Node port of `bdd_scaffold.sh`)
- [ ] Windows quickstart notes (Git Bash, path tips)

## Repo Hygiene
- [ ] Add CODEOWNERS and issue templates
- [ ] Add CONTRIBUTING.md (link to AGENTS.md + style guides)
- [ ] Periodically roll `.archive/*` entries by date

Notes
- Keep curated acceptance doc as source of truth; re‑extract features on change.
- Preserve docs subfolders per feature: `internal`, `external`, `archive`, `images`.
