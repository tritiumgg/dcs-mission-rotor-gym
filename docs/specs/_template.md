# <Practice area name>

**Status:** idea | planned | building | done
**Size classes:** Small / Medium / Large (see [the index](README.md#size-classes)), or "all, one shared lane"

## Purpose
What the pilot practises here, in one or two sentences.

## Location
Where it goes and why. Distance and bearing from the spawn point. Point to the data
(`src/layout.lua`, a TSV in `docs/`) rather than copying coordinates here.
Note anything checked in game (trees, clutter, surface) and anything not yet checked.

## Layout
What is placed: markers, zones, statics, lanes. How it scales per size class.

## Player flow
How a pilot starts, uses and resets the area: F10 menu entries, triggers, messages,
timers or scoring. Scripts find the pilot at runtime and store their group or unit;
nothing depends on our slot names.

## Tests
What the Lua tests cover (build output, script logic with the DCS stub) and what
needs checking in game.

## Open questions
Decisions still to make.
