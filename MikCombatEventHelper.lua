-------------------------------------------------------------------------------------
-- Title: Mik's Combat Event Helper (ClassicAPI 1.17.7 combat log)
-- Author: Mik, Fostercare5988
-- Maintainer: Fostercare5988
-------------------------------------------------------------------------------------

-- ClassicAPIRequirement.lua checks the DLLs.
if not MSBT_REQUIREMENTS_MET then return end

-- Create namespace.
MikCEH = {};

local string_find, string_gfind = string.find, string.gfind
local string_len, string_sub = string.len, string.sub
local table_wipe = table.wipe
local GetTime, UnitHealth, UnitHealthMax = GetTime, UnitHealth, UnitHealthMax
local UnitMana, UnitManaMax, UnitName, UnitClass = UnitMana, UnitManaMax, UnitName, UnitClass
local UnitIsFriend, UnitExists, UnitGUID = UnitIsFriend, UnitExists, UnitGUID
local UnitPowerType, GetComboPoints = UnitPowerType, GetComboPoints
local GetSpellInfo = GetSpellInfo
local pairs, tonumber, type, pcall = pairs, tonumber, type, pcall
local bit_band = bit.band

-------------------------------------------------------------------------------------
-- Public constants.
-------------------------------------------------------------------------------------

-- Event types.
MikCEH.EVENTTYPE_DAMAGE		= 1;
MikCEH.EVENTTYPE_HEAL		= 2;
MikCEH.EVENTTYPE_NOTIFICATION	= 3;

-- Direction types.
MikCEH.DIRECTIONTYPE_PLAYER_INCOMING	= 1;
MikCEH.DIRECTIONTYPE_PLAYER_OUTGOING	= 2;
MikCEH.DIRECTIONTYPE_PET_OUTGOING		= 3;
MikCEH.DIRECTIONTYPE_PET_INCOMING		= 4;

-- Action types.
MikCEH.ACTIONTYPE_HIT		= 1;
MikCEH.ACTIONTYPE_MISS		= 2;
MikCEH.ACTIONTYPE_DODGE		= 3;
MikCEH.ACTIONTYPE_PARRY		= 4;
MikCEH.ACTIONTYPE_BLOCK		= 5;
MikCEH.ACTIONTYPE_RESIST	= 6;
MikCEH.ACTIONTYPE_ABSORB	= 7;
MikCEH.ACTIONTYPE_IMMUNE	= 8;
MikCEH.ACTIONTYPE_EVADE		= 9;
MikCEH.ACTIONTYPE_REFLECT	= 10;
MikCEH.ACTIONTYPE_DROWNING	= 11;
MikCEH.ACTIONTYPE_FALLING	= 12;
MikCEH.ACTIONTYPE_FATIGUE	= 13;
MikCEH.ACTIONTYPE_FIRE		= 14;
MikCEH.ACTIONTYPE_LAVA		= 15;
MikCEH.ACTIONTYPE_SLIME		= 16;

-- Hit types.
MikCEH.HITTYPE_NORMAL		= 1;
MikCEH.HITTYPE_CRIT		= 2;
MikCEH.HITTYPE_OVER_TIME	= 3;

-- Damage types.
MikCEH.DAMAGETYPE_PHYSICAL	= 1;
MikCEH.DAMAGETYPE_HOLY		= 2;
MikCEH.DAMAGETYPE_NATURE	= 3;
MikCEH.DAMAGETYPE_FIRE		= 4;
MikCEH.DAMAGETYPE_FROST		= 5;
MikCEH.DAMAGETYPE_SHADOW	= 6;
MikCEH.DAMAGETYPE_ARCANE	= 7;
MikCEH.DAMAGETYPE_UNKNOWN	= 999;

-- Partial action types.
MikCEH.PARTIALACTIONTYPE_ABSORB		= 1;
MikCEH.PARTIALACTIONTYPE_BLOCK		= 2;
MikCEH.PARTIALACTIONTYPE_RESIST		= 3;
MikCEH.PARTIALACTIONTYPE_CRUSHING	= 5;
MikCEH.PARTIALACTIONTYPE_GLANCING	= 6;

-- Heal types.
MikCEH.HEALTYPE_NORMAL		= 1;
MikCEH.HEALTYPE_CRIT		= 2;
MikCEH.HEALTYPE_OVER_TIME	= 3;

-- Notification types.
MikCEH.NOTIFICATIONTYPE_DEBUFF		= 1;
MikCEH.NOTIFICATIONTYPE_BUFF			= 2;
MikCEH.NOTIFICATIONTYPE_BUFF_FADE		= 4;
MikCEH.NOTIFICATIONTYPE_COMBAT_ENTER	= 5;
MikCEH.NOTIFICATIONTYPE_COMBAT_LEAVE	= 6;
MikCEH.NOTIFICATIONTYPE_POWER_GAIN		= 7;
MikCEH.NOTIFICATIONTYPE_POWER_LOSS		= 8;
MikCEH.NOTIFICATIONTYPE_CP_GAIN		= 9;
MikCEH.NOTIFICATIONTYPE_HONOR_GAIN		= 10;
MikCEH.NOTIFICATIONTYPE_REP_GAIN		= 11;
MikCEH.NOTIFICATIONTYPE_REP_LOSS		= 12;
MikCEH.NOTIFICATIONTYPE_SKILL_GAIN		= 13;
MikCEH.NOTIFICATIONTYPE_EXPERIENCE_GAIN	= 14;
MikCEH.NOTIFICATIONTYPE_PC_KILLING_BLOW	= 15;
MikCEH.NOTIFICATIONTYPE_NPC_KILLING_BLOW	= 16;

