-------------------------------------------------------------------------------------
-- Title: Mik's Combat Event Helper (ClassicAPI 1.17.7+, SuperWoW, NamPower)
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
local UnitIsFriend, UnitExists = UnitIsFriend, UnitExists
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
MikCEH.TRIGGERTYPE_SEARCH_PATTERN	= 6;

-- Hit info bit flags.
local HITINFO_CRITICALHIT = 128;
local HITINFO_CRUSHING    = 32768;
local HITINFO_GLANCING    = 16384;

-- Lookup tables for NamPower event fields.
local nampowerVictimStateToAction = {
 [0] = MikCEH.ACTIONTYPE_MISS,
 [1] = MikCEH.ACTIONTYPE_HIT,
 [2] = MikCEH.ACTIONTYPE_DODGE,
 [3] = MikCEH.ACTIONTYPE_PARRY,
 [4] = MikCEH.ACTIONTYPE_HIT,
 [5] = MikCEH.ACTIONTYPE_BLOCK,
 [6] = MikCEH.ACTIONTYPE_EVADE,
 [7] = MikCEH.ACTIONTYPE_IMMUNE,
 [8] = MikCEH.ACTIONTYPE_PARRY, -- deflect
}

local nampowerMissToAction = {
 [0] = MikCEH.ACTIONTYPE_MISS,
 [1] = MikCEH.ACTIONTYPE_MISS,
 [2] = MikCEH.ACTIONTYPE_RESIST,
 [3] = MikCEH.ACTIONTYPE_DODGE,
 [4] = MikCEH.ACTIONTYPE_PARRY,
 [5] = MikCEH.ACTIONTYPE_BLOCK,
 [6] = MikCEH.ACTIONTYPE_EVADE,
 [7] = MikCEH.ACTIONTYPE_IMMUNE,
 [8] = MikCEH.ACTIONTYPE_IMMUNE,
 [9] = MikCEH.ACTIONTYPE_PARRY, -- deflect
 [10] = MikCEH.ACTIONTYPE_ABSORB,
 [11] = MikCEH.ACTIONTYPE_REFLECT,
}

local nampowerEnvToAction = {
 [0] = MikCEH.ACTIONTYPE_FATIGUE,
 [1] = MikCEH.ACTIONTYPE_DROWNING,
 [2] = MikCEH.ACTIONTYPE_FALLING,
 [3] = MikCEH.ACTIONTYPE_LAVA,
 [4] = MikCEH.ACTIONTYPE_SLIME,
 [5] = MikCEH.ACTIONTYPE_FIRE,
}

local nampowerSchoolToType = {
 [0] = MikCEH.DAMAGETYPE_PHYSICAL,
 [1] = MikCEH.DAMAGETYPE_HOLY,
 [2] = MikCEH.DAMAGETYPE_FIRE,
 [3] = MikCEH.DAMAGETYPE_NATURE,
 [4] = MikCEH.DAMAGETYPE_FROST,
 [5] = MikCEH.DAMAGETYPE_SHADOW,
 [6] = MikCEH.DAMAGETYPE_ARCANE,
}

local nampowerPowerTypeToString = {
 [0] = MANA,
 [1] = RAGE,
 [2] = nil,
 [3] = ENERGY,
}

-------------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------------

local playerClass = nil;

-- GUIDs of the player and pet, refreshed on world entry and UNIT_PET. Every
-- NamPower event is matched against them, so the compare stays a plain ==.
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
local searchTriggers = {};
local searchFrame;
local searchFilter;

local nampowerEventFrame = nil;
local combatLogFrame = nil;
local nampowerHandlers = {};

-------------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------------

local function RefreshGUIDs()
 local _, guid = UnitExists("player");
 playerGUID = guid;
 local exists, pet = UnitExists("pet");
 petGUID = exists and pet or nil;
end

local function IsPlayerGUID(guid)
 return guid ~= nil and guid == playerGUID
end

local function IsPetGUID(guid)
 return guid ~= nil and guid == petGUID
