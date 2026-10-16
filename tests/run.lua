-- Minimal test runner for Lua 5.1 (the version DCS embeds). Run: `mise run test`.
-- Each test file returns a table of name -> function; a test fails by raising an error.

local root = (arg[0]:match("^(.*)[/\\]tests[/\\]") or ".")
package.path = root .. "/src/?.lua;" .. root .. "/tests/?.lua;" .. package.path
ROOT = root

local FILES = {
  "miz_test",
  "generate_test",
  "parked_test",
  "variants_test",
}

local passed, failed = 0, 0
for _, file in ipairs(FILES) do
  local suite = require(file)
  local names = {}
  for name in pairs(suite) do names[#names + 1] = name end
  table.sort(names)
  for _, name in ipairs(names) do
    local ok, err = pcall(suite[name])
    if ok then
      passed = passed + 1
    else
      failed = failed + 1
      print("FAIL " .. file .. ": " .. name .. "\n     " .. tostring(err))
    end
  end
end
print(string.format("%d passed, %d failed", passed, failed))
os.exit(failed == 0 and 0 or 1)