-- Trigger types.
MikCEH.TRIGGERTYPE_SELF_HEALTH		= 1;
MikCEH.TRIGGERTYPE_SELF_MANA		= 2;
MikCEH.TRIGGERTYPE_PET_HEALTH		= 3;
MikCEH.TRIGGERTYPE_ENEMY_HEALTH		= 4;
MikCEH.TRIGGERTYPE_FRIENDLY_HEALTH	= 5;
-- 6 was the retired Search Pattern type (chat text); saved numbers stay.
MikCEH.TRIGGERTYPE_AURA_GAIN		= 7;
MikCEH.TRIGGERTYPE_YOU_DODGE		= 8;
MikCEH.TRIGGERTYPE_YOU_PARRY		= 9;
MikCEH.TRIGGERTYPE_TARGET_DODGES	= 10;

-- Combat log values (ClassicAPI 1.17 COMBAT_LOG_EVENT_UNFILTERED).
local SCHOOL_TO_TYPE = {
 [1] = MikCEH.DAMAGETYPE_PHYSICAL,
 [2] = MikCEH.DAMAGETYPE_HOLY,
 [4] = MikCEH.DAMAGETYPE_FIRE,
 [8] = MikCEH.DAMAGETYPE_NATURE,
 [16] = MikCEH.DAMAGETYPE_FROST,
 [32] = MikCEH.DAMAGETYPE_SHADOW,
 [64] = MikCEH.DAMAGETYPE_ARCANE,
};

local MISS_TO_ACTION = {
 MISS = MikCEH.ACTIONTYPE_MISS,
 RESIST = MikCEH.ACTIONTYPE_RESIST,
 DODGE = MikCEH.ACTIONTYPE_DODGE,
 PARRY = MikCEH.ACTIONTYPE_PARRY,
 DEFLECT = MikCEH.ACTIONTYPE_PARRY,
 BLOCK = MikCEH.ACTIONTYPE_BLOCK,
 EVADE = MikCEH.ACTIONTYPE_EVADE,
 IMMUNE = MikCEH.ACTIONTYPE_IMMUNE,
 ABSORB = MikCEH.ACTIONTYPE_ABSORB,
 REFLECT = MikCEH.ACTIONTYPE_REFLECT,
};

local ENVIRONMENT_TO_ACTION = {
 FATIGUE = MikCEH.ACTIONTYPE_FATIGUE,
 DROWNING = MikCEH.ACTIONTYPE_DROWNING,
 FALLING = MikCEH.ACTIONTYPE_FALLING,
 LAVA = MikCEH.ACTIONTYPE_LAVA,
 SLIME = MikCEH.ACTIONTYPE_SLIME,
 FIRE = MikCEH.ACTIONTYPE_FIRE,
};

-- Enum.PowerType values MSBT shows.
local POWER_TYPE_TO_STRING = {
 [0] = MANA,
 [1] = RAGE,
 [3] = ENERGY,
};

-------------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------------

local playerClass = nil;

-- GUIDs of the player and pet, refreshed on world entry, enable and UNIT_PET.
-- Every combat log event is matched against them with a plain ==.
local playerGUID = nil;
local petGUID = nil;

-- Recycled event tables.
MikCEH.CombatEventData = {};
MikCEH.TriggerEventData = {};
local orderedCaptureData = {};
local globalStringInfoArray = {};
local globalStringInfoSize = 0;

-- Triggers format.
local selfHealthTriggers = {};
local selfManaTriggers = {};
local petHealthTriggers = {};
local enemyHealthTriggers = {};
local friendlyHealthTriggers = {};
-- Event triggers: aura gains by aura name, and dodges/parries from misses.
local auraGainTriggers = {};
local youDodgeTriggers = {};
local youParryTriggers = {};
local targetDodgesTriggers = {};

local lastSelfHealthPercentage = 0;
local lastSelfManaPercentage = 0;
local lastSelfManaAmount = 0;
local lastPetHealthPercentage = 0;
local lastEnemyHealthPercentage = 0;
local lastFriendlyHealthPercentage = 0;

local TRIGGER_THROTTLE_INTERVAL = 0.15;
local lastHealthTriggerCheckTime = {player = 0, target = 0, pet = 0};
local pendingHealthChecks = {};
local thresholdGeneration = 0;

local function ParseHealthUnit(unit)
 if unit == "player" then MikCEH.ParseSelfHealthTriggers();
 elseif unit == "pet" then MikCEH.ParsePetHealthTriggers();
 elseif UnitIsFriend("player", "target") then MikCEH.ParseFriendlyHealthTriggers();
 else MikCEH.ParseEnemyHealthTriggers(); end
end

-- Spell names and icons by ID from ClassicAPI's GetSpellInfo. Misses are
-- cached as false so an unknown ID is looked up once.
local spellNames, spellIcons = {}, {};
local spellCacheSize = 0;
local MAX_CACHED_SPELLS = 256;
-- Experience at the last PLAYER_XP_UPDATE; nil until the first one after login.
local lastXP, lastXPMax;

local combatLogFrame = nil;

-------------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------------

local function RefreshGUIDs()
 playerGUID = UnitGUID("player");
 petGUID = UnitGUID("pet");
end

local function IsPlayerGUID(guid)
 return guid ~= nil and guid == playerGUID
end

local function IsPetGUID(guid)
 return guid ~= nil and guid == petGUID
end

local function GetCombatDirection(casterGuid, targetGuid)
 if IsPlayerGUID(targetGuid) then return MikCEH.DIRECTIONTYPE_PLAYER_INCOMING end
 if IsPetGUID(targetGuid) then return MikCEH.DIRECTIONTYPE_PET_INCOMING end
 if IsPlayerGUID(casterGuid) then return MikCEH.DIRECTIONTYPE_PLAYER_OUTGOING end
 if IsPetGUID(casterGuid) then return MikCEH.DIRECTIONTYPE_PET_OUTGOING end
end

