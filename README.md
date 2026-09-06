# Mik's Scrolling Battle Text

[![Interface: 1.12.1](https://img.shields.io/badge/Interface-1.12.1%20(5875)-orange.svg)](https://github.com/Fostercare5988/MikScrollingBattleText)
[![Version: 6.5.0](https://img.shields.io/badge/Version-6.5.0-blue.svg)](https://github.com/Fostercare5988/MikScrollingBattleText/releases)
[![ClassicAPI: v1.14.0+](https://img.shields.io/badge/ClassicAPI-v1.14.0+-green.svg)](https://github.com/brues-code/ClassicAPI)
[![SuperWoW: v2.2+](https://img.shields.io/badge/SuperWoW-v2.2+-brightgreen.svg)](https://github.com/balakethelock/SuperWoW)
[![NamPower: v4.6.3+](https://img.shields.io/badge/NamPower-v4.6.3+-blueviolet.svg)](https://github.com/Emyrk/nampower)
[![UnitXP: SP3](https://img.shields.io/badge/UnitXP-SP3-teal.svg)](https://github.com/brues-code/UnitXP_SP3)
[![DXVK: Vulkan](https://img.shields.io/badge/DXVK-Vulkan-red.svg)](https://github.com/doitsujin/dxvk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Mik's Scrolling Battle Text (MSBT) v6.5.0** is an enterprise-grade, zero-latency combat text display engine engineered natively for **World of Warcraft 1.12.1 (Build 5875)** running on the **Enhanced Client Extension Stack** (**ClassicAPI v1.14.0+**, **SuperWoW v2.2+**, **NamPower 4.6.3+**, **UnitXP SP3**, and **DXVK**).

MSBT replaces the default scrolling combat text with fully customizable scroll areas, dynamic combat event notifications, high-precision overheal tracking, and native binary packet parsing via NamPower.

Created and actively maintained by **[Fostercare5988](https://github.com/Fostercare5988)**.

---

## 🚀 Engine Architecture & Performance

MSBT is engineered around strict low-level system integration:

| Engine Component | Minimum Version | Architectural Role & Implementation |
| :--- | :--- | :--- |
| **ClassicAPI** | `v1.14.0+` | C++ hardware timers (`C_Timer.NewTicker`), native bitwise operations (`bit.band`), unconditional C++ `table.wipe` memory recycling, and source-rewritten Lua 5.1 syntax. |
| **SuperWoW** | `v2.2+` | Direct memory state access, zero-latency combat synchronization, and OS-level window alerting. |
| **NamPower** | `v4.6.3+` | Microsecond-precision combat pipeline and frame-0 event dispatching (`SPELL_DAMAGE_EVENT_*`, `AUTO_ATTACK_*`, `SPELL_MISS_*`, `SPELL_HEAL_*`, `ENVIRONMENTAL_DMG_SELF`). |
| **UnitXP** | `SP3` | High-precision uncapped unit HP inspection to calculate exact effective healing vs. overheal amounts live. |
| **DXVK** | `Latest` | Decoupled high-refresh frame pacing with zero garbage collection heap churn and smooth text scrolling animations. |

### Elimination of 2006 Legacy Techniques
- **Zero Chat Log Scraping**: Combat feedback intercepts NamPower binary events directly, completely bypassing slow string matching and chat log formatting overhead.
- **Zero OnUpdate Polling**: Eradicated legacy per-frame `OnUpdate` polling loops in favor of native hardware tickers (`C_Timer.NewTicker(5.0, ...)`).
- **Strict Mouse Passthrough (Rule C8)**: All three active combat text scroll frames (`MSBTFrameIncoming`, `MSBTFrameOutgoing`, `MSBTFrameNotification`) leave mouse input unintercepted (`enableMouse="false"`), ensuring floating combat text never blocks targeting, clicking NPCs, or mouse-look.
- **Zero-GC Table Recycler**: Combat animations and event tables reuse pre-allocated pools via `MikTableRecyclerObject` and native C++ `table.wipe`, eliminating garbage collection stutter.

---

## ⚡ Key Features

### 1. High-Performance Combat Event Feedback
- **Direct Binary Packet Processing**: Intercepts NamPower binary events (`SPELL_DAMAGE_EVENT_*`, `AUTO_ATTACK_*`, `SPELL_MISS_*`, `SPELL_HEAL_*`, `ENVIRONMENTAL_DMG_SELF`) for zero-latency combat feedback.
- **Accurate Absorb vs. Immune Classification**: Fixed 1.12.1 `VictimState` and full-shield absorption logic so complete absorbs display clean `ABSORB!` banners while genuine mechanic/shield immunities display `IMMUNE!`.
- **Precision Overheal Tracking**: Integrated with **UnitXP SP3** uncapped HP inspection to calculate exact effective vs. overheal amounts live.

### 2. Fully Customizable Scroll Areas
- **Multiple Scroll Areas**: Independent customizable areas for incoming damage/heals, outgoing player damage/heals, pet actions, and notifications.
- **Visual Mover Mode**: Intuitive drag-and-drop handles for moving and sizing scroll areas dynamically on screen.
- **Font & Style Customization**: Per-event font selection, size, outline, animation speed, and color customization.

---

## ⌨️ Slash Commands & Configuration Matrix

Use `/msbt`:

| Command / Action | Description |
| :--- | :--- |
| `/msbt` | Opens the graphical options interface |
| `/msbt reset` | Resets current profile settings to default |
| `/msbt version` | Displays active MSBT version in chat |

---

## 📦 Installation & Engine Prerequisites

### Prerequisites
1. **World of Warcraft 1.12.1** (Build 5875).
2. [**ClassicAPI v1.14.0+**](https://github.com/brues-code/ClassicAPI) (`ClassicAPI.dll`).
3. [**SuperWoW v2.2+**](https://github.com/balakethelock/SuperWoW) (`SuperWoW.dll`).
4. [**NamPower v4.6.3+**](https://github.com/Emyrk/nampower) (`nampower.dll`).
5. [**UnitXP SP3**](https://github.com/brues-code/UnitXP_SP3) (`UnitXP_SP3.dll`).
6. [**DXVK**](https://github.com/doitsujin/dxvk) & [**VanillaFixes**](https://github.com/hannesmann/vanillafixes).

### Step-by-Step Installation
1. Clone or download the repository into your WoW AddOns directory:
   ```text
   World of Warcraft/Interface/AddOns/MikScrollingBattleText/
   ```
2. Verify that `MikScrollingBattleText.toc` is located directly at:
   ```text
   World of Warcraft/Interface/AddOns/MikScrollingBattleText/MikScrollingBattleText.toc
   ```
3. Launch the game using your DLL loader or launcher with ClassicAPI and SuperWoW enabled.
4. Ensure **Mik's Scrolling Battle Text** is checked in the character selection AddOn screen.

---

## 📜 Changelog

### v6.5.0
- **Modern Clean Font Pack**: Added 8 ultra-clean, modern TrueType fonts (`Google Sans Bold`, `Google Sans Medium`, `Apple SF Pro Display`, `Apple SF Pro Text`, `Inter Bold`, `Inter SemiBold`, `Roboto`, `Roboto Mono`) to replace dated cartoonish typography with crisp, readable modern aesthetics. Default master font updated to Google Sans Bold.
- **Quick Font Cycling Controls**: Integrated clickable previous (`<`) and next (`>`) arrow navigation buttons alongside Normal and Crit font dropdown menus in the Font Settings window for instant previewing without tedious dropdown reopening.
- **Mousewheel Cycling Integration**: Added smooth mousewheel scroll support over font dropdowns and preview text panels for rapid cycling through available fonts.

### v6.4.0
- **Numeric Engine Startup Guards**: Standardized startup guards across all modules (`MikTableRecyclerObject.lua`, `MikCombatEventHelper.lua`, `MikScrollingBattleText.lua`, `MSBTOptions.lua`) with strict numeric boundary validation (`MIN_CLASSIC_API = 11400`).
- **Modern Table Operations**: Replaced legacy `table.getn` lookups across options tabs and event configuration with native `#` length operator.
- **Pre-commit Linter Integration**: Configured strict pre-commit static analysis hook enforcing zero warnings and zero errors.

### v6.3.1
- **Unconditional C++ Memory Operations**: Eradicated remaining 2006 fallback nil-loops in `RepositionAnimDisplayInfo`, `RepositionStickyAnimDisplayInfo`, and `OnUpdate` merge routines in favor of direct, unconditional C++ `table.wipe`.
- **Metadata & Style Cleanup**: Pruned legacy marketing buzzwords (high-refresh rate marketing notations) from `.toc` notes in strict adherence to Enhanced Engine linter standards.
- **Verified Engine Integrity**: 100% pass across all syntax, AST, and DLL dependency checks via enhanced engine linter suite.

### v6.3.0
- **Universal Engine Guard**: Enforced strict dependency checks across all modules (`MikTableRecyclerObject.lua`, `MikCombatEventHelper.lua`, `MikScrollingBattleText.lua`, `MSBTOptions.lua`) for ClassicAPI v1.14.0+ and SuperWoW v2.2+.
- **Unconditional C++ Memory Operations**: Streamlined `MikTRO:EraseTable` to unconditionally invoke native C++ `table.wipe(t)`.
- **Native Bitwise Integration**: Leveraged native `bit` library without fallback nil checks.
- **Updated Documentation**: Fully aligned README with ClassicAPI v1.14.0+ and SuperWoW v2.2+ standards.

### v6.2.0
- **Native Memory Operations**: Integrated native C++ `table.wipe` into `MikTRO:EraseTable` and all active sticky/non-sticky/merge array cleanups.
- **Universal Engine Stack Standardization**: Modernized startup dependency check to inspect `CLASSIC_API_VERSION` and `SUPERWOW_VERSION` globals.
- **Modern Lua 5.1 AST Syntax**: Modernized table length checks to `#` syntax.

### v6.1.0
- **Eradicated OnUpdate Polling**: Replaced `MCEHEventFrame:OnUpdate` polling loop with native `C_Timer.NewTicker(5.0, ...)`.
- **Zero-Bloat Consolidation**: Consolidated 180 lines of legacy version migrations and unified 4 repetitive trigger parsers into `CheckHealthThresholds`.
- **Absorb vs. Immunity Fix**: Corrected NamPower `VictimState` enum mapping and full absorption handling.

---

## 📄 License & Community

- **Original Author**: **Mik**
- **Author & Maintainer**: **[Fostercare5988](https://github.com/Fostercare5988)**
- **GitHub Repository**: [https://github.com/Fostercare5988/MikScrollingBattleText](https://github.com/Fostercare5988/MikScrollingBattleText)
- **License**: MIT License - See [LICENSE](LICENSE) for details.
