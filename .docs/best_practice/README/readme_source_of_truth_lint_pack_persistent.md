# README Source-of-Truth + Lint Pack (Persistent)

## README AGENT INSTRUCTIONS:

## Purpose
This template instructs coding agents on **how to apply the README Source-of-Truth + Lint Pack** and the **Readme Spec Template** consistently across projects. Attach this at the head of the README Source-of-Truth + Lint Pack document. Reference the Readme Spec Template JSON when generating or linting READMEs.

---

## Instructions for Agents

1. **Inputs Required**
   - `readme_spec` (from the Readme Spec Template JSON)
   - `project_facts` (basic metadata: project name, tagline, language/runtime, install instructions, usage examples, env vars, license, contribution guidelines, etc.)

2. **Core Task**
   - Generate a `README.md` that follows the `ordering` and `sections` in `readme_spec`.
   - Apply `conventions` for headings, code fences, images, and line length.
   - Ensure all `validation.required_sections` are present unless explicitly excluded by project facts.

3. **Pruning / Relevance Rules**
   - Skip any section with no data from `project_facts`.
   - Do not insert placeholders like “TBD” or empty headings.
   - Omit duplicate information.
   - Include only sections that help a new user install, run, learn, or contribute.

4. **Heuristics for Optional Sections**
   - **Examples**: include if code or CLI commands exist.
   - **Configuration / API**: include if env vars, config files, or API surface exists.
   - **Project Structure**: include if repo has multiple directories worth describing.
   - **Roadmap / Status**: include if project is not yet stable or has known issues.
   - **Security**: include if policy or sensitive data handling exists.
   - **FAQ**: include only if common recurring questions are known.
   - **Images**: include screenshots or diagrams if files exist.

5. **Linting / Validation**
   - Use the **README Lint Pack** to enforce compliance.
   - Run `npm run lint:md` to check; `npm run lint:md:fix` to auto-fix formatting.
   - CI should fail if validation errors remain (missing required sections, wrong heading order, missing LICENSE, unresolved links, etc.).

6. **Output Rules**
   - Produce clean `README.md` in Markdown.
   - One `# H1` at top with title + tagline.
   - Insert ToC only if 4+ H2 sections remain.
   - Code blocks must declare language (e.g., ```bash, ```python).
   - Images must use relative paths + alt text.

7. **Success Criteria**
   - A first-time user can install and run the project from README alone.
   - No irrelevant or empty sections.
   - Links and assets resolve correctly.
   - License matches SPDX ID and exists in repo.

---

## Agent Output Template
```
Generate README for project:

readme_spec:
```json
{{READMESPEC_JSON}}
```

project_facts:
```json
{{PROJECTFACTS_JSON}}
```

Return ONLY the final README.md content.
```

---

