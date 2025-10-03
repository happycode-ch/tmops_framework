#!/usr/bin/env node
/*
 TeamOps CLI (portable)
 - demo-gherkin: create a tiny curated doc and extract runnable features
 - bdd-scaffold: wrapper around tmops_tools/bdd_scaffold.sh
*/

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

function projectRoot() {
  // package root is tmops_v6_portable; project root is its parent
  return path.resolve(__dirname, '..', '..');
}

function portableDir() {
  return path.resolve(__dirname, '..');
}

function runBash(scriptPath, args = []) {
  return new Promise((resolve, reject) => {
    const proc = spawn('bash', [scriptPath, ...args], {
      stdio: 'inherit',
      cwd: portableDir()
    });
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

async function main() {
  const cmd = process.argv[2];
  if (!cmd || cmd === '-h' || cmd === '--help') {
    console.log('Usage: tmops <command>');
    console.log('  demo-gherkin     Create a tiny curated doc and extract features');
    console.log('  bdd-scaffold     Extract features from a curated doc (wrapper)');
    process.exit(0);
  }
  try {
    if (cmd === 'demo-gherkin') {
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

