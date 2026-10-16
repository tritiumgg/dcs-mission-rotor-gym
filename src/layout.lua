-- Where generated content goes. DCS map coordinates: x is north, z (written as `y`
-- in mission files) is east, in metres. Headings are degrees true.

-- Kobuleti's helicopter-capable parking stands (Terrain.getStandList, DCS 2.9.30).
-- `index` is the stand's crossroad index (a unit's `parking`), `name` its label
-- (`parking_id`). `fits` is the largest helicopter footprint (src/helicopters.lua
-- `size`) the stand takes: the 01-16 row is spaced about 30 m apart, the others
-- are 67 x 79 m pads. `heading` (degrees true) is how DCS parks aircraft there, read
-- from the airfield's stand data (KOBULETI.rn4) and matching a live check on stand 06.
-- `row` groups stands that sit side by side; list order within a row is neighbour order.
-- The south row splits at the 70 m gap between 09 and 10, where its heading changes.
local function stand(name, index, x, y, fits, heading, row)
  return { name = name, index = index, x = x, y = y, fits = fits, heading = heading, row = row }
end

return {
  airbaseId = 24,  -- Kobuleti, Caucasus

  -- Each helicopter's cold and hot slots take the first two neighbouring free stands, in
  -- one row, that both fit it.
  -- Stands are paved, so slots never start in trees.
  stands = {
    stand("01", 28, -318328.2, 635190.9, 18, 348.43, "south 01-09"),
    stand("02", 29, -318321.0, 635219.9, 18, 348.43, "south 01-09"),
    stand("03", 30, -318314.6, 635249.2, 18, 348.43, "south 01-09"),
    stand("04", 31, -318308.0, 635278.5, 18, 348.43, "south 01-09"),
    stand("05", 32, -318301.1, 635307.9, 18, 348.43, "south 01-09"),
    stand("06", 33, -318294.4, 635337.2, 18, 348.43, "south 01-09"),
    stand("07", 34, -318287.8, 635366.2, 18, 348.43, "south 01-09"),
    stand("08", 35, -318280.8, 635395.4, 18, 348.43, "south 01-09"),
    stand("09", 36, -318274.2, 635424.7, 18, 348.43, "south 01-09"),
    stand("10", 37, -318253.2, 635494.2, 18, 339.77, "south 10-16"),
    stand("11", 38, -318242.9, 635522.3, 18, 339.77, "south 10-16"),
    stand("12", 39, -318232.6, 635550.6, 18, 339.77, "south 10-16"),
    stand("13", 40, -318222.5, 635578.8, 18, 339.77, "south 10-16"),
    stand("14", 41, -318212.3, 635607.1, 18, 339.77, "south 10-16"),
    stand("15", 42, -318202.0, 635635.1, 18, 339.77, "south 10-16"),
    stand("16", 43, -318191.5, 635663.3, 18, 339.77, "south 10-16"),
    stand("17", 23, -318165.3, 635727.5, 30, 339.77, "south pads"),
    stand("18", 24, -318144.2, 635783.7, 30, 339.77, "south pads"),
    stand("19", 25, -318123.4, 635840.1, 30, 339.77, "south pads"),
    stand("20", 26, -318103.3, 635896.6, 30, 339.77, "south pads"),
    stand("21", 27, -318082.7, 635952.9, 30, 339.77, "south pads"),
    stand("41", 3, -317748.4, 635096.6, 30, 122.30, "north pads"),
    stand("42", 2, -317882.4, 635012.9, 30, 122.30, "north pads"),
    stand("28", 16, -317884.2, 636664.6, 30, 339.26, "east pads"),
    stand("29", 14, -317854.4, 636854.7, 30, 339.26, "east pads"),
    stand("30", 15, -317688.1, 636897.1, 30, 249.63, "east pads"),
  },

  slots = {
    groundAlt = 18,  -- Kobuleti field elevation
  },

  -- Anchor points of the practice areas. Planned positions from the terrain survey;
  -- each is replaced by the real station position when that station is built.
  areas = {
    { name = "rooftops near the field",  x = -316800, y = 636100 },
    { name = "rooftops east of town",    x = -318300, y = 638700 },
    { name = "pinnacle 255 m",           x = -323982, y = 641363 },
    { name = "pinnacle 615 m",           x = -325982, y = 647113 },
    { name = "pinnacle 908 m",           x = -329982, y = 644863 },
    { name = "pinnacle 1174 m",          x = -336982, y = 645113 },
    { name = "pinnacle 1356 m",          x = -330982, y = 649363 },
    { name = "oil rig",                  x = -322000, y = 624500 },
    { name = "ship racetrack",           x = -322000, y = 622000 },
  },

  -- Kobuleti runway 07/25 ends (Terrain.getRunwayList).
  runway = {
    { name = "07", x = -318347.9, y = 634572.1 },
    { name = "25", x = -317576.7, y = 636693.9 },
  },

  -- Where the Mission Editor's map opens (mission.map): centred on Kobuleti, with
  -- the runway and every stand within `radius` of the centre. `zoom` is the editor's
  -- map scale; 12000 shows the whole airport (checked in the editor, 2026-10-15).
  view = { x = -317962, y = 635735, radius = 1300, zoom = 12000 },
}