local function SetCombatIdentity(eventData, casterGuid, targetGuid)
 eventData.SourceGUID, eventData.TargetGUID = casterGuid, targetGuid;
 local incoming = eventData.DirectionType == MikCEH.DIRECTIONTYPE_PLAYER_INCOMING or
                  eventData.DirectionType == MikCEH.DIRECTIONTYPE_PET_INCOMING;
 eventData.UnitGUID = incoming and casterGuid or targetGuid;
end

local function FireTriggers(triggers)
 for triggerKey in pairs(triggers) do
  MikCEH.SendTriggerEvent(MikCEH.GetThresholdTriggerEventData(triggerKey, nil));
 end
end

-- Dodge and parry triggers: you avoided an attack, or your target dodged.
local function FireAvoidTriggers(directionType, dodged, parried)
 if (directionType == MikCEH.DIRECTIONTYPE_PLAYER_INCOMING) then
  if dodged then FireTriggers(youDodgeTriggers) elseif parried then FireTriggers(youParryTriggers) end
 elseif (directionType == MikCEH.DIRECTIONTYPE_PLAYER_OUTGOING and dodged) then
  FireTriggers(targetDodgesTriggers);
 end
end

local function CacheSpell(spellId)
 if spellCacheSize >= MAX_CACHED_SPELLS then
  table_wipe(spellNames); table_wipe(spellIcons);
  spellCacheSize = 0;
 end
 local name, _, icon = GetSpellInfo(spellId);
 spellNames[spellId] = name or false;
 spellIcons[spellId] = icon or false;
 spellCacheSize = spellCacheSize + 1;
end

local function GetSpellNameFromId(spellId)
 if not spellId or spellId == 0 then return nil end
 if spellNames[spellId] == nil then CacheSpell(spellId) end
 return spellNames[spellId] or nil;
end

function MikCEH.GetSpellIcon(spellId)
 if not spellId or spellId == 0 then return nil end
 if spellIcons[spellId] == nil then CacheSpell(spellId) end
 return spellIcons[spellId] or nil;
end

-------------------------------------------------------------------------------------
-- Combat log handlers. Each gets the source and destination GUIDs; the other
-- values are in the c*/v* locals, numbered as ClassicAPI documents them.
-------------------------------------------------------------------------------------

-- Values of the combat log event being handled, from CombatLogGetCurrentEventInfo.
local cSubevent, cSourceName, cDestName, cDestFlags;
local v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23;

local combatLogHandlers = {};

-- Name of the other unit: the attacker for incoming events, else the target.
local function OtherName(directionType)
 if (directionType == MikCEH.DIRECTIONTYPE_PLAYER_INCOMING or directionType == MikCEH.DIRECTIONTYPE_PET_INCOMING) then
  return cSourceName;
 end
 return cDestName;
end

local function Damage(sourceGUID, destGUID, spellId, spellName, amount, school, resisted, blocked, absorbed, critical, glancing, crushing, periodic)
 local directionType = GetCombatDirection(sourceGUID, destGUID);
 if not directionType then return end

 local hitType = MikCEH.HITTYPE_NORMAL;
 if periodic then hitType = MikCEH.HITTYPE_OVER_TIME elseif critical then hitType = MikCEH.HITTYPE_CRIT end
 amount = amount or 0;
 local eventData = MikCEH.GetDamageEventData(directionType, MikCEH.ACTIONTYPE_HIT, hitType,
   SCHOOL_TO_TYPE[school] or MikCEH.DAMAGETYPE_PHYSICAL, amount, spellName, OtherName(directionType));
 eventData.SpellId = spellId;
 eventData.IsCrit = critical and true or nil;

 -- One partial effect: crushing/glancing, then absorbed, blocked, resisted.
 if crushing then
  eventData.PartialActionType = MikCEH.PARTIALACTIONTYPE_CRUSHING;
 elseif glancing then
  eventData.PartialActionType = MikCEH.PARTIALACTIONTYPE_GLANCING;
 elseif absorbed then
  eventData.PartialActionType, eventData.PartialAmount = MikCEH.PARTIALACTIONTYPE_ABSORB, absorbed;
 elseif blocked then
  eventData.PartialActionType, eventData.PartialAmount = MikCEH.PARTIALACTIONTYPE_BLOCK, blocked;
 elseif resisted then
  eventData.PartialActionType, eventData.PartialAmount = MikCEH.PARTIALACTIONTYPE_RESIST, resisted;
 end
 if (amount == 0 and absorbed) then
  eventData.ActionType, eventData.PartialActionType = MikCEH.ACTIONTYPE_ABSORB, nil;
 end

 SetCombatIdentity(eventData, sourceGUID, destGUID);
 MikCEH.SendEvent(eventData);
end

local function Miss(sourceGUID, destGUID, spellId, spellName, missType)
 local directionType = GetCombatDirection(sourceGUID, destGUID);
 if not directionType then return end
 FireAvoidTriggers(directionType, missType == "DODGE", missType == "PARRY");

 local eventData = MikCEH.GetDamageEventData(directionType, MISS_TO_ACTION[missType] or MikCEH.ACTIONTYPE_MISS,
   nil, nil, nil, spellName, OtherName(directionType));
 eventData.SpellId = spellId;
 SetCombatIdentity(eventData, sourceGUID, destGUID);
 MikCEH.SendEvent(eventData);
end

-- Melee: amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing.
combatLogHandlers.SWING_DAMAGE = function(sourceGUID, destGUID)
 Damage(sourceGUID, destGUID, nil, nil, v12, v14, v15, v16, v17, v18, v19, v20);
end
combatLogHandlers.SWING_MISSED = function(sourceGUID, destGUID)
 Miss(sourceGUID, destGUID, nil, nil, v12);
end

-- Spells, ranged and damage shields: spellId, spellName, school, then the damage suffix.
local function SpellDamage(sourceGUID, destGUID)
 Damage(sourceGUID, destGUID, v12, v13, v15, v17, v18, v19, v20, v21, v22, v23, cSubevent == "SPELL_PERIODIC_DAMAGE");
