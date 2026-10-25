# Mik's Scrolling Battle Text

Scrolling combat text for World of Warcraft 1.12.1: player and pet damage,
heals, misses, absorbs, critical hits, resource gains and configurable alerts.

## Requirements

- World of Warcraft 1.12.1 (build 5875).
- ClassicAPI 1.17.7 or newer, SuperWoW 2.2, and NamPower 4.6.2 or newer.

Use your client's configured launcher to load those DLLs. DLL changes require
a complete client restart. UnitXP is not required by MSBT.

## Install or update

Download `MikScrollingBattleText-1.0.0.zip` from
[Releases](https://github.com/Fostercare5988/MikScrollingBattleText/releases/latest).
Close the game and extract it into `Interface/AddOns`, so the TOC is at
`Interface/AddOns/MikScrollingBattleText/MikScrollingBattleText.toc`.
Enable the addon on the character-selection screen. Keep existing SavedVariables
when updating to preserve profiles, fonts, triggers, filters and positions.

## Configure

Type `/msbt`. The six pages are General, Incoming, Outgoing, Notification,
Triggers and Suppressions. Configure each scroll area, normal/critical fonts,
event messages and alerts. Movers support drag positioning, scroll height,
preview, save and cancel. See [the user guide](docs/USER_GUIDE.md).

Commands: `/msbt`, `/msbt enable`, `/msbt disable`, `/msbt version`.
`/msbt reset` immediately resets the current profile, including custom triggers
and filters. Use the existing profile controls when managing multiple profiles.

## Healing and other displays

Heals show the total NamPower reports; no installed provider reports overheal.
Killing blows and drained power come from ClassicAPI's combat log, and
reputation from its `FACTION_STANDING_CHANGED` event.

Show Game Damage controls native damage above enemy heads. Other addons retain
their own resource, floating-text and encounter displays. Combat text does not
capture mouse input.

## License and credits

Original author: Mik. Maintained by [Fostercare5988](https://github.com/Fostercare5988). Licensed under the MIT License.
The table recycler credits tekkub's compostLib; original source credits are retained.
