-- Read and write the Lua tables inside an extracted .miz.
-- DCS stores each file as `name = { ... }`; this loads that table and writes
-- it back in the same style, with keys sorted so the output diffs cleanly.

local M = {}

-- Written for Lua 5.1, the version DCS embeds.
function M.load(path, name)
  local env = {}
  local chunk, err = loadfile(path)
  if not chunk then error("cannot load " .. path .. ": " .. err) end
  setfenv(chunk, env)
  chunk()
  local t = env[name]
  if type(t) ~= "table" then error(path .. " does not define table '" .. name .. "'") end
  return t
end

local function formatNumber(n)
  if n == math.floor(n) and math.abs(n) < 2^53 then return string.format("%d", n) end
  -- Short like DCS writes it when that is exact; otherwise enough digits to round-trip.
  local short = string.format("%.14g", n)
  if tonumber(short) == n then return short end
  return string.format("%.17g", n)
end

local function formatKey(k)
  if type(k) == "number" then return "[" .. formatNumber(k) .. "]" end
  return "[" .. string.format("%q", k) .. "]"
end

local function formatValue(v)
  local t = type(v)
  if t == "number" then return formatNumber(v) end
  if t == "string" then return (string.format("%q", v):gsub("\\\n", "\\n")) end
  if t == "boolean" then return tostring(v) end
  error("cannot serialize value of type " .. t)
end

local function sortedKeys(t)
  local keys = {}
  for k in pairs(t) do keys[#keys + 1] = k end
  table.sort(keys, function(a, b)
    local ta, tb = type(a), type(b)
    if ta ~= tb then return ta == "number" end
    return a < b
  end)
  return keys
end

local function write(out, t, indent)
  for _, k in ipairs(sortedKeys(t)) do
    local v = t[k]
    local key = formatKey(k)
    if type(v) == "table" then
      if next(v) == nil then
        out[#out + 1] = indent .. key .. " = {},"
      else
        out[#out + 1] = indent .. key .. " = "
        out[#out + 1] = indent .. "{"
        write(out, v, indent .. "\t")
        out[#out + 1] = indent .. "}, -- end of " .. key
      end
    else
      out[#out + 1] = indent .. key .. " = " .. formatValue(v) .. ","
    end
  end
end

function M.save(path, name, t)
  local out = { name .. " = ", "{" }
  write(out, t, "\t")
  out[#out + 1] = "} -- end of " .. name
  local f = assert(io.open(path, "wb"))
  f:write(table.concat(out, "\n"), "\n")
  f:close()
end

return M
