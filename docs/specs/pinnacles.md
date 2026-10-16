# Pinnacles

**Status:** planned
**Size classes:** each pad labelled with the largest class that fits

## Purpose
Land on hilltops and ridges, where wind, power margin and the approach path matter.
Graded from easy to hard.

## Location
Hilltops east and south-east of the field, from a terrain survey. Planned anchors are in `src/layout.lua` (`areas`). Distances are from the planned centre point:

| Peak | Distance and bearing |
|---|---|
| 255 m | 2.3 nm, 084° |
| 615 m | 5.5 nm, 099° |
| 908 m | 5.1 nm, 126° |
| 1174 m | 8.0 nm, 147° |
| 1356 m | 7.5 nm, 118° |
| 1478 m (optional) | 9.6 nm, 158° |

These are forested ridges rather than isolated peaks. The tops haven't been checked in game for trees or for usable flat spots.

## Layout
- A marked pad (a helipad static or smoke) on each chosen top, labelled with its height and the class that fits.
- Brainstorm extra (idea): a "low power pinnacle" placed near the top of the power margin.

## Player flow
- F10 menu: smoke on or off at a pinnacle, and information about it (height, size class, wind).
- No scoring beyond an optional touchdown check.

## Tests
- Build: pads placed at the surveyed points, with their labels.
- In game: whether each top is clear of trees and level enough, and how big it is.

## Open questions
- Which tops to use after a visual check.
- Whether to clear trees with the "remove scenery objects" trigger.
