local A = require("assert")
local miz = require("miz")
local variants = require("variants")

local T = {}

local function source()
  return miz.load(ROOT .. "/mission/mission", "mission"),
         miz.load(ROOT .. "/mission/l10n/DEFAULT/dictionary", "dictionary")
end

local function byName(name)
  for _, v in ipairs(variants.list) do
    if v.name == name then return v end
  end
end

T["there is a day and a night variant with distinct file names"] = function()
  A.truthy(byName("day"), "day variant")
  A.truthy(byName("night"), "night variant")
  local files = {}
  for _, v in ipairs(variants.list) do
    A.truthy(not files[v.file], "unique file name " .. v.file)
    files[v.file] = true
  end
end

T["the day variant keeps the editor's time and name"] = function()
  local mission, dictionary = source()
  local start, title = mission.start_time, dictionary[mission.sortie]
  variants.apply(mission, dictionary, byName("day"))
  A.equal(mission.start_time, start, "start time")
  A.equal(dictionary[mission.sortie], title, "mission name")
end

T["the night variant starts at night and says so in its name"] = function()
  local mission, dictionary = source()
  local title = dictionary[mission.sortie]
  local date = { mission.date.Year, mission.date.Month, mission.date.Day }
  variants.apply(mission, dictionary, byName("night"))
  A.equal(mission.start_time, 23 * 3600, "starts at 23:00")
  A.equal(dictionary[mission.sortie], title .. " (Night)", "mission name")
  A.same({ mission.date.Year, mission.date.Month, mission.date.Day }, date, "same date (a night after full moon)")
end

return T