end
combatLogHandlers.SPELL_DAMAGE = SpellDamage;
combatLogHandlers.SPELL_PERIODIC_DAMAGE = SpellDamage;
combatLogHandlers.RANGE_DAMAGE = SpellDamage;
combatLogHandlers.DAMAGE_SPLIT = SpellDamage;
-- A damage shield names no spell.
combatLogHandlers.DAMAGE_SHIELD = function(sourceGUID, destGUID)
 Damage(sourceGUID, destGUID, nil, "Damage Shield", v15, v17, v18, v19, v20);
end

local function SpellMiss(sourceGUID, destGUID)
 Miss(sourceGUID, destGUID, v12, v13, v15);
end
combatLogHandlers.SPELL_MISSED = SpellMiss;
combatLogHandlers.SPELL_PERIODIC_MISSED = SpellMiss;
combatLogHandlers.RANGE_MISSED = SpellMiss;
combatLogHandlers.DAMAGE_SHIELD_MISSED = function(sourceGUID, destGUID)
 Miss(sourceGUID, destGUID, nil, "Damage Shield", v15);
end

-- Environment: type, then amount, overkill, school, resisted, blocked, absorbed.
combatLogHandlers.ENVIRONMENTAL_DAMAGE = function(sourceGUID, destGUID)
 if (destGUID ~= playerGUID) then return end
 local eventData = MikCEH.GetDamageEventData(MikCEH.DIRECTIONTYPE_PLAYER_INCOMING,
   ENVIRONMENT_TO_ACTION[v12] or MikCEH.ACTIONTYPE_FALLING, MikCEH.HITTYPE_NORMAL, MikCEH.DAMAGETYPE_PHYSICAL, v13 or 0);
 if v18 then
  eventData.PartialActionType, eventData.PartialAmount = MikCEH.PARTIALACTIONTYPE_ABSORB, v18;
 elseif v16 then
  eventData.PartialActionType, eventData.PartialAmount = MikCEH.PARTIALACTIONTYPE_RESIST, v16;
 end
 MikCEH.SendEvent(eventData);
end

-- Heals: amount, overhealing (always 0), absorbed, critical.
local function Heal(sourceGUID, destGUID)
 local directionType = GetCombatDirection(sourceGUID, destGUID);
 if not directionType then return end
 local healType = MikCEH.HEALTYPE_NORMAL;
 if (cSubevent == "SPELL_PERIODIC_HEAL") then healType = MikCEH.HEALTYPE_OVER_TIME elseif v18 then healType = MikCEH.HEALTYPE_CRIT end
 local eventData = MikCEH.GetHealEventData(directionType, healType, v15 or 0, v13, OtherName(directionType));
 eventData.SpellId = v12;
 eventData.IsCrit = v18 and true or nil;
 SetCombatIdentity(eventData, sourceGUID, destGUID);
 MikCEH.SendEvent(eventData);
end
combatLogHandlers.SPELL_HEAL = Heal;
combatLogHandlers.SPELL_PERIODIC_HEAL = Heal;

-- Power you gain: amount, powerType.
local function Energize(sourceGUID, destGUID)
 if (destGUID ~= playerGUID) then return end
 local powerType = tonumber(v16);
 local powerTypeStr = POWER_TYPE_TO_STRING[powerType];
 if not powerTypeStr then return end
 local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_POWER_GAIN, v15 or 0, powerTypeStr, v13);
 eventData.SpellId = v12;
 eventData.IsSpellManaGain = powerType == 0;
 MikCEH.SendEvent(eventData);
end
combatLogHandlers.SPELL_ENERGIZE = Energize;
combatLogHandlers.SPELL_PERIODIC_ENERGIZE = Energize;

-- Power taken from you: amount, powerType.
local function Drain(sourceGUID, destGUID)
 if (destGUID ~= playerGUID) then return end
 local powerTypeStr = POWER_TYPE_TO_STRING[tonumber(v16)];
 local amount = tonumber(v15) or 0;
 if (powerTypeStr and amount > 0) then
  local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_POWER_LOSS, amount, powerTypeStr, v13);
  eventData.SpellId = v12;
  MikCEH.SendEvent(eventData);
 end
end
combatLogHandlers.SPELL_DRAIN = Drain;
combatLogHandlers.SPELL_PERIODIC_DRAIN = Drain;
combatLogHandlers.SPELL_LEECH = Drain;
combatLogHandlers.SPELL_PERIODIC_LEECH = Drain;

-- Your auras: spellId, spellName, school, auraType ("BUFF"/"DEBUFF"). A stack
-- gain shows again like a new aura; a stack loss (REMOVED_DOSE) is not a fade.
local function AuraGained(sourceGUID, destGUID)
 if (destGUID ~= playerGUID) then return end
 local spellName = v13 or GetSpellNameFromId(v12);
 if not spellName then return end
 if (cSubevent == "SPELL_AURA_APPLIED" and auraGainTriggers[spellName]) then FireTriggers(auraGainTriggers[spellName]) end
 local notificationType = (v15 == "DEBUFF") and MikCEH.NOTIFICATIONTYPE_DEBUFF or MikCEH.NOTIFICATIONTYPE_BUFF;
 local eventData = MikCEH.GetNotificationEventData(notificationType, nil, spellName);
 eventData.SpellId = v12;
 MikCEH.SendEvent(eventData);
end
combatLogHandlers.SPELL_AURA_APPLIED = AuraGained;
combatLogHandlers.SPELL_AURA_APPLIED_DOSE = AuraGained;
combatLogHandlers.SPELL_AURA_REMOVED = function(sourceGUID, destGUID)
 if (destGUID ~= playerGUID) then return end
 local spellName = v13 or GetSpellNameFromId(v12);
 if not spellName then return end
 local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_BUFF_FADE, nil, spellName);
 eventData.SpellId = v12;
 MikCEH.SendEvent(eventData);
