local A = require("assert")
local miz = require("miz")

local T = {}

local function tmp()
  return os.tmpname()
end

T["save then load returns the same table"] = function()
  local t = {
    ["name"] = "Rotor \"Gym\"\nline two",
    [1] = 1.5, [2] = -318507, [3] = 0.1 + 0.2,
    nested = { flag = true, off = false, empty = {} },
  }
  local path = tmp()
  miz.save(path, "mission", t)
  A.same(miz.load(path, "mission"), t)
  os.remove(path)
end

T["the source mission round-trips unchanged"] = function()
  for _, name in ipairs({ "mission", "warehouses", "options" }) do
    local t = miz.load(ROOT .. "/mission/" .. name, name)
    local path = tmp()
    miz.save(path, name, t)
    A.same(miz.load(path, name), t, name)
    os.remove(path)
  end
end

T["load rejects a file that defines a different table"] = function()
  local path = tmp()
  miz.save(path, "options", {})
  local ok = pcall(miz.load, path, "mission")
  A.equal(ok, false, "loading the wrong table name")
  os.remove(path)
end

return T
