-- Mission variants built from the same source. Each one becomes its own .miz:
-- out/<file>_<version>.miz. A variant only changes what it lists; everything else
-- comes from the Mission Editor source. Lua 5.1.

local M = {}

M.list = {
  { name = "day", file = "Rotor_Gym" },
  -- 23:00 on the source date (21 June 2016, the night after a full moon), so a bright
  -- moon is up for night-vision flying.
  { name = "night", file = "Rotor_Gym_Night", startTime = 23 * 3600, titleSuffix = " (Night)" },
}

-- Applies `variant` to the mission and its dictionary, in place.
function M.apply(mission, dictionary, variant)
  if variant.startTime then mission.start_time = variant.startTime end
  if variant.titleSuffix then
    dictionary[mission.sortie] = (dictionary[mission.sortie] or "") .. variant.titleSuffix
  end
end

return M
