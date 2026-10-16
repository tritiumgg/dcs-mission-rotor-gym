-- Builds the mission's generated content on top of the Mission Editor source.
--
--   lua src/build.lua <source dir> <output root>
--
-- Reads the unpacked .miz from the source dir and writes, for every variant in
-- variants.lua, the changed files to <output root>/<variant file>/ (that directory and
-- its l10n/DEFAULT must exist; tools/build.mjs creates them). The pack step lays each
-- variant's directory over the source.
--   lua src/build.lua --list   prints the variant file names, one per line.
-- Lua 5.1, the version DCS embeds.

local here = arg[0]:match("^(.*)[/\\]") or "."
package.path = here .. "/?.lua;" .. package.path

local miz = require("miz")
local generate = require("generate")
local variants = require("variants")

if arg[1] == "--list" then
  for _, v in ipairs(variants.list) do print(v.file) end
  os.exit(0)
end

local srcDir, outRoot = arg[1], arg[2]
if not srcDir or not outRoot then
  io.stderr:write("usage: lua src/build.lua <source dir> <output root> | --list\n")
  os.exit(2)
end

local bundle = generate.bundle(here .. "/..")

for _, variant in ipairs(variants.list) do
  local mission = miz.load(srcDir .. "/mission", "mission")
  local warehouses = miz.load(srcDir .. "/warehouses", "warehouses")
  local mapResource = miz.load(srcDir .. "/l10n/DEFAULT/mapResource", "mapResource")
  local dictionary = miz.load(srcDir .. "/l10n/DEFAULT/dictionary", "dictionary")

  local result = generate.apply(mission, warehouses, { mapResource = mapResource })
  variants.apply(mission, dictionary, variant)

  local out = outRoot .. "/" .. variant.file
  miz.save(out .. "/mission", "mission", mission)
  miz.save(out .. "/warehouses", "warehouses", warehouses)
  miz.save(out .. "/l10n/DEFAULT/mapResource", "mapResource", result.mapResource)
  miz.save(out .. "/l10n/DEFAULT/dictionary", "dictionary", dictionary)
  local f = assert(io.open(out .. "/l10n/DEFAULT/" .. generate.SCRIPT_FILE, "wb"))
  f:write(bundle)
  f:close()
  print(string.format("build: %s: %d player slots, dynamic spawn at airbase %d",
    variant.name, result.slots, result.airbaseId))
end