end

local function GetNameFromGUID(guid)
 if not guid or guid == "" or not UnitExists(guid) then return nil end
 return UnitName(guid);
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

local function SchoolToDamageType(school)
 if not school then return MikCEH.DAMAGETYPE_PHYSICAL end
 return nampowerSchoolToType[school] or MikCEH.DAMAGETYPE_PHYSICAL
end

local function ParseNampowerMitigation(mitigationStr, eventData)
 if not mitigationStr or mitigationStr == "" then return end
 local _, _, a, b, r = string_find(mitigationStr, "^([^,]*),([^,]*),([^,]*)$")
 local absorb = tonumber(a)
 local block = tonumber(b)
 local resist = tonumber(r)

 if absorb and absorb > 0 then
  if eventData.Amount == 0 then
   eventData.ActionType = MikCEH.ACTIONTYPE_ABSORB
   eventData.PartialActionType = nil
  else
   eventData.PartialActionType = MikCEH.PARTIALACTIONTYPE_ABSORB
   eventData.PartialAmount = absorb
  end
 elseif block and block > 0 then
  if eventData.Amount == 0 then
   eventData.ActionType = MikCEH.ACTIONTYPE_BLOCK
   eventData.PartialActionType = nil
  else
   eventData.PartialActionType = MikCEH.PARTIALACTIONTYPE_BLOCK
   eventData.PartialAmount = block
  end
 elseif resist and resist > 0 then
  if eventData.Amount == 0 then
   eventData.ActionType = MikCEH.ACTIONTYPE_RESIST
   eventData.PartialActionType = nil
  else
   eventData.PartialActionType = MikCEH.PARTIALACTIONTYPE_RESIST
   eventData.PartialAmount = resist
  end
 end
end

-------------------------------------------------------------------------------------
-- NamPower Binary Event Handlers (Strictly Scoped to Player and Pet)
-------------------------------------------------------------------------------------

nampowerHandlers["SPELL_DAMAGE_EVENT_SELF"] = function()
 local targetGuid, casterGuid = arg1, arg2
 local spellId = arg3
 local damage = tonumber(arg4) or 0
 local mitigationStr = arg5
 local hitInfo = tonumber(arg6) or 0
 local spellSchool = arg7
 local effectAuraStr = arg8

 local directionType = GetCombatDirection(casterGuid, targetGuid);
 if not directionType then return end;

 local spellName = GetSpellNameFromId(spellId)
 local damageType = SchoolToDamageType(spellSchool)
 local incoming = directionType == MikCEH.DIRECTIONTYPE_PLAYER_INCOMING or directionType == MikCEH.DIRECTIONTYPE_PET_INCOMING;
 local targetName = GetNameFromGUID(incoming and casterGuid or targetGuid)

 local isDoT = false
 if effectAuraStr then
  local _, _, auraTypeStr = string_find(effectAuraStr, "%d+,%d+,%d+,(%d+)")
  local auraType = tonumber(auraTypeStr)
  if auraType == 3 or auraType == 89 then isDoT = true end
 end

 local hitType = MikCEH.HITTYPE_NORMAL
 if isDoT then
  hitType = MikCEH.HITTYPE_OVER_TIME
 elseif bit_band(hitInfo, 2) ~= 0 then
  hitType = MikCEH.HITTYPE_CRIT
 end

 local eventData = MikCEH.GetDamageEventData(directionType, MikCEH.ACTIONTYPE_HIT, hitType, damageType, damage, spellName, targetName)
 eventData.SpellId = spellId
 eventData.IsCrit = bit_band(hitInfo, 2) ~= 0;
 ParseNampowerMitigation(mitigationStr, eventData)
 SetCombatIdentity(eventData, casterGuid, targetGuid);
 MikCEH.SendEvent(eventData)
end

nampowerHandlers["SPELL_DAMAGE_EVENT_OTHER"] = nampowerHandlers["SPELL_DAMAGE_EVENT_SELF"];