end

-- Killing blows: the victim's flags say whether it was a player.
combatLogHandlers.PARTY_KILL = function(sourceGUID, destGUID)
 if (sourceGUID ~= playerGUID) then return end
 local notificationType = MikCEH.NOTIFICATIONTYPE_NPC_KILLING_BLOW;
 if (bit_band(cDestFlags or 0, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0) then
  notificationType = MikCEH.NOTIFICATIONTYPE_PC_KILLING_BLOW;
 end
 MikCEH.SendEvent(MikCEH.GetNotificationEventData(notificationType, nil, cDestName));
end

-- The whole nearby combat stream arrives here; events that involve neither you
-- nor your pet return after the GUID compares.
function MikCEH.OnCombatLogEvent()
 local sourceGUID, destGUID = arg4, arg8;
 if (sourceGUID ~= playerGUID and destGUID ~= playerGUID and
     (petGUID == nil or (sourceGUID ~= petGUID and destGUID ~= petGUID))) then return end
 local handler = combatLogHandlers[arg2];
 if not handler then return end
 local _;
 _, cSubevent, _, _, cSourceName, _, _, _, cDestName, cDestFlags, _,
   v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23 = CombatLogGetCurrentEventInfo();
 handler(sourceGUID, destGUID);
end


-------------------------------------------------------------------------------------
-- Core Helper Initialization & Lifecycle
-------------------------------------------------------------------------------------

function MikCEH.Init()
 local _;
 _, playerClass = UnitClass("player");
 RefreshGUIDs();
end

function MikCEH.RegisterEvents()
 RefreshGUIDs();
 if MCEHEventFrame then
  MCEHEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
  MCEHEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
  MCEHEventFrame:RegisterEvent("PLAYER_COMBO_POINTS");
  -- Only the units with triggers; other tokens never reach Lua.
  MCEHEventFrame:RegisterUnitEvent("UNIT_HEALTH", "player", "pet", "target");
  MCEHEventFrame:RegisterUnitEvent("UNIT_MANA", "player");
  MCEHEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
  MCEHEventFrame:RegisterEvent("UNIT_PET");
  MCEHEventFrame:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN");
  MCEHEventFrame:RegisterEvent("FACTION_STANDING_CHANGED");
  MCEHEventFrame:RegisterEvent("CHAT_MSG_SKILL");
  -- Every XP gain (kills, quests, exploration) as the change in UnitXP.
  MCEHEventFrame:RegisterEvent("PLAYER_XP_UPDATE");
 end
 if combatLogFrame then combatLogFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") end
 MikCEH.ResetThresholdState();
end

function MikCEH.UnregisterEvents()
 if MCEHEventFrame then
  MCEHEventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED");
  MCEHEventFrame:UnregisterEvent("PLAYER_REGEN_DISABLED");
  MCEHEventFrame:UnregisterEvent("PLAYER_COMBO_POINTS");
  MCEHEventFrame:UnregisterEvent("UNIT_HEALTH");
  MCEHEventFrame:UnregisterEvent("UNIT_MANA");
  MCEHEventFrame:UnregisterEvent("PLAYER_TARGET_CHANGED");
  MCEHEventFrame:UnregisterEvent("UNIT_PET");
  MCEHEventFrame:UnregisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN");
  MCEHEventFrame:UnregisterEvent("FACTION_STANDING_CHANGED");
  MCEHEventFrame:UnregisterEvent("CHAT_MSG_SKILL");
  MCEHEventFrame:UnregisterEvent("PLAYER_XP_UPDATE");
 end
 lastXP, lastXPMax = nil, nil;
 if combatLogFrame then combatLogFrame:UnregisterAllEvents() end
 MikCEH.ResetThresholdState();
end

function MikCEH.OnLoad()
 MCEHEventFrame:RegisterEvent("ADDON_LOADED");
 MCEHEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

 combatLogFrame = CreateFrame("Frame");
 combatLogFrame:SetScript("OnEvent", MikCEH.OnCombatLogEvent);

 MikCEH.RegisterEvents();
end

function MikCEH.OnEvent()
 if (event == "ADDON_LOADED") then
  if (arg1 == MikSBT.MOD_NAME) then
   this:UnregisterEvent("ADDON_LOADED");
   MikCEH.Init();
  end

 elseif (event == "PLAYER_ENTERING_WORLD") then
  RefreshGUIDs();
  lastXP, lastXPMax = UnitXP("player"), UnitXPMax("player");
  table_wipe(spellNames); table_wipe(spellIcons); spellCacheSize = 0;
  table_wipe(globalStringInfoArray); globalStringInfoSize = 0;
  MikCEH.ResetThresholdState();

 elseif (event == "PLAYER_REGEN_ENABLED") then
  local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_COMBAT_LEAVE, nil, nil);
  MikCEH.SendEvent(eventData);

 elseif (event == "PLAYER_REGEN_DISABLED") then
  local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_COMBAT_ENTER, nil, nil);
  MikCEH.SendEvent(eventData);

 elseif (event == "PLAYER_COMBO_POINTS") then
  local numCP = GetComboPoints();
  if (numCP and numCP > 0) then
   local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_CP_GAIN, numCP, nil);
   MikCEH.SendEvent(eventData);
  end

 elseif (event == "UNIT_HEALTH") then
  if arg1 == "player" and not next(selfHealthTriggers) then return end;
  if arg1 == "pet" and not next(petHealthTriggers) then return end;
  if arg1 == "target" and not next(enemyHealthTriggers) and not next(friendlyHealthTriggers) then return end;
  local lastCheck = lastHealthTriggerCheckTime[arg1];
  if not lastCheck then return end;
  local now = GetTime();
  if (now - lastCheck >= TRIGGER_THROTTLE_INTERVAL) then
   lastHealthTriggerCheckTime[arg1] = now;
   if pendingHealthChecks[arg1] then pendingHealthChecks[arg1]:Cancel(); pendingHealthChecks[arg1] = nil end;
   ParseHealthUnit(arg1);
  elseif not pendingHealthChecks[arg1] then
   local unit, generation = arg1, thresholdGeneration;
   pendingHealthChecks[unit] = C_Timer.NewTimer(TRIGGER_THROTTLE_INTERVAL - (now-lastCheck), function()
    if generation ~= thresholdGeneration then return end;
    pendingHealthChecks[unit] = nil;
    lastHealthTriggerCheckTime[unit] = GetTime();
    ParseHealthUnit(unit);
   end);
  end

 elseif (event == "UNIT_MANA") then
  if arg1 ~= "player" then return end;
  MikCEH.ParseSelfManaTriggers();

 elseif (event == "PLAYER_TARGET_CHANGED") then
  if pendingHealthChecks.target then pendingHealthChecks.target:Cancel(); pendingHealthChecks.target = nil end;
  lastEnemyHealthPercentage, lastFriendlyHealthPercentage = 1, 1;
  lastHealthTriggerCheckTime.target = 0;
  if UnitIsFriend("player", "target") then MikCEH.ParseFriendlyHealthTriggers();
  else MikCEH.ParseEnemyHealthTriggers(); end

 elseif (event == "UNIT_PET" and arg1 == "player") then
  RefreshGUIDs();
  if pendingHealthChecks.pet then pendingHealthChecks.pet:Cancel(); pendingHealthChecks.pet = nil end;
  lastPetHealthPercentage, lastHealthTriggerCheckTime.pet = 1, 0;
  MikCEH.ParsePetHealthTriggers();

 elseif (event == "CHAT_MSG_COMBAT_HONOR_GAIN") then
  local capturedData = MikCEH.GetCapturedData(arg1, "COMBATLOG_HONORGAIN", {"%n", "", "%a"});
  if (capturedData ~= nil) then
   local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_HONOR_GAIN, capturedData.Amount, nil);
   MikCEH.SendEvent(eventData);
  else
   capturedData = MikCEH.GetCapturedData(arg1, "COMBATLOG_HONORAWARD", {"%a"});
   if (capturedData ~= nil) then
    local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_HONOR_GAIN, capturedData.Amount, nil);
    MikCEH.SendEvent(eventData);
   end
  end

 elseif (event == "FACTION_STANDING_CHANGED") then
  -- ClassicAPI: factionID, new standing, signed change.
  local change = tonumber(arg3) or 0;
  if (change ~= 0) then
   local notificationType = (change > 0) and MikCEH.NOTIFICATIONTYPE_REP_GAIN or MikCEH.NOTIFICATIONTYPE_REP_LOSS;
   MikCEH.SendEvent(MikCEH.GetNotificationEventData(notificationType, math.abs(change), (GetFactionInfoByID(arg1))));
  end

 elseif (event == "CHAT_MSG_SKILL") then
  local capturedData = MikCEH.GetCapturedData(arg1, "SKILL_RANK_UP", {"%k", "%a"});
  if (capturedData ~= nil) then
   local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_SKILL_GAIN, capturedData.Amount, capturedData.SkillName);
   MikCEH.SendEvent(eventData);
  end

 elseif (event == "PLAYER_XP_UPDATE") then
  local xp, xpMax = UnitXP("player"), UnitXPMax("player");
  if (lastXP) then
   local gain = xp - lastXP;
   -- A level-up starts the bar again: the rest of the old level plus the new.
   if (gain < 0) then gain = (lastXPMax - lastXP) + xp end;
   if (gain > 0) then
    MikCEH.SendEvent(MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_EXPERIENCE_GAIN, gain, nil));
   end
  end
  lastXP, lastXPMax = xp, xpMax;

 end
