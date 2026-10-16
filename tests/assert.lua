-- Small assertion helpers that report what was expected.
local A = {}

function A.equal(actual, expected, what)
  if actual ~= expected then
    error((what or "value") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
  end
end

function A.truthy(value, what)
  if not value then error((what or "value") .. " should be true", 2) end
end

-- Recursively compares two values; errors with the path of the first difference.
function A.same(a, b, path)
  path = path or "value"
  if type(a) ~= type(b) then error(path .. ": type " .. type(a) .. " vs " .. type(b), 2) end
  if type(a) ~= "table" then
    if a ~= b then error(path .. ": " .. tostring(a) .. " vs " .. tostring(b), 2) end
    return
  end
  for k, v in pairs(a) do A.same(v, b[k], path .. "." .. tostring(k)) end
  for k in pairs(b) do
    if a[k] == nil then error(path .. "." .. tostring(k) .. ": missing on the left", 2) end
  end
end

return A
