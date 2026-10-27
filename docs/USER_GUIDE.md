# Mik's Scrolling Battle Text user guide

Type `/msbt` to open the settings. The tabs are **General, Areas, Incoming,
Outgoing, Notices, Triggers, Filters and Profiles**. Every change applies at
once and is saved in `MikSBT_Save` when you log out or reload. The close button
or Escape closes the window.

## General

Turn MSBT on or off, and choose partial effects (absorbed, blocked, resisted,
crushing and glancing amounts), sticky critical hits, all mana gains
(regeneration and drinking included), the game's own damage numbers, the
low health, low mana and frost-resist sounds, and the scroll speed.
**Fonts** sets the master font, outline and size for normal and critical text;
areas and events inherit them unless you change them. **Game damage font**
changes the game's own damage numbers after you log in again.

In a font editor, the arrows or the mouse wheel step through the fonts. **Inherit
size** uses the size of the area or master font; turn it off to set a size
(12-64).

## Areas

Pick Incoming, Outgoing or Notices, then its movement (straight or curved, up or
down), text alignment, scroll height and fonts. **Move areas** shows a handle per
area: drag it to place the area, and click **Move areas** again to hide the
handles. **Preview** shows a sample line in each area. **Reset positions** puts
all three areas back.

## Incoming, Outgoing and Notices

One row per event: turn it on or off, click the dot to pick its color, click the
message to edit it (Enter saves, Escape keeps the old text), and **Font** edits
its font. The message tooltip lists the codes it fills, such as `%a` amount,
`%n` name, `%s` spell and `%t` damage type. On Notices, **Sticky** pops the event
in the middle of the area instead of scrolling it. The arrows at the bottom turn
the page.

All combat text comes from ClassicAPI's combat log. Heals show the total; the
log reports no overheal. Killing blows count a player kill even when you never
targeted the player. Power Losses shows mana, rage or energy drained from you.
Reputation changes show the faction and amount. Experience Gains shows every
gain: kills, quests and exploring.

## Triggers

Each trigger shows a message when something happens. A row has an on/off switch,
the message (click to edit), its color, **Sticky**, **Font**, **Edit** and **X**
to delete. **Add trigger** creates one and opens its editor.

The editor sets the type, the classes it applies to, an icon path and:

- **Threshold types** (self health or mana, pet health, enemy or friendly target
  health): the percentage it fires below.
- **Aura Gained**: the exact buff name, for example Clearcasting.
- **You Dodge**, **You Parry**, **Your Attack Dodged**: no further setting.

All but the threshold types can require a stance or form. **Save** keeps the
changes, **Cancel** drops them. The built-in Overpower, Riposte, Counterattack,
Mongoose Bite, Clearcasting, Nightfall and Windfury alerts use the event types.

## Filters

A filter hides any text whose message or spell name matches its Lua pattern.
Click a pattern to edit it, **X** deletes it, **Add filter** adds one.

## Profiles

Profiles are shared by your characters. Click a profile's dot to use it.
**Create** adds a profile with the default settings, **Delete** removes one (not
Default), and **Reset this profile** puts the current profile back to the
defaults, triggers and filters included. `/msbt reset` does the same.

## Commands and other addons

`/msbt`, `/msbt enable`, `/msbt disable`, `/msbt version`, `/msbt reset`.

BigWigs and other addons can send text through `MikSBT.DisplayMessage`. MSBT
leaves other addons' floating text and settings alone.

Requirements: ClassicAPI 1.17.11+. SuperWoW, NamPower and UnitXP are not needed.
DLL updates need a full client restart.