nampowerHandlers["AUTO_ATTACK_SELF"] = function()
 local casterGuid, targetGuid = arg1, arg2
 local damage = tonumber(arg3) or 0
 local hitInfo = tonumber(arg4) or 0
 local victimState = tonumber(arg5)
 local blockedDmg = tonumber(arg7) or 0
 local absorbedDmg = tonumber(arg8) or 0
 local resistedDmg = tonumber(arg9) or 0

 local directionType = GetCombatDirection(casterGuid, targetGuid);
 if not directionType then return end;

 local incoming = directionType == MikCEH.DIRECTIONTYPE_PLAYER_INCOMING or directionType == MikCEH.DIRECTIONTYPE_PET_INCOMING;
 local targetName = GetNameFromGUID(incoming and casterGuid or targetGuid)
 local actionType = nampowerVictimStateToAction[victimState]
 if absorbedDmg > 0 and damage == 0 then
  actionType = MikCEH.ACTIONTYPE_ABSORB
 elseif blockedDmg > 0 and damage > 0 then
  actionType = MikCEH.ACTIONTYPE_HIT
 elseif not actionType then
  actionType = (damage > 0) and MikCEH.ACTIONTYPE_HIT or MikCEH.ACTIONTYPE_MISS
 end

 if actionType ~= MikCEH.ACTIONTYPE_HIT then
  local eventData = MikCEH.GetDamageEventData(directionType, actionType, nil, nil, nil, nil, targetName)
  SetCombatIdentity(eventData, casterGuid, targetGuid);
 MikCEH.SendEvent(eventData)
  return
 end

 local hitType = MikCEH.HITTYPE_NORMAL
 if hitInfo and bit_band then
  if bit_band(hitInfo, HITINFO_CRITICALHIT) ~= 0 then
   hitType = MikCEH.HITTYPE_CRIT
  end
 end

 local eventData = MikCEH.GetDamageEventData(directionType, MikCEH.ACTIONTYPE_HIT, hitType, MikCEH.DAMAGETYPE_PHYSICAL, damage, nil, targetName)

 if hitInfo and bit_band then
  if bit_band(hitInfo, HITINFO_CRUSHING) ~= 0 then
   eventData.PartialActionType = MikCEH.PARTIALACTIONTYPE_CRUSHING
  elseif bit_band(hitInfo, HITINFO_GLANCING) ~= 0 then
   eventData.PartialActionType = MikCEH.PARTIALACTIONTYPE_GLANCING
  end
 end

 if not eventData.PartialActionType then
  if absorbedDmg > 0 then
   eventData.PartialActionType = MikCEH.PARTIALACTIONTYPE_ABSORB
   eventData.PartialAmount = absorbedDmg
  elseif blockedDmg > 0 then
   eventData.PartialActionType = MikCEH.PARTIALACTIONTYPE_BLOCK
   eventData.PartialAmount = blockedDmg
  elseif resistedDmg > 0 then
   eventData.PartialActionType = MikCEH.PARTIALACTIONTYPE_RESIST
   eventData.PartialAmount = resistedDmg
  end
 end

 SetCombatIdentity(eventData, casterGuid, targetGuid);
 MikCEH.SendEvent(eventData)
end

nampowerHandlers["AUTO_ATTACK_OTHER"] = nampowerHandlers["AUTO_ATTACK_SELF"];

local function HandleSpellHeal()
 local targetGuid, casterGuid = arg1, arg2;
 local directionType = GetCombatDirection(casterGuid, targetGuid);
 if not directionType then return end;
 local healType = MikCEH.HEALTYPE_NORMAL;
 if tonumber(arg6) == 1 then healType = MikCEH.HEALTYPE_OVER_TIME;
 elseif tonumber(arg5) == 1 then healType = MikCEH.HEALTYPE_CRIT; end
 local incoming = directionType == MikCEH.DIRECTIONTYPE_PLAYER_INCOMING or directionType == MikCEH.DIRECTIONTYPE_PET_INCOMING;
 local eventData = MikCEH.GetHealEventData(directionType, healType, tonumber(arg4) or 0,
   GetSpellNameFromId(arg3), GetNameFromGUID(incoming and casterGuid or targetGuid));
 eventData.SpellId = arg3;
 eventData.IsCrit = tonumber(arg5) == 1;
 SetCombatIdentity(eventData, casterGuid, targetGuid);
 -- NamPower 4.6.2 has no effective-heal/overheal field or guaranteed health-update ordering.
 MikCEH.SendEvent(eventData);
