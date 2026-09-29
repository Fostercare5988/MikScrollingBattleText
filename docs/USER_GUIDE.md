# Mik's Scrolling Battle Text User Guide

Detailed configuration, scroll area customization, and trigger reference for **MSBT**.

---

## 1. Opening Configuration & Moving Scroll Areas

- **Options Window**: Type `/msbt` in chat to open the options panel.
- **Scroll Area Movers**:
  - In `/msbt`, navigate to **Scroll Areas**.
  - Click the **Move / Resize** buttons to reveal on-screen drag handles for each combat text container (Incoming, Outgoing, Notification, and Static).
  - Drag to reposition or drag corner grips to adjust height and width.
  - Click **Save** to lock in your coordinates.
- **Resetting Settings**: Type `/msbt reset` to restore default positions and styling.

---

## 2. Configuring Combat Events & Typography

### Event Settings
Under `/msbt` > **Events**, you can toggle, customize colors, and adjust sound alerts for specific combat events:
- **Incoming Damage & Heals**: Configure how hits, criticals, dots, and heals applied to your character appear.
- **Outgoing Damage & Heals**: Configure your player and pet attacks, spells, crits, and heals applied to targets.
- **Absorbs and Immunities**: Absorbed damage displays as `ABSORB!`, while genuine damage immunities display as `IMMUNE!`.
- **Overhealing**: When UnitXP SP3 is available, MSBT calculates exact effective healing versus overheal (e.g. `+1200 [400 overheal]`).

### Fonts and Aesthetics
- Under `/msbt` > **Font Settings**, choose normal and critical hit fonts independently.
- Use the quick arrow buttons (`<` / `>`) or mousewheel scrolling over the dropdown to preview fonts in real time.
- Adjust font sizes, outlines (Thin, Thick, None), text opacity, and scroll speeds per area.

---

## 3. Custom Triggers & Alerts

Under `/msbt` > **Triggers**, configure custom warnings and audio cues:
- **Low Health / Mana Warnings**: Audible and visual alerts when health or mana drops below your chosen percentage.
- **Cooldown Readiness**: Announce when essential class abilities (e.g., execute, counterspell, shield wall) come off cooldown.
- **Combo Points & Buffs**: Visual notifications when reaching max combo points or gaining key procs.
