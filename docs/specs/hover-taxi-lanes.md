# Hover-taxi lanes

**Status:** planned
**Size classes:** one set of lanes per class

## Purpose
Hover-taxi forward, rearward and sideways along a marked lane, keeping height and
staying inside the lane.

## Location
Within about 2 nm of the spawn, next to the hover box. Not chosen yet.

## Layout
- Straight lanes marked with cones, about 1.5 D wide (D = the class's largest footprint).
- Separate lanes, or marked directions, for forward, rearward and sideways.

## Player flow
- F10 menu: start a run in a chosen direction.
- The run fails if the helicopter leaves the lane or climbs above the height limit; it is timed otherwise.

## Tests
- Script: lane-containment and height checks, direction handling, run states. Run against the DCS stub.
- In game: lane widths per class, and whether the markers read clearly at hover height.

## Open questions
- Lane length.
- One lane per direction, or one lane flown in each direction.
- Height limit per class.
