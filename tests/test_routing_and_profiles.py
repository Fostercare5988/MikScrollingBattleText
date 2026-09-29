"""Regression tests for MSBT event routing, profile initialization, and queue batching.
Requires lupa Lua 5.1.
Run: python -B tests/test_routing_and_profiles.py [directory-containing-lupa]
"""
from pathlib import Path
import sys
import unittest

if len(sys.argv) > 1:
    sys.path.insert(0, sys.argv.pop(1))
from lupa.lua51 import LuaRuntime

MSBT_DIR = Path(__file__).resolve().parents[1]
CEH_SOURCE = (MSBT_DIR / "MikCombatEventHelper.lua").read_text(encoding="utf-8")
MSBT_SOURCE = (MSBT_DIR / "MikScrollingBattleText.lua").read_text(encoding="utf-8")

class MSBTRoutingAndProfileTests(unittest.TestCase):
    def test_update_profiles_resets_unversioned_profile(self):
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.execute("""
            MikSBT = { VERSION_NUMBER = 6.5 }
            MikSBT_Save = {
                CurrentProfile = "Default",
                Profiles = {
                    Default = { CreationVersion = 6.1 },
                    CustomOld = { SomeOldSetting = true } -- unversioned
                }
            }
            local resetCalledWith = nil
            function MikSBT.ProfileExists(name)
                return MikSBT_Save.Profiles[name] ~= nil
            end
            function MikSBT.ResetProfile(profileName)
                resetCalledWith = profileName
                if type(profileName) == "string" and MikSBT_Save.Profiles[profileName] then
                    MikSBT_Save.Profiles[profileName] = { CreationVersion = MikSBT.VERSION_NUMBER }
                end
            end
        """)
        # Extract UpdateProfiles from MSBT_SOURCE
        start = MSBT_SOURCE.index("function MikSBT.UpdateProfiles()")
        end = MSBT_SOURCE.index("function MikSBT.ProfileExists(", start)
        lua.execute(MSBT_SOURCE[start:end])

        lua.globals().MikSBT.UpdateProfiles()
        g = lua.globals()
        old_prof = g.MikSBT_Save.Profiles.CustomOld
        # Must have been reset and received CreationVersion
        self.assertEqual(old_prof.CreationVersion, 6.5)

    def test_spell_heal_on_self_routes_pet_heal(self):
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.execute("""
            nampowerHandlers = {}
            MikCEH = {
                DIRECTIONTYPE_PLAYER_INCOMING = 1,
                DIRECTIONTYPE_PLAYER_OUTGOING = 2,
                DIRECTIONTYPE_PET_OUTGOING = 3,
                DIRECTIONTYPE_PET_INCOMING = 4,
                HEALTYPE_NORMAL = 1,
                HEALTYPE_OVER_TIME = 2,
                HEALTYPE_CRIT = 3,
            }
            playerName = "Hero"
            function IsPlayerGUID(g) return g == "0xPLAYER" end
            function IsPetGUID(g) return g == "0xPET" end
            function GetSpellNameFromId(id) return "Mend Pet" end
            function GetNameFromGUID(g) return g == "0xCASTER" and "Priest" or nil end
            function UnitName(u) return u == "pet" and "Wolf" or "Hero" end
            function MikCEH.GetHealEventData(dir, ht, amt, spell, caster)
                return { DirectionType = dir, HealType = ht, Amount = amt, Spell = spell, Caster = caster }
            end
            overhealCheckedFor = nil
            function MikCEH.PopulateOverhealData(eventData)
                overhealCheckedFor = eventData.Name
            end
            sentEvent = nil
            function MikCEH.SendEvent(e) sentEvent = e end
        """)
        start = CEH_SOURCE.index('nampowerHandlers["SPELL_HEAL_ON_SELF"]')
        end = CEH_SOURCE.index('nampowerHandlers["SPELL_HEAL_BY_SELF"]', start)
        lua.execute(CEH_SOURCE[start:end])

        g = lua.globals()
        # Test 1: Heal on player
        g.arg1, g.arg2, g.arg3, g.arg4, g.arg5, g.arg6 = "0xPLAYER", "0xCASTER", 1234, 500, 0, 0
        g.nampowerHandlers["SPELL_HEAL_ON_SELF"]()
        self.assertEqual(g.sentEvent.DirectionType, 1) # PLAYER_INCOMING
        self.assertEqual(g.overhealCheckedFor, "Hero")

        # Test 2: Heal on pet
        g.arg1, g.arg2, g.arg3, g.arg4, g.arg5, g.arg6 = "0xPET", "0xCASTER", 1234, 300, 0, 0
        g.nampowerHandlers["SPELL_HEAL_ON_SELF"]()
        self.assertEqual(g.sentEvent.DirectionType, 4) # PET_INCOMING
        self.assertEqual(g.overhealCheckedFor, "Wolf")

    def test_process_merge_avoids_queue_holes(self):
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.execute("""
            stillMerging = false
            animationMergeData = {
                Incoming = { TimerPending = false, UnmergedEvents = {}, MergedEvents = {} }
            }
            eventsRecycler = {
                ReclaimTable = function(self, t) end
            }
            MikSBT = {
                MSG_HITS = "Hits",
                MSG_CRIT = "Crit",
                MSG_CRITS = "Crits",
            }
            C_Timer = {
                After = function(d, fn) end
            }
            table_insert = table.insert
            table_setn = table.setn or function() end
            table.wipe = table.wipe or function(t) for k in pairs(t) do t[k] = nil end end
            MERGE_DELAY_TIME = 0.05
            ProcessIncomingMerge = function() end
            ProcessOutgoingMerge = function() end
            addedDuringMerge = false
            function MikSBT.AddAnimation(e)
                if not addedDuringMerge then
                    addedDuringMerge = true
                    -- Simulate a concurrent event arriving during merge execution
                    table.insert(animationMergeData.Incoming.UnmergedEvents, { EventType = "EVT3", Amount = 30 })
                end
            end
        """)
        # We will test the ProcessMerge logic
        start = MSBT_SOURCE.index("function MikSBT.MergeEvents(")
        end = MSBT_SOURCE.index("function MikSBT.GetFontSize(", start)
        lua.execute(MSBT_SOURCE[start:end])

        start_pm = MSBT_SOURCE.index("local function ProcessMerge(mergeData)")
        end_pm = MSBT_SOURCE.index("function MikSBT.DispatchAnimationEvent(", start_pm)
        chunk_pm = MSBT_SOURCE[start_pm:end_pm].replace("local function ProcessMerge", "function ProcessMerge")
        lua.execute(chunk_pm)

        lua.execute("""
            table.insert(animationMergeData.Incoming.UnmergedEvents, { EventType = "EVT1", Amount = 10 })
            table.insert(animationMergeData.Incoming.UnmergedEvents, { EventType = "EVT2", Amount = 20 })
            ProcessMerge(animationMergeData.Incoming)
        """)
        g = lua.globals()
        # After ProcessMerge finishes, the event that arrived during merge must be in UnmergedEvents at index 1 (no hole!)
        remaining = g.animationMergeData.Incoming.UnmergedEvents
        self.assertEqual(len(remaining), 1)
        self.assertEqual(remaining[1].EventType, "EVT3")

if __name__ == "__main__":
    unittest.main()