end

nampowerHandlers["SPELL_HEAL_ON_SELF"] = HandleSpellHeal;
nampowerHandlers["SPELL_HEAL_BY_SELF"] = function()
 if IsPlayerGUID(arg1) then return end; -- The provider also emits ON_SELF for this heal.
 HandleSpellHeal();
end
nampowerHandlers["SPELL_HEAL_BY_OTHER"] = nampowerHandlers["SPELL_HEAL_BY_SELF"];

nampowerHandlers["SPELL_ENERGIZE_ON_SELF"] = function()
 local spellId = arg3
 local powerType = tonumber(arg4) or 0
 local amount = tonumber(arg5) or 0

 local powerTypeStr = nampowerPowerTypeToString[powerType]
 if not powerTypeStr then return end

 local spellName = GetSpellNameFromId(spellId)
 local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_POWER_GAIN, amount, powerTypeStr, spellName)
 eventData.SpellId = spellId
 eventData.IsSpellManaGain = powerType == 0;

 MikCEH.SendEvent(eventData)
end

nampowerHandlers["SPELL_MISS_SELF"] = function()
 local casterGuid, targetGuid = arg1, arg2
 local spellId = arg3
 local missInfo = tonumber(arg4) or 0

 local directionType = GetCombatDirection(casterGuid, targetGuid);
 if not directionType then return end;

 local spellName = GetSpellNameFromId(spellId)
 local incoming = directionType == MikCEH.DIRECTIONTYPE_PLAYER_INCOMING or directionType == MikCEH.DIRECTIONTYPE_PET_INCOMING;
 local targetName = GetNameFromGUID(incoming and casterGuid or targetGuid)
 local actionType = nampowerMissToAction[missInfo] or MikCEH.ACTIONTYPE_MISS

 local eventData = MikCEH.GetDamageEventData(directionType, actionType, nil, nil, nil, spellName, targetName)
 eventData.SpellId = spellId

 SetCombatIdentity(eventData, casterGuid, targetGuid);
 MikCEH.SendEvent(eventData)
end

nampowerHandlers["SPELL_MISS_OTHER"] = nampowerHandlers["SPELL_MISS_SELF"];

nampowerHandlers["DAMAGE_SHIELD_SELF"] = function()
 -- NamPower 4.6.2+: shield owner, damaged attacker, damage, school; no spell ID.
 local casterGuid, targetGuid = arg1, arg2
 local damage = tonumber(arg3) or 0
 local spellSchool = arg4

 local directionType = GetCombatDirection(casterGuid, targetGuid);
 if not directionType then return end;

 local spellName = "Damage Shield"
 local damageType = SchoolToDamageType(spellSchool)
 local name = (directionType == MikCEH.DIRECTIONTYPE_PLAYER_INCOMING or directionType == MikCEH.DIRECTIONTYPE_PET_INCOMING) and GetNameFromGUID(casterGuid) or (GetNameFromGUID(targetGuid))

 local eventData = MikCEH.GetDamageEventData(directionType, MikCEH.ACTIONTYPE_HIT, MikCEH.HITTYPE_NORMAL, damageType, damage, spellName, name)
 SetCombatIdentity(eventData, casterGuid, targetGuid);
 MikCEH.SendEvent(eventData)
end

nampowerHandlers["DAMAGE_SHIELD_OTHER"] = nampowerHandlers["DAMAGE_SHIELD_SELF"];

