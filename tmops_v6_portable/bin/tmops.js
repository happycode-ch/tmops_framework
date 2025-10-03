#!/usr/bin/env node
/*
 TeamOps CLI (portable)
 - demo-gherkin: create a tiny curated doc and extract runnable features
 - bdd-scaffold: wrapper around tmops_tools/bdd_scaffold.sh
*/

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');
const readline = require('readline');

function projectRoot() {
  // package root is tmops_v6_portable; project root is its parent
  return path.resolve(__dirname, '..', '..');
}

function portableDir() {
  return path.resolve(__dirname, '..');
}

function runBash(scriptPath, args = []) {
  return new Promise((resolve, reject) => {
    const env = { ...process.env, TMOPS_PROJECT_ROOT: process.cwd() };
    const proc = spawn('bash', [scriptPath, ...args], { stdio: 'inherit', cwd: portableDir(), env });
    proc.on('exit', (code) => {
      if (code === 0) resolve(); else reject(new Error(`Exit ${code}`));
    });
  });
}

async function cmdDemoGherkin(argv) {
  const root = projectRoot();
  const docsDir = path.join(root, 'docs', 'product', 'gherkin');
  fs.mkdirSync(docsDir, { recursive: true });
  const demoPath = path.join(docsDir, 'acceptance_demo.md');
  const content = `# Acceptance Demo\n\n\n\u0060\u0060\u0060gherkin\n@feat-demo @req-DEMO-1 @persona-user @nfr-perf-p95-lte-2000ms\nFeature: Find things quickly\n  As a user\n  I want to search for items\n  So that I can find what I need fast\n\n  Scenario: Search returns results ranked by relevance\n    Given there are items available\n    When I search for \"coffee\"\n    Then I see results that include \"coffee\"\n    And the most relevant results appear first\n\n\u0060\u0060\u0060\n`;
  fs.writeFileSync(demoPath, content, 'utf8');
  console.log(`Created demo: ${path.relative(root, demoPath)}`);

  const args = ['--from', path.relative(portableDir(), demoPath), '--stack', 'js', '--gen-steps'];
  const scaffold = path.join(portableDir(), 'tmops_tools', 'bdd_scaffold.sh');
  await runBash(scaffold, args);
}

async function cmdBddScaffold(argv) {
  let args = process.argv.slice(3);
  const interactive = args.includes('--interactive');
  const scaffold = path.join(portableDir(), 'tmops_tools', 'bdd_scaffold.sh');

  if (!interactive) {
    if (args.length === 0) {
      console.log('Usage: tmops bdd-scaffold --from <file> [--stack js|python] [--feature-slug <slug>] [--out <dir>] [--gen-steps] [--interactive]');
      process.exit(1);
    }
    // normalize --from path to be relative to portableDir()
    const idx = args.indexOf('--from');
    if (idx >= 0 && idx + 1 < args.length) {
      const val = args[idx + 1];
      const abs = path.isAbsolute(val) ? val : path.join(process.cwd(), val);
      args[idx + 1] = path.relative(portableDir(), abs);
    }
    await runBash(scaffold, args);
    return;
  }

  // Interactive wizard
  // 1) Discover curated docs
  const root = process.cwd();
  const defaultDir = path.join(root, 'docs', 'product', 'gherkin');
  let candidates = [];
  try {
    if (fs.existsSync(defaultDir)) {
      candidates = fs.readdirSync(defaultDir)
        .filter(f => f.endsWith('.md'))
        .map(f => path.join(defaultDir, f));
    }
  } catch {}

  let chosen = '';
  if (candidates.length > 0) {
    console.log('Found curated docs:');
    candidates.forEach((f, i) => console.log(`  [${i+1}] ${path.relative(root, f)}`));
    const pick = await askInput('Pick a file by number or enter a path', '1');
    const idx = parseInt(pick, 10);
    if (!isNaN(idx) && idx >= 1 && idx <= candidates.length) {
      chosen = candidates[idx-1];
    } else {
      chosen = path.isAbsolute(pick) ? pick : path.join(root, pick);
    }
  } else {
    chosen = await askInput('Path to curated acceptance doc (Markdown)', 'docs/product/gherkin/acceptance_demo.md');
    chosen = path.isAbsolute(chosen) ? chosen : path.join(root, chosen);
  }
  if (!fs.existsSync(chosen)) {
    console.error(`ERROR: File not found: ${chosen}`);
    process.exit(1);
  }

  // 2) Optional check for gherkin blocks
  const content = fs.readFileSync(chosen, 'utf8');
  const blockRe = /```gherkin[\s\S]*?```/g;
  const blocks = content.match(blockRe) || [];
  if (blocks.length === 0) {
    console.warn('WARNING: No ```gherkin blocks found. The scaffold may not create any feature files.');
  } else {
    console.log(`Detected ${blocks.length} gherkin block(s).`);
  }

  // 3) Stack selection
  const stackAns = await askInput('Stack (js/python)', 'js');
  const stack = (stackAns || 'js').toLowerCase();

  // 4) Feature slug suggestion
  const base = path.basename(chosen, path.extname(chosen));
  const suggestedSlug = base.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
  const featureSlug = await askInput('Feature group slug', suggestedSlug);

  // 5) Output dir suggestion
  const suggestedOut = path.join(root, 'tests', 'features', featureSlug);
  const outDir = await askInput('Output directory for .feature files', path.relative(root, suggestedOut));

  // 6) Step stubs
  const genSteps = await askYN('Generate step stubs?', true);

  // Build args
  const callArgs = ['--from', path.relative(portableDir(), chosen), '--stack', stack, '--feature-slug', featureSlug, '--out', outDir];
  if (genSteps) callArgs.push('--gen-steps');

  await runBash(scaffold, callArgs);

  const runCmd = stack === 'python' ? 'pytest -q' : 'npx cucumber-js tests/features';
  const runNow = await askYN(`Run tests now? (${runCmd})`, false);
  if (runNow) {
    const [cmd, ...cmdArgs] = runCmd.split(' ');
    await new Promise((resolve) => {
      const proc = spawn(cmd, cmdArgs, { stdio: 'inherit', cwd: root });
      proc.on('exit', () => resolve());
    });
  } else {
    console.log(`Next: ${runCmd}`);
  }
}

