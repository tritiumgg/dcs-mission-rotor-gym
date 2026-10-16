// Packs and unpacks .miz files. Adapted from dcs-range's miz.mjs.
//
//   node tools/miz.mjs unpack <file.miz> <dir>   .miz -> unpacked tree (replaces <dir>)
//   node tools/miz.mjs pack   <dir>... <file.miz> unpacked tree(s) -> .miz; a later dir's
//                                                files replace an earlier dir's
//
// A .miz is a plain zip of Lua sources: `mission`, `options`, `warehouses`, `theatre`, the
// `l10n/DEFAULT/` dictionary and bundled files. DCS opens it with minizip, which wants forward-slash
// entry names and ordinary deflate, so the writer below is enough: no directory entries, no zip64,
// no extra fields, and a fixed timestamp so the output is byte-stable.
import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';

function readZip(file) {
  const buf = fs.readFileSync(file);
  let eocd = buf.length - 22;
  while (eocd >= 0 && buf.readUInt32LE(eocd) !== 0x06054b50) eocd--;
  if (eocd < 0) throw new Error(`not a zip: ${file}`);
  const count = buf.readUInt16LE(eocd + 10);
  let p = buf.readUInt32LE(eocd + 16);
  const entries = [];
  for (let i = 0; i < count; i++) {
    if (buf.readUInt32LE(p) !== 0x02014b50) throw new Error(`bad central directory in ${file}`);
    const method = buf.readUInt16LE(p + 10);
    const csize = buf.readUInt32LE(p + 20), usize = buf.readUInt32LE(p + 24);
    const nlen = buf.readUInt16LE(p + 28), elen = buf.readUInt16LE(p + 30), clen = buf.readUInt16LE(p + 32);
    const off = buf.readUInt32LE(p + 42);
    const name = buf.toString('utf8', p + 46, p + 46 + nlen);
    // local header: skip its own (possibly different) name and extra fields
    const lnlen = buf.readUInt16LE(off + 26), lelen = buf.readUInt16LE(off + 28);
    const start = off + 30 + lnlen + lelen;
    const raw = buf.subarray(start, start + csize);
    if (!name.endsWith('/')) {
      const data = method === 0 ? raw : zlib.inflateRawSync(raw);
      if (data.length !== usize) throw new Error(`size mismatch for ${name} in ${file}`);
      entries.push({ name, data });
    }
    p += 46 + nlen + elen + clen;
  }
  return entries;
}

function writeZip(file, entries) {
  const locals = [], central = [];
  let offset = 0;
  for (const { name, data } of entries) {
    const nameBuf = Buffer.from(name, 'utf8');
    const comp = zlib.deflateRawSync(data, { level: 9 });
    const crc = zlib.crc32 ? zlib.crc32(data) : crc32(data);
    const lh = Buffer.alloc(30);
    lh.writeUInt32LE(0x04034b50, 0);
    lh.writeUInt16LE(20, 4);            // version needed
    lh.writeUInt16LE(0x0800, 6);        // UTF-8 names
    lh.writeUInt16LE(8, 8);             // deflate
    lh.writeUInt16LE(0, 10); lh.writeUInt16LE(0, 12); // fixed dos time: byte-stable output
    lh.writeUInt32LE(crc, 14);
    lh.writeUInt32LE(comp.length, 18);
    lh.writeUInt32LE(data.length, 22);
    lh.writeUInt16LE(nameBuf.length, 26);
    locals.push(lh, nameBuf, comp);

    const ch = Buffer.alloc(46);
    ch.writeUInt32LE(0x02014b50, 0);
    ch.writeUInt16LE(20, 4); ch.writeUInt16LE(20, 6);
    ch.writeUInt16LE(0x0800, 8);
    ch.writeUInt16LE(8, 10);
    ch.writeUInt16LE(0, 12); ch.writeUInt16LE(0, 14);
    ch.writeUInt32LE(crc, 16);
    ch.writeUInt32LE(comp.length, 20);
    ch.writeUInt32LE(data.length, 24);
    ch.writeUInt16LE(nameBuf.length, 28);
    ch.writeUInt32LE(offset, 42);
    central.push(ch, nameBuf);
    offset += 30 + nameBuf.length + comp.length;
  }
  const cd = Buffer.concat(central);
  const eocd = Buffer.alloc(22);
  eocd.writeUInt32LE(0x06054b50, 0);
  eocd.writeUInt16LE(entries.length, 8);
  eocd.writeUInt16LE(entries.length, 10);
  eocd.writeUInt32LE(cd.length, 12);
  eocd.writeUInt32LE(offset, 16);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, Buffer.concat([...locals, cd, eocd]));
}

// node 24 has zlib.crc32; keep a fallback so an older node still writes a valid archive
let TABLE;
function crc32(buf) {
  if (!TABLE) {
    TABLE = new Int32Array(256);
    for (let n = 0; n < 256; n++) {
      let c = n;
      for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
      TABLE[n] = c;
    }
  }
  let c = -1;
  for (let i = 0; i < buf.length; i++) c = TABLE[(c ^ buf[i]) & 0xff] ^ (c >>> 8);
  return (c ^ -1) >>> 0;
}

// DCS does not care about entry order, but a stable order keeps the output byte-stable.
const ORDER = ['mission', 'options', 'warehouses', 'theatre'];
const sortEntries = (names) => names.slice().sort((a, b) => {
  const ia = ORDER.indexOf(a), ib = ORDER.indexOf(b);
  if (ia !== ib) return (ia < 0 ? 99 : ia) - (ib < 0 ? 99 : ib);
  return a < b ? -1 : a > b ? 1 : 0;
});

function readTrees(dirs) {
  const files = new Map();
  for (const dir of dirs) {
    if (!fs.existsSync(dir)) throw new Error(`no such directory: ${dir}`);
    const walk = (d, prefix) => {
      for (const e of fs.readdirSync(d, { withFileTypes: true })) {
        const rel = prefix ? `${prefix}/${e.name}` : e.name;
        if (e.isDirectory()) walk(path.join(d, e.name), rel);
        else files.set(rel, path.join(d, e.name));
      }
    };
    walk(dir, '');
  }
  if (!files.has('mission')) throw new Error(`no 'mission' file in ${dirs.join(', ')}`);
  return sortEntries([...files.keys()]).map(name => ({ name, data: fs.readFileSync(files.get(name)) }));
}

function writeTree(dir, entries) {
  fs.rmSync(dir, { recursive: true, force: true });
  for (const { name, data } of entries) {
    const dest = path.join(dir, name);
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.writeFileSync(dest, data);
  }
}

const [cmd, ...args] = process.argv.slice(2);
try {
  if (cmd === 'unpack' && args.length === 2) {
    const [miz, dir] = args;
    const entries = readZip(miz);
    writeTree(dir, entries);
    console.log(`unpack: ${entries.length} entries from ${miz} -> ${dir}`);
  } else if (cmd === 'pack' && args.length >= 2) {
    const dirs = args.slice(0, -1), miz = args[args.length - 1];
    const entries = readTrees(dirs);
    writeZip(miz, entries);
    console.log(`pack: ${entries.length} entries from ${dirs.join(' + ')} -> ${miz}`);
  } else {
    console.error('usage: node tools/miz.mjs unpack <file.miz> <dir> | pack <dir>... <file.miz>');
    process.exit(2);
  }
} catch (e) {
  console.error(String(e.message || e));
  process.exit(1);
}
