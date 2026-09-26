"""NamPower four-argument damage-shield regression. Requires lupa Lua 5.1.
Run: python -B tests/test_damage_shield.py [directory-containing-lupa]
Executes the actual handler section with mocked WoW helpers; not an in-game test.
"""
from pathlib import Path
import sys
import unittest

if len(sys.argv) > 1:
    sys.path.insert(0, sys.argv.pop(1))
from lupa.lua51 import LuaRuntime

SOURCE = (Path(__file__).resolve().parents[1] / "MikCombatEventHelper.lua").read_text(encoding="utf-8")
START = SOURCE.index('nampowerHandlers["DAMAGE_SHIELD_SELF"]')
END = SOURCE.index('nampowerHandlers["ENVIRONMENTAL_DMG_SELF"]', START)

class DamageShieldTests(unittest.TestCase):
    def test_payload_direction_amount_school_and_no_invented_spell(self):
        cases = [
            ("SELF", "player", "enemy", "player_out", "enemy"),
            ("OTHER", "enemy", "player", "player_in", "enemy"),
            ("OTHER", "pet", "enemy", "pet_out", "enemy"),
            ("OTHER", "enemy", "pet", "pet_in", "enemy"),
            ("OTHER", "stranger", "enemy", None, None),
        ]
        for event, owner, victim, direction, other in cases:
            with self.subTest(event=event, owner=owner, victim=victim):
                lua = LuaRuntime(unpack_returned_tuples=True)
                lua.execute("""
                    nampowerHandlers = {}
                    MikCEH = {
                        DIRECTIONTYPE_PLAYER_OUTGOING="player_out",
                        DIRECTIONTYPE_PLAYER_INCOMING="player_in",
                        DIRECTIONTYPE_PET_OUTGOING="pet_out",
                        DIRECTIONTYPE_PET_INCOMING="pet_in",
                        ACTIONTYPE_HIT=1, HITTYPE_NORMAL=1
                    }
                    function IsPlayerGUID(g) return g=="player" end
                    function IsPetGUID(g) return g=="pet" end
                    function GetNameFromGUID(g) return g end
                    function UnitName() return "fallback" end
                    function SchoolToDamageType(s) return s end
                    function GetSpellNameFromId() error("event has no spell ID") end
                    function MikCEH.GetDamageEventData(d,a,h,s,n,spell,name)
                        return {direction=d, school=s, damage=n, spell=spell, name=name}
                    end
                    function MikCEH.SendEvent(e) sent=e end
                """)
                lua.execute(SOURCE[START:END])
                g=lua.globals()
                g.arg1, g.arg2, g.arg3, g.arg4 = owner, victim, 137, 3
                g.nampowerHandlers["DAMAGE_SHIELD_"+event]()
                if direction is None:
                    self.assertIsNone(g.sent)
                else:
                    self.assertEqual(g.sent.direction, direction)
                    self.assertEqual(g.sent.damage, 137)
                    self.assertEqual(g.sent.school, 3)
                    self.assertEqual(g.sent.name, other)
                    self.assertEqual(g.sent.spell, "Damage Shield")
                    self.assertIsNone(g.sent.SpellId)

if __name__ == "__main__":
    unittest.main()
