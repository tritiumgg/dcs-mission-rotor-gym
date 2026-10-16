-- A small fake of the DCS mission-scripting API, enough to run mission scripts in tests.
-- stub.install(missionTable) sets the DCS globals; the returned world lets tests
-- spawn and remove units, advance time and inspect what the script did.

local S = {}

function S.install(missionTable)
  local w = {
    time = 0,
    units = {},        -- name -> { name, x, y, alive }
    statics = {},      -- name -> { data = addStaticObject table, country, alive }
    added = {},        -- every addStaticObject call, in order
    scheduled = {},    -- { fn, arg, at }
    handlers = {},
  }

  local function point(x, y) return { x = x, y = 18, z = y } end

  local function unitObject(u)
    return {
      getName = function() return u.name end,
      isExist = function() return u.alive end,
      getPoint = function() return point(u.x, u.y) end,
    }
  end

  local function staticObject(s)
    return {
      getName = function() return s.data.name end,
      isExist = function() return s.alive end,
      getPoint = function() return point(s.data.x, s.data.y) end,
      destroy = function() s.alive = false end,
    }
  end

  local function log(_) end
  _G.env = { mission = missionTable, info = log, warning = log, error = log }
  _G.Unit = {
    getByName = function(name)
      local u = w.units[name]
      if u and u.alive then return unitObject(u) end
    end,
  }
  _G.StaticObject = {
    getByName = function(name)
      local s = w.statics[name]
      if s and s.alive then return staticObject(s) end
    end,
  }
  _G.coalition = {
    addStaticObject = function(country, data)
      local s = { data = data, country = country, alive = true }
      w.statics[data.name] = s
      table.insert(w.added, s)
      return staticObject(s)
    end,
  }
  _G.timer = {
    getTime = function() return w.time end,
    scheduleFunction = function(fn, arg, at)
      table.insert(w.scheduled, { fn = fn, arg = arg, at = at })
      return #w.scheduled
    end,
  }
  _G.world = {
    event = { S_EVENT_BIRTH = 15 },
    -- The single player's unit: the first unit spawned with player = true.
    getPlayer = function()
      for _, u in pairs(w.units) do
        if u.alive and u.player then return unitObject(u) end
      end
    end,
    addEventHandler = function(h) table.insert(w.handlers, h) end,
    VolumeType = { SPHERE = 2 },
    -- Calls fn for every live unit inside the sphere.
    searchObjects = function(_, volume, fn)
      local c, r = volume.params.point, volume.params.radius
      for _, u in pairs(w.units) do
        if u.alive and (u.x - c.x) ^ 2 + (u.y - c.z) ^ 2 <= r * r then fn(unitObject(u)) end
      end
    end,
  }
  _G.Object = { Category = { UNIT = 1 } }

  -- A unit appears (a player takes a slot) and the BIRTH event fires. `player` marks
  -- the single player's own unit.
  function w.spawn(name, x, y, player)
    w.units[name] = { name = name, x = x, y = y, alive = true, player = player }
    for _, h in ipairs(w.handlers) do
      h:onEvent({ id = 15, time = w.time, initiator = unitObject(w.units[name]) })
    end
  end

  function w.despawn(name) w.units[name].alive = false end

  -- Moves time forward, running scheduled functions that come due (and the ones they
  -- schedule) in time order. A function's numeric return reschedules it, as in DCS.
  function w.advance(seconds)
    local target = w.time + seconds
    while true do
      local nextIndex
      for i, s in ipairs(w.scheduled) do
        if s.at <= target and (not nextIndex or s.at < w.scheduled[nextIndex].at) then nextIndex = i end
      end
      if not nextIndex then break end
      local s = table.remove(w.scheduled, nextIndex)
      w.time = s.at
      local again = s.fn(s.arg, w.time)
      if type(again) == "number" then table.insert(w.scheduled, { fn = s.fn, arg = s.arg, at = again }) end
    end
    w.time = target
  end

  function w.liveStatics()
    local n = {}
    for name, s in pairs(w.statics) do if s.alive then n[#n + 1] = name end end
    table.sort(n)
    return n
  end

  return w
end

-- A mission table with the given helicopter groups in one blue country.
-- Each slot: { group = "UH-1H Cold Start", unit = "RG Slot UH-1H Cold Start", type = "UH-1H",
--              x = ..., y = ..., heading = radians, skill = "Client", livery = "..." }
function S.mission(slots, extra)
  local groups = {}
  for i, s in ipairs(slots) do
    groups[i] = {
      name = s.group, groupId = i, dynSpawnTemplate = s.template,
      units = { { name = s.unit, unitId = i, type = s.type, skill = s.skill or "Client",
                  x = s.x, y = s.y, heading = s.heading or 0, livery_id = s.livery } },
    }
  end
  local m = {
    coalition = {
      blue = { country = { { id = 80, name = "CJTF Blue", helicopter = { group = groups } } } },
      red = { country = {} },
    },
  }
  for k, v in pairs(extra or {}) do m[k] = v end
  return m
end

return S
