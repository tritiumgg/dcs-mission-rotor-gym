// Builds Lua 5.1.5 (the Lua version DCS embeds) into .tools/lua51/bin with `zig cc`
// (zig comes from mise). Run through mise: `mise run build:lua`. Adapted from dcs-range.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const TOOLS = path.join(ROOT, '.tools');
const OUT = path.join(TOOLS, 'lua51');
const BIN = path.join(OUT, 'bin');
const URL = 'https://www.lua.org/ftp/lua-5.1.5.tar.gz';
const SHA256 = '2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333';
const EXE = process.platform === 'win32' ? '.exe' : '';
// Windows' own bsdtar handles absolute drive paths; Git Bash's GNU tar reads "C:" as a remote host.
const TAR = process.platform === 'win32'
  ? path.join(process.env.SystemRoot || 'C:/Windows', 'System32', 'tar.exe') : 'tar';

if (fs.existsSync(path.join(BIN, 'luac' + EXE)) && !process.argv.includes('--force')) {
  console.log('Lua 5.1.5 already built in ' + BIN + ' (--force to rebuild)');
  process.exit(0);
}
fs.mkdirSync(TOOLS, { recursive: true });
const tarball = path.join(TOOLS, 'lua-5.1.5.tar.gz');
if (!fs.existsSync(tarball)) {
  console.log('downloading ' + URL);
  const res = await fetch(URL);
  if (!res.ok) throw new Error('download failed: ' + res.status);
  fs.writeFileSync(tarball, Buffer.from(await res.arrayBuffer()));
}
const sum = crypto.createHash('sha256').update(fs.readFileSync(tarball)).digest('hex');
if (sum !== SHA256) {
  fs.rmSync(tarball);
  throw new Error('sha256 mismatch for lua-5.1.5.tar.gz: ' + sum);
}
execFileSync(TAR, ['-xzf', tarball, '-C', TOOLS], { stdio: 'inherit' });
const SRC = path.join(TOOLS, 'lua-5.1.5', 'src');
const core = fs.readdirSync(SRC).filter(f => f.endsWith('.c') && !['lua.c', 'luac.c', 'print.c'].includes(f))
  .map(f => path.join(SRC, f));
fs.mkdirSync(BIN, { recursive: true });
const cc = (out, files) => {
  console.log('zig cc -> ' + path.basename(out));
  execFileSync('zig', ['cc', '-O2', '-std=gnu99', '-o', out, ...files,
    ...(process.platform === 'win32' ? [] : ['-lm'])], { stdio: 'inherit' });
};
cc(path.join(BIN, 'lua' + EXE), [...core, path.join(SRC, 'lua.c')]);
cc(path.join(BIN, 'luac' + EXE), [...core, path.join(SRC, 'luac.c'), path.join(SRC, 'print.c')]);
console.log(execFileSync(path.join(BIN, 'lua' + EXE), ['-v'], { encoding: 'utf8' }).trim() || 'built');
