local A = require("assert")
local stub = require("dcs_stub")

local T = {}

local SLOTS = {
  { group = "UH-1H Cold Start", unit = "RG Slot UH-1H Cold Start", type = "UH-1H", x = 100, y = 200, heading = 1.0, livery = "Army Standard" },
  { group = "UH-1H Hot Start",  unit = "RG Slot UH-1H Hot Start",  type = "UH-1H", x = 100, y = 230, heading = 1.0, livery = "Army Standard" },
  -- A slot a player added in the editor: no generated prefix, any name.
  { group = "My Huey",          unit = "Pilot #001",               type = "UH-1H", x = 100, y = 260, heading = 2.0 },
}

-- Loads the mission script fresh against a stubbed DCS. `singlePlayer` decides the mode.
local function start(slots, singlePlayer, playerSlot)
  local w = stub.install(stub.mission(slots))
  if playerSlot then w.spawn(playerSlot.unit, playerSlot.x, playerSlot.y, true) end
  package.loaded["parked"] = nil
  local parked = dofile(ROOT .. "/scripts/parked.lua")
  parked.isSinglePlayer = function() return singlePlayer end
  parked.start()
  return w, parked
end

T["finds every client helicopter slot in the mission, generated or not"] = function()
  local _, parked = start(SLOTS, true)
  local names = {}
  for _, s in ipairs(parked.slots()) do names[#names + 1] = s.unit end
  table.sort(names)
  A.same(names, { "Pilot #001", "RG Slot UH-1H Cold Start", "RG Slot UH-1H Hot Start" })
end

T["ignores AI helicopters and dynamic spawn templates"] = function()
  local slots = {
    SLOTS[1],
    { group = "AI Huey", unit = "AI Huey 1", type = "UH-1H", x = 0, y = 0, skill = "High" },
    { group = "Template", unit = "Template 1", type = "UH-1H", x = 0, y = 0, template = true },
  }
  local _, parked = start(slots, true)
  A.equal(#parked.slots(), 1, "slots")
end

T["in single player, empty slots get a parked copy after start"] = function()
  local w = start(SLOTS, true, SLOTS[1])
  w.advance(2)
  A.same(w.liveStatics(), { "Parked Pilot #001", "Parked RG Slot UH-1H Hot Start" })
  local s = w.statics["Parked RG Slot UH-1H Hot Start"]
  A.equal(s.country, 80, "country")
  A.equal(s.data.type, "UH-1H", "type")
  A.equal(s.data.category, "Helicopters", "category")
  A.equal(s.data.livery_id, "Army Standard", "livery")
  A.equal(s.data.x, 100, "x")
  A.equal(s.data.y, 230, "y")
  A.equal(s.data.heading, 1.0, "heading")end

T["in multiplayer, nothing is parked"] = function()
  local w = start(SLOTS, false)
  w.advance(60)
  A.equal(#w.added, 0, "statics added")
end

T["no copies until the player's helicopter exists, so none lands on the player"] = function()
  -- A slow-loading module: the player's helicopter appears 5 seconds in.
  local w = start(SLOTS, true)
  w.advance(5)
  A.equal(#w.added, 0, "nothing parked before the player exists")
  w.spawn(SLOTS[1].unit, SLOTS[1].x, SLOTS[1].y, true)
  w.advance(3)
  A.same(w.liveStatics(), { "Parked Pilot #001", "Parked RG Slot UH-1H Hot Start" })
end

T["a helicopter spawning in a slot removes its parked copy"] = function()
  local w = start(SLOTS, true, SLOTS[1])
  w.advance(2)
  w.spawn("Pilot #001", 100, 260)
  A.same(w.liveStatics(), { "Parked RG Slot UH-1H Hot Start" })
end

T["a vacated slot gets its parked copy back once the stand is clear"] = function()
  local w, parked = start(SLOTS, true, SLOTS[1])
  w.advance(2)
  -- The player flies off and the slot's unit no longer exists.
  w.despawn("RG Slot UH-1H Cold Start")
  w.advance(parked.RESPAWN_DELAY - 1)
  A.truthy(not w.statics["Parked RG Slot UH-1H Cold Start"], "not back too soon")
  w.advance(parked.RESPAWN_DELAY + parked.POLL_INTERVAL)
  A.truthy(w.statics["Parked RG Slot UH-1H Cold Start"].alive, "back after the delay")
end

T["a parked copy waits while something stands on the stand"] = function()
  local w, parked = start(SLOTS, true, SLOTS[1])
  w.advance(2)
  w.despawn("RG Slot UH-1H Cold Start")
  -- Another helicopter hovers on the empty stand.
  w.units["Visitor"] = { name = "Visitor", x = 102, y = 203, alive = true }
  w.advance(parked.RESPAWN_DELAY + 3 * parked.POLL_INTERVAL)
  A.truthy(not w.statics["Parked RG Slot UH-1H Cold Start"], "kept off an occupied stand")
  w.despawn("Visitor")
  w.advance(parked.RESPAWN_DELAY + parked.POLL_INTERVAL)
  A.truthy(w.statics["Parked RG Slot UH-1H Cold Start"].alive, "parked once clear")
end

-- isSinglePlayer against a stubbed `net`. Single player: nobody connected, ids 0.
local function detect(net)
  stub.install(stub.mission({}))
  _G.net = net
  local parked = dofile(ROOT .. "/scripts/parked.lua")
  local result = parked.isSinglePlayer()
  _G.net = nil
  return result
end

local function fakeNet(list, server, me)
  return {
    get_player_list = function() return list end,
    get_server_id = function() return server end,
    get_my_player_id = function() return me end,
  }
end

T["single player is recognised"] = function()
  A.equal(detect(fakeNet({}, 0, 0)), true, "empty list, ids 0")
end

T["anything that looks like multiplayer is treated as multiplayer"] = function()
  A.equal(detect(nil), false, "no net")
  A.equal(detect(fakeNet({ 1 }, 1, 1)), false, "server with players")
  A.equal(detect(fakeNet({}, 1, 1)), false, "server id 1")
  A.equal(detect(fakeNet({ 2 }, 0, 0)), false, "players connected")
  A.equal(detect({ get_player_list = function() error("boom") end }), false, "net errors")
end

return T
