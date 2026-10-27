# Mik's Scrolling Battle Text

Scrolling combat text for World of Warcraft 1.12.1: player and pet damage,
heals, misses, absorbs, critical hits, resource gains and configurable alerts.

## Requirements

- World of Warcraft 1.12.1 (build 5875).
- ClassicAPI 1.17.11 or newer. SuperWoW, NamPower and UnitXP are not needed.

Load ClassicAPI with your client's launcher; DLL changes need a complete client
restart.

## Install or update

Download `MikScrollingBattleText-1.2.0.zip` from
[Releases](https://github.com/Fostercare5988/MikScrollingBattleText/releases/latest).
Close the game and extract it into `Interface/AddOns`, so the TOC is at
`Interface/AddOns/MikScrollingBattleText/MikScrollingBattleText.toc`.
Enable the addon on the character-selection screen. Keep existing SavedVariables
when updating to preserve profiles, fonts, triggers, filters and positions.

## Configure

Type `/msbt`. The tabs are General, Areas, Incoming, Outgoing, Notices, Triggers,
Filters and Profiles. See [the user guide](docs/USER_GUIDE.md).

Commands: `/msbt`, `/msbt enable`, `/msbt disable`, `/msbt version`, `/msbt reset`.

## Healing and other displays

All combat text comes from ClassicAPI's combat log; heals show the total, as the
log reports no overheal. Reputation comes from its `FACTION_STANDING_CHANGED`
event.

Show Game Damage controls native damage above enemy heads. Other addons retain
their own resource, floating-text and encounter displays. Combat text does not
capture mouse input.

## License and credits

Original author: Mik. Maintained by [Fostercare5988](https://github.com/Fostercare5988). Licensed under the MIT License.
The table recycler credits tekkub's compostLib; the settings window uses the ForgeUI kit. Original source credits are retained.