end

-------------------------------------------------------------------------------------
-- Event Data Generators & Overheal Logic
-------------------------------------------------------------------------------------

function MikCEH.GetDamageEventData(directionType, actionType, hitType, damageType, amount, effectName, name)
 local eventData = MikCEH.CombatEventData;
 MikCEH.EraseTable(eventData);

 eventData.EventType = MikCEH.EVENTTYPE_DAMAGE;
 eventData.DirectionType = directionType;
 eventData.ActionType = actionType;
 eventData.HitType = hitType;
 eventData.DamageType = damageType;
 eventData.Amount = amount;
 eventData.EffectName = effectName;
 eventData.Name = name;

 return eventData;
end

function MikCEH.GetHealEventData(directionType, healType, amount, effectName, name)
 local eventData = MikCEH.CombatEventData;
 MikCEH.EraseTable(eventData);

 eventData.EventType = MikCEH.EVENTTYPE_HEAL;
 eventData.DirectionType = directionType;
 eventData.HealType = healType;
 eventData.Amount = amount;
 eventData.EffectName = effectName;
 eventData.Name = name;

 return eventData;
end

function MikCEH.GetNotificationEventData(notificationType, amount, effectName, SpellName)
 local eventData = MikCEH.CombatEventData;
 MikCEH.EraseTable(eventData);

 eventData.EventType = MikCEH.EVENTTYPE_NOTIFICATION;
 eventData.NotificationType = notificationType;
 eventData.Amount = amount;
 if effectName == MANA or effectName == RAGE or effectName == ENERGY then
  eventData.Amount = (amount or 0) .. " " .. effectName;
  eventData.EffectName = SpellName;
 else
  eventData.EffectName = effectName;
 end

 return eventData;
end

function MikCEH.SendEvent(eventData)
	if (MikSBT.CombatEventsHandler ~= nil) then
		MikSBT.CombatEventsHandler(eventData);
	end
end

function MikCEH.EraseTable(t)
	table_wipe(t);
