# NamPower 4.6.2 compatibility review

Reviewed 2026-09-26 against addon baseline 0e65b99.
Task: bounded compatibility audit and damage-shield bug fix.
ClassicAPI minimum remains 11514; NamPower supported baseline remains 4.6.2.

## Evidence

[SOURCE-VERIFIED] Official v4.6.2 source commit:
11dddf3b9da8855081b9ea05965478bf8af386cf.

- [Event contracts](https://github.com/Emyrk/nampower/blob/11dddf3b9da8855081b9ea05965478bf8af386cf/EVENTS.md),
  blob 86377537ae978af67d8a90ead3cc6d0496b945cd.
- [Function contracts](https://github.com/Emyrk/nampower/blob/11dddf3b9da8855081b9ea05965478bf8af386cf/SCRIPTS.md),
  blob ca4b56093a9cbeafc64eeff67d9ef142e8922966.
- [Damage-shield emitter](https://github.com/Emyrk/nampower/blob/11dddf3b9da8855081b9ea05965478bf8af386cf/nampower/unit.cpp#L301),
  blob 8bb188cc1e594d5f13da5e7fb24771e4b10a70e9.
- Registration/CVars: nampower/main.cpp, blob 47f96c30f2844f22d5be95e11f6019d66a3a7c8f.
- Spell events: nampower/spellevents.cpp, blob e4b8085414a63e948006ef7248ceb70b9e0595c7.
- Aura events: nampower/auras.cpp, blob 9584f5ffd9d5b2a2d632230eef08d4e92461e83a.

The complete v4.6.2...v4.6.3 diff contains a README wording change and
a guard rejecting zero-spell-ID dispel callbacks. It does not add required MSBT
APIs or change the consumed event contracts. MSBT does not register dispel events.
No 4.6.3-only dependency was identified.

## Consumed event contract check

| Family | Payload consumed by MSBT |
| --- | --- |
| SPELL_DAMAGE_EVENT_SELF/OTHER | target, caster, spell ID, amount, mitigation string, hit flags, school, aura/effect string |
| AUTO_ATTACK_SELF/OTHER | attacker, target, amount, hit flags, victim state; mitigation in slots 7-9 |
| SPELL_HEAL_BY_SELF/ON_SELF | target, caster, spell ID, amount, critical, periodic; self-heal duplicate filtered |
| SPELL_ENERGIZE_ON_SELF | spell ID in slot 3, power type in 4, amount in 5 |
| SPELL_MISS_SELF/OTHER | caster, target, spell ID, miss type |
| BUFF/DEBUFF_ADDED/REMOVED_SELF | affected unit in slot 1, spell ID in slot 3 |
| ENVIRONMENTAL_DMG_SELF | unit, damage type, amount, absorb, resist |
| DAMAGE_SHIELD_SELF/OTHER | shield owner, damaged attacker, amount, school; NO spell ID |

The three NP_EnableAutoAttackEvents, NP_EnableSpellHealEvents and
NP_EnableSpellEnergizeEvents CVars and the GetNampowerVersion,
GetSpellNameAndRankForId and GetUnitField functions exist at the pinned baseline.
This verifies the required surface; it is not a complete audit of all MSBT
classification, health timing or API-provider overlap.

## Corrected defect

Both damage-shield handlers previously treated the four-field event as a
five-field spell-damage event: GUID roles were reversed, damage was read from the
school slot, and a damage amount was treated as a spell ID. The handlers now read
the actual payload, preserve player/pet incoming/outgoing routing, and use a
generic Damage Shield label without fabricating a SpellId. Incoming pet feedback
names the shield owner.

## Validation and integration review

- Lua 5.1 mocked regression covers outgoing player, incoming player, outgoing pet,
  incoming pet and unrelated-unit filtering.
- The regression fails four scenarios against the pre-fix source and passes with
  the correction.
- Strict addon linter passes with zero errors/warnings.
- No SavedVariables, TOC/load-order, CVar ownership or startup-floor change.
- No performance claims. Complete diff/whitespace reviewed before commit.
- Test: python -B tests/test_damage_shield.py [directory-containing-lupa].
  Install/use lupa only in a development runtime, not inside the addon.

[UNVERIFIED - TEST FIRST] Test NamPower 4.6.2 with Thorns/another damage shield,
both dealt and received, including pets; verify amount, direction, school and
label. Smoke-test spells, melee, heals, power gains and aura notifications.
No in-game validation or installed DLL replacement was performed.

Retrospective: comparing actual emitter payloads exposed a bug that version
replacement and static linting could not find. Keep this addon-specific evidence
here; no new framework pattern is needed.


Support policy update (2026-09-27): the published ClassicAPI minimum is now
v1.15.15+ by explicit maintainer decision. Older capability evidence above is
retained as audit history; it does not describe the current startup guard.
