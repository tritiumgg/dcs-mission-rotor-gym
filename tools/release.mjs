// Publishes the built .miz files as a GitHub release for the version tag on HEAD.
// Run through mise: `mise run release:publish` (CI runs it on a pushed vX.Y.Z tag; it works
// the same locally with the GitHub CLI signed in).
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { version } from './version.mjs';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const v = version();
if (!/^\d+\.\d+\.\d+$/.test(v)) {
  console.error(`release: HEAD is not a clean release tag (version ${v}). Tag it first: git tag v1.2.3`);
  process.exit(1);
}
// Every variant built for this version (day and night).
const OUT = path.join(ROOT, 'out');
const mizFiles = fs.existsSync(OUT)
  ? fs.readdirSync(OUT).filter(f => f.endsWith(`_${v}.miz`)).map(f => path.join(OUT, f))
  : [];
if (mizFiles.length === 0) {
  console.error(`release: no out/*_${v}.miz; run \`mise run build\` first`);
  process.exit(1);
}
execFileSync('gh', ['release', 'create', `v${v}`, ...mizFiles, '--title', `Rotor Gym ${v}`, '--generate-notes', '--verify-tag'],
  { stdio: 'inherit', cwd: ROOT });
