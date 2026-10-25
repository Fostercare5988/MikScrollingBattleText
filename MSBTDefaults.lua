-------------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text: constants, strings and default profile
-- Author: Mik, Fostercare5988
-- Maintainer: Fostercare5988
-------------------------------------------------------------------------------------

-- Create "namespace."
MikSBT = {};

-------------------------------------------------------------------------------
-- Mod Constants
-------------------------------------------------------------------------------

MikSBT.MOD_NAME		= "MikScrollingBattleText"
MikSBT.VERSION_STRING	= "v" .. GetAddOnMetadata("MikScrollingBattleText", "Version");
MikSBT.COMMAND		= "/msbt";

------------------------------
-- Commands
------------------------------
MikSBT.COMMAND_RESET		= "reset";
MikSBT.COMMAND_DISABLE		= "disable";
MikSBT.COMMAND_ENABLE		= "enable";
MikSBT.COMMAND_SHOWVER		= "version";
MikSBT.COMMAND_SEARCH		= "search";
MikSBT.COMMAND_HELP		= "help";

MikSBT.COMMAND_USAGE = {
 "Usage: " .. MikSBT.COMMAND .. " <command> [params]",
 " Commands:",
 "  " .. MikSBT.COMMAND_RESET .. " - Reset the current profile to the default settings.",
 "  " .. MikSBT.COMMAND_DISABLE .. " - Disables the mod.",
 "  " .. MikSBT.COMMAND_ENABLE .. " - Enables the mod.",
 "  " .. MikSBT.COMMAND_SHOWVER .. " - Shows the current version.",
 "  " .. MikSBT.COMMAND_SEARCH .. " filter - Sets a filter for searching event types.",
 "  " .. MikSBT.COMMAND_HELP .. " - Show the command usage.",
};


------------------------------
-- Output messages
------------------------------

MikSBT.MSG_SEARCH_ENABLE			= "Event search mode has been enabled.  Searching for: ";
MikSBT.MSG_SEARCH_DISABLE			= "Event search mode has been disabled.";
MikSBT.MSG_DISABLE					= "The mod is now disabled.";
MikSBT.MSG_ENABLE					= "The mod is now enabled.";
MikSBT.MSG_HITS						= "Hits";
MikSBT.MSG_CRIT						= "Crit";
MikSBT.MSG_CRITS					= "Crits";
MikSBT.MSG_MULTIPLE_TARGETS			= "Multiple";
MikSBT.MSG_PROFILE_RESET			= "Profile Reset";
MikSBT.MSG_ENVIRONMENTAL_DROWNING	= "Drowning";
MikSBT.MSG_ENVIRONMENTAL_FALLING	= "Falling";
MikSBT.MSG_ENVIRONMENTAL_FATIGUE	= "Fatigue";
MikSBT.MSG_ENVIRONMENTAL_FIRE		= "Fire";
MikSBT.MSG_ENVIRONMENTAL_LAVA		= "Lava";
MikSBT.MSG_ENVIRONMENTAL_SLIME		= "Slime";



------------------------------
-- Font info
------------------------------

