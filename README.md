# Mik's Scrolling Battle Text

[![Version](https://img.shields.io/badge/Version-6.2.0-blue.svg)](https://github.com/Fostercare5988/MikScrollingBattleText/releases)
[![Interface](https://img.shields.io/badge/Interface-1.12.1%20(Build%205875)-orange.svg)](https://github.com/Fostercare5988/MikScrollingBattleText)
[![Engine](https://img.shields.io/badge/Engine-ClassicAPI%20%7C%20SuperWoW%20%7C%20NamPower%20%7C%20UnitXP%20%7C%20DXVK-green.svg)](https://github.com/Fostercare5988/MikScrollingBattleText)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/Fostercare5988/MikScrollingBattleText)

**Mik's Scrolling Battle Text (MSBT)** is an ultra-high performance, zero-latency combat text display system engineered natively for **World of Warcraft 1.12.1** running the **Enhanced Client Extension Stack** (**ClassicAPI**, **SuperWoW 2.2+**, **NamPower 4.6.2+**, **UnitXP SP3**, and **DXVK**) created and maintained by **Fostercare5988**.

MSBT replaces the default scrolling combat text with fully customizable scroll areas, dynamic combat event notifications, high-precision overheal tracking, and native binary packet parsing via NamPower.

---

## ✨ Key Features

- **Direct Binary Packet Processing**: Intercepts NamPower binary events (`SPELL_DAMAGE_EVENT_*`, `AUTO_ATTACK_*`, `SPELL_MISS_*`, `SPELL_HEAL_*`, `ENVIRONMENTAL_DMG_SELF`) for zero-latency combat feedback, bypassing slow text chat combat logs.
- **Accurate Absorb vs. Immune Classification**: Fixed 1.12.1 `VictimState` and full-shield absorption logic so complete absorbs display clean `ABSORB!` banners while genuine mechanic/shield immunities display `IMMUNE!`.
- **Zero GC Churn via Object Recycler**: All combat animations and event tables reuse pre-allocated pools via `MikTableRecyclerObject` and native C++ `table.wipe`, eliminating stutter and garbage collection spikes.
- **Precision Overheal Tracking**: Integrated with **UnitXP SP3** uncapped HP inspection to calculate exact effective vs. overheal amounts live.
- **Full Customization GUI**: Type `/msbt` to open the visual configuration menu to customize scroll areas, fonts, sound alerts, triggers, and colors.

---

## 💻 Technical Architecture & Zero-Bloat Optimizations

- **Strict Engine Dependency Guard**: Declares an active runtime requirement checking `CLASSIC_API_VERSION` and `SUPERWOW_VERSION` globals.
- **Native Memory Operations**: Integrated native C++ `table.wipe` into `MikTRO:EraseTable` and internal animation queues (`activeStickies`, `activeNonStickies`, `mergeData.MergedEvents`).
- **Zero OnUpdate Polling Overhead**: Completely removed legacy per-frame `OnUpdate` polling loops in `MikCombatEventHelper` in favor of native hardware tickers (`C_Timer.NewTicker(5.0, ...)`).
- **Consolidated Generic Schema Backfiller**: Replaced 180 lines of cascading 10-step legacy 2006 migration loops (`< 2.0` through `< 4.6`) with a single generic table backfiller in `MikSBT.UpdateProfiles()`.
- **Unified DRY Threshold Parsers**: Consolidated 4 duplicate 20-line trigger functions (`ParseSelfHealthTriggers`, `ParsePetHealthTriggers`, `ParseEnemyHealthTriggers`, `ParseFriendlyHealthTriggers`) into a single parameterized `CheckHealthThresholds` helper.
- **Dead Text Parser Eradication**: Removed legacy `CHAT_MSG_COMBAT_SELF_HITS` text pattern matching, as environmental damage is 100% processed via NamPower's binary `ENVIRONMENTAL_DMG_SELF` packets.
- **Modern Lua 5.1 Syntax**: Converted all table length inspections to `#` length operator via ClassicAPI AST source-rewriter.

---

## ⌨️ Slash Commands

Use `/msbt`:

| Command | Description |
| :--- | :--- |
| `/msbt` | Opens the graphical options interface |
| `/msbt reset` | Resets current profile settings to default |
| `/msbt version` | Displays active MSBT version in chat |

---

## 📦 Installation & Requirements

1. **Requirements**:
   - **World of Warcraft 1.12.1** (Build 5875).
   - [**ClassicAPI**](https://github.com/brues-code/ClassicAPI) (`ClassicAPI.dll`).
   - [**SuperWoW**](https://github.com/balakethelock/SuperWoW) (`SuperWoW.dll` v2.2+).
   - [**NamPower**](https://github.com/Emyrk/nampower) (`nampower.dll` v4.6.2+).
   - [**UnitXP SP3**](https://codeberg.org/konaka/UnitXP_SP3) (`UnitXP_SP3.dll`).
   - [**DXVK**](https://github.com/doitsujin/dxvk) & [**VanillaFixes**](https://github.com/hannesmann/vanillafixes).
2. **Installation**:
   - Place the `MikScrollingBattleText` folder into:
     ```text
     World of Warcraft/Interface/AddOns/MikScrollingBattleText/
     ```
   - Ensure `MikScrollingBattleText.toc` is directly inside `Interface/AddOns/MikScrollingBattleText/`.
   - Enable **Mik's Scrolling Battle Text** in the AddOn list at character selection.

---

## 👤 Credits & Attribution

- **Mik** — Original creator and developer of MikScrollingBattleText.
- **Fostercare5988** — Modernization, NamPower / SuperWoW integration, Absorb/Immunity engine fix, ClassicAPI dependency guard, Zero-Bloat architectural refactoring, and repository maintenance.

---

## 📜 Changelog

### v6.2.0
- **Native Memory Operations**: Integrated native C++ `table.wipe` into `MikTRO:EraseTable` and all active sticky/non-sticky/merge array cleanups.
- **Universal Engine Stack Standardization**: Modernized startup dependency check to inspect `CLASSIC_API_VERSION` and `SUPERWOW_VERSION` globals.
- **Modern Lua 5.1 AST Syntax**: Modernized table length checks to `#` syntax.
- **Clean Standard Presentation**: Standardized TOC metadata and comprehensive documentation under Master System Prompt Rule H5.

### v6.1.0
- **Eradicated OnUpdate Polling**: Replaced `MCEHEventFrame:OnUpdate` polling loop with native `C_Timer.NewTicker(5.0, ...)`.
- **Zero-Bloat Consolidation**: Consolidated 180 lines of legacy version migrations and unified 4 repetitive trigger parsers into `CheckHealthThresholds` (-182 lines net code reduction).
- **Absorb vs. Immunity Fix**: Corrected NamPower `VictimState` enum mapping (5=Block, 6=Evade, 7=Immune, 8=Deflect/Immune) and full absorption handling (`damage == 0` with `absorb > 0`) across both auto-attacks and spell damage events.
- **ClassicAPI Guard**: Added mandatory engine dependency verification at startup.
- **Modernized TOC & Docs**: Updated TOC metadata and published comprehensive README documentation.
