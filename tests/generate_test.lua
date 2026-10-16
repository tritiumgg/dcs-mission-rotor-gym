local A = require("assert")
local miz = require("miz")
local generate = require("generate")
local helicopters = require("helicopters")
local layout = require("layout")

local T = {}

local function source()
  return miz.load(ROOT .. "/mission/mission", "mission"),
         miz.load(ROOT .. "/mission/warehouses", "warehouses")
end

local function slotGroups(mission)
  local found = {}
  for _, country in ipairs(mission.coalition.blue.country or {}) do
    for _, g in ipairs((country.helicopter or {}).group or {}) do
      local unit = g.units and g.units[1]
      if unit and unit.name:sub(1, #generate.SLOT_PREFIX) == generate.SLOT_PREFIX then found[#found + 1] = g end
    end
  end
  return found
end

local function built()
  local mission, warehouses = source()
  generate.apply(mission, warehouses)
  return mission, warehouses
end

T["every helicopter gets a cold and a hot client slot"] = function()
  local mission = built()
  local starts = {}
  for _, g in ipairs(slotGroups(mission)) do
    local u, p = g.units[1], g.route.points[1]
    A.equal(u.skill, "Client", g.name .. " skill")
    starts[u.type .. "/" .. p.type] = (starts[u.type .. "/" .. p.type] or 0) + 1
  end
  for _, heli in ipairs(helicopters) do
    A.equal(starts[heli.type .. "/TakeOffParking"], 1, heli.type .. " cold slots")
    A.equal(starts[heli.type .. "/TakeOffParkingHot"], 1, heli.type .. " hot slots")
  end
  A.equal(#slotGroups(mission), 2 * #helicopters, "slot count")
end

T["slot group names say the helicopter and how it starts"] = function()
  local mission = built()
  local names = {}
  for _, g in ipairs(slotGroups(mission)) do names[g.name] = g.route.points[1].type end
  for _, heli in ipairs(helicopters) do
    A.equal(names[heli.displayName .. " Cold Start"], "TakeOffParking", heli.displayName .. " Cold Start")
    A.equal(names[heli.displayName .. " Hot Start"], "TakeOffParkingHot", heli.displayName .. " Hot Start")
  end
end

T["slot unit names carry the generated prefix and stay unique"] = function()
  local mission = built()
  local seen = {}
  for _, g in ipairs(slotGroups(mission)) do
    local name = g.units[1].name
    A.equal(name, generate.SLOT_PREFIX .. g.name, g.name .. " unit name")
    A.truthy(not seen[name], name .. " is unique")
    seen[name] = true
  end
end

T["each helicopter's cold and hot slots are on neighbouring stands in one row"] = function()
  local mission = built()
  local position, stands = {}, {}
  for i, s in ipairs(layout.stands) do position[s.name], stands[s.name] = i, s end
  local byType = {}
  for _, g in ipairs(slotGroups(mission)) do
    local u = g.units[1]
    byType[u.type] = byType[u.type] or {}
    table.insert(byType[u.type], u.parking_id)
  end
  for typeName, pair in pairs(byType) do
    A.equal(#pair, 2, typeName .. " slots")
    local a, b = stands[pair[1]], stands[pair[2]]
    A.equal(a.row, b.row, typeName .. " stands " .. pair[1] .. "/" .. pair[2] .. " in one row")
    A.equal(math.abs(position[pair[1]] - position[pair[2]]), 1, typeName .. " stands next to each other")
  end
end

T["slot units face the way their stand parks aircraft"] = function()
  local mission = built()
  local stands = {}
  for _, s in ipairs(layout.stands) do stands[s.name] = s end
  for _, g in ipairs(slotGroups(mission)) do
    local u = g.units[1]
    A.equal(u.heading, math.rad(stands[u.parking_id].heading), g.name .. " heading")
  end
end

-- The mission-start trigger that loads the bundled scripts.
local function scriptTrigger(mission)
  for i, rule in ipairs(mission.trigrules or {}) do
    if rule.comment == generate.SCRIPT_TRIGGER then return i, rule end
  end
end

T["a mission start trigger loads the bundled scripts"] = function()
  local mission, warehouses = source()
  local result = generate.apply(mission, warehouses)
  local i, rule = scriptTrigger(mission)
  A.truthy(rule, "script trigger")
  A.equal(rule.predicate, "triggerStart", "runs at mission start")
  local action = rule.actions[1]
  A.equal(action.predicate, "a_do_script_file", "action")
  A.equal(result.mapResource[action.file], generate.SCRIPT_FILE, "resource maps to the script")
  A.truthy(tonumber(action.file:match("(%d+)$")) <= mission.maxDictId, "key within maxDictId")
  local t = mission.trig
  A.equal(t.actions[i], 'a_do_script_file(getValueResourceByKey("' .. action.file .. '"));', "compiled action")
  A.equal(t.conditions[i], "return(true)", "compiled condition")
  A.equal(t.funcStartup[i], "if mission.trig.conditions[" .. i .. "]() then mission.trig.actions[" .. i .. "]() end", "startup")
  A.equal(t.flag[i], true, "flag")
  A.equal(t.func[i], nil, "not a repeating trigger")
end

T["the script trigger keeps the mission's own triggers and is not duplicated"] = function()
  local mission, warehouses = source()
  mission.trigrules = { { predicate = "triggerOnce", comment = "Player trigger", rules = {}, actions = {}, eventlist = "" } }
  mission.trig.conditions[1], mission.trig.actions[1], mission.trig.func[1], mission.trig.flag[1] =
    "return(c_flag_is_true(1))", "a_out_text_delay('hi', 10);", "if mission.trig.conditions[1]() then mission.trig.actions[1]() end", true
  local first = generate.apply(mission, warehouses)
  local second = generate.apply(mission, warehouses, { mapResource = first.mapResource })
  A.equal(#mission.trigrules, 2, "player trigger plus ours")
  A.equal(mission.trigrules[1].comment, "Player trigger", "player trigger first")
  A.equal(mission.trig.actions[1], "a_out_text_delay('hi', 10);", "player action untouched")
  local count = 0
  for _ in pairs(second.mapResource) do count = count + 1 end
  A.equal(count, 1, "one script resource")
end

T["the bundled script compiles and starts the parked helicopters"] = function()
  local stub = require("dcs_stub")
  local w = stub.install(stub.mission({}))
  _G.net = { get_player_list = function() return {} end, get_server_id = function() return 0 end,
             get_my_player_id = function() return 0 end }
  local chunk = assert(loadstring(generate.bundle(ROOT), "bundle"))
  chunk()
  _G.net = nil
  A.truthy(RotorGym and RotorGym.parked, "RotorGym.parked defined")
  A.equal(#w.handlers, 1, "parked helicopters started")
  RotorGym = nil
end

T["slots start on kobuleti stands, one slot per stand"] = function()
  local mission = built()
  local stands = {}
  for _, s in ipairs(layout.stands) do stands[s.name] = s end
  local used = {}
  for _, g in ipairs(slotGroups(mission)) do
    local u, p = g.units[1], g.route.points[1]
    A.equal(p.airdromeId, layout.airbaseId, g.name .. " airdromeId")
    local stand = stands[u.parking_id]
    A.truthy(stand, g.name .. " is on a known stand (" .. tostring(u.parking_id) .. ")")
    A.equal(u.parking, stand.index, g.name .. " parking index")
    A.equal(u.x, stand.x, g.name .. " x")
    A.equal(u.y, stand.y, g.name .. " y")
    A.truthy(not used[u.parking_id], "stand " .. u.parking_id .. " used once")
    used[u.parking_id] = true
  end
end

T["each helicopter's footprint fits its stand"] = function()
  local mission = built()
  local size, stands = {}, {}
  for _, h in ipairs(helicopters) do size[h.type] = h.size end
  for _, s in ipairs(layout.stands) do stands[s.name] = s end
  for _, g in ipairs(slotGroups(mission)) do
    local u = g.units[1]
    A.truthy(size[u.type] <= stands[u.parking_id].fits, g.name .. " fits stand " .. u.parking_id)
  end
end

T["slots sit in country 80 on the blue side"] = function()
  local mission = built()
  local ids = {}
  for _, c in ipairs(mission.coalition.blue.country) do ids[c.id] = c end
  A.truthy(ids[80] and ids[80].helicopter, "country 80 helicopters")
end

T["group and unit ids are unique"] = function()
  local mission = built()
  local groups, units = {}, {}
  for _, g in ipairs(slotGroups(mission)) do
    A.truthy(not groups[g.groupId], "unique groupId " .. g.groupId)
    groups[g.groupId] = true
    for _, u in ipairs(g.units) do
      A.truthy(not units[u.unitId], "unique unitId " .. u.unitId)
      units[u.unitId] = true
    end
  end
end

T["applying twice gives the same mission"] = function()
  local m1, w1 = built()
  local m2, w2 = source()
  generate.apply(m2, w2)
  generate.apply(m2, w2)
  A.same(m2, m1)
  A.same(w2, w1)
end

T["too many helicopters for the stands is an error"] = function()
  local mission, warehouses = source()
  local ok, err = pcall(generate.apply, mission, warehouses, { stands = { layout.stands[1] } })
  A.equal(ok, false, "apply with one stand")
  A.truthy(tostring(err):find("stand"), "error mentions stands: " .. tostring(err))
end

T["the editor camera opens on kobuleti"] = function()
  local mission = built()
  A.equal(mission.map.centerX, layout.view.x, "centerX (north)")
  A.equal(mission.map.centerY, layout.view.y, "centerY (east)")
  A.equal(mission.map.zoom, layout.view.zoom, "zoom")
end

T["the whole airfield lies inside the camera view"] = function()
  local v = layout.view
  local points = {}
  for _, s in ipairs(layout.stands) do points[#points + 1] = { name = "stand " .. s.name, x = s.x, y = s.y } end
  for _, e in ipairs(layout.runway) do points[#points + 1] = { name = "runway end " .. e.name, x = e.x, y = e.y } end
  A.truthy(#points > #layout.stands, "runway ends are listed")
  for _, p in ipairs(points) do
    local d = math.sqrt((p.x - v.x) ^ 2 + (p.y - v.y) ^ 2)
    A.truthy(d <= v.radius, p.name .. " is " .. math.floor(d) .. " m from the view centre")
  end
end

T["kobuleti offers only the listed helicopters for dynamic spawn"] = function()
  local _, warehouses = built()
  local a = warehouses.airports[24]
  A.equal(a.coalition, "BLUE", "coalition")
  A.equal(a.dynamicSpawn, true, "dynamicSpawn")
  A.equal(a.allowHotStart, true, "allowHotStart")
  A.equal(a.unlimitedAircrafts, false, "unlimitedAircrafts")
  local listed = {}
  for _, h in ipairs(helicopters) do listed[h.type] = true end
  local planes = 0
  for typeName, e in pairs(a.aircrafts.planes) do
    planes = planes + 1
    A.equal(e.initialAmount, 0, typeName .. " amount")
  end
  A.truthy(planes > 100, "every plane type is listed at zero")
  for typeName, e in pairs(a.aircrafts.helicopters) do
    A.equal(e.unlimited, listed[typeName] == true, typeName .. " unlimited")
    A.equal(e.initialAmount > 0, listed[typeName] == true, typeName .. " available")
  end
end

return T
