-- Parked helicopters: in single player, every client helicopter slot nobody is flying
-- shows a static copy of its helicopter on its spot. The copy goes away when the slot's
-- helicopter spawns and comes back once the slot is empty and its spot is clear.
--
-- Multiplayer is skipped: a mission script only learns about a spawn after the
-- helicopter exists, so a copy could still be standing where a player appears.
--
-- Slots are read from the mission at runtime, so slots added in the Mission Editor get
-- copies too. Plain DCS scripting API, Lua 5.1.

local M = {}

M.POLL_INTERVAL = 2      -- seconds between checks for vacated slots
M.RESPAWN_DELAY = 10     -- seconds a slot must be empty before its copy returns
M.CLEAR_RADIUS = 15      -- metres around the spot that must be free of units
M.START_DELAY = 1        -- seconds after mission start before the first copies appear
M.PREFIX = "Parked "

-- Single player shows no connected players and ids of 0; a multiplayer server reports
-- id 1 (ED's Sim_ControlAPI.md). Anything unexpected counts as multiplayer, so copies
-- are never placed where a player might spawn into them.
function M.isSinglePlayer()
  if type(net) ~= "table" then return false end
  local okList, list = pcall(net.get_player_list)
  local okServer, server = pcall(net.get_server_id)
  local okMe, me = pcall(net.get_my_player_id)
  return okList and okServer and okMe and type(list) == "table" and next(list) == nil
    and server == 0 and me == 0
end

local function isPlayerSkill(skill)
  return skill == "Client" or skill == "Player"
end

-- Every client or player helicopter in the mission, as { unit, type, livery, x, y,
-- heading, country }. Dynamic spawn templates are not slots.
function M.slots()
  local found = {}
  for _, side in pairs(env.mission.coalition or {}) do
    for _, country in ipairs(side.country or {}) do
      for _, group in ipairs((country.helicopter or {}).group or {}) do
        if not group.dynSpawnTemplate then
          for _, u in ipairs(group.units or {}) do
            if isPlayerSkill(u.skill) then
              found[#found + 1] = {
                unit = u.name, type = u.type, livery = u.livery_id,
                x = u.x, y = u.y, heading = u.heading or 0, country = country.id,
              }
            end
          end
        end
      end
    end
  end
  return found
end

local slots, bySlotUnit = {}, {}
local emptySince = {}  -- unit name -> time the slot was first seen empty

local function staticName(slot) return M.PREFIX .. slot.unit end

local function unitExists(name)
  local u = Unit.getByName(name)
  return u ~= nil and u:isExist()
end

local function parkedCopy(slot)
  local s = StaticObject.getByName(staticName(slot))
  if s and s:isExist() then return s end
end

local function spotIsClear(slot)
  local clear = true
  world.searchObjects(Object.Category.UNIT, {
    id = world.VolumeType.SPHERE,
    params = { point = { x = slot.x, y = 0, z = slot.y }, radius = M.CLEAR_RADIUS },
  }, function() clear = false return false end)
  return clear
end

local function park(slot)
  coalition.addStaticObject(slot.country, {
    name = staticName(slot), type = slot.type, category = "Helicopters",
    livery_id = slot.livery, x = slot.x, y = slot.y, heading = slot.heading, dead = false,
  })
  -- The copies show on the F10 map: tested in 2.9.30, statics added by script ignore
  -- `hidden` (and hiddenOnPlanner / hiddenOnMFD). The user chose to keep them visible.
end

-- Parks every slot that has been empty for `delay` seconds and whose spot is clear.
local function fill(now, delay)
  for _, slot in ipairs(slots) do
    if unitExists(slot.unit) or parkedCopy(slot) then
      emptySince[slot.unit] = nil
    else
      emptySince[slot.unit] = emptySince[slot.unit] or now
      if now - emptySince[slot.unit] >= delay and spotIsClear(slot) then
        park(slot)
        emptySince[slot.unit] = nil
      end
    end
  end
end

local handler = {}
function handler:onEvent(event)
  if event.id ~= world.event.S_EVENT_BIRTH or not event.initiator then return end
  local slot = bySlotUnit[event.initiator:getName()]
  local copy = slot and parkedCopy(slot)
  if copy then copy:destroy() end
end

function M.start()
  if not M.isSinglePlayer() then
    env.info("Rotor Gym: parked helicopters are single player only; skipping")
    return false
  end
  slots, bySlotUnit, emptySince = M.slots(), {}, {}
  for _, slot in ipairs(slots) do bySlotUnit[slot.unit] = slot end
  world.addEventHandler(handler)
  -- Wait for the player's helicopter before parking anything: a module can take
  -- seconds to load, and a copy parked on the player's slot in that time would be
  -- spawned into. Then the first pass parks every empty slot at once; after that,
  -- vacated slots wait RESPAWN_DELAY before their copy returns.
  timer.scheduleFunction(function(_, now)
    if not world.getPlayer() then return now + 1 end
    timer.scheduleFunction(function(_, t) fill(t, 0) end, nil, now + M.START_DELAY)
    timer.scheduleFunction(function(_, t)
      fill(t, M.RESPAWN_DELAY)
      return t + M.POLL_INTERVAL
    end, nil, now + M.START_DELAY + M.POLL_INTERVAL)
  end, nil, timer.getTime() + 1)
  return true
end

return M
