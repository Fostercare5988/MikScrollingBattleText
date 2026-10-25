# Mik's Scrolling Battle Text user guide

Open `/msbt`. The six pages are **General, Incoming, Outgoing, Notification,
Triggers and Suppressions**. Changes normally apply immediately and are saved by
the game in `MikSBT_Save` on a normal logout/reload.

## General and profiles

General contains enable/disable, animation speed (1–5), partial effects,
sticky criticals, mana-gain display, low-health/low-mana sounds, resist sound,
game damage and profile controls. Resist sound applies to Cone of Cold/Frost Nova.
Show All Mana Gains displays observed increases, including regeneration/drinking;
spell mana gains share that stream. Energy/rage spell gains remain separate.

Select a profile, then **Load Profile**. **Create Profile** creates defaults under
the entered name; it does not copy the current profile. **Reset Profile** and
**Delete Profile** use the existing confirmation dialogs. `/msbt reset` immediately
resets the current profile, including custom triggers and filters. Existing profile choices are preserved when updating.

**Edit Master Font Settings** sets normal/critical font, outline and size. Area and
event font editors can inherit these values or override them. Font sizes are
12–64; arrow buttons or mousewheel over font selectors/previews cycle fonts.
**Edit Game Damage Font** edits native damage text separately; it changes after
you log in again.
There is no separate opacity control.

## Incoming, Outgoing and Notification

Each page enables its area and lists events. Rows have an enabled choice, color,
editable message and font button. Click the message to edit it; Enter accepts and
clears focus, Escape restores the previous message. Tooltips list supported
substitutions (such as `%a` amount, `%n` name, `%s` spell). Scroll to the last rows.

**Configure Scroll Area** opens movers for three areas: Incoming, Outgoing and
Notification. Drag a handle to move an area. The control dialog selects the area,
animation style, direction, alignment, scroll height (100–600), and numeric X/Y
offsets. Width and corner resizing are not controls. **Preview** temporarily applies
the layout and displays samples; **Save Settings** accepts it. **Cancel** or Escape
restores the previous layout and stops active drags. Dialogs scale down to fit the
UI canvas; verify comfort/input at your chosen game resolution and UI scale.

Player/pet damage and heals come from ClassicAPI's combat log. Melee against different
GUIDs remains distinct even if names match; configured spell merging can combine
targets and labels those results Multiple. Critical counts and totals are retained.
Absorbs and immunity use distinct events. Damage shields supply no spell ID and
use the generic Damage Shield name without an invented icon.

**Healing amounts are total healing.** The combat log reports no overheal, so
MSBT shows none.

Killing blows come from the combat log: a player you killed counts as a player
kill even if you never targeted them. Power Losses shows mana, rage or energy
drained from you. Reputation changes come with the faction's name and amount.

## Triggers and suppressions

Triggers lists enabled state, message, color, font and trigger settings. **Add New
Trigger** creates an entry. Its editor supports class restrictions and these types:
player health/mana, pet health, enemy/friendly target health (1–100% threshold);
Aura Gained (an aura name, for example Clearcasting); You Dodge; You Parry; Your
Attack Dodged; and Search Pattern over selected chat events. All but the threshold
types can require a stance. Any trigger can show an icon; clear the icon field to
remove it. The built-in Overpower, Riposte, Counterattack, Mongoose Bite,
Clearcasting, Nightfall and Windfury alerts use the event types; saved copies you
never edited move over on load. Save Settings accepts the
editor; Cancel leaves saved trigger settings intact. Thresholds fire when crossing
below the percentage. Target changes reconsider the new target.

Search patterns accept Lua patterns or a native global format-string name;
captures can be inserted with `%1`–`%9`. Invalid patterns do not break processing.
Readiness defaults are health/proc/search alerts (for example Execute), not a
general cooldown scheduler. MSBT does not track arbitrary cooldown completion.

Suppressions adds enabled Lua patterns matched against formatted output/spell
names. Edit the row message to change the pattern. Invalid patterns match nothing.
Keep patterns narrow enough to preserve useful encounter text.

## Other displays and commands

MSBT keeps its own combat events, profiles and animations. FostercareTweaks owns
its energy/mana tick indicator; UnitXP owns its optional floating combat text.
MSBT leaves their settings alone. Show Game Damage still controls native damage
above heads. BigWigs can send chosen notifications through the unchanged
`MikSBT.DisplayMessage` interface. Threat/encounter packages remain independent.

Commands: `/msbt`, `/msbt enable`, `/msbt disable`, `/msbt version`, `/msbt reset`.
`/msbt search CHAT_MSG` enables diagnostic event text; `/msbt search` stops it.
Leave diagnostic output off during frame-pacing tests.

Requirements: ClassicAPI 1.17.7+. SuperWoW, NamPower and UnitXP are not needed. DLL updates require a full restart. Use your configured client launcher.
