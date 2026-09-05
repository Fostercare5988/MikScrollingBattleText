-------------------------------------------------------------------------------------
-- Title: Mik's Combat Event Helper (ClassicAPI v1.13.4+ & SuperWoW 2.2+ Stack)
-- Author: Mik, Fostercare5988
-- Maintainer: Fostercare5988
-------------------------------------------------------------------------------------

-- Strict Engine Dependency Guard (Mandatory ClassicAPI v1.13.4+ & SuperWoW v2.2+)
local MIN_CLASSIC_API = 11304
if not (CLASSIC_API_VERSION and SUPERWOW_VERSION) or 
   (type(CLASSIC_API_VERSION) == "number" and CLASSIC_API_VERSION < MIN_CLASSIC_API) then
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage("|cffff2020[MSBT Fatal Error]|r MikScrollingBattleText requires ClassicAPI (v1.13.4+) & SuperWoW (v2.2+)! Please ensure both DLLs are loaded.", 1, 0.2, 0.2)
	end
	return
end

-- Create namespace.
MikCEH = {};

-- Upvalue caches for high-performance execution.
-- Static unit ID pre-allocations for O(1) loop iteration
local PARTY_UNITS = {}
local RAID_UNITS = {}
for i = 1, 4 do PARTY_UNITS[i] = "party" .. i end
for i = 1, 40 do RAID_UNITS[i] = "raid" .. i end

local string_find, string_gsub, string_gfind = string.find, string.gsub, string.gfind
local string_len, string_sub, string_lower = string.len, string.sub, string.lower
local table_insert, table_setn = table.insert, table.setn
local GetTime, UnitHealth, UnitHealthMax = GetTime, UnitHealth, UnitHealthMax
local UnitMana, UnitManaMax, UnitName, UnitClass = UnitMana, UnitManaMax, UnitName, UnitClass
local UnitIsPlayer, UnitIsFriend, UnitExists = UnitIsPlayer, UnitIsFriend, UnitExists
local UnitPowerType, GetComboPoints = UnitPowerType, GetComboPoints
local pairs, tonumber, type, pcall, tostring = pairs, tonumber, type, pcall, tostring
local bit_band = bit and bit.band

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
MikCEH.PARTIALACTIONTYPE_VULNERABLE	= 4;
MikCEH.PARTIALACTIONTYPE_CRUSHING	= 5;
MikCEH.PARTIALACTIONTYPE_GLANCING	= 6;
MikCEH.PARTIALACTIONTYPE_OVERHEAL	= 7;

-- Heal types.
MikCEH.HEALTYPE_NORMAL		= 1;
MikCEH.HEALTYPE_CRIT		= 2;
MikCEH.HEALTYPE_OVER_TIME	= 3;

-- Notification types.
MikCEH.NOTIFICATIONTYPE_DEBUFF		= 1;
MikCEH.NOTIFICATIONTYPE_BUFF			= 2;
MikCEH.NOTIFICATIONTYPE_ITEM_BUFF		= 3;
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
local HITINFO_CRITICALHIT = 2;
local HITINFO_CRUSHING    = 32;
local HITINFO_GLANCING    = 64;

