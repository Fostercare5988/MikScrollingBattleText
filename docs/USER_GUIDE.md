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
**Edit Game Damage Font** edits native damage text separately; its editor reports
that a client restart may be needed. A full client restart may be needed to refresh that font.
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

Player/pet damage and heals use structured NamPower events. Melee against different
GUIDs remains distinct even if names match; configured spell merging can combine
targets and labels those results Multiple. Critical counts and totals are retained.
Absorbs and immunity use distinct events. Damage shields supply no spell ID and
use the generic Damage Shield name without an invented icon.

**Healing amounts are total healing reported by NamPower.** Installed 4.6.2 events
provide no effective-heal/overheal field, and UnitXP build 90 implements neither
`health` nor `maxhealth`. Exact overheal is unavailable. The existing Show Overheals
preference remains stored but produces no estimate with these providers. Sampling
health after a heal would not establish exact overheal.

## Triggers and suppressions

Triggers lists enabled state, message, color, font and trigger settings. **Add New
Trigger** creates an entry. Its editor supports class restrictions, player
health/mana, pet health, enemy/friendly target health (1–100% threshold), or search
patterns over selected native text events. Search triggers can require a stance
and set an icon; clear the icon field to remove it. Save Settings accepts the
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

Commands: `/msbt`, `/msbt enable`, `/msbt disable`, `/msbt version`, `/msbt stats`.
`/msbt search CHAT_MSG` enables diagnostic event text; `/msbt search` stops it.
Leave diagnostic output off during frame-pacing tests.

Requirements remain ClassicAPI 1.15.15+, SuperWoW 2.2 and NamPower 4.6.2+.
UnitXP is not required for MSBT healing. DLL updates require a full restart. Use your configured client launcher.
