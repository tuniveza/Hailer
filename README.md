# Hailer

A water/rain-themed World of Warcraft (retail) addon that automatically greets people when they join your guild, group, or communities.

## Features

- **Guild**: separate "New Member" and "Came Online" greetings, each independently configurable
- **Party / Raid**, **Instance Group** (dungeon/raid/M+ premade groups): greets whoever joins your existing group
- **Communities**: greets Blizzard Community members coming online (whisper-only — Blizzard blocks addons from posting into Community chat automatically)
- **Friends**: greets in-game and Battle.net friends coming online (whisper-only — there's no chat channel for a friends list)
- **Custom Channels**: best-effort greeting for named chat channels (Trade, General, etc.) — WoW has no "channel join" event, so this greets the first message seen from each name per session
- Message pools with built-in presets, `{name}` / `{class}` / `{level}` placeholders, and random selection so greetings don't repeat
- Per-scope cooldown and chance-to-greet, both with a little randomness so it doesn't fire like clockwork
- Ignore list
- Draggable minimap icon (with an Addon Compartment entry too)
- A custom water/rain themed UI: animated rain, ripple "splash" feedback on every greet, and a caustics-textured background

## Installation

Drop the `Hailer` folder into `Interface/AddOns/`.

## Usage

`/hailer` or `/hl` opens the settings window. Everything else is configured there.

No external libraries — it's a single self-contained addon (plain SavedVariables, a hand-rolled minimap button, a hand-rolled options UI).

## Credits

- [Agave](https://github.com/blobject/agave) font (used for the title) — SIL Open Font License 1.1, see `Fonts/LICENSE`