end

-------------------------------------------------------------------------------------
-- Chat text capture (honor and skill: no structured event exists for either)
-------------------------------------------------------------------------------------

function MikCEH.GetGlobalStringInfo(globalStringName)
 local globalString = getglobal(globalStringName);
 if type(globalString) ~= "string" then return nil end

 if (globalStringInfoArray[globalStringName] == nil) then
  if globalStringInfoSize >= 256 then table_wipe(globalStringInfoArray); globalStringInfoSize = 0 end;
  local searchString = "";
  local currentChar;
  local formatCode;
  local argumentNumber = 0;
  local argumentOrder = {};
  local stringLength = string_len(globalString);

  for index = 0, stringLength do
   currentChar = string_sub(globalString, index, index);

   if (formatCode == nil) then
    if (currentChar == "%") then
     formatCode = currentChar;
    else
     if (string_find(currentChar, "[%^%$%(%)%.%[%]%*%-%+%?]")) then
      searchString = searchString .. "%" .. currentChar;
     else
      searchString = searchString .. currentChar;
     end
    end
   else
    formatCode = formatCode .. currentChar;
    if (formatCode == "%%") then
     searchString = searchString .. "%%";
     formatCode = nil;
    elseif (string_find(currentChar, "[%$%.%d]")) then
     -- continue format parsing
    elseif (string_find(currentChar, "[cEefgGiouXxqs]")) then
     searchString = searchString .. "(.+)";
     argumentNumber = argumentNumber + 1;
     local _, _, argumentPosition = string_find(formatCode, "(%d+)%$");
     argumentOrder[argumentNumber] = argumentPosition and tonumber(argumentPosition) or argumentNumber;
     formatCode = nil;
    elseif (currentChar == "d") then
     searchString = searchString .. "(%d+)";
     argumentNumber = argumentNumber + 1;
     local _, _, argumentPosition = string_find(formatCode, "(%d+)%$");
     argumentOrder[argumentNumber] = argumentPosition and tonumber(argumentPosition) or argumentNumber;
     formatCode = nil;
    else
     formatCode = nil;
    end
   end
  end

  globalStringInfoArray[globalStringName] = {Search=searchString, ArgumentOrder=argumentOrder};
  globalStringInfoSize = globalStringInfoSize + 1;
 end

 return globalStringInfoArray[globalStringName];
end

