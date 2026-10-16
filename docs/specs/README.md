# Practice area specs

One spec per practice area. New specs start from [_template.md](_template.md).

**Status** says how far an area has got:

| Status | Meaning |
|---|---|
| idea | From brainstorming. Not a commitment; may never be built. |
| planned | Wanted. Will be built, in a later batch. |
| building | In the current batch. |
| done | Built, tested and checked in game. |

## Practice areas

| Area | Status | Notes |
|---|---|---|
| [Hover box](hover-box.md) | planned | Fundamentals, near the spawn |
| [Hover-taxi lanes](hover-taxi-lanes.md) | planned | Forward, rearward and sideways flight |
| [Pedal turns](pedal-turns.md) | planned | Turns about the mast and about the nose |
| [Autorotation lane](autorotation-lane.md) | planned | |
| [Slalom](slalom.md) | planned | |
| [Sling loading](sling-loading.md) | planned | |
| [Pinnacles](pinnacles.md) | planned | Hilltops east and south-east of the field |
| [Rooftops](rooftops.md) | planned | Flat-roofed buildings near the field |
| [Oil rig](oil-rig.md) | planned | Sea station |
| [Ship deck](ship-deck.md) | planned | Sea station |
| [Approach lanes](approach-lanes.md) | idea | Normal, steep and shallow approaches with gates |
| [Spot landing](spot-landing.md) | idea | Rings, scored by distance from centre |
| [Confined areas](confined-areas.md) | idea | Clearings sized in rotor diameters |
| [Slope pads](slope-pads.md) | idea | |
| [Running landings](running-landings.md) | idea | |
| [Engine failure on demand](engine-failure.md) | idea | |
| [Troops and internal cargo](troops.md) | idea | |
| [Low-level navigation](low-level-navigation.md) | idea | Valley run, checkpoint navigation, ring course |
| [Formation](formation.md) | idea | |

## Already in the mission

These aren't practice areas, but every area builds on them:

- **Player slots:** a cold-start and a hot-start slot for each official helicopter, side by side on Kobuleti's stands. Groups are named for players, such as "UH-1H Cold Start". Defined in `src/helicopters.lua` and `src/layout.lua`.
- **Dynamic spawn** at Kobuleti for multiplayer: helicopters only, cold or hot.
- **Parked helicopters** (single player only): a static copy on every empty slot stand. `scripts/parked.lua`.
- **Day and night variants:** the night mission starts at 23:00, the night after a full moon. `src/variants.lua`.

## Shared decisions

These apply to every area.

- **Site:** Kobuleti, Caucasus. Every area lies within about 10 nm of one centre point.
- **Fundamentals stay close:** the hover box, hover-taxi lanes and pedal turns go within about 2 nm of the spawn.
- **Small batches:** build one or two areas at a time, and test each batch in game before starting the next.
- **Test-first:** build scripts and in-mission scripts get Lua 5.1 tests (`mise run test`). In-mission logic runs against the DCS stub in `tests/dcs_stub.lua`.
- **Plain DCS API:** no external libraries (no MOOSE, MIST, CTLD and so on).
- **No hard-coded unit names:** players may edit the mission and add helicopters. Scripts find the pilot at runtime (F10 menu, zone entry, events) and store their group or unit when an area starts.
- **Works in single player and co-op:** per-player state where it matters, so two pilots can use different areas at once.
- **Nothing is saved between runs:** no leaderboard. Times and scores last for the session only.
- **Trees:** no API can detect trees, so every placement on grass needs a visual check in game, or a paved surface.
- **Ground life (ambience):** removed for now; may come back later.

## Size classes

Footprint is the larger of a type's rotor diameter and its length (`size` in `src/helicopters.lua`).

| Class | Types | Footprint |
|---|---|---|
| Small | SA342 L/M/Minigun, OH-58D | about 11–12 m |
| Medium | Ka-50, UH-1H, AH-64D | about 16–18 m |
| Large | Mi-24P, Mi-8, CH-47F | about 21–28 m |

How each kind of area handles size:

- **Size-critical areas** (hover box, hover-taxi lanes, pedal turns, slalom, confined areas) get one lane or pad per class, side by side, drawn in units of the class's largest footprint (D).
- **Areas where size doesn't matter** (autorotation, approaches, running landings, the ship) get one shared lane. Scoring windows can still scale to the type being flown.
- **Fixed spots** (rooftops, pinnacles, oil rig) are labelled with the largest class that fits.
- **New helicopter types** pick up their class and scoring windows from their `size`.