## 1) README Spec JSON (source of truth)
```json
{
  "readme_spec": {
    "name": "Professional README Spec",
    "version": "1.0.0",
    "influences": [
      "standard-readme",
      "github-readme-conventions"
    ],
    "ordering": [
      "title",
      "badges",
      "description",
      "table_of_contents",
      "overview",
      "installation",
      "usage",
      "examples",
      "configuration_api",
      "project_structure",
      "roadmap_status",
      "contributing",
      "security",
      "license",
      "authors_maintainers",
      "acknowledgements",
      "faq",
      "links"
    ],
    "sections": {
      "title": {
        "required": true,
        "format": "# {project_name} — {tagline}",
        "notes": "Single H1. Keep tagline to one line."
      },
      "badges": {
        "required": false,
        "items": [
          "ci_status",
          "coverage",
          "package_version",
          "license",
          "downloads"
        ],
        "notes": "Use shields.io. Place immediately under title."
      },
      "description": {
        "required": true,
        "content": {
          "what": "One-paragraph plain-English explanation.",
          "why": "Problem it solves and who it’s for.",
          "differentiators": "2–3 bullets on what makes it different."
        }
      },
      "table_of_contents": {
        "required": false,
        "autogenerate_hint": true,
        "notes": "Use GitHub autolinked headings. Include only H2/H3 anchors."
      },
      "overview": {
        "required": true,
        "content": {
          "features": ["bullet_1", "bullet_2", "bullet_3"],
          "screenshot": "relative_path/to/image.png",
          "demo": "url_or_relative_link"
        },
        "notes": "Screenshots use relative paths; keep under /docs/ or /assets/."
      },
      "installation": {
        "required": true,
        "content": {
          "prerequisites": ["node>=18", "python>=3.11"],
          "steps": [
            "git clone {repo_url}",
            "cd {repo_dir}",
            "{package_manager_install_cmd}"
          ]
        },
        "code_lang": "bash"
      },
      "usage": {
        "required": true,
        "content": {
          "quickstart": "Minimal runnable example",
          "cli_or_api": "Primary command or function call",
          "env_vars": ["EXAMPLE_API_KEY", "EXAMPLE_ENV"]
        }
      },
      "examples": {
        "required": false,
        "content": [
          { "title": "Basic", "code_lang": "bash", "code": "example command or snippet" },
          { "title": "Programmatic", "code_lang": "python", "code": "example code" }
        ],
        "notes": "Prefer 1–2 concise examples; link to /examples for more."
      },
      "configuration_api": {
        "required": false,
        "content": {
          "config_files": ["app.config.{json|yaml}"],
          "env_reference": [
            { "name": "PORT", "default": "3000", "desc": "HTTP port" },
            { "name": "LOG_LEVEL", "default": "info", "desc": "debug|info|warn|error" }
          ],
          "primary_api": [
            { "symbol": "init()", "desc": "Initialize library" },
            { "symbol": "run(opts)", "desc": "Start service" }
          ]
        }
      },
      "project_structure": {
        "required": false,
        "content": [
          { "path": "src/", "desc": "Source code" },
          { "path": "tests/", "desc": "Unit/integration tests" },
          { "path": "docs/", "desc": "Extended docs and images" }
        ]
      },
      "roadmap_status": {
        "required": false,
        "content": {
          "status": "alpha|beta|stable",
          "next": ["item_1", "item_2"],
          "known_issues": ["issue_1", "issue_2"]
        }
      },
      "contributing": {
        "required": true,
        "content": {
          "guidelines_link": "CONTRIBUTING.md",
          "dev_setup": ["make setup", "make test"],
          "code_style": "ruff/black/prettier/eslint",
          "branching": "feat/*, fix/*; PRs require CI green"
        }
      },
      "security": {
        "required": false,
        "content": {
          "policy_link": "SECURITY.md",
          "contact": "security@example.com",
          "disclosure": "Responsible disclosure policy summary"
        }
      },
      "license": {
        "required": true,
        "content": {
          "spdx_id": "MIT",
          "file": "LICENSE"
        }
      },
      "authors_maintainers": {
        "required": true,
        "content": [
          { "name": "Your Name", "handle": "@yourhandle", "email": "you@example.com" }
        ]
      },
      "acknowledgements": {
        "required": false,
        "content": ["lib_or_project_1", "inspiration_2"]
      },
      "faq": {
        "required": false,
        "content": [
          { "q": "Does it run on Windows?", "a": "Yes, via WSL or native." }
        ]
      },
      "links": {
        "required": false,
        "content": {
          "homepage": "https://example.com",
          "docs": "https://example.com/docs",
          "changelog": "CHANGELOG.md",
          "issues": "https://github.com/org/repo/issues"
        }
      }
    },
    "conventions": {
      "markdown": {
        "heading_style": "ATX",
        "code_fences": "```lang",
        "link_style": "relative preferred",
        "badges": "top-only",
        "max_line_length": 100
      },
      "toc": {
        "include_levels": [2, 3],
        "exclude": ["title", "badges"]
      },
      "images": {
        "relative_paths": true,
        "folder": "docs/assets",
        "alt_text_required": true
      }
    },
    "validation": {
      "required_sections": [
        "title",
        "description",
        "overview",
        "installation",
        "usage",
        "contributing",
        "license",
        "authors_maintainers"
      ],
      "lint_rules": [
        "must_have_single_h1",
        "all_code_blocks_have_language",
        "all_images_have_alt",
        "relative_links_resolve",
        "license_file_exists"
      ]
    },
    "generators": {
      "from_this_spec": {
        "readme_path": "README.md",
        "supporting_files": ["LICENSE", "CONTRIBUTING.md", "SECURITY.md", "CHANGELOG.md"]
      }
    },
    "placeholders": {
      "project_name": "MyProject",
      "tagline": "Concise one-liner",
      "repo_url": "https://github.com/org/repo",
      "repo_dir": "repo",
      "package_manager_install_cmd": "npm ci"
    }
  }
}
```

---

## 2) Prompt JSON (agent instructions)
```json
{
  "system": "You are a senior technical writer-bot. Generate a professional README from the provided JSON spec and project facts. Include only sections that are relevant and non-empty. Be concise, correct, and consistent.",
  "instructions": {
    "goal": "Produce README.md content that follows the readme_spec ordering and conventions while omitting irrelevant sections.",
    "inputs": [
      "readme_spec (the JSON spec you defined)",
      "project_facts (name, tagline, repo type, language/runtime, packaging, CLI/API presence, env vars, images, docs links, status, license, contribution policy, etc.)"
    ],
    "relevance_rules": [
      "Drop a section if: it has no concrete content from project_facts; or it duplicates another section; or it adds zero actionable value to a first-time user.",
      "Keep only the smallest set of sections that enable install → run → learn → contribute.",
      "Prefer linking to existing files (CONTRIBUTING.md, SECURITY.md, CHANGELOG.md) over restating them."
    ],
    "prune_logic_pseudocode": "for section in readme_spec.ordering:\n  data = resolve(section, readme_spec.sections[section], project_facts)\n  if is_empty(data) or not is_applicable(section, project_facts):\n    continue\n  render(section, data)",
    "applicability_heuristics": {
      "examples": "Include only if you have runnable commands or minimal code.",
      "configuration_api": "Include if there are env vars, config files, or public API surface.",
      "project_structure": "Include if repo has multiple top-level dirs worth explaining.",
      "roadmap_status": "Include if status != 'stable' OR next/known_issues are non-empty.",
      "security": "Include if security contact/policy exists or package handles sensitive data.",
      "faq": "Include only if there are recurring user questions.",
      "images": "Only if screenshots or diagrams exist at the given relative paths."
    },
    "style_rules": [
      "Single H1 title.",
      "Short paragraphs, imperative voice.",
      "All code blocks specify language.",
      "Relative links when possible; do not fabricate links or badges.",
      "No empty headings; never write 'TBD' or placeholders."
    ],
    "output_format": {
      "type": "markdown",
      "file": "README.md",
      "sections": "Emit in spec order after pruning. Insert a minimal ToC only if >= 4 H2 sections remain."
    },
    "success_criteria": [
      "Installs and runs from README alone.",
      "No empty/irrelevant sections.",
      "All links and paths resolve within repo.",
      "License is present and matches SPDX."
    ]
  },
  "user_template": "Generate README for project:\n\nreadme_spec:\n```\n{{READMESPEC_JSON}}\n```\n\nproject_facts:\n```\n{{PROJECTFACTS_JSON}}\n```\n\nReturn ONLY the final README.md content."
}
```

---

## 3) README Lint Pack (remark)

### 3.1 `.remarkrc.mjs`
```js
// .remarkrc.mjs
import remarkLint from 'remark-preset-lint-recommended';
import remarkReadmeSpec from './remark-readme-spec.js';