function rl() {
  return readline.createInterface({ input: process.stdin, output: process.stdout });
}

async function askYN(q, def = true) {
  const r = rl();
  const hint = def ? 'Y/n' : 'y/N';
  return new Promise((resolve) => {
    r.question(`${q} [${hint}]: `, (ans) => {
      r.close();
      const a = ans.trim().toLowerCase();
      if (!a) return resolve(def);
      if (['y', 'yes'].includes(a)) return resolve(true);
      if (['n', 'no'].includes(a)) return resolve(false);
      resolve(def);
    });
  });
}

async function askInput(q, def = '') {
  const r = rl();
  return new Promise((resolve) => {
    r.question(`${q}${def ? ` [${def}]` : ''}: `, (ans) => {
      r.close();
      const v = ans.trim();
      resolve(v || def);
    });
  });
}

async function cmdInit(argv) {
  const args = process.argv.slice(3);
  let feature = args[0];
  let runType = 'initial';
  const flags = [];

  // detect if interactive
  const interactive = args.includes('--interactive') || args.length < 1;
  if (interactive) {
    feature = await askInput('Feature name (kebab-case)', feature || 'demo');
    const useCurrent = await askYN('Use current git branch?', true);
    const skipBranch = !useCurrent ? await askYN('Skip branch operations?', false) : false;
    let branchName = '';
    if (!useCurrent && !skipBranch) {
      branchName = await askInput('Branch name', `feature/${feature}`);
    }
    if (useCurrent) flags.push('--use-current-branch');
    if (skipBranch) flags.push('--skip-branch');
    if (branchName) flags.push('--branch', branchName);
  } else {
    // non-interactive passthrough
    if (!feature) {
      console.error('Usage: tmops init <feature> [run-type] [--use-current-branch|--skip-branch|--branch <name>]');
      process.exit(1);
    }
    if (args[1] && !args[1].startsWith('--')) runType = args[1];
    flags.push(...args.slice(2));
  }

  const script = path.join(portableDir(), 'tmops_tools', 'init_feature_multi.sh');
  const callArgs = [feature, runType, ...flags];
  await runBash(script, callArgs);
}

async function cmdRunManager(argv) {
  const args = process.argv.slice(3);
  if (args.length < 2) {
    console.log('Usage: tmops run-manager <feature> <list|new|clear|switch> [options]');
    process.exit(1);
  }
  const script = path.join(portableDir(), 'tmops_tools', 'run_manager.sh');
  await runBash(script, args);
}

