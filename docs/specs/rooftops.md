# Rooftops

**Status:** planned
**Size classes:** each roof labelled with the largest class that fits

## Purpose
Use flat-roofed buildings near the field for pinnacle-style landings, sling-load deliveries and landing practice.

## Location
Surveyed in game. Data:
- [docs/buildings/buildings.tsv](../buildings/buildings.tsv): every candidate building, with position, roof height and footprint.
- [docs/buildings/models.tsv](../buildings/models.tsv): per model, roof shape, clutter and which classes fit.
- One screenshot per model, in [docs/buildings/](../buildings/).

Best candidates:
- `ceh_ang_b`: a clean flat roof of about 118 × 86 m that fits every class. Three instances, the nearest about 0.9 nm from the spawn.
- `ceh_c`: about 50 × 60 m, fits every class. Avoid its central vent and the chimneys to the south. Farthest, about 4.5 nm.
- Small helicopters only: the narrow apartment slabs and the 16-storey towers, where machine rooms clutter the roofs.

## Layout
- A marker or smoke on each chosen roof, labelled with its roof height and the classes that fit.
- A progression: about 10–27 m halls, then 15 m blocks, 30 m slabs and 55 m towers.

## Player flow
- F10 menu: smoke on a chosen roof, and roof information.
- Sling-load deliveries to roofs, see [sling loading](sling-loading.md).

## Tests
- Build: markers at the surveyed roofs.
- In game: usable roof area and obstacles per building. The measured heights are bounding-box tops, so they include machine rooms and parapets.

## Open questions
- Which buildings to use, and in what order.
- Markers on roofs: smoke only, or statics such as an H pad.