nampowerHandlers["ENVIRONMENTAL_DMG_SELF"] = function()
 local targetGuid = arg1
 local envType = tonumber(arg2) or 2
 local damage = tonumber(arg3) or 0
 local absorbed = tonumber(arg4) or 0
 local resisted = tonumber(arg5) or 0

 if not IsPlayerGUID(targetGuid) and not IsPetGUID(targetGuid) then return end

 local actionType = nampowerEnvToAction[envType] or MikCEH.ACTIONTYPE_FALLING
 local eventData = MikCEH.GetDamageEventData(MikCEH.DIRECTIONTYPE_PLAYER_INCOMING, actionType, MikCEH.HITTYPE_NORMAL, MikCEH.DAMAGETYPE_PHYSICAL, damage, nil, nil)

 if absorbed > 0 then
  eventData.PartialActionType = MikCEH.PARTIALACTIONTYPE_ABSORB
  eventData.PartialAmount = absorbed
 elseif resisted > 0 then
  eventData.PartialActionType = MikCEH.PARTIALACTIONTYPE_RESIST
  eventData.PartialAmount = resisted
 end

 MikCEH.SendEvent(eventData)
end

nampowerHandlers["BUFF_ADDED_SELF"] = function()
 local unitGuid = arg1
 local spellId = arg3
 if not IsPlayerGUID(unitGuid) then return end

 local spellName = GetSpellNameFromId(spellId)
 if not spellName then return end

 local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_BUFF, nil, spellName)
 eventData.SpellId = spellId
 MikCEH.SendEvent(eventData)
end

nampowerHandlers["DEBUFF_ADDED_SELF"] = function()
 local unitGuid = arg1
 local spellId = arg3
 if not IsPlayerGUID(unitGuid) then return end

 local spellName = GetSpellNameFromId(spellId)
 if not spellName then return end

 local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_DEBUFF, nil, spellName)
 eventData.SpellId = spellId
 MikCEH.SendEvent(eventData)
end

-- NamPower aura state (arg7): 0 = added, 1 = removed, 2 = stack change.
-- A *_REMOVED_* event with state 2 is a stack decrease; the aura is still active.
local AURA_STATE_MODIFIED = 2

nampowerHandlers["BUFF_REMOVED_SELF"] = function()
 local unitGuid = arg1
 local spellId = arg3
 if tonumber(arg7) == AURA_STATE_MODIFIED then return end
 if not IsPlayerGUID(unitGuid) then return end

 local spellName = GetSpellNameFromId(spellId)
 if not spellName then return end

 local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_BUFF_FADE, nil, spellName)
 eventData.SpellId = spellId
 MikCEH.SendEvent(eventData)
end

nampowerHandlers["DEBUFF_REMOVED_SELF"] = function()
 local unitGuid = arg1
 local spellId = arg3
 if tonumber(arg7) == AURA_STATE_MODIFIED then return end
 if not IsPlayerGUID(unitGuid) then return end

 local spellName = GetSpellNameFromId(spellId)
 if not spellName then return end

 local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_BUFF_FADE, nil, spellName)
 eventData.SpellId = spellId
 MikCEH.SendEvent(eventData)
end

function MikCEH.OnNampowerEvent()
 local handler = nampowerHandlers[event]
 if handler then handler() end
end

-------------------------------------------------------------------------------------
-- Core Helper Initialization & Lifecycle
-------------------------------------------------------------------------------------

function MikCEH.Init()
 _, playerClass = UnitClass("player");
 RefreshGUIDs();

 -- NamPower sends these events only when its CVars are on.
 SetCVar("NP_EnableAutoAttackEvents", "1");
 SetCVar("NP_EnableSpellHealEvents", "1");
 SetCVar("NP_EnableSpellEnergizeEvents", "1");
end