async function main() {
  const cmd = process.argv[2];
  if (!cmd || cmd === '-h' || cmd === '--help') {
    console.log('Usage: tmops <command>');
    console.log('  init             Initialize a feature (supports --interactive)');
    console.log('  run-manager      Manage runs: list/new/clear/switch');
    console.log('  demo-gherkin     Create a tiny curated doc and extract features');
    console.log('  bdd-scaffold     Extract features from a curated doc (supports --interactive)');
    console.log('  doctor           Environment checks and suggestions');
    console.log('  types-init       Scaffold types.json and types docs');
    console.log('  types-materialize  Create minimal TS/Py stubs from types (placeholder)');
    console.log('  types-gate       Print suggested type gates and checks (placeholder)');
    console.log('  demo-types-first Create a tiny types.json and minimal stubs/tests');
    process.exit(0);
  }
  try {
    if (cmd === 'init') {
      await cmdInit(process.argv.slice(3));
    } else if (cmd === 'run-manager') {
      await cmdRunManager(process.argv.slice(3));
    } else if (cmd === 'demo-gherkin') {
      await cmdDemoGherkin(process.argv.slice(3));
    } else if (cmd === 'bdd-scaffold') {
      await cmdBddScaffold(process.argv.slice(3));
    } else if (cmd === 'doctor') {
      await cmdDoctor();
    } else if (cmd === 'types-init') {
      await cmdTypesInit();
  } else if (cmd === 'types-materialize') {
      // parse optional --stack <js|python>
      const args = process.argv.slice(3);
      let stackArg = null;
      const idx = args.indexOf('--stack');
      if (idx >= 0 && idx + 1 < args.length) {
        stackArg = args[idx + 1];
      }
      await cmdTypesMaterialize({ stack: stackArg });
    } else if (cmd === 'types-gate') {
      await cmdTypesGate();
    } else if (cmd === 'demo-types-first') {
      await cmdDemoTypesFirst();
    } else {
      console.error(`Unknown command: ${cmd}`);
      process.exit(1);
    }
  } catch (err) {
    console.error(err.message || err);
    process.exit(1);
  }
}

main();

// --------------------
// Doctor
async function cmdDoctor() {
  const results = [];
  function add(name, ok, fix) { results.push({ name, ok, fix }); }

  // Node
  const nodeOk = (() => {
    try {
      const v = process.versions.node.split('.')[0];
      return parseInt(v, 10) >= 16;
    } catch { return false; }
  })();
  add('Node >= 16', nodeOk, 'Install Node 16+ (https://nodejs.org/)');

  // bash
  const bashOk = await new Promise((resolve) => {
    const p = spawn(process.platform === 'win32' ? 'bash.exe' : 'bash', ['-lc', 'echo ok'], { stdio: 'ignore' });
    p.on('exit', code => resolve(code === 0));
    p.on('error', () => resolve(false));
  });
  add('Bash available', bashOk, 'Install Git Bash (Windows) or ensure bash is in PATH');

  // git
  const gitOk = await new Promise((resolve) => {
    const p = spawn('git', ['--version'], { stdio: 'ignore' });
    p.on('exit', code => resolve(code === 0));
    p.on('error', () => resolve(false));
  });
  add('Git available', gitOk, 'Install Git and ensure it is in PATH');

  // repo
  const inRepo = await new Promise((resolve) => {
    const p = spawn('git', ['rev-parse', '--is-inside-work-tree'], { stdio: 'ignore' });
    p.on('exit', code => resolve(code === 0));
    p.on('error', () => resolve(false));
  });
  add('Inside a Git repository', inRepo, 'Run tmops inside a Git repo');

  // write access
  const canWrite = (() => {
    try {
      const probe = path.join(process.cwd(), `.tmops_write_probe_${Date.now()}`);
      fs.writeFileSync(probe, 'ok');
      fs.unlinkSync(probe);
      return true;
    } catch { return false; }
  })();
  add('Write access to current directory', canWrite, 'Check permissions for current directory');

  // scripts executable
  const scripts = [
    'tmops_tools/init_feature_multi.sh',
    'tmops_tools/run_manager.sh',
    'tmops_tools/bdd_scaffold.sh',
    'tmops_tools/init_preflight.sh',
  ];
  const scriptChecks = scripts.map(rel => {
    const full = path.join(portableDir(), rel);
    try { fs.accessSync(full, fs.constants.X_OK); return true; } catch { return false; }
  });
  add('Core scripts executable', scriptChecks.every(Boolean), 'Ensure executable bit on tmops_v6_portable/tmops_tools/*.sh');

  // BDD toolchain (advisory)
  const hasCucumber = fs.existsSync(path.join(process.cwd(), 'node_modules', '@cucumber', 'cucumber'));
  add('JS BDD: @cucumber/cucumber present (advisory)', hasCucumber, 'npm i -D @cucumber/cucumber');

  // Summarize
  const criticalOk = nodeOk && bashOk && gitOk && canWrite;
  console.log('\nTMOPS Doctor Report');
  results.forEach(r => console.log(`${r.ok ? '✅' : '❌'} ${r.name}${r.ok ? '' : ` — ${r.fix}`}`));
  process.exit(criticalOk ? 0 : 1);
}

