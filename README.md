# Rotor Gym

A DCS World helicopter practice mission at Kobuleti (Caucasus), for single player and co-op.

## Layout

- `mission/` — the unpacked mission as the Mission Editor saves it (the source of truth)
- `src/` — Lua 5.1 build scripts and data (`helicopters.lua` lists the flyable types, `variants.lua` the day and night missions)
- `scripts/` — Lua 5.1 scripts that run inside the mission (bundled into the .miz)
- `tests/` — Lua 5.1 tests
- `docs/specs/` — one spec per practice area, with an index of status and shared decisions
- `docs/buildings/` — the rooftop survey (screenshots and TSV data)
- `tools/` — Node helpers for building Lua, packing the `.miz`, versions and releases
- `out/` — built missions (not committed)

## Tasks

Install [mise](https://mise.jdx.dev), then:

```sh
mise run test                 # run the tests (builds Lua 5.1.5 with zig on first use)
mise run lint                 # lua-language-server check, pinned to Lua 5.1 by .luarc.json
mise run build                # -> out/Rotor_Gym_<version>.miz and out/Rotor_Gym_Night_<version>.miz
mise run miz:unpack -- <file> # take a Mission Editor save back into mission/
mise run version              # the version the build would use
```

## Versions and releases

The version comes from git tags. A commit tagged `v1.2.0` builds `Rotor_Gym_1.2.0.miz`; anything
else builds a development version such as `1.2.0-3-gabc1234`. Only releases get a new tag.

To release, tag the commit and push the tag. GitHub Actions builds, tests and publishes the
release. To publish from your own machine instead, run `mise run release:publish` with the
GitHub CLI signed in.

## Adding a helicopter

Append one entry to `src/helicopters.lua`, then rebuild. It gets cold and hot slots at the hub
and is offered for dynamic spawn.