function MikCEH.RegisterEvents()
 RefreshGUIDs();
 if searchFilter then MikCEH.EnableEventSearching(searchFilter) end;
 if MCEHEventFrame then
  MCEHEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
  MCEHEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
  MCEHEventFrame:RegisterEvent("PLAYER_COMBO_POINTS");
  MCEHEventFrame:RegisterEvent("UNIT_HEALTH");
  MCEHEventFrame:RegisterEvent("UNIT_MANA");
  MCEHEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
  MCEHEventFrame:RegisterEvent("UNIT_PET");
  MCEHEventFrame:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN");
  MCEHEventFrame:RegisterEvent("FACTION_STANDING_CHANGED");
  MCEHEventFrame:RegisterEvent("CHAT_MSG_SKILL");
  MCEHEventFrame:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN");
 end
 if combatLogFrame then combatLogFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") end

 if nampowerEventFrame then
  nampowerEventFrame:RegisterEvent("SPELL_DAMAGE_EVENT_SELF");
  nampowerEventFrame:RegisterEvent("SPELL_DAMAGE_EVENT_OTHER");
  nampowerEventFrame:RegisterEvent("AUTO_ATTACK_SELF");
  nampowerEventFrame:RegisterEvent("AUTO_ATTACK_OTHER");
  nampowerEventFrame:RegisterEvent("SPELL_HEAL_BY_SELF");
  nampowerEventFrame:RegisterEvent("SPELL_HEAL_BY_OTHER");
  nampowerEventFrame:RegisterEvent("SPELL_HEAL_ON_SELF");
  nampowerEventFrame:RegisterEvent("SPELL_ENERGIZE_ON_SELF");
  nampowerEventFrame:RegisterEvent("SPELL_MISS_SELF");
  nampowerEventFrame:RegisterEvent("SPELL_MISS_OTHER");
  nampowerEventFrame:RegisterEvent("BUFF_ADDED_SELF");
  nampowerEventFrame:RegisterEvent("BUFF_REMOVED_SELF");
  nampowerEventFrame:RegisterEvent("DEBUFF_ADDED_SELF");
  nampowerEventFrame:RegisterEvent("DEBUFF_REMOVED_SELF");
  nampowerEventFrame:RegisterEvent("DAMAGE_SHIELD_SELF");
  nampowerEventFrame:RegisterEvent("DAMAGE_SHIELD_OTHER");
  nampowerEventFrame:RegisterEvent("ENVIRONMENTAL_DMG_SELF");
 end
 if searchFrame then
  for name in pairs(searchTriggers) do searchFrame:RegisterEvent(name) end
 end
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
  MCEHEventFrame:UnregisterEvent("CHAT_MSG_COMBAT_XP_GAIN");
 end
 if combatLogFrame then combatLogFrame:UnregisterAllEvents() end

 if nampowerEventFrame then
  nampowerEventFrame:UnregisterAllEvents();
 end
 if searchFrame then searchFrame:UnregisterAllEvents() end;
 MikCEH.ResetThresholdState();
end

function MikCEH.OnSearchEvent()
 if type(arg1) ~= "string" then return end;
 if searchFilter and string_find(event, searchFilter, 1, true) then
  MikSBT.Print(event .. ": " .. arg1);
 end
 local triggers = searchTriggers[event];
 if not triggers then return end;
 for key, settings in pairs(triggers) do
  for _, pattern in ipairs(settings.SearchPatterns or {}) do
   local info = MikCEH.GetGlobalStringInfo(pattern);
   local captures = {pcall(string_find, arg1, info and info.Search or pattern)};
   if captures[1] and captures[2] then
    local data = MikCEH.TriggerEventData;
    MikCEH.EraseTable(data);
    data.TriggerKey, data.NumCaptures = key, #captures - 3;
    for i = 1, data.NumCaptures do
     local position = info and info.ArgumentOrder[i] or i;
     data["CapturedData" .. position] = captures[i+3];
    end
    MikCEH.SendTriggerEvent(data);
    break;
   end
  end
 end
end

function MikCEH.EnableEventSearching(searchPattern)
 searchFilter = searchPattern;
 if searchFrame and not (MikSBT_Save and MikSBT_Save.UserDisabled) then
  for _, name in ipairs(MikSBTOpt.AvailableTriggerEvents or {}) do searchFrame:RegisterEvent(name) end;
 end