-- Lookup tables for NamPower event fields.
local nampowerVictimStateToAction = {
 [0] = MikCEH.ACTIONTYPE_MISS,
 [1] = MikCEH.ACTIONTYPE_HIT,
 [2] = MikCEH.ACTIONTYPE_DODGE,
 [3] = MikCEH.ACTIONTYPE_PARRY,
 [4] = MikCEH.ACTIONTYPE_BLOCK,
 [5] = MikCEH.ACTIONTYPE_BLOCK,
 [6] = MikCEH.ACTIONTYPE_EVADE,
 [7] = MikCEH.ACTIONTYPE_IMMUNE,
 [8] = MikCEH.ACTIONTYPE_IMMUNE,
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
 [9] = MikCEH.ACTIONTYPE_REFLECT,
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

local playerName = nil;
local playerClass = nil;
local playerGUID = nil;

-- DLL feature flags.
local hasNampower = false;
local hasSuperWoW = false;
local hasUnitXP = false;

-- Recycled event tables.
MikCEH.CombatEventData = {};
MikCEH.TriggerEventData = {};
local orderedCaptureData = {};
local globalStringInfoArray = {};

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

local recentlySelectedPlayers = {};
local RECENTLY_SELECTED_PLAYERS_UPDATE_INTERVAL = 10;
local elapsedTime = 0;

local TRIGGER_THROTTLE_INTERVAL = 0.15;
local lastTriggerCheckTime = 0;

-- Caches.
local spellNameCache = {};

local nampowerEventFrame = nil;
local nampowerHandlers = {};

-------------------------------------------------------------------------------------
-- DLL Verification & Helpers
-------------------------------------------------------------------------------------

local function GetUnitGuidSafe(unit)
 if not unit then return nil end
 if GetUnitGUID then
  local ok, guid = pcall(GetUnitGUID, unit)
  if ok and guid and guid ~= "" then return guid end
 end
 if UnitExists then
  local ok, exists, guid = pcall(UnitExists, unit)
  if ok and exists and guid and guid ~= "" then return guid end
 end
 if UnitGUID then
  local ok, guid = pcall(UnitGUID, unit)
  if ok and guid and guid ~= "" then return guid end
 end
 return nil
end

local function GetPlayerGUID()
 if not playerGUID or playerGUID == "" then
  playerGUID = GetUnitGuidSafe("player")
 end
 return playerGUID
end

local function EnsurePlayerGUID()
 return GetPlayerGUID() ~= nil
end

local function IsPlayerGUID(guid)
 if not guid or guid == "" then return false end
 local pGuid = GetPlayerGUID()
 if not pGuid then return false end
 return (guid == pGuid) or (string_lower(tostring(guid)) == string_lower(tostring(pGuid)))
end

local function IsPetGUID(guid)
 if not guid or guid == "" or not UnitExists("pet") then return false end
 local petGuid = GetUnitGuidSafe("pet")
 if not petGuid then return false end
 return (guid == petGuid) or (string_lower(tostring(guid)) == string_lower(tostring(petGuid)))
end

local function GetNameFromGUID(guid)
 if not guid or guid == "" then return nil end
 if hasSuperWoW and UnitName then
  local ok, n = pcall(UnitName, guid)
  if ok and n and n ~= "" then return n end
 end
 if hasSuperWoW and UnitExists then
  local ok, exists, uid = pcall(UnitExists, guid)
  if ok and exists and uid then
   local n = UnitName(uid)
   if n and n ~= "" then return n end
  end
 end
 if GetUnitField then
  local ok, name = pcall(GetUnitField, guid, "name")
  if ok and name and name ~= "" then return name end
 end
 if UnitExists("target") and UnitName("target") then
  local tGuid = GetUnitGuidSafe("target")
  if tGuid and (tGuid == guid or string_lower(tostring(tGuid)) == string_lower(tostring(guid))) then
   return UnitName("target")
  end
 end
 return nil
end

local function GetSpellNameFromId(spellId)
 if not spellId or spellId == 0 then return nil end
 if spellNameCache[spellId] then return spellNameCache[spellId] end

 local name
 if hasSuperWoW and SpellInfo then
  local ok, n = pcall(SpellInfo, spellId)
  if ok and n and n ~= "" then name = n end
 end
 if not name and hasNampower and GetSpellNameAndRankForId then
  local ok, n = pcall(GetSpellNameAndRankForId, spellId)
  if ok and n and n ~= "" then name = n end
 end
 if not name and MikSBT and MikSBT.SpellName then
  name = MikSBT.SpellName(spellId, "Ability")
 end

 if name then spellNameCache[spellId] = name end
 return name
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

 local directionType
 if IsPetGUID(casterGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PET_OUTGOING
 elseif IsPlayerGUID(casterGuid) then
  if IsPlayerGUID(targetGuid) then
   directionType = MikCEH.DIRECTIONTYPE_PLAYER_INCOMING
  else
   directionType = MikCEH.DIRECTIONTYPE_PLAYER_OUTGOING
  end
 elseif IsPlayerGUID(targetGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PLAYER_INCOMING
 else
  -- If GUIDs are still resolving on startup, default to player outgoing
  directionType = MikCEH.DIRECTIONTYPE_PLAYER_OUTGOING
 end

 local spellName = GetSpellNameFromId(spellId)
 local damageType = SchoolToDamageType(spellSchool)
 local targetName = GetNameFromGUID(targetGuid) or UnitName("target")

 local isDoT = false
 if effectAuraStr then
  local _, _, auraTypeStr = string_find(effectAuraStr, "%d+,%d+,%d+,(%d+)")
  local auraType = tonumber(auraTypeStr)
  if auraType == 3 or auraType == 89 then isDoT = true end
 end

 local hitType = MikCEH.HITTYPE_NORMAL
 if isDoT then
  hitType = MikCEH.HITTYPE_OVER_TIME
 elseif hitInfo ~= 0 then
  hitType = MikCEH.HITTYPE_CRIT
 end

 local eventData = MikCEH.GetDamageEventData(directionType, MikCEH.ACTIONTYPE_HIT, hitType, damageType, damage, spellName, targetName)
 eventData.SpellId = spellId
 ParseNampowerMitigation(mitigationStr, eventData)
 MikCEH.SendEvent(eventData)
end

nampowerHandlers["SPELL_DAMAGE_EVENT_OTHER"] = function()
 local targetGuid, casterGuid = arg1, arg2
 local spellId = arg3
 local damage = tonumber(arg4) or 0
 local mitigationStr = arg5
 local hitInfo = tonumber(arg6) or 0
 local spellSchool = arg7
 local effectAuraStr = arg8

 -- ONLY process if the target is the player or player's pet!
 local directionType
 if IsPlayerGUID(targetGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PLAYER_INCOMING
 elseif IsPetGUID(targetGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PET_INCOMING
 else
  return -- Ignore other raid members/NPC damage
 end

 local spellName = GetSpellNameFromId(spellId)
 local damageType = SchoolToDamageType(spellSchool)
 local casterName = GetNameFromGUID(casterGuid)

 local isDoT = false
 if effectAuraStr then
  local _, _, auraTypeStr = string_find(effectAuraStr, "%d+,%d+,%d+,(%d+)")
  local auraType = tonumber(auraTypeStr)
  if auraType == 3 or auraType == 89 then isDoT = true end
 end

 local hitType = MikCEH.HITTYPE_NORMAL
 if isDoT then
  hitType = MikCEH.HITTYPE_OVER_TIME
 elseif hitInfo ~= 0 then
  hitType = MikCEH.HITTYPE_CRIT
 end

 local eventData = MikCEH.GetDamageEventData(directionType, MikCEH.ACTIONTYPE_HIT, hitType, damageType, damage, spellName, casterName)
 eventData.SpellId = spellId
 ParseNampowerMitigation(mitigationStr, eventData)
 MikCEH.SendEvent(eventData)
end

nampowerHandlers["AUTO_ATTACK_SELF"] = function()
 local casterGuid, targetGuid = arg1, arg2
 local damage = tonumber(arg3) or 0
 local hitInfo = tonumber(arg4) or 0
 local victimState = tonumber(arg5)
 local blockedDmg = tonumber(arg7) or 0
 local absorbedDmg = tonumber(arg8) or 0
 local resistedDmg = tonumber(arg9) or 0

 local directionType = MikCEH.DIRECTIONTYPE_PLAYER_OUTGOING
 if IsPetGUID(casterGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PET_OUTGOING
 end

 local targetName = GetNameFromGUID(targetGuid) or UnitName("target")
 local actionType = nampowerVictimStateToAction[victimState]
 if absorbedDmg > 0 and damage == 0 then
  actionType = MikCEH.ACTIONTYPE_ABSORB
 elseif not actionType then
  actionType = (damage > 0) and MikCEH.ACTIONTYPE_HIT or MikCEH.ACTIONTYPE_MISS
 end

 if actionType ~= MikCEH.ACTIONTYPE_HIT then
  local eventData = MikCEH.GetDamageEventData(directionType, actionType, nil, nil, nil, nil, targetName)
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

 MikCEH.SendEvent(eventData)
end

nampowerHandlers["AUTO_ATTACK_OTHER"] = function()
 local casterGuid, targetGuid = arg1, arg2
 local damage = tonumber(arg3) or 0
 local hitInfo = tonumber(arg4) or 0
 local victimState = tonumber(arg5)
 local blockedDmg = tonumber(arg7) or 0
 local absorbedDmg = tonumber(arg8) or 0
 local resistedDmg = tonumber(arg9) or 0

 -- ONLY process if the target is the player or player's pet!
 local directionType
 if IsPlayerGUID(targetGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PLAYER_INCOMING
 elseif IsPetGUID(targetGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PET_INCOMING
 else
  return -- Ignore other raid members/NPCs attacking each other
 end

 local casterName = GetNameFromGUID(casterGuid)
 local actionType = nampowerVictimStateToAction[victimState]
 if absorbedDmg > 0 and damage == 0 then
  actionType = MikCEH.ACTIONTYPE_ABSORB
 elseif not actionType then
  actionType = (damage > 0) and MikCEH.ACTIONTYPE_HIT or MikCEH.ACTIONTYPE_MISS
 end

 if actionType ~= MikCEH.ACTIONTYPE_HIT then
  local eventData = MikCEH.GetDamageEventData(directionType, actionType, nil, nil, nil, nil, casterName)
  MikCEH.SendEvent(eventData)
  return
 end

 local hitType = MikCEH.HITTYPE_NORMAL
 if hitInfo and bit_band then
  if bit_band(hitInfo, HITINFO_CRITICALHIT) ~= 0 then
   hitType = MikCEH.HITTYPE_CRIT
  end
 end

 local eventData = MikCEH.GetDamageEventData(directionType, MikCEH.ACTIONTYPE_HIT, hitType, MikCEH.DAMAGETYPE_PHYSICAL, damage, nil, casterName)

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

 MikCEH.SendEvent(eventData)
end

nampowerHandlers["SPELL_HEAL_ON_SELF"] = function()
 local targetGuid, casterGuid = arg1, arg2
 local spellId = arg3
 local healAmount = tonumber(arg4) or 0
 local isCrit = tonumber(arg5) or 0
 local isHot = tonumber(arg6) or 0

 if not IsPlayerGUID(targetGuid) and not IsPetGUID(targetGuid) then return end

 local spellName = GetSpellNameFromId(spellId)
 local casterName = GetNameFromGUID(casterGuid)

 local healType = MikCEH.HEALTYPE_NORMAL
 if isHot ~= 0 then
  healType = MikCEH.HEALTYPE_OVER_TIME
 elseif isCrit ~= 0 then
  healType = MikCEH.HEALTYPE_CRIT
 end

 local eventData = MikCEH.GetHealEventData(MikCEH.DIRECTIONTYPE_PLAYER_INCOMING, healType, healAmount, spellName, casterName)
 eventData.SpellId = spellId

 eventData.Name = playerName
 MikCEH.PopulateOverhealData(eventData)
 eventData.Name = casterName
 MikCEH.SendEvent(eventData)
end

nampowerHandlers["SPELL_HEAL_BY_SELF"] = function()
 local targetGuid, casterGuid = arg1, arg2
 local spellId = arg3
 local healAmount = tonumber(arg4) or 0
 local isCrit = tonumber(arg5) or 0
 local isHot = tonumber(arg6) or 0

 if not IsPlayerGUID(casterGuid) and not IsPetGUID(casterGuid) then return end
 if IsPlayerGUID(targetGuid) then return end -- handled by SPELL_HEAL_ON_SELF

 local spellName = GetSpellNameFromId(spellId)
 local targetName = GetNameFromGUID(targetGuid) or UnitName("target")

 local healType = MikCEH.HEALTYPE_NORMAL
 if isHot ~= 0 then
  healType = MikCEH.HEALTYPE_OVER_TIME
 elseif isCrit ~= 0 then
  healType = MikCEH.HEALTYPE_CRIT
 end

 local eventData = MikCEH.GetHealEventData(MikCEH.DIRECTIONTYPE_PLAYER_OUTGOING, healType, healAmount, spellName, targetName)
 eventData.SpellId = spellId

 MikCEH.PopulateOverhealData(eventData)
 MikCEH.SendEvent(eventData)
end

nampowerHandlers["SPELL_ENERGIZE_ON_SELF"] = function()
 local spellId = arg3
 local powerType = tonumber(arg4) or 0
 local amount = tonumber(arg5) or 0

 local powerTypeStr = nampowerPowerTypeToString[powerType]
 if not powerTypeStr then return end

 local spellName = GetSpellNameFromId(spellId)
 local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_POWER_GAIN, amount, powerTypeStr, spellName)
 eventData.SpellId = spellId

 MikCEH.SendEvent(eventData)
end

nampowerHandlers["SPELL_MISS_SELF"] = function()
 local casterGuid, targetGuid = arg1, arg2
 local spellId = arg3
 local missInfo = tonumber(arg4) or 0

 local directionType
 if IsPetGUID(casterGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PET_OUTGOING
 elseif IsPlayerGUID(casterGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PLAYER_OUTGOING
 else
  directionType = MikCEH.DIRECTIONTYPE_PLAYER_OUTGOING
 end

 local spellName = GetSpellNameFromId(spellId)
 local targetName = GetNameFromGUID(targetGuid) or UnitName("target")
 local actionType = nampowerMissToAction[missInfo] or MikCEH.ACTIONTYPE_MISS

 local eventData = MikCEH.GetDamageEventData(directionType, actionType, nil, nil, nil, spellName, targetName)
 eventData.SpellId = spellId

 MikCEH.SendEvent(eventData)
end

nampowerHandlers["SPELL_MISS_OTHER"] = function()
 local casterGuid, targetGuid = arg1, arg2
 local spellId = arg3
 local missInfo = tonumber(arg4) or 0

 -- ONLY process if the target is the player or player's pet!
 local directionType
 if IsPlayerGUID(targetGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PLAYER_INCOMING
 elseif IsPetGUID(targetGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PET_INCOMING
 else
  return -- Ignore misses against other raid members/NPCs
 end

 local spellName = GetSpellNameFromId(spellId)
 local casterName = GetNameFromGUID(casterGuid)
 local actionType = nampowerMissToAction[missInfo] or MikCEH.ACTIONTYPE_MISS

 local eventData = MikCEH.GetDamageEventData(directionType, actionType, nil, nil, nil, spellName, casterName)
 eventData.SpellId = spellId

 MikCEH.SendEvent(eventData)
end

nampowerHandlers["DAMAGE_SHIELD_SELF"] = function()
 local targetGuid, casterGuid = arg1, arg2
 local spellId = arg3
 local damage = tonumber(arg4) or 0
 local spellSchool = arg5

 local directionType
 if IsPlayerGUID(casterGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PLAYER_OUTGOING
 elseif IsPlayerGUID(targetGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PLAYER_INCOMING
 elseif IsPetGUID(casterGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PET_OUTGOING
 elseif IsPetGUID(targetGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PET_INCOMING
 else
  directionType = MikCEH.DIRECTIONTYPE_PLAYER_OUTGOING
 end

 local spellName = GetSpellNameFromId(spellId) or "Damage Shield"
 local damageType = SchoolToDamageType(spellSchool)
 local name = (directionType == MikCEH.DIRECTIONTYPE_PLAYER_INCOMING) and GetNameFromGUID(casterGuid) or (GetNameFromGUID(targetGuid) or UnitName("target"))

 local eventData = MikCEH.GetDamageEventData(directionType, MikCEH.ACTIONTYPE_HIT, MikCEH.HITTYPE_NORMAL, damageType, damage, spellName, name)
 eventData.SpellId = spellId
 MikCEH.SendEvent(eventData)
end

nampowerHandlers["DAMAGE_SHIELD_OTHER"] = function()
 local targetGuid, casterGuid = arg1, arg2
 local spellId = arg3
 local damage = tonumber(arg4) or 0
 local spellSchool = arg5

 local directionType
 if IsPlayerGUID(targetGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PLAYER_INCOMING
 elseif IsPetGUID(targetGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PET_INCOMING
 elseif IsPlayerGUID(casterGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PLAYER_OUTGOING
 elseif IsPetGUID(casterGuid) then
  directionType = MikCEH.DIRECTIONTYPE_PET_OUTGOING
 else
  return
 end

 local spellName = GetSpellNameFromId(spellId) or "Damage Shield"
 local damageType = SchoolToDamageType(spellSchool)
 local name = (directionType == MikCEH.DIRECTIONTYPE_PLAYER_INCOMING) and GetNameFromGUID(casterGuid) or (GetNameFromGUID(targetGuid) or UnitName("target"))

 local eventData = MikCEH.GetDamageEventData(directionType, MikCEH.ACTIONTYPE_HIT, MikCEH.HITTYPE_NORMAL, damageType, damage, spellName, name)
 eventData.SpellId = spellId
 MikCEH.SendEvent(eventData)
end

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
 if not IsPlayerGUID(unitGuid) and not IsPetGUID(unitGuid) then return end

 local spellName = GetSpellNameFromId(spellId)
 if not spellName then return end

 local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_BUFF, nil, spellName)
 eventData.SpellId = spellId
 MikCEH.SendEvent(eventData)
end

nampowerHandlers["DEBUFF_ADDED_SELF"] = function()
 local unitGuid = arg1
 local spellId = arg3
 if not IsPlayerGUID(unitGuid) and not IsPetGUID(unitGuid) then return end

 local spellName = GetSpellNameFromId(spellId)
 if not spellName then return end

 local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_DEBUFF, nil, spellName)
 eventData.SpellId = spellId
 MikCEH.SendEvent(eventData)
end

nampowerHandlers["BUFF_REMOVED_SELF"] = function()
 local unitGuid = arg1
 local spellId = arg3
 if not IsPlayerGUID(unitGuid) and not IsPetGUID(unitGuid) then return end

 local spellName = GetSpellNameFromId(spellId)
 if not spellName then return end

 local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_BUFF_FADE, nil, spellName)
 eventData.SpellId = spellId
 MikCEH.SendEvent(eventData)
end

nampowerHandlers["DEBUFF_REMOVED_SELF"] = function()
 local unitGuid = arg1
 local spellId = arg3
 if not IsPlayerGUID(unitGuid) and not IsPetGUID(unitGuid) then return end

 local spellName = GetSpellNameFromId(spellId)
 if not spellName then return end

 local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_BUFF_FADE, nil, spellName)
 eventData.SpellId = spellId
 MikCEH.SendEvent(eventData)
end

function MikCEH.OnNampowerEvent()
 EnsurePlayerGUID()
 local handler = nampowerHandlers[event]
 if handler then handler() end
end

-------------------------------------------------------------------------------------
-- Core Helper Initialization & Lifecycle
-------------------------------------------------------------------------------------

function MikCEH.Init()
 playerName = UnitName("player");
 _, playerClass = UnitClass("player");

 hasNampower = (GetNampowerVersion ~= nil);
 hasSuperWoW = (SUPERWOW_VERSION ~= nil) or (SpellInfo ~= nil);
 hasUnitXP = pcall(UnitXP, "nop", "nop");

 MikCEH.hasNampower = hasNampower;
 MikCEH.hasSuperWoW = hasSuperWoW;
 MikCEH.hasUnitXP = hasUnitXP;

 if not hasNampower or not hasSuperWoW then
  DEFAULT_CHAT_FRAME:AddMessage("|cffff2020[MSBT Modern]|r Requires NamPower and SuperWoW 2.2 for combat event processing!", 1, 0.2, 0.2);
 end

 if hasSuperWoW and UnitExists("player") then
  local _, _, guid = pcall(UnitExists, "player")
  if guid then playerGUID = guid end
 elseif hasNampower and UnitGUID then
  local ok, guid = pcall(UnitGUID, "player")
  if ok and guid then playerGUID = guid end
 end

 if hasNampower and SetCVar then
  pcall(SetCVar, "NP_EnableAutoAttackEvents", "1")
  pcall(SetCVar, "NP_EnableSpellHealEvents", "1")
  pcall(SetCVar, "NP_EnableSpellEnergizeEvents", "1")
 end

 if C_Timer and C_Timer.NewTicker then
  C_Timer.NewTicker(5.0, function()
   for pName, lastSeen in pairs(recentlySelectedPlayers) do
    lastSeen = lastSeen + 5.0;
    if (lastSeen >= 60) then
     recentlySelectedPlayers[pName] = nil;
    else
     recentlySelectedPlayers[pName] = lastSeen;
    end
   end
  end)
 end
end

function MikCEH.RegisterEvents()
 if MCEHEventFrame then
  MCEHEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
  MCEHEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
  MCEHEventFrame:RegisterEvent("PLAYER_COMBO_POINTS");
  MCEHEventFrame:RegisterEvent("UNIT_HEALTH");
  MCEHEventFrame:RegisterEvent("UNIT_MANA");
  MCEHEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
  MCEHEventFrame:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN");
  MCEHEventFrame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE");
  MCEHEventFrame:RegisterEvent("CHAT_MSG_SKILL");
  MCEHEventFrame:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN");
  MCEHEventFrame:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH");
 end

 if nampowerEventFrame then
  nampowerEventFrame:RegisterEvent("SPELL_DAMAGE_EVENT_SELF");
  nampowerEventFrame:RegisterEvent("SPELL_DAMAGE_EVENT_OTHER");
  nampowerEventFrame:RegisterEvent("AUTO_ATTACK_SELF");
  nampowerEventFrame:RegisterEvent("AUTO_ATTACK_OTHER");
  nampowerEventFrame:RegisterEvent("SPELL_HEAL_BY_SELF");
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
end

function MikCEH.UnregisterEvents()
 if MCEHEventFrame then
  MCEHEventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED");
  MCEHEventFrame:UnregisterEvent("PLAYER_REGEN_DISABLED");
  MCEHEventFrame:UnregisterEvent("PLAYER_COMBO_POINTS");
  MCEHEventFrame:UnregisterEvent("UNIT_HEALTH");
  MCEHEventFrame:UnregisterEvent("UNIT_MANA");
  MCEHEventFrame:UnregisterEvent("PLAYER_TARGET_CHANGED");
  MCEHEventFrame:UnregisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN");
  MCEHEventFrame:UnregisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE");
  MCEHEventFrame:UnregisterEvent("CHAT_MSG_SKILL");
  MCEHEventFrame:UnregisterEvent("CHAT_MSG_COMBAT_XP_GAIN");
  MCEHEventFrame:UnregisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH");
 end

 if nampowerEventFrame then
  nampowerEventFrame:UnregisterAllEvents();
 end
end

function MikCEH.EnableEventSearching(searchPattern)
end

function MikCEH.DisableEventSearching()
end

function MikCEH.OnLoad()
 MCEHEventFrame:RegisterEvent("ADDON_LOADED");
 MCEHEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

 nampowerEventFrame = CreateFrame("Frame");
 nampowerEventFrame:SetScript("OnEvent", MikCEH.OnNampowerEvent);

 MikCEH.RegisterEvents();
end

function MikCEH.OnEvent()
 if (event == "ADDON_LOADED") then
  if (arg1 == MikSBT.MOD_NAME) then
   this:UnregisterEvent("ADDON_LOADED");
   MikCEH.Init();
  end

 elseif (event == "PLAYER_ENTERING_WORLD") then
  this:UnregisterEvent("PLAYER_ENTERING_WORLD");
  EnsurePlayerGUID();

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
  local now = GetTime();
  if (now - lastTriggerCheckTime >= TRIGGER_THROTTLE_INTERVAL) then
   lastTriggerCheckTime = now;
   if (arg1 == "player") then
    MikCEH.ParseSelfHealthTriggers();
   elseif (arg1 == "target") then
    if (not UnitIsFriend("player", "target")) then
     MikCEH.ParseEnemyHealthTriggers();
    else
     MikCEH.ParseFriendlyHealthTriggers();
    end
   elseif (arg1 == "pet") then
    MikCEH.ParsePetHealthTriggers();
   end
  end

 elseif (event == "UNIT_MANA") then
  local now = GetTime();
  if (now - lastTriggerCheckTime >= TRIGGER_THROTTLE_INTERVAL) then
   lastTriggerCheckTime = now;
   if (arg1 == "player") then
    MikCEH.ParseSelfManaTriggers();
   end
  end

 elseif (event == "PLAYER_TARGET_CHANGED") then
  if (UnitExists("target") and UnitIsPlayer("target") and not UnitIsFriend("player", "target")) then
   local targetName = UnitName("target");
   if (targetName) then
    recentlySelectedPlayers[targetName] = 0;
   end
  end

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

 elseif (event == "CHAT_MSG_COMBAT_FACTION_CHANGE") then
  local capturedData = MikCEH.GetCapturedData(arg1, "FACTION_STANDING_INCREASED", {"%f", "%a"});
  if (capturedData ~= nil) then
   local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_REP_GAIN, capturedData.Amount, capturedData.FactionName);
   MikCEH.SendEvent(eventData);
  else
   capturedData = MikCEH.GetCapturedData(arg1, "FACTION_STANDING_DECREASED", {"%f", "%a"});
   if (capturedData ~= nil) then
    local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_REP_LOSS, capturedData.Amount, capturedData.FactionName);
    MikCEH.SendEvent(eventData);
   end
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

 elseif (event == "CHAT_MSG_COMBAT_HOSTILE_DEATH") then
  local capturedData = MikCEH.GetCapturedData(arg1, "SELFKILLOTHER", {"%n"});
  if (capturedData ~= nil) then
   local notificationType = MikCEH.NOTIFICATIONTYPE_NPC_KILLING_BLOW;
   if ((UnitExists("target") and (UnitName("target") == capturedData.Name) and UnitIsPlayer("target")) or
       (recentlySelectedPlayers[capturedData.Name] ~= nil)) then
    notificationType = MikCEH.NOTIFICATIONTYPE_PC_KILLING_BLOW;
   end
   local eventData = MikCEH.GetNotificationEventData(notificationType, nil, capturedData.Name);
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

function MikCEH.GetUnitIDFromName(uName)
 if not uName then return nil, nil end

 if hasSuperWoW then
  local ok, exist, uid = pcall(UnitExists, uName)
  if ok and exist then return uid, UnitName(uid) end
 end

 if (uName == playerName) then
  return "player", playerName
 elseif (uName == UnitName("pet")) then
  return "pet", UnitName("pet")
 elseif (uName == UnitName("target")) then
  return "target", UnitName("target")
 end

 -- Fast pre-allocated party & raid entity lookup
 for i = 1, 4 do
  local uid = PARTY_UNITS[i]
  if UnitExists(uid) and UnitName(uid) == uName then
   return uid, uName
  end
 end
 for i = 1, 40 do
  local uid = RAID_UNITS[i]
  if UnitExists(uid) and UnitName(uid) == uName then
   return uid, uName
  end
 end

 return nil, nil
end

function MikCEH.PopulateOverhealData(eventData)
 local unitID = MikCEH.GetUnitIDFromName(eventData.Name);
 if (unitID) then
  local curHealth, maxHealth
  if hasUnitXP and UnitXP then
   local ok, ch, mh = pcall(function() return UnitXP("health", unitID), UnitXP("maxhealth", unitID) end)
   if ok and ch and mh and mh > 0 then
    curHealth = ch
    maxHealth = mh
   end
  end
  if not curHealth or not maxHealth then
   curHealth = UnitHealth(unitID)
   maxHealth = UnitHealthMax(unitID)
  end

  if maxHealth and curHealth and maxHealth > 0 then
   local healthMissing = maxHealth - curHealth
   local overhealAmount = (eventData.Amount or 0) - healthMissing
   if overhealAmount > 0 and maxHealth ~= 100 then
    eventData.PartialActionType = MikCEH.PARTIALACTIONTYPE_OVERHEAL
    eventData.PartialAmount = overhealAmount
   end
  end
 end
end

function MikCEH.SendEvent(eventData)
 if (MikSBT.CombatEventsHandler ~= nil) then
  MikSBT.CombatEventsHandler(eventData);
 end
end

function MikCEH.EraseTable(t)
 for key in pairs(t) do
  t[key] = nil;
 end
 table_setn(t, 0);
end

-------------------------------------------------------------------------------------
-- Notification String Capture Helper (for XP, Rep, Honor, Environment)
-------------------------------------------------------------------------------------

function MikCEH.GetGlobalStringInfo(globalStringName)
 local globalString = getglobal(globalStringName);
 if (globalString == nil) then return nil end

 if (globalStringInfoArray[globalStringName] == nil) then
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
   local captureString = temp[globalStringInfo.ArgumentOrder[argNum]];
   if (substituteValue == "%a") then
    orderedCaptureData.Amount = captureString;
   elseif (substituteValue == "%b") then
    orderedCaptureData.BuffName = captureString;
   elseif (substituteValue == "%f") then
    orderedCaptureData.FactionName = captureString;
   elseif (substituteValue == "%k") then
    orderedCaptureData.SkillName = captureString;
   elseif (substituteValue == "%n") then
    orderedCaptureData.Name = captureString;
   elseif (substituteValue == "%p") then
    orderedCaptureData.PowerType = captureString;
   elseif (substituteValue == "%s") then
    orderedCaptureData.SpellName = captureString;
   elseif (substituteValue == "%t") then
    orderedCaptureData.DamageType = MikCEH.GetDamageTypeNumber(captureString);
   end
  end
  return orderedCaptureData;
 end
 return nil;
end

function MikCEH.GetDamageTypeNumber(damageTypeString)
 if (damageTypeString == SPELL_SCHOOL0_CAP) then return MikCEH.DAMAGETYPE_PHYSICAL
 elseif (damageTypeString == SPELL_SCHOOL1_CAP) then return MikCEH.DAMAGETYPE_HOLY
 elseif (damageTypeString == SPELL_SCHOOL2_CAP) then return MikCEH.DAMAGETYPE_FIRE
 elseif (damageTypeString == SPELL_SCHOOL3_CAP) then return MikCEH.DAMAGETYPE_NATURE
 elseif (damageTypeString == SPELL_SCHOOL4_CAP) then return MikCEH.DAMAGETYPE_FROST
 elseif (damageTypeString == SPELL_SCHOOL5_CAP) then return MikCEH.DAMAGETYPE_SHADOW
 elseif (damageTypeString == SPELL_SCHOOL6_CAP or damageTypeString == "Arcane") then return MikCEH.DAMAGETYPE_ARCANE
 end
 return MikCEH.DAMAGETYPE_UNKNOWN;
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
  end
 end
end

function MikCEH.UnregisterAllTriggers()
 MikCEH.EraseTable(selfHealthTriggers);
 MikCEH.EraseTable(selfManaTriggers);
 MikCEH.EraseTable(petHealthTriggers);
 MikCEH.EraseTable(enemyHealthTriggers);
 MikCEH.EraseTable(friendlyHealthTriggers);
end

local function CheckHealthThresholds(unit, triggers, lastPercentage)
 local health = UnitHealth(unit);
 local maxHealth = UnitHealthMax(unit);
 if not maxHealth or maxHealth == 0 then return lastPercentage end
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
 if (UnitPowerType("player") == 0) then
  local manaAmount = UnitMana("player");
  local maxMana = UnitManaMax("player");
  if not maxMana or maxMana == 0 then return end
  local manaPercentage = manaAmount / maxMana;

  local manaDiff = manaAmount - lastSelfManaAmount;
  if (manaDiff > 0 and MikSBT.CurrentProfile and MikSBT.CurrentProfile.ShowAllManaGains) then
   local eventData = MikCEH.GetNotificationEventData(MikCEH.NOTIFICATIONTYPE_POWER_GAIN, manaDiff .. " " .. MANA, 0);
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
