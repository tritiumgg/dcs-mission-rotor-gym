# Engine failure on demand

**Status:** idea
**Size classes:** all

## Purpose
Have the engine fail unexpectedly, for realistic autorotation practice.

## Location
Anywhere; pairs with the [autorotation lane](autorotation-lane.md).

## Layout
Nothing placed.

## Player flow
- F10 menu: arm an engine failure after a random delay.
- Mechanism found so far: the Mission Editor's "SET FAILURE" trigger action (failure, probability, random delay), fired by a flag that the F10 command sets. The failures available depend on the aircraft type.

## Tests
- Build: the trigger and flag wiring.
- In game: who the failure affects in multiplayer (all players, or only the one who asked), and which failure id each type needs.

## Open questions
- Whether a per-player failure is possible in co-op.