end
function MikCEH.DisableEventSearching()
 searchFilter = nil;
 if searchFrame then
  searchFrame:UnregisterAllEvents();
  if not (MikSBT_Save and MikSBT_Save.UserDisabled) then
   for name in pairs(searchTriggers) do searchFrame:RegisterEvent(name) end;
  end
 end
end

function MikCEH.OnLoad()
 MCEHEventFrame:RegisterEvent("ADDON_LOADED");
 MCEHEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

 searchFrame = CreateFrame("Frame");
 searchFrame:SetScript("OnEvent", MikCEH.OnSearchEvent);
 nampowerEventFrame = CreateFrame("Frame");
 nampowerEventFrame:SetScript("OnEvent", MikCEH.OnNampowerEvent);
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

 elseif (event == "CHAT_MSG_COMBAT_XP_GAIN") then
  local capturedData = MikCEH.GetCapturedData(arg1, "COMBATLOG_XPGAIN_FIRSTPERSON", {"%n", "%a"});
  if (capturedData ~= nil) then
   local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_EXPERIENCE_GAIN, capturedData.Amount, capturedData.Name);
   MikCEH.SendEvent(eventData);
  end

 end
end

-- Subevents that take power from the destination unit.
local DRAIN_SUBEVENTS = {SPELL_DRAIN = true, SPELL_PERIODIC_DRAIN = true, SPELL_LEECH = true, SPELL_PERIODIC_LEECH = true};

-- The combat log gives killing blows (the victim's flags say whether it was a
-- player) and power drained from you. Events that do not involve you, the bulk
-- of the nearby combat stream, return at the first compare.
function MikCEH.OnCombatLogEvent()
 if (arg4 ~= playerGUID and arg8 ~= playerGUID) then return end
 local subevent = arg2;
 if (subevent == "PARTY_KILL") then
  if (arg4 ~= playerGUID) then return end
  local notificationType = MikCEH.NOTIFICATIONTYPE_NPC_KILLING_BLOW;
  if (bit_band(arg10 or 0, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0) then
   notificationType = MikCEH.NOTIFICATIONTYPE_PC_KILLING_BLOW;
  end
  MikCEH.SendEvent(MikCEH.GetNotificationEventData(notificationType, nil, arg9));
 elseif (DRAIN_SUBEVENTS[subevent] and arg8 == playerGUID) then
  -- spellId, spellName, school, then amount, powerType.
  local powerTypeStr = nampowerPowerTypeToString[tonumber(arg16)];
  local amount = tonumber(arg15) or 0;
  if (powerTypeStr and amount > 0) then
   local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_POWER_LOSS, amount, powerTypeStr, arg13);
   eventData.SpellId = arg12;
   MikCEH.SendEvent(eventData);
  end
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
-- Chat text capture (honor, skill, XP and search triggers)
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
  elseif (triggerSettings.TriggerType == MikCEH.TRIGGERTYPE_SEARCH_PATTERN) then
   for _, name in ipairs(triggerSettings.TriggerEvents or {}) do
    if not searchTriggers[name] then searchTriggers[name] = {} end
    searchTriggers[name][triggerKey] = triggerSettings;
    if searchFrame and not (MikSBT_Save and MikSBT_Save.UserDisabled) then searchFrame:RegisterEvent(name) end
   end
  end
 end
end

function MikCEH.UnregisterAllTriggers()
 if searchFrame then searchFrame:UnregisterAllEvents() end;
 table_wipe(searchTriggers);
 if searchFilter then MikCEH.EnableEventSearching(searchFilter) end;
 MikCEH.ResetThresholdState();
 MikCEH.EraseTable(selfHealthTriggers);
 MikCEH.EraseTable(selfManaTriggers);
 MikCEH.EraseTable(petHealthTriggers);
 MikCEH.EraseTable(enemyHealthTriggers);
 MikCEH.EraseTable(friendlyHealthTriggers);
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
