# pretty_levelup

A World of Warcraft 3.3.5 (WotLK) addon that shows a loot-style toast for every spell, ability, or passive you learn. It's built for servers that teach spells automatically on level up.

It uses the "You have learned a new spell/ability/passive effect" system messages, so it works whether the server sends spell links or plain text like `Frost Nova (Rank 1)`.

## Features

- One toast per learned spell, with its icon, name, and rank
- Hover for the spell tooltip, shift-click to link it in chat, right-click to dismiss
- Up to 4 toasts on screen at once (configurable); extras queue
- One sound per level-up batch, not one per toast
- Skips the duplicate spell messages the game sends after a loading screen or a dual-spec swap

## Install

1. Download or clone this repo into `World of Warcraft/Interface/AddOns/`.
2. Make sure the folder is named `pretty_levelup`.
3. Restart the game.

## Usage

- `/levelup test`: show a sample toast

## Configuration

Edit `config.lua`:

| Option | Default | Description |
| --- | --- | --- |
| `scale` | `1` | Toast size |
| `sound` | `true` | Play a sound |
| `sound_file` | `"levelup.mp3"` | Sound file in `assets/` (.mp3, .ogg, .wav) |
| `numbuttons` | `4` | Toasts shown at once (max 8) |
| `anims` | `true` | Glow and shine animations |
| `point_x`, `point_y` | `0`, `120` | Toast position |
| `spell_quality` | `4` | Border and name color (2 green, 3 blue, 4 purple, 5 orange, 7 gold) |

## Credits

- Based on [pretty_lootalert](https://github.com/s0h2x/pretty_lootalert) by s0h2x.
- Sound: "Arcade UI 1" by floraphonic, from [Pixabay](https://pixabay.com/).