export default {
  plugins: [
    remarkLint,
    [remarkReadmeSpec, {
      specPath: 'readme_spec.json',
      sectionHeadingMap: {
        "configuration_api": "Configuration / API",
        "project_structure": "Project Structure",
        "roadmap_status": "Roadmap / Status",
        "authors_maintainers": "Authors / Maintainers"
      }
    }]
  ]
};
```

### 3.2 `remark-readme-spec.js`
```js
import {readFileSync, existsSync} from 'node:fs';
import path from 'node:path';
import {visit} from 'unist-util-visit';

export default function remarkReadmeSpec(options = {}) {
  const { specPath = 'readme_spec.json', sectionHeadingMap = {} } = options;
  const cwd = process.cwd();

  if (!existsSync(path.resolve(cwd, specPath))) {
    throw new Error(`[remark-readme-spec] Spec file not found at ${specPath}`);
  }
  const spec = JSON.parse(readFileSync(path.resolve(cwd, specPath), 'utf8')).readme_spec;

  function rule(tree, file) {
    const headings = [];
    const images = [];
    const links = [];
    const codeBlocks = [];
    const h1s = [];

    visit(tree, (node) => {
      if (node.type === 'heading') {
        const text = toText(node);
        const depth = node.depth;
        headings.push({depth, text});
        if (depth === 1) h1s.push(text);
      }
      if (node.type === 'image') images.push(node);
      if (node.type === 'link') links.push(node);
      if (node.type === 'code') codeBlocks.push(node);
    });

    if (spec.validation.lint_rules.includes('must_have_single_h1')) {
      if (h1s.length !== 1) file.message(`Expected exactly one H1 title, found ${h1s.length}.`, tree);
    }

    const requiredKeys = spec.validation.required_sections || [];
    const presentH2 = headings.filter(h => h.depth === 2).map(h => normalize(h.text));

    const keyToTitle = (key) => sectionHeadingMap[key] || keyToDefaultTitle(key);
    const missingRequired = requiredKeys.filter((key) => {
      if (key === 'title') return h1s.length === 0;
      const expected = normalize(keyToTitle(key));
      return !presentH2.includes(expected);
    });
    if (missingRequired.length > 0) file.message(`Missing required sections: ${missingRequired.join(', ')}`, tree);

    const orderKeys = spec.ordering.filter(k => !['title','badges','table_of_contents'].includes(k));
    const expectedOrder = orderKeys.map(keyToTitle).map(normalize);
    const actualOrder = presentH2;
    const filteredExpected = expectedOrder.filter(e => actualOrder.includes(e));
    const isInOrder = isSubsequence(actualOrder, filteredExpected);
    if (!isInOrder) file.message(`Sections out of order. Expected order (present subset): ${filteredExpected.join(' → ')}`, tree);

    if (spec.validation.lint_rules.includes('all_code_blocks_have_language')) {
      const noLang = codeBlocks.filter(c => !c.lang);
      if (noLang.length > 0) file.message(`All code blocks must specify a language. Found ${noLang.length} without lang.`, tree);
    }

    if (spec.validation.lint_rules.includes('all_images_have_alt')) {
      const missingAlt = images.filter(img => !(img.alt && img.alt.trim().length > 0));
      if (missingAlt.length > 0) file.message(`All images must have non-empty alt text. Missing: ${missingAlt.length}.`, tree);
    }

    if (spec.validation.lint_rules.includes('relative_links_resolve')) {
      const unresolved = links.filter(l => {
        const url = String(l.url || '');
        if (!url || url.startsWith('http') || url.startsWith('mailto:') || url.startsWith('#')) return false;
        const p = url.split('#')[0];
        return !existsSync(path.resolve(cwd, p));
      });
      if (unresolved.length > 0) {
        const list = unresolved.map(l => l.url).slice(0,5).join(', ');
        file.message(`Some relative links do not resolve on disk: ${list}${unresolved.length>5?' …':''}`, tree);
      }
    }

    if (spec.validation.lint_rules.includes('license_file_exists')) {
      const licensePath = spec.sections.license?.content?.file || 'LICENSE';
      if (!existsSync(path.resolve(cwd, licensePath))) file.message(`LICENSE file not found at ${licensePath}.`, tree);
    }
  }

  return rule;
}

