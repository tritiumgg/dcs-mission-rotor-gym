// Builds out/<variant>_<version>.miz for every variant in src/variants.lua (day and
// night), from mission/ plus the generated content in src/. Run through mise:
// `mise run build`. The version comes from git tags (see version.mjs).
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { version } from './version.mjs';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const SOURCE = path.join(ROOT, 'mission');
const GENERATED = path.join(ROOT, '.build', 'variants');
const OUT = path.join(ROOT, 'out');
const BUILD_LUA = path.join(ROOT, 'src', 'build.lua');

const v = version();
const files = execFileSync('lua', [BUILD_LUA, '--list'], { encoding: 'utf8', cwd: ROOT }).split(/\r?\n/).filter(Boolean);

fs.rmSync(GENERATED, { recursive: true, force: true });
for (const file of files) fs.mkdirSync(path.join(GENERATED, file, 'l10n', 'DEFAULT'), { recursive: true });
execFileSync('lua', [BUILD_LUA, SOURCE, GENERATED], { stdio: 'inherit', cwd: ROOT });

const built = [];
for (const file of files) {
  const miz = path.join(OUT, `${file}_${v}.miz`);
  execFileSync('node', [path.join(ROOT, 'tools', 'miz.mjs'), 'pack', SOURCE, path.join(GENERATED, file), miz],
    { stdio: 'inherit', cwd: ROOT });
  built.push(miz);
}
if (process.env.GITHUB_OUTPUT) {
  fs.appendFileSync(process.env.GITHUB_OUTPUT, `version=${v}\nmiz<<EOF\n${built.join('\n')}\nEOF\n`);
}
