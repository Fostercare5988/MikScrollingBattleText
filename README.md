# Mik's Scrolling Battle Text

A customizable scrolling combat text replacement for World of Warcraft 1.12.1.

## Features

- **Customizable Scroll Areas**: Independently configure and position text areas for incoming attacks, outgoing damage, heals, pet actions, and notifications.
- **Rich Combat Feedback**: Real-time display of damage hits, critical strikes, periodic ticks, heals, resists, absorbs, and interrupts.
- **Precision Overheal Tracking**: Displays exact effective healing versus overheal amounts when paired with UnitXP SP3.
- **Interactive Layout Mover**: Visual on-screen handles make moving and resizing scroll areas intuitive.
- **Modern Typography**: Includes a clean collection of modern TrueType fonts with interactive preview cycling.
- **Custom Triggers & Alerts**: Sound and visual warnings for low health/mana, cooldown readiness, and proc notifications.

## Requirements

- **World of Warcraft 1.12.1** (Build 5875)
- [ClassicAPI v1.15.15+](https://github.com/brues-code/ClassicAPI) (`ClassicAPI.dll`)
- [SuperWoW v2.2+](https://github.com/balakethelock/SuperWoW) (`SuperWoWhook.dll` / `SuperWoWlauncher.exe`)
- [NamPower v4.6.2+](https://github.com/Emyrk/nampower) (`nampower.dll`)
- *Optional:* [UnitXP SP3](https://github.com/brues-code/UnitXP_SP3) (`UnitXP_SP3.dll`) for precision uncapped health inspection and overheal calculations.

> Note: Completely restart the game client after installing or updating DLLs. `/reload` cannot reload DLLs.

## Installation

1. Copy or clone this repository into your WoW add-on directory:
   ```text
   World of Warcraft/Interface/AddOns/MikScrollingBattleText/
   ```
2. Verify that `MikScrollingBattleText.toc` is located directly at `Interface/AddOns/MikScrollingBattleText/MikScrollingBattleText.toc`.
3. Launch WoW using the SuperWoW launcher with NamPower and ClassicAPI enabled.
4. Ensure MikScrollingBattleText is checked on the character selection AddOn screen.

## Useful Commands

| Command | Description |
| :--- | :--- |
| `/msbt` | Open graphical configuration interface |
| `/msbt reset` | Reset current profile to defaults |
| `/msbt version` | Display active version in chat |

## Limitations & Notes

- **Mouse Passthrough**: Floating combat text frames leave mouse interaction uncaptured so text never blocks targeting, clicking NPCs, or mouse camera control.
- **Overheal Precision**: Precise overheal calculation requires UnitXP SP3; standard client values are used if UnitXP is absent.

---

For detailed configuration, font settings, and trigger creation, see the [User Guide](docs/USER_GUIDE.md). Technical notes and NamPower integration are documented in [docs/NAMPOWER_4.6.2_REVIEW.md](docs/NAMPOWER_4.6.2_REVIEW.md).

## License & Credits

Original author: Mik. Maintained by [Fostercare5988](https://github.com/Fostercare5988). Licensed under the MIT License.