function toText(node) {
  let s = '';
  visit(node, 'text', (n) => { s += n.value; });
  return s.trim();
}
function normalize(s) {
  return String(s).toLowerCase().replace(/\s+/g, ' ').trim();
}
function keyToDefaultTitle(key) {
  const map = {
    description: 'Description',
    overview: 'Overview',
    installation: 'Installation',
    usage: 'Usage',
    examples: 'Examples',
    configuration_api: 'Configuration / API',
    project_structure: 'Project Structure',
    roadmap_status: 'Roadmap / Status',
    contributing: 'Contributing',
    security: 'Security',
    license: 'License',
    authors_maintainers: 'Authors / Maintainers',
    acknowledgements: 'Acknowledgements',
    faq: 'FAQ',
    links: 'Links'
  };
  return map[key] || key;
}
function isSubsequence(arr, targetOrder) {
  let i = 0;
  for (const el of arr) {
    if (el === targetOrder[i]) i++;
    if (i === targetOrder.length) return true;
  }
  return targetOrder.length === 0;
}
```

### 3.3 `package.json`
```json
{
  "name": "readme-lint",
  "private": true,
  "type": "module",
  "devDependencies": {
    "remark": "^15.0.1",
    "remark-cli": "^11.0.0",
    "remark-preset-lint-recommended": "^6.1.0",
    "unist-util-visit": "^5.0.0"
  },
  "scripts": {
    "lint:md": "remark -q README.md",
    "lint:md:fix": "remark -q README.md -o"
  }
}
```

### 3.4 Usage
```md
# README Lint Setup

## Install (Node 18+)
```bash
npm i -D remark remark-cli remark-preset-lint-recommended unist-util-visit
```

## Files
- `readme_spec.json` — your spec
- `remark-readme-spec.js` — custom remark rule enforcing the spec
- `.remarkrc.mjs` — remark config
- `package.json` — includes scripts

## Run
```bash
npm run lint:md
# or auto-fix some formatting issues
npm run lint:md:fix
```
```

---

**Optional next:** I can add a GitHub Actions workflow to run the README linter on PRs. Say the word and I’ll drop it in here.