-- Holds the available fonts.
MikSBT.AVAILABLE_FONTS = {
 [1] = {Name="Adventure", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\adventure.ttf"},
 [2] = {Name="Backsplatter", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\backsplatter.ttf"},
 [3] = {Name="Budhand", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\budhand.ttf"},
 [4] = {Name="Comic", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\comic.ttf"},
 [5] = {Name="Creeper", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\creeper.ttf"},
 [6] = {Name="Friz", Path="Fonts\\FRIZQT__.TTF"},
 [7] = {Name="Porky", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\porky.ttf"},
 [8] = {Name="Signature", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\signature.ttf"},
 [9] = {Name="Black Castle", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\BlackCastleMF.ttf"},
 [10] = {Name="Exocet", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\exocet.ttf"},
 [11] = {Name="FuturaBold", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\FuturaBold.ttf"},
 [12] = {Name="Mail Ray Stuff", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\mailrays.ttf"},
 [13] = {Name="Pepsi", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\pepsi.ttf"},
 [14] = {Name="Bazooka", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\bazooka.ttf"},
 [15] = {Name="Cooline", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\cooline.ttf"},
 [16] = {Name="Yellowjacket", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\yellowjacket.ttf"},
 [17] = {Name="Defused", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\defused.ttf"},
 [18] = {Name="Zombie", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\zombie.ttf"},
 [19] = {Name="Basket Of Hammers", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\basketofhammers.ttf"},
 [20] = {Name="College", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\college.ttf"},
 [21] = {Name="Galaxy", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\galaxy.ttf"},
 [22] = {Name="Skratch Punk", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\skratchpunk.ttf"},
 [23] = {Name="DieDieDie", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\DieDieDie.ttf"},
 [24] = {Name="BigNoodleTitling", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\BigNoodleTitling.ttf"},
 [25] = {Name="Continuum", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\Continuum.ttf"},
 [26] = {Name="Expressway", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\Expressway.ttf"},
 [27] = {Name="Homespun", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\Homespun.ttf"},
 [28] = {Name="Myriad-Pro", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\Myriad-Pro.ttf"},
 [29] = {Name="PT-Sans-Narrow-Bold", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\PT-Sans-Narrow-Bold.ttf"},
 [30] = {Name="PT-Sans-Narrow-Regular", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\PT-Sans-Narrow-Regular.ttf"},
 [31] = {Name="Simhei", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\simhei.ttf"},
 [32] = {Name="Archangelsk", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\archangelsk.ttf"},
 [33] = {Name="Google Sans Bold", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\GoogleSans-Bold.ttf"},
 [34] = {Name="Google Sans Medium", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\GoogleSans-Medium.ttf"},
 [35] = {Name="Apple SF Pro Display", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\SFProDisplay-Bold.ttf"},
 [36] = {Name="Apple SF Pro Text", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\SFProText-Bold.ttf"},
 [37] = {Name="Inter Bold", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\Inter-Bold.ttf"},
 [38] = {Name="Inter SemiBold", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\Inter-SemiBold.ttf"},
 [39] = {Name="Roboto", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\Roboto.ttf"},
 [40] = {Name="Roboto Mono", Path="Interface\\Addons\\MikScrollingBattleText\\Fonts\\RobotoMono.ttf"},
};

-- Holds the available font outlines.
MikSBT.AVAILABLE_OUTLINES = {
 [1] = {Name="None", Style=""},
 [2] = {Name="Thin", Style="OUTLINE"},
 [3] = {Name="Thick", Style="THICKOUTLINE"},
};

-- Holds the available text aligns.
MikSBT.AVAILABLE_TEXT_ALIGNS = {
 [1] = {Name="Left", AnchorPoint="BOTTOMLEFT"},
 [2] = {Name="Center", AnchorPoint="BOTTOM"},
 [3] = {Name="Right", AnchorPoint="BOTTOMRIGHT"},
};


------------------------------
-- Animation info
------------------------------

MikSBT.AVAILABLE_SCROLL_DIRECTIONS = {
 [1] = {Name="Up"},
 [2] = {Name="Down"},
}

-- Holds the available animation styles.
MikSBT.AVAILABLE_ANIMATION_STYLES = {
 [1] = {Name="Straight", AllowedScrollDirections={1,2}},
 [2] = {Name="Left Parabola", AllowedScrollDirections={1,2}},
 [3] = {Name="Right Parabola", AllowedScrollDirections={1,2}},
};


------------------------------
-- Trigger info
------------------------------

-- Holds the available trigger types.
MikSBT.AVAILABLE_TRIGGER_TYPES = {
 [1] = {Name="Self Health"},
 [2] = {Name="Self Mana"},
 [3] = {Name="Pet Health"},
 [4] = {Name="Enemy Target Health"},
 [5] = {Name="Friendly Target Health"},
 [6] = {Name="Search Pattern"},
 [7] = {Name="Aura Gained"},
 [8] = {Name="You Dodge"},
 [9] = {Name="You Parry"},
 [10] = {Name="Your Attack Dodged"},
};


------------------------------
-- Stances info
------------------------------

-- Holds the available stances.
MikSBT.AVAILABLE_STANCES = {
 [1] = {Name="|cffC79C6EBattle Stance|r/|cffFF7D0ABear Form|r/|cffFFF569Stealth|r/|cffF58CBADevotion Aura"},
 [2] = {Name="|cffC79C6EDefensive Stance|r/|cffFF7D0AAquatic Form|r/|cffF58CBARetribution Aura"},
 [3] = {Name="|cffC79C6EBeserker Stance|r/|cffFF7D0ACat Form|r/|cffF58CBAConcentration Aura"},
 [4] = {Name="|cffFF7D0ATravel Form|r/|cffF58CBAShadow Resistance Aura"},
 [5] = {Name="|cffFF7D0AMoonkin Form|r/|cffF58CBAFrost Resistance Aura"},
 [6] = {Name="|cffF58CBAFire Resistance Aura"},
 [7] = {Name="Any"},
};


------------------------------
-- Defaults
------------------------------
MikSBT.DEFAULT_PROFILE_NAME = "Default";

-- %a = amount of the attack, heal, gain, loss, etc.
-- %n = name of enemy/player
-- %s = name of the spell, ability, buff, debuff, power type, etc.
-- %t = damage type
MikSBT.DEFAULT_CONFIG = {
 ShowPartialEffects				= true,
 ShowGameDamage					= false,
 UseStickyCrits					= true,
 ShowAllManaGains				= false,
 LowHealthSound					= true,
 LowManaSound					= true,
 ResistSound					= true,
 AnimationStep					= 1.5,
 MasterFontSettings = {
  Normal 						= {FontIndex=33, OutlineIndex=2, FontSize=18},
  Crit 							= {FontIndex=33, OutlineIndex=2, FontSize=26},
 },
 BlizzardFontSettings = {
  Normal 						= {FontIndex=6},
 },
 DisplaySettings = {
  Incoming =  {
   Show						= true,
   FrameOffsets					= {x=-450, y=-170},
   AnimationStyle				= 1,
   ScrollDirection				= 1,
   ScrollHeight					= 450,
   FontSettings = {
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    TextAlignIndex				= 3,
   },
  },
  Outgoing = {
   Show						= true,
   FrameOffsets					= {x=450, y=-170},
   AnimationStyle				= 1,
   ScrollDirection				= 1,
   ScrollHeight					= 450,
   FontSettings = {
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    TextAlignIndex				= 1,
   },
  },
  Notification = {
   Show						= true,
   FrameOffsets					= {x=-300, y=-322},
   AnimationStyle				= 1,
   ScrollDirection				= 1,
   ScrollHeight					= 150,
   FontSettings = {
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize = 0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize = 0},
    TextAlignIndex				= 2,
   },
  },
 },
 EventSettings = {
  MSBT_EVENTTYPE_INCOMING_DAMAGE = {
   Show						= true,
   Message						= "-%a",
   FontSettings = {
    Color						= {r=1, g=1, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_MISS = {
   Show						= true,
   Message						= MISS.."!",
   FontSettings = {
    Color						= {r=0, g=0, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_DODGE = {
   Show						= true,
   Message						= DODGE.."!",
   FontSettings = {
    Color						= {r=0, g=0, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PARRY = {
   Show						= true,
   Message						= PARRY.."!",
   FontSettings = {
    Color						= {r=0, g=0, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_BLOCK = {
   Show						= true,
   Message						= BLOCK.."!",
   FontSettings = {
    Color						= {r=0, g=0, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_ABSORB = {
   Show						= true,
   Message						= ABSORB.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_IMMUNE = {
   Show						= true,
   Message						= IMMUNE.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_EVADE = {
   Show						= true,
   Message						= EVADE.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_SPELL_DAMAGE = {
   Show						= true,
   Message						= "-%a",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_SPELL_DOT = {
   Show						= true,
   Message						= "-%a",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_SPELL_MISS = {
   Show						= true,
   Message						= MISS.."!",
   FontSettings = {
    Color						= {r=0, g=0, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_SPELL_DODGE = {
   Show						= true,
   Message						= DODGE.."!",
   FontSettings = {
    Color						= {r=0, g=0, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_SPELL_PARRY = {
   Show						= true,
   Message						= PARRY.."!",
   FontSettings = {
    Color						= {r=0, g=0, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_SPELL_BLOCK = {
   Show						= true,
   Message						= BLOCK.."!",
   FontSettings = {
    Color						= {r=0, g=0, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_SPELL_RESIST = {
   Show						= true,
   Message						= "(%s) "..RESIST.."!",
   FontSettings = {
    Color						= {r=0.502, g=0, b=0.502},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_SPELL_ABSORB = {
   Show						= true,
   Message						= "(%s) "..ABSORB.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_SPELL_IMMUNE = {
   Show						= true,
   Message						= "(%s) "..IMMUNE.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_SPELL_REFLECT = {
   Show						= true,
   Message						= "(%s) "..REFLECT.."!",
   FontSettings = {
    Color						= {r=0.502, g=0, b=0.502},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_SPELL_EVADE = {
   Show						= true,
   Message						= "(%s) "..EVADE.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_HEAL = {
   Show						= true,
   Message						= "+%a (%n)",
   FontSettings = {
    Color						= {r=0, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   }
  },
  MSBT_EVENTTYPE_INCOMING_HOT = {
   Show						= true,
   Message						= "+%a (%n)",
   FontSettings = {
    Color						= {r=0, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   }
  },
  MSBT_EVENTTYPE_INCOMING_ENVIRONMENTAL = {
   Show						= true,
   Message						= "-%a %s",
   FontSettings = {
    Color						= {r=1, g=0, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_DAMAGE = {
   Show						= true,
   Message						= "-%a (Pet)",
   FontSettings = {
    Color						= {r=1, g=1, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_MISS = {
   Show						= true,
   Message						= MISS.."! (Pet)",
   FontSettings = {
    Color						= {r=0.2, g=0.4, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_DODGE = {
   Show						= true,
   Message						= DODGE.."! (Pet)",
   FontSettings = {
    Color						= {r=0.2, g=0.4, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_PARRY = {
   Show						= true,
   Message						= PARRY.."! (Pet)",
   FontSettings = {
    Color						= {r=0.2, g=0.4, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_BLOCK = {
   Show						= true,
   Message						= BLOCK.."! (Pet)",
   FontSettings = {
    Color						= {r=0.2, g=0.4, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_ABSORB = {
   Show						= true,
   Message						= ABSORB.."! (Pet)",
   FontSettings = {
    Color						= {r=1, g=0.7, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_IMMUNE = {
   Show						= true,
   Message						= IMMUNE.."! (Pet)",
   FontSettings = {
    Color						= {r=1, g=0.7, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_EVADE = {
   Show						= true,
   Message						= EVADE.."! (Pet)",
   FontSettings = {
    Color						= {r=1, g=0.7, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_SPELL_DAMAGE = {
   Show						= true,
   Message						= "-%a (Pet)",
   FontSettings = {
    Color						= {r=1, g=0.7, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_SPELL_DOT = {
   Show						= true,
   Message						= "-%a (Pet)",
   FontSettings = {
    Color						= {r=1, g=0.7, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_SPELL_MISS = {
   Show						= true,
   Message						= MISS.."! (Pet)",
   FontSettings = {
    Color						= {r=0.2, g=0.4, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_SPELL_DODGE = {
   Show						= true,
   Message						= DODGE.."! (Pet)",
   FontSettings = {
    Color						= {r=0.2, g=0.4, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_SPELL_PARRY = {
   Show						= true,
   Message						= PARRY.."! (Pet)",
   FontSettings = {
    Color						= {r=0.2, g=0.4, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_SPELL_BLOCK = {
   Show						= true,
   Message						= BLOCK.."! (Pet)",
   FontSettings = {
    Color						= {r=0.2, g=0.4, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_SPELL_RESIST = {
   Show						= true,
   Message						= RESIST.."! (Pet)",
   FontSettings = {
    Color						= {r=0.5, g=0, b=0.4},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_SPELL_ABSORB = {
   Show						= true,
   Message						= "(%s) "..ABSORB.."! (Pet)",
   FontSettings = {
    Color						= {r=1, g=0.7, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_SPELL_IMMUNE = {
   Show						= true,
   Message						= "(%s) "..IMMUNE.."! (Pet)",
   FontSettings = {
    Color						= {r=1, g=0.7, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_SPELL_EVADE = {
   Show						= true,
   Message						= "(%s) "..EVADE.."! (Pet)",
   FontSettings = {
    Color						= {r=1, g=0.7, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_SPELL_REFLECT = {
   Show						= true,
   Message						= "(%s) "..REFLECT.."! (Pet)",
   FontSettings = {
    Color						= {r=1, g=0.7, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_PET_HEAL = {
   Show						= true,
   Message						= "+%a (%n) (Pet)",
   FontSettings = {
    Color						= {r=0, g=1, b=0.4},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   }
  },
  MSBT_EVENTTYPE_INCOMING_PET_HOT = {
   Show						= true,
   Message						= "+%a (%n) (Pet)",
   FontSettings = {
    Color						= {r=0, g=1, b=0.4},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   }
  },
  MSBT_EVENTTYPE_OUTGOING_DAMAGE = {
   Show						= true,
   Message						= "%a",
   FontSettings = {
    Color						= {r=1, g=1, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_MISS = {
   Show						= true,
   Message						= MISS.."!",
   FontSettings = {
    Color						= {r=0, g=0, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_DODGE = {
   Show						= true,
   Message						= DODGE.."!",
   FontSettings = {
    Color						= {r=0, g=0, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PARRY = {
   Show						= true,
   Message						= PARRY.."!",
   FontSettings = {
    Color						= {r=0, g=0, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_BLOCK = {
   Show						= true,
   Message						= BLOCK.."!",
   FontSettings = {
    Color						= {r=0, g=0, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_ABSORB = {
   Show						= true,
   Message						= ABSORB.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_IMMUNE = {
   Show						= true,
   Message						= IMMUNE.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_EVADE = {
   Show						= true,
   Message						= EVADE.."!",
   FontSettings = {
    Color						= {r=1, g=0.502, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=22},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_SPELL_DAMAGE = {
   Show						= true,
   Message						= "%a",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_SPELL_DOT = {
   Show						= true,
   Message						= "%a",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_SPELL_MISS = {
   Show						= true,
   Message						= MISS.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_SPELL_DODGE = {
   Show						= true,
   Message						= DODGE.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_SPELL_PARRY = {
   Show						= true,
   Message						= PARRY.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_SPELL_BLOCK = {
   Show						= true,
   Message						= BLOCK.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_SPELL_RESIST = {
   Show						= true,
   Message						= RESIST.."!",
   FontSettings = {
    Color						= {r=0.502, g=0.502, b=0.698},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_SPELL_ABSORB = {
   Show						= true,
   Message						= "(%s) "..ABSORB.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_SPELL_IMMUNE = {
   Show						= true,
   Message						= "(%s) "..IMMUNE.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_SPELL_REFLECT = {
   Show						= true,
   Message						= "(%s) "..REFLECT.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_REFLECT = {
   Show						= true,
   Message						= REFLECT.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_RESIST = {
   Show						= true,
   Message						= RESIST.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_REFLECT = {
   Show						= true,
   Message						= REFLECT.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_INCOMING_RESIST = {
   Show						= true,
   Message						= RESIST.."!",
   FontSettings = {
    Color						= {r=1, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_SPELL_EVADE = {
   Show						= true,
   Message						= "(%s) "..EVADE.."!",
   FontSettings = {
    Color						= {r=1, g=0.502, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=22},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_HEAL = {
   Show						= true,
   Message						= "+%a",
   FontSettings = {
    Color						= {r=0, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=22},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_HOT = {
   Show						= true,
   Message						= "+%a",
   FontSettings = {
    Color						= {r=0, g=1, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  
  

  MSBT_EVENTTYPE_OUTGOING_PET_DAMAGE = {
   Show						= true,
   Message						= "Pet %a",
   FontSettings = {
    Color						= {r=1, g=0.502, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },

  },
  MSBT_EVENTTYPE_OUTGOING_PET_MISS = {
   Show						= true,
   Message						= "Pet "..MISS.."!",
   FontSettings = {
    Color						= {r=1, g=0.502, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PET_DODGE = {
   Show						= true,
   Message						= "Pet "..DODGE.."!",
   FontSettings = {
    Color						= {r=1, g=0.502, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PET_PARRY = {
   Show						= true,
   Message						= "Pet "..PARRY.."!",
   FontSettings = {
    Color						= {r=1, g=0.502, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PET_BLOCK = {
   Show						= true,
   Message						= "Pet "..BLOCK.."!",
   FontSettings = {
    Color						= {r=1, g=0.502, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PET_ABSORB = {
   Show						= true,
   Message						= "Pet "..ABSORB.."!",
   FontSettings = {
    Color						= {r=0.502, g=0.502, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PET_IMMUNE = {
   Show						= true,
   Message						= "Pet "..IMMUNE.."!",
   FontSettings = {
    Color						= {r=0.502, g=0.502, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PET_EVADE = {
   Show						= true,
   Message						= "Pet "..EVADE.."!",
   FontSettings = {
    Color						= {r=1, g=0.502, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PET_SPELL_DAMAGE = {
   Show						= true,
   Message						= "Pet %a (%s)",
   FontSettings = {
    Color						= {r=0.33, g=0.33, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
    Crit 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PET_SPELL_MISS = {
   Show						= true,
   Message						= "Pet "..MISS.."! (%s)",
   FontSettings = {
    Color						= {r=0.33, g=0.33, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PET_SPELL_DODGE = {
   Show						= true,
   Message						= "Pet "..DODGE.."! (%s)",
   FontSettings = {
    Color						= {r=0.33, g=0.33, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PET_SPELL_PARRY = {
   Show						= true,
   Message						= "Pet "..PARRY.."! (%s)",
   FontSettings = {
    Color						= {r=0.33, g=0.33, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PET_SPELL_BLOCK = {
   Show						= true,
   Message						= "Pet "..BLOCK.."! (%s)",
   FontSettings = {
    Color						= {r=0.33, g=0.33, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PET_SPELL_RESIST = {
   Show						= true,
   Message						= "Pet "..RESIST.."! (%s)",
   FontSettings = {
    Color						= {r=0.502, g=0.502, b=0.698},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PET_SPELL_ABSORB = {
   Show						= true,
   Message						= "Pet "..ABSORB.."! (%s)",
   FontSettings = {
    Color						= {r=0.502, g=0.502, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PET_SPELL_IMMUNE = {
   Show						= true,
   Message						= "Pet "..IMMUNE.."! (%s)",
   FontSettings = {
    Color						= {r=0.502, g=0.502, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_OUTGOING_PET_SPELL_EVADE = {
   Show						= true,
   Message						= "Pet "..EVADE.."! (%s)",
   FontSettings = {
    Color						= {r=1, g=0.502, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=22},
   },
  },



  MSBT_EVENTTYPE_NOTIFICATION_DEBUFF = {
   Show						= true,
   Message						= "[%s]",
   IsSticky						= false,
   FontSettings = {
    Color						= {r=0, g=0.502, b=0.502},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_NOTIFICATION_BUFF = {
   Show						= true,
   Message						= "[%s]",
   IsSticky						= false,
   FontSettings = {
    Color						= {r=0.698, g=0.698, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_NOTIFICATION_BUFF_FADE = {
   Show						= true,
   Message						= "-[%s]",
   IsSticky						= false,
   FontSettings = {
    Color						= {r=0.698, g=0.698, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_NOTIFICATION_COMBAT_ENTER = {
   Show						= true,
   Message						= "+Combat",
   IsSticky						= false,
   FontSettings = {
    Color						= {r=1, g=1, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_NOTIFICATION_COMBAT_LEAVE = {
   Show						= true,
   Message						= "-Combat",
   IsSticky						= false,
   FontSettings = {
    Color						= {r=1, g=1, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_NOTIFICATION_POWER_GAIN = {
   Show						= true,
   Message						= "+%a",
   IsSticky						= false,
   FontSettings = {
    Color						= {r=0.3098039215686275, g=0.3098039215686275, b=0.8784313725490196},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_NOTIFICATION_POWER_LOSS = {
   Show						= true,
   Message						= "-%a",
   IsSticky						= false,
   FontSettings = {
    Color						= {r=0.7568627450980392, g=0.2705882352941176, b=0.8235294117647058},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_NOTIFICATION_CP_GAIN = {
   Show						= true,
   Message						= "%a CP",
   IsSticky						= false,
   FontSettings = {
    Color						= {r=1, g=0.502, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_NOTIFICATION_CP_FULL = {
   Show						= true,
   Message						= "%a CP Finish It!",
   IsSticky						= false,
   FontSettings = {
    Color						= {r=1, g=0.502, b=0},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_NOTIFICATION_HONOR_GAIN = {
   Show						= true,
   Message						= "+%a "..HONOR,
   IsSticky						= false,
   FontSettings = {
    Color						= {r=0.502, g=0.502, b=0.698},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_NOTIFICATION_REP_GAIN = {
   Show						= true,
   Message						= "+%a "..TUTORIAL_TITLE16.." (%s)",
   IsSticky						= false,
   FontSettings = {
    Color						= {r=0.502, g=0.502, b=0.698},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_NOTIFICATION_REP_LOSS = {
   Show						= true,
   Message						= "-%a "..TUTORIAL_TITLE16.." (%s)",
   IsSticky						= false,
   FontSettings = {
    Color						= {r=0.502, g=0.502, b=0.698},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_NOTIFICATION_SKILL_GAIN = {
   Show						= true,
   Message						= "%s: %a",
   IsSticky						= false,
   FontSettings = {
    Color						= {r=0.333, g=0.333, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=0},
   },
  },
  MSBT_EVENTTYPE_NOTIFICATION_EXPERIENCE_GAIN = {
   Show						= true,
   Message						= "%a XP",
   IsSticky						= true,
   FontSettings = {
    Color						= {r=0.756, g=0.270, b=0.823},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=26},
   },
  },
  MSBT_EVENTTYPE_NOTIFICATION_PC_KILLING_BLOW = {
   Show						= true,
   Message						= "Killing Blow! (%s)",
   IsSticky						= true,
   FontSettings = {
    Color						= {r=0.333, g=0.333, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=20},
   },
  },
  MSBT_EVENTTYPE_NOTIFICATION_NPC_KILLING_BLOW = {
   Show						= false,
   Message						= "Killing Blow! (%s)",
   IsSticky						= true,
   FontSettings = {
    Color						= {r=0.333, g=0.333, b=1},
    Normal 						= {FontIndex=0, OutlineIndex=0, FontSize=20},
   },
  },
 },

 Triggers = {
  MSBT_TRIGGER_LOW_HEALTH = {
   EventSettings = {
    Show				= true,
    Message				= "Low Health! (%1)",
    IsSticky			= false,
    FontSettings = {
     Color				= {r=1, g=0.502, b=0.502},
     Normal 			= {FontIndex=0, OutlineIndex=0, FontSize=26},
    },
   },
   TriggerSettings = {
    TriggerType			= 1,
    Threshold			= 40,
   },
   Texture = "Interface\\Icons\\spell_holy_sealofsacrifice"
  },
  MSBT_TRIGGER_LOW_MANA = {
   EventSettings = {
    Show				= true,
    Message				= "Low Mana! (%1)",
    IsSticky			= false,
    FontSettings = {
     Color				= {r=0.502, g=0.502, b=1},
     Normal 			= {FontIndex=0, OutlineIndex=0, FontSize=26},
    },
   },
   TriggerSettings = {
    Classes				= {DRUID=true,HUNTER=true,MAGE=true,PALADIN=true,PRIEST=true,SHAMAN=true,WARLOCK=true},
    TriggerType			= 2,
    Threshold			= 35,
   },
  },
  MSBT_TRIGGER_LOW_PET_HEALTH = {
   EventSettings = {
    Show				= true,
    Message				= "Low Pet Health! (%1)",
    IsSticky			= false,
    FontSettings = {
     Color				= {r=1, g=0.502, b=0.502},
     Normal 			= {FontIndex=0, OutlineIndex=0, FontSize=26},
    },
   },
   TriggerSettings = {
    Classes				= {HUNTER=true,WARLOCK=true},
    TriggerType			= 3,
    Threshold			= 40,
   },
   Texture = "Interface\\Icons\\spell_holy_sealofsacrifice"
  },
  MSBT_TRIGGER_EXECUTE = {
   EventSettings = {
    Show				= true,
    Message				= "Execute".."!",
    IsSticky			= true,
    FontSettings = {
     Color				= {r=1, g=1, b=0},
     Normal 			= {FontIndex=0, OutlineIndex=0, FontSize=26},
    },
   },
   TriggerSettings = {
    Classes				= {WARRIOR=true},
    TriggerType			= 4,
    Threshold			= 20,
   },
   Texture = "Interface\\Icons\\inv_sword_48"
  },
  MSBT_TRIGGER_HAMMER_OF_WRATH = {
   EventSettings = {
    Show				= true,
    Message				= "Hammer of Wrath".."!",
    IsSticky			= true,
    FontSettings = {
     Color				= {r=1, g=1, b=0},
     Normal 			= {FontIndex=0, OutlineIndex=0, FontSize=26},
    },
   },
   TriggerSettings = {
    Classes				= {PALADIN=true},
    TriggerType			= 4,
    Threshold			= 20,
   },
   Texture = "Interface\\Icons\\ability_thunderclap"
  },
  MSBT_TRIGGER_COUNTER_ATTACK = {
   EventSettings = {
    Show				= true,
    Message				= "Counterattack".."!",
    IsSticky			= true,
    FontSettings = {
     Color				= {r=1, g=1, b=0},
     Normal 			= {FontIndex=0, OutlineIndex=0, FontSize=26},
    },
   },
   TriggerSettings = {
    Classes				= {HUNTER=true},
    TriggerType			= 9,
   },
   Texture = "Interface\\Icons\\ability_warrior_challange"
  },
  MSBT_TRIGGER_MONGOOSE_BITE = {
   EventSettings = {
    Show				= true,
    Message				= "Mongoose Bite".."!",
    IsSticky			= true,
    FontSettings = {
     Color				= {r=1, g=1, b=0},
     Normal 			= {FontIndex=0, OutlineIndex=0, FontSize=26},
    },
   },
   TriggerSettings = {
    Classes				= {HUNTER=true},
    TriggerType			= 8,
   },
   Texture = "Interface\\Icons\\ability_hunter_swiftstrike"
  },
  MSBT_TRIGGER_CLEARCAST = {
   EventSettings = {
    Show				= true,
    Message				= "Clearcasting".."!",
    IsSticky			= true,
    FontSettings = {
     Color				= {r=1, g=1, b=0},
     Normal 			= {FontIndex=0, OutlineIndex=0, FontSize=26},
    },
   },
   TriggerSettings = {
    Classes				= {MAGE=true,SHAMAN=true},
    TriggerType			= 7,
    AuraName			= "Clearcasting",
   },
   Texture = "Interface\\Icons\\spell_shadow_manaburn"
  },
  MSBT_TRIGGER_RIPOSTE = {
   EventSettings = {
    Show				= true,
    Message				= "Riposte".."!",
    IsSticky			= true,
    FontSettings = {
     Color				= {r=1, g=1, b=0},
     Normal 			= {FontIndex=0, OutlineIndex=0, FontSize=26},
    },
   },
   TriggerSettings = {
    Classes				= {ROGUE=true},
    TriggerType			= 9,
   },
   Texture = "Interface\\Icons\\ability_warrior_challange"
  },
  MSBT_TRIGGER_WINDFURY = {
   EventSettings = {
    Show				= true,
    Message				= "Windfury!",
    IsSticky			= true,
    FontSettings = {
     Color				= {r=1, g=1, b=0},
     Normal 			= {FontIndex=0, OutlineIndex=0, FontSize=26},
    },
   },
   TriggerSettings = {
    TriggerType			= 7,
    AuraName			= "Windfury Totem",
   },
   Texture = "Interface\\Icons\\spell_nature_cyclone"
  },
  MSBT_TRIGGER_NIGHTFALL = {
   EventSettings = {
    Show				= true,
    Message				= "Nightfall".."!",
    IsSticky			= true,
    FontSettings = {
     Color				= {r=0.709, g=0, b=0.709},
     Normal 			= {FontIndex=0, OutlineIndex=0, FontSize=26},
    },
   },
   TriggerSettings = {
    Classes				= {WARLOCK=true},
    TriggerType			= 7,
    AuraName			= "Shadow Trance",
   },
   Texture = "Interface\\Icons\\spell_shadow_twilight"
  },
  MSBT_TRIGGER_OVERPOWER = {
   EventSettings = {
    Show				= true,
    Message				= "Overpower".."!",
    IsSticky			= true,
    FontSettings = {
     Color				= {r=1, g=1, b=0},
     Normal 			= {FontIndex=0, OutlineIndex=0, FontSize=26},
    },
   },
   TriggerSettings = {
    Classes				= {WARRIOR=true},
    TriggerType			= 10,
   },
   Texture = "Interface\\Icons\\ability_meleedamage"
  },
 },

 Suppressions = {
  MSBT_SUPPRESSION_WISDOM_MANA_GAINS = {
   Enabled				= true,
   SearchPattern			= "+[35][039] " .. MANA,
  },
  MSBT_SUPPRESSION_ROGUE_VIGOR = {
   Enabled				= true,
   SearchPattern			= "Vigor",
  },
  MSBT_SUPPRESSION_SHAMAN_WINDFURY = {
   Enabled				= false,
   SearchPattern			= "Windfury",
  },
  MSBT_SUPPRESSION_SHAMAN_HEALING_STREAM = {
   Enabled				= false,
   SearchPattern			= "Healing Stream",
  },
  MSBT_SUPPRESSION_SHAMAN_MANA_SPRING = {
   Enabled				= false,
   SearchPattern			= "Mana Spring",
  },
  MSBT_SUPPRESSION_SHAMAN_GRACE_OF_AIR = {
   Enabled				= false,
   SearchPattern			= "Grace of Air",
  },
  MSBT_SUPPRESSION_SHAMAN_STRENGTH_OF_EARTH = {
   Enabled				= false,
   SearchPattern			= "Strength of Earth",
  },
  MSBT_SUPPRESSION_SHAMAN_STONESKIN = {
   Enabled				= false,
   SearchPattern			= "Stoneskin",
  },
  MSBT_SUPPRESSION_SHAMAN_LIGHTNING_SHIELD = {
   Enabled				= false,
   SearchPattern			= "Lightning Shield",
  },
 },
};
