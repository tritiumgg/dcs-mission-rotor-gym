// The mission version, derived from git tags. Releases are tagged vMAJOR.MINOR.PATCH.
//
//   on a release tag          1.2.0
//   commits after a tag       1.2.0-3-gabc1234
//   uncommitted changes       ...-dirty
//   no release tag yet        0.0.0-dev-gabc1234  (or 0.0.0-dev with no commits)
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const git = (...args) => execFileSync('git', args, { cwd: ROOT, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();

export function version() {
  try {
    return git('describe', '--tags', '--match', 'v[0-9]*', '--dirty').replace(/^v/, '');
  } catch {
    try {
      const dirty = git('status', '--porcelain') ? '-dirty' : '';
      return `0.0.0-dev-g${git('rev-parse', '--short', 'HEAD')}${dirty}`;
    } catch {
      return '0.0.0-dev';
    }
  }
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) console.log(version());