function MikCEH.GetCapturedData(combatMessage, globalStringName, captureOrder)
 local globalStringInfo = MikCEH.GetGlobalStringInfo(globalStringName);
 if not globalStringInfo then return nil end

 MikCEH.EraseTable(orderedCaptureData);
 local temp = {string_gfind(combatMessage, globalStringInfo.Search)()};
 if (#temp ~= 0) then
  for argNum, substituteValue in pairs(captureOrder) do
   local captureString;
   for captureIndex, position in ipairs(globalStringInfo.ArgumentOrder) do
    if position == argNum then captureString = temp[captureIndex]; break end;
   end
   if (substituteValue == "%a") then
    orderedCaptureData.Amount = captureString;
   elseif (substituteValue == "%k") then
    orderedCaptureData.SkillName = captureString;
   elseif (substituteValue == "%n") then
    orderedCaptureData.Name = captureString;
   end
  end
  return orderedCaptureData;
 end
 return nil;
end

function MikCEH.GetDamageTypeString(damageType)
 if (damageType == MikCEH.DAMAGETYPE_PHYSICAL) then return SPELL_SCHOOL0_CAP
 elseif (damageType == MikCEH.DAMAGETYPE_HOLY) then return SPELL_SCHOOL1_CAP
 elseif (damageType == MikCEH.DAMAGETYPE_FIRE) then return SPELL_SCHOOL2_CAP
 elseif (damageType == MikCEH.DAMAGETYPE_NATURE) then return SPELL_SCHOOL3_CAP
 elseif (damageType == MikCEH.DAMAGETYPE_FROST) then return SPELL_SCHOOL4_CAP
 elseif (damageType == MikCEH.DAMAGETYPE_SHADOW) then return SPELL_SCHOOL5_CAP
 elseif (damageType == MikCEH.DAMAGETYPE_ARCANE) then return SPELL_SCHOOL6_CAP
 end
 return UNKNOWN;
end

-------------------------------------------------------------------------------------
-- Trigger System (Throttled & Consolidated)
-------------------------------------------------------------------------------------

function MikCEH.SendTriggerEvent(eventData)
 if (MikSBT.TriggerHandler ~= nil) then
  MikSBT.TriggerHandler(eventData);
 end
end

function MikCEH.GetThresholdTriggerEventData(triggerKey, triggerAmount)
 local eventData = MikCEH.TriggerEventData;
 MikCEH.EraseTable(eventData);
 eventData.TriggerKey = triggerKey;
 eventData.NumCaptures = 1;
 eventData.CapturedData1 = triggerAmount;
 return eventData;
end

function MikCEH.RegisterTrigger(triggerKey, triggerSettings)
 if (not triggerSettings.Classes or triggerSettings.Classes[playerClass]) then
  if (triggerSettings.TriggerType == MikCEH.TRIGGERTYPE_SELF_HEALTH) then
   selfHealthTriggers[triggerKey] = triggerSettings;
  elseif (triggerSettings.TriggerType == MikCEH.TRIGGERTYPE_SELF_MANA) then
   selfManaTriggers[triggerKey] = triggerSettings;
  elseif (triggerSettings.TriggerType == MikCEH.TRIGGERTYPE_PET_HEALTH) then
   petHealthTriggers[triggerKey] = triggerSettings;
  elseif (triggerSettings.TriggerType == MikCEH.TRIGGERTYPE_ENEMY_HEALTH) then
   enemyHealthTriggers[triggerKey] = triggerSettings;
  elseif (triggerSettings.TriggerType == MikCEH.TRIGGERTYPE_FRIENDLY_HEALTH) then
   friendlyHealthTriggers[triggerKey] = triggerSettings;
  elseif (triggerSettings.TriggerType == MikCEH.TRIGGERTYPE_AURA_GAIN) then
   local auraName = triggerSettings.AuraName;
   if (auraName and auraName ~= "") then
    if not auraGainTriggers[auraName] then auraGainTriggers[auraName] = {} end
    auraGainTriggers[auraName][triggerKey] = triggerSettings;
   end
  elseif (triggerSettings.TriggerType == MikCEH.TRIGGERTYPE_YOU_DODGE) then
   youDodgeTriggers[triggerKey] = triggerSettings;
  elseif (triggerSettings.TriggerType == MikCEH.TRIGGERTYPE_YOU_PARRY) then
   youParryTriggers[triggerKey] = triggerSettings;
  elseif (triggerSettings.TriggerType == MikCEH.TRIGGERTYPE_TARGET_DODGES) then
   targetDodgesTriggers[triggerKey] = triggerSettings;
  end
 end
end

function MikCEH.UnregisterAllTriggers()
 MikCEH.ResetThresholdState();
 MikCEH.EraseTable(selfHealthTriggers);
 MikCEH.EraseTable(selfManaTriggers);
 MikCEH.EraseTable(petHealthTriggers);
 MikCEH.EraseTable(enemyHealthTriggers);
 MikCEH.EraseTable(friendlyHealthTriggers);
 MikCEH.EraseTable(auraGainTriggers);
 MikCEH.EraseTable(youDodgeTriggers);
 MikCEH.EraseTable(youParryTriggers);
 MikCEH.EraseTable(targetDodgesTriggers);
end

-- Start mana-gain observation from the current amount. Called when "Show All
-- Mana Gains" is switched on, because observation stops while it is off.
function MikCEH.ResetManaBaseline()
 lastSelfManaAmount = UnitMana("player") or 0;
end

function MikCEH.ResetThresholdState()
 thresholdGeneration = thresholdGeneration + 1;
 for unit, timer in pairs(pendingHealthChecks) do timer:Cancel(); pendingHealthChecks[unit] = nil end;
 lastSelfHealthPercentage, lastPetHealthPercentage = 0, 0;
 lastEnemyHealthPercentage, lastFriendlyHealthPercentage = 0, 0;
 lastSelfManaPercentage = 0;
 lastSelfManaAmount = UnitMana("player") or 0;
 lastHealthTriggerCheckTime.player, lastHealthTriggerCheckTime.pet, lastHealthTriggerCheckTime.target = 0, 0, 0;
end

local function CheckHealthThresholds(unit, triggers, lastPercentage)
 if not next(triggers) or not UnitExists(unit) then return lastPercentage end;
 local health = UnitHealth(unit);
 local maxHealth = UnitHealthMax(unit);
 if not health or not maxHealth or maxHealth <= 0 then return lastPercentage end
 local pct = health / maxHealth;

 for triggerKey, triggerSettings in pairs(triggers) do
  if (pct < triggerSettings.Threshold/100 and lastPercentage >= triggerSettings.Threshold/100) then
   local eventData = MikCEH.GetThresholdTriggerEventData(triggerKey, health);
   MikCEH.SendTriggerEvent(eventData);
   if unit == "player" and MikSBT.CurrentProfile and MikSBT.CurrentProfile.LowHealthSound then
    PlaySoundFile("Interface\\AddOns\\MikScrollingBattleText\\sounds\\LowHealth.mp3", "Master");
   end
  end
 end
 return pct;
end

function MikCEH.ParseSelfHealthTriggers()
 lastSelfHealthPercentage = CheckHealthThresholds("player", selfHealthTriggers, lastSelfHealthPercentage);
end

function MikCEH.ParsePetHealthTriggers()
 lastPetHealthPercentage = CheckHealthThresholds("pet", petHealthTriggers, lastPetHealthPercentage);
end

function MikCEH.ParseEnemyHealthTriggers()
 lastEnemyHealthPercentage = CheckHealthThresholds("target", enemyHealthTriggers, lastEnemyHealthPercentage);
end

function MikCEH.ParseFriendlyHealthTriggers()
 lastFriendlyHealthPercentage = CheckHealthThresholds("target", friendlyHealthTriggers, lastFriendlyHealthPercentage);
end

function MikCEH.ParseSelfManaTriggers()
 if not next(selfManaTriggers) and not (MikSBT.CurrentProfile and MikSBT.CurrentProfile.ShowAllManaGains) then return end;
 if (UnitPowerType("player") == 0) then
  local manaAmount = UnitMana("player");
  local maxMana = UnitManaMax("player");
  if not maxMana or maxMana == 0 then return end
  local manaPercentage = manaAmount / maxMana;

  local manaDiff = manaAmount - lastSelfManaAmount;
  if (manaDiff > 0 and MikSBT.CurrentProfile and MikSBT.CurrentProfile.ShowAllManaGains) then
   local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_POWER_GAIN, manaDiff, MANA);
   MikCEH.SendEvent(eventData);
  end

  for triggerKey, triggerSettings in pairs(selfManaTriggers) do
   if (manaPercentage < triggerSettings.Threshold/100 and lastSelfManaPercentage >= triggerSettings.Threshold/100) then
    local eventData = MikCEH.GetThresholdTriggerEventData(triggerKey, manaAmount);
    MikCEH.SendTriggerEvent(eventData);
    if MikSBT.CurrentProfile and MikSBT.CurrentProfile.LowManaSound then
     PlaySoundFile("Interface\\AddOns\\MikScrollingBattleText\\sounds\\LowMana.mp3", "Master");
    end
   end
  end
  lastSelfManaPercentage = manaPercentage;
  lastSelfManaAmount = manaAmount;
 end
end
