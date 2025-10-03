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
  const args = process.argv.slice(3);
  if (args.length === 0) {
    console.log('Usage: tmops bdd-scaffold --from <file> [--stack js|python] [--feature-slug <slug>] [--out <dir>] [--gen-steps]');
    process.exit(1);
  }
  const scaffold = path.join(portableDir(), 'tmops_tools', 'bdd_scaffold.sh');
  await runBash(scaffold, args);
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
    console.log('  bdd-scaffold     Extract features from a curated doc (wrapper)');
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