// --------------------
// Types-first commands
async function cmdTypesInit() {
  const root = process.cwd();
  const typesDir = path.join(root, 'docs', 'types');
  fs.mkdirSync(typesDir, { recursive: true });
  const typesPath = path.join(typesDir, 'types.json');
  if (!fs.existsSync(typesPath)) {
    const skeleton = {
      domain: "Demo",
      types: {
        Money: { kind: "value", fields: { amount: "decimal>=0", currency: "ISO-4217" } },
        Status: { kind: "sum", variants: ["pending", "done", "failed"] },
        Entity: { kind: "product", fields: { id: "Ulid", amount: "Money", status: "Status" } }
      },
      invariants: ["done ⇒ amount.amount > 0"],
      examples: { Entity: { valid: [{ id: "01H..", amount: { amount: 10, currency: "CHF" }, status: "done" }], invalid: [] } }
    };
    fs.writeFileSync(typesPath, JSON.stringify(skeleton, null, 2));
    console.log(`Created ${path.relative(root, typesPath)}`);
  } else {
    console.log(`Found existing ${path.relative(root, typesPath)}`);
  }
  const typesReadme = path.join(typesDir, 'README.md');
  if (!fs.existsSync(typesReadme)) {
    fs.writeFileSync(typesReadme, `# Types (Source of Truth)\n\n- Edit types.json via the Types Curator flow.\n- Optional: add OpenAPI at contracts/openapi.yaml or JSON Schema under schema/.\n- Bind Gherkin and tests to these types.\n`);
    console.log(`Created ${path.relative(root, typesReadme)}`);
  }
  console.log('\nNext: tmops types-materialize  # create stubs');
}

async function cmdTypesMaterialize(opts = {}) {
  const root = process.cwd();
  let stack = opts.stack;
  if (!stack) {
    if (!process.stdin.isTTY) {
      stack = 'js';
      console.log('Non-interactive mode detected, using stack: js');
    } else {
      stack = (await askInput('Stack to scaffold (js/python)', 'js')).toLowerCase();
    }
  }
  if (stack === 'js') {
    const target = path.join(root, 'src', 'types');
    fs.mkdirSync(target, { recursive: true });
    const file = path.join(target, 'index.ts');
    if (!fs.existsSync(file)) {
      fs.writeFileSync(file, `import { z } from 'zod';\n\nexport const MoneySchema = z.object({ amount: z.number().nonnegative(), currency: z.string() });\nexport type Money = z.infer<typeof MoneySchema>;\n`);
      console.log(`Created ${path.relative(root, file)}`);
    }
    const testDir = path.join(root, 'tests', 'types');
    fs.mkdirSync(testDir, { recursive: true });
    const testFile = path.join(testDir, 'property.money.test.ts');
    if (!fs.existsSync(testFile)) {
      fs.writeFileSync(testFile, `import fc from 'fast-check';\nimport { MoneySchema } from '../../src/types';\n\ntest('amount is nonnegative', () => {\n  fc.assert(fc.property(fc.float({ noDefaultInfinity: true }), (x) => {\n    const amt = Math.abs(x);\n    const parsed = MoneySchema.safeParse({ amount: amt, currency: 'CHF' });\n    return parsed.success;\n  }));\n});\n`);
      console.log(`Created ${path.relative(root, testFile)}`);
    }
  } else if (stack === 'python') {
    const target = path.join(root, 'src', 'types');
    fs.mkdirSync(target, { recursive: true });
    const file = path.join(target, 'models.py');
    if (!fs.existsSync(file)) {
      fs.writeFileSync(file, `from pydantic import BaseModel, Field\n\nclass Money(BaseModel):\n    amount: float = Field(ge=0)\n    currency: str\n`);
      console.log(`Created ${path.relative(root, file)}`);
    }
    const testDir = path.join(root, 'tests', 'types');
    fs.mkdirSync(testDir, { recursive: true });
    const testFile = path.join(testDir, 'test_property_money.py');
    if (!fs.existsSync(testFile)) {
      fs.writeFileSync(testFile, `from hypothesis import given, strategies as st\nfrom src.types.models import Money\n\n@given(st.floats(allow_infinity=False, allow_nan=False).map(abs))\ndef test_amount_nonnegative(x):\n    m = Money(amount=x, currency='CHF')\n    assert m.amount >= 0\n`);
      console.log(`Created ${path.relative(root, testFile)}`);
    }
  } else {
    console.log('Unknown stack. Use js or python.');
  }
  console.log('Next: implement strict type gates in your CI. See tmops types-gate');
}

async function cmdTypesGate() {
  console.log('Suggested gates (configure in your CI):');
  console.log('- TypeScript: tsc --noEmit, ESLint no-explicit-any + strict-boolean, type-coverage >= 95%');
  console.log('- Python: pyright --strict --verifytypes <pkg> >= 90%, mypy --strict with Any budget');
  console.log('- Contracts: oasdiff (OpenAPI breaking) + Spectral lint (if applicable)');
}

async function cmdDemoTypesFirst() {
  await cmdTypesInit();
  await cmdTypesMaterialize({ stack: 'js' });
  console.log('\nDemo ready. Run your tests, then bind your Gherkin steps to these types.');
}
