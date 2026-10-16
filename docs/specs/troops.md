# Troops and internal cargo

**Status:** idea
**Size classes:** troop-carrying types only

## Purpose
Load troops at one spot, fly them to a landing zone and drop them off, against the clock.

## Location
Not chosen.

## Layout
- A pickup point and a landing zone.
- Hot LZ drill (idea): a few hostile units near the LZ; enemy fire optional through the F10 menu.

## Player flow
- Our own small script (no CTLD or other libraries): F10 commands to load and unload troops, and a timer for the whole cycle.

## Tests
- Script: load and unload rules, timer. Run against the DCS stub.

## Open questions
- Whether DCS's own troop transport (dynamic cargo or internal cargo) covers this without scripting.
