-------------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text (ClassicAPI 1.17.7+, SuperWoW, NamPower)
-- Author: Mik, Fostercare5988
-- Maintainer: Fostercare5988
-------------------------------------------------------------------------------------

-- ClassicAPIRequirement.lua checks the DLLs.
if not MSBT_REQUIREMENTS_MET then return end

-------------------------------------------------------------------------------------
-- Public Constants.
-------------------------------------------------------------------------------------

-- Upvalue caches for frequently called functions.
local string_find, string_gsub = string.find, string.gsub
local table_insert = table.insert
local table_setn = table.setn
local math_ceil, math_floor, math_random = math.ceil, math.floor, math.random
local GetTime = GetTime
local getglobal = getglobal
local tonumber = tonumber
local UnitClass = UnitClass

-- Display types for incoming, outgoing, and notification events.
MikSBT.DISPLAYTYPE_INCOMING			= 1;
MikSBT.DISPLAYTYPE_OUTGOING			= 2;
MikSBT.DISPLAYTYPE_NOTIFICATION		= 3;


-------------------------------------------------------------------------------------
-- Public Variables.
-------------------------------------------------------------------------------------

-- Holds the current profile.
MikSBT.CurrentProfile = nil;


-------------------------------------------------------------------------------------
-- Private constants.
-------------------------------------------------------------------------------------

-- Damage type → color prefix lookup (lazily initialized after globals are available).
local damageTypeColors
local function GetDamageTypeColor(dt)
 if not damageTypeColors then
  damageTypeColors = {
   [SPELL_SCHOOL1_CAP] = "\124cffF6F99E\124h",
   [SPELL_SCHOOL2_CAP] = "\124cffFF4444\124h",
   [SPELL_SCHOOL3_CAP] = "\124cff44FF44\124h",
   [SPELL_SCHOOL4_CAP] = "\124cff4488FF\124h",
   [SPELL_SCHOOL5_CAP] = "\124cff6600CC\124h",
   [SPELL_SCHOOL6_CAP] = "\124cffCC66FF\124h",
   ["Unknown"]         = "\124cffCC66FF\124h",
  }
 end
 return damageTypeColors[dt]
end

-- Damage type → {r, g, b} float lookup for SetTextColor (lazily initialized).
local damageTypeFontColors
local function GetDamageTypeFontColor(dt)
 if not damageTypeFontColors then
  damageTypeFontColors = {
   [SPELL_SCHOOL2_CAP] = { r=1.0,  g=0.27, b=0.27 },  -- Fire (red)
   [SPELL_SCHOOL3_CAP] = { r=0.27, g=1.0,  b=0.27 },  -- Nature (green)
   [SPELL_SCHOOL4_CAP] = { r=0.27, g=0.53, b=1.0  },  -- Frost (blue)
   [SPELL_SCHOOL5_CAP] = { r=0.4,  g=0.0,  b=0.8  },  -- Shadow (deep purple)
   [SPELL_SCHOOL6_CAP] = { r=0.8,  g=0.4,  b=1.0  },  -- Arcane (purple/pink)
  }
 end
 return damageTypeFontColors[dt]
end

-- Number of font strings.
local NUM_FONT_STRINGS = 20;

-- Animation values for incoming and outgoing events.
local MIN_VERTICAL_SPACING = 8;

-- How long to wait before showing events so that merges may happen.
local MERGE_DELAY_TIME = 0.3;

-- How long to show stickies before they are faded.
local STICKY_FADE_IN_TIME = 0.15;
local STICKY_DISPLAY_TIME = 2;
local STICKY_FADE_OUT_TIME = 0.5;

-- The animation speed.
local ANIMATION_SPEED = 0.02;

-- Scroll directions
local SCROLL_DIRECTION_UP			= 1;
local SCROLL_DIRECTION_DOWN			= 2;

-- Animation Styles
local ANIMATION_STYLE_STRAIGHT		= 1;
local ANIMATION_STYLE_LEFT_PARABOLA		= 2;
local ANIMATION_STYLE_RIGHT_PARABOLA	= 3;

-- Max number of combo points.
local MAX_COMBO_POINTS = 5;


-- Pre-built event type string lookup tables (eliminates string concatenation in CombatEventsHandler).
local DIRECTION_SCROLLAREA_KEY = {
 [MikCEH.DIRECTIONTYPE_PLAYER_INCOMING] = "Incoming",
 [MikCEH.DIRECTIONTYPE_PLAYER_OUTGOING] = "Outgoing",
 [MikCEH.DIRECTIONTYPE_PET_OUTGOING]    = "Outgoing",
 [MikCEH.DIRECTIONTYPE_PET_INCOMING]    = "Incoming",
};

local DIRECTION_PREFIX = {
 [MikCEH.DIRECTIONTYPE_PLAYER_INCOMING] = "MSBT_EVENTTYPE_INCOMING_",
 [MikCEH.DIRECTIONTYPE_PLAYER_OUTGOING] = "MSBT_EVENTTYPE_OUTGOING_",
 [MikCEH.DIRECTIONTYPE_PET_OUTGOING]    = "MSBT_EVENTTYPE_OUTGOING_PET_",
 [MikCEH.DIRECTIONTYPE_PET_INCOMING]    = "MSBT_EVENTTYPE_INCOMING_PET_",
};

-- Action type → suffix string for damage events.
local ACTION_SUFFIX = {
 [MikCEH.ACTIONTYPE_MISS]    = "MISS",
 [MikCEH.ACTIONTYPE_DODGE]   = "DODGE",
 [MikCEH.ACTIONTYPE_PARRY]   = "PARRY",
 [MikCEH.ACTIONTYPE_BLOCK]   = "BLOCK",
 [MikCEH.ACTIONTYPE_RESIST]  = "RESIST",
 [MikCEH.ACTIONTYPE_ABSORB]  = "ABSORB",
 [MikCEH.ACTIONTYPE_IMMUNE]  = "IMMUNE",
 [MikCEH.ACTIONTYPE_EVADE]   = "EVADE",
 [MikCEH.ACTIONTYPE_REFLECT] = "REFLECT",
};

-- Environmental action type → localized effect name.
local ENVIRONMENTAL_NAMES = {
 [MikCEH.ACTIONTYPE_DROWNING] = MikSBT.MSG_ENVIRONMENTAL_DROWNING,
 [MikCEH.ACTIONTYPE_FALLING]  = MikSBT.MSG_ENVIRONMENTAL_FALLING,
 [MikCEH.ACTIONTYPE_FATIGUE]  = MikSBT.MSG_ENVIRONMENTAL_FATIGUE,
 [MikCEH.ACTIONTYPE_FIRE]     = MikSBT.MSG_ENVIRONMENTAL_FIRE,
 [MikCEH.ACTIONTYPE_LAVA]     = MikSBT.MSG_ENVIRONMENTAL_LAVA,
 [MikCEH.ACTIONTYPE_SLIME]    = MikSBT.MSG_ENVIRONMENTAL_SLIME,
};

-- Class name → color prefix string for unit name coloring.
local CLASS_COLORS = {
 PALADIN  = "|cffF58CBA|h",
 DRUID    = "|cffFF7D0A|h",
 HUNTER   = "|cffABD473|h",
 MAGE     = "|cff69CCF0|h",
 PRIEST   = "|cffFFFFFF|h",
 ROGUE    = "|cffFFF569|h",
 SHAMAN   = "|cff0070DE|h",
 WARLOCK  = "|cff9482C9|h",
 WARRIOR  = "|cffC79C6E|h",
};

-- Notification type → suffix string.
local NOTIFICATION_SUFFIX = {
 [MikCEH.NOTIFICATIONTYPE_DEBUFF]          = "DEBUFF",
 [MikCEH.NOTIFICATIONTYPE_BUFF]            = "BUFF",
 [MikCEH.NOTIFICATIONTYPE_BUFF_FADE]       = "BUFF_FADE",
 [MikCEH.NOTIFICATIONTYPE_COMBAT_ENTER]    = "COMBAT_ENTER",
 [MikCEH.NOTIFICATIONTYPE_COMBAT_LEAVE]    = "COMBAT_LEAVE",
 [MikCEH.NOTIFICATIONTYPE_POWER_GAIN]      = "POWER_GAIN",
 [MikCEH.NOTIFICATIONTYPE_POWER_LOSS]      = "POWER_LOSS",
 [MikCEH.NOTIFICATIONTYPE_CP_GAIN]         = "CP_GAIN",
 [MikCEH.NOTIFICATIONTYPE_HONOR_GAIN]      = "HONOR_GAIN",
 [MikCEH.NOTIFICATIONTYPE_REP_GAIN]        = "REP_GAIN",
 [MikCEH.NOTIFICATIONTYPE_REP_LOSS]        = "REP_LOSS",
 [MikCEH.NOTIFICATIONTYPE_SKILL_GAIN]      = "SKILL_GAIN",
 [MikCEH.NOTIFICATIONTYPE_EXPERIENCE_GAIN] = "EXPERIENCE_GAIN",
 [MikCEH.NOTIFICATIONTYPE_PC_KILLING_BLOW] = "PC_KILLING_BLOW",
 [MikCEH.NOTIFICATIONTYPE_NPC_KILLING_BLOW] = "NPC_KILLING_BLOW",
};

-- Pre-build all possible event type strings to avoid runtime concatenation.
-- dmgEventStr[dirType][suffix] for non-spell damage, dmgEventStrSpell[dirType][suffix] for spell damage.
local dmgEventStr = {};
local dmgEventStrSpell = {};
local healEventStr = {};
local notifEventStr = {};

do
 local suffixes = {"DAMAGE", "DOT", "MISS", "DODGE", "PARRY", "BLOCK", "RESIST", "ABSORB", "IMMUNE", "EVADE", "REFLECT", "ENVIRONMENTAL"};
 for dirType, prefix in pairs(DIRECTION_PREFIX) do
  dmgEventStr[dirType] = {};
  dmgEventStrSpell[dirType] = {};
  for _, suffix in ipairs(suffixes) do
   dmgEventStr[dirType][suffix] = prefix .. suffix;
   dmgEventStrSpell[dirType][suffix] = prefix .. "SPELL_" .. suffix;
  end

  -- Spell-only actions fallback to SPELL_ variant
  dmgEventStr[dirType]["DOT"] = prefix .. "SPELL_DOT";
  dmgEventStr[dirType]["RESIST"] = prefix .. "SPELL_RESIST";
  dmgEventStr[dirType]["REFLECT"] = prefix .. "SPELL_REFLECT";

  healEventStr[dirType] = {};
  healEventStr[dirType]["HEAL"] = prefix .. "HEAL";
  healEventStr[dirType]["HOT"] = prefix .. "HOT";
 end

 -- Specific pet event overrides
 dmgEventStrSpell[3]["DOT"] = "MSBT_EVENTTYPE_OUTGOING_SPELL_DOT";
 dmgEventStr[3]["DOT"] = "MSBT_EVENTTYPE_OUTGOING_SPELL_DOT";
 dmgEventStrSpell[3]["REFLECT"] = "MSBT_EVENTTYPE_OUTGOING_SPELL_REFLECT";
 dmgEventStr[3]["REFLECT"] = "MSBT_EVENTTYPE_OUTGOING_SPELL_REFLECT";
 healEventStr[3]["HEAL"] = "MSBT_EVENTTYPE_OUTGOING_HEAL";
 healEventStr[3]["HOT"] = "MSBT_EVENTTYPE_OUTGOING_HOT";

 for notifType, suffix in pairs(NOTIFICATION_SUFFIX) do
  notifEventStr[notifType] = "MSBT_EVENTTYPE_NOTIFICATION_" .. suffix;
 end
 notifEventStr["CP_FULL"] = "MSBT_EVENTTYPE_NOTIFICATION_CP_FULL";
end


-------------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------------

-- Holds the events the mod is interested in.
local listenEvents = {};

-- Holds data for each scroll area.
local scrollAreas = {};

-- Holds arrays of unmerged events, merged events to be displayed and the time since
-- the last merge for incoming and outgoing events.
local animationMergeData = {
 ["Incoming"]	= {["TimeSinceMerge"] = 0, TimerPending = false, Generation=0, UnmergedEvents={}, SpareEvents={}, MergedEvents={}},
 ["Outgoing"]	= {["TimeSinceMerge"] = 0, TimerPending = false, Generation=0, UnmergedEvents={}, SpareEvents={}, MergedEvents={}},
};

-- Holds whether or not a merge is still being processed.
local stillMerging = false;

-- Temp arrays for repositioning animation display data to avoid overlaps.
local activeNonStickies = {};
local activeStickies = {};

-- Create a new table recycler object that holds up to 40 table references
-- in primary cache.
local eventsRecycler = MikTRO:NewRecyclerObject(40);


-------------------------------------------------------------------------------------
-- Printing functions.
-------------------------------------------------------------------------------------

-- **********************************************************************************
-- Prints out the passed message to the default chat frame.
-- **********************************************************************************
function MikSBT.Print(msg, r, g, b)
 -- Add the message to the default chat frame.
 DEFAULT_CHAT_FRAME:AddMessage("MSBT: " .. msg, r, g, b);
end


-------------------------------------------------------------------------------------
-- Core event handlers.
-------------------------------------------------------------------------------------

-- **********************************************************************************
-- Registers all of the core events the mod is interested in.
-- **********************************************************************************
function MikSBT.RegisterEvents()
 -- Register the events we are interested in receiving for shaman.
 for k, v in listenEvents do
  MSBTEventFrame:RegisterEvent(v);
 end
end


-- **********************************************************************************
-- Unregisters all of the events the mod registered for.
-- **********************************************************************************
function MikSBT.UnregisterEvents()
 for k, v in listenEvents do
  MSBTEventFrame:UnregisterEvent(v);
 end
end


-- **********************************************************************************
-- Called when the mod is loaded.
-- **********************************************************************************
function MikSBT.OnLoad()
 -- Register for the ADDON_LOADED event.
 MSBTEventFrame:RegisterEvent("ADDON_LOADED");
 MSBTEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
end

-- **********************************************************************************
-- Called when the events we registered for occur.
-- **********************************************************************************
function MikSBT.OnEvent()
 -- When an addon is loaded.
 if (event == "ADDON_LOADED") then
  -- Make sure it's this addon.
  if (arg1 == MikSBT.MOD_NAME) then

   -- Register for the events the helper is interested in receiving.
   MikSBT.RegisterEvents();

   -- Initialize the mod.
   this:UnregisterEvent("ADDON_LOADED");
   MikSBT.Init();
  end
 end
 
 if (event == "PLAYER_ENTERING_WORLD") then
	if MikSBT.CurrentProfile then MikSBT.ClearPendingEvents() end;
 end
end


-- **********************************************************************************
-- Called when the mod's animation frames are updated.
-- **********************************************************************************
function MikSBT.OnUpdateAnimationFrame(frame)
 local scrollArea = frame.MSBTScrollArea;

 -- Flag for whether or not all the animations are inactive.
 local allInactive = true;

 -- Loop through all possible animation display objects for the scroll area.
 for _, animDisplayInfo in scrollArea.AnimationDisplayArray do
  -- Check if the animation is active.
  if (animDisplayInfo.IsActive) then
   -- Do the animation and clear the all inactive flag.
   MikSBT.DoAnimation(animDisplayInfo, scrollArea);
   allInactive = false;
  end
 end

 -- Check if none of the animations are active and the events frame is visible.  If so, hide it so
 -- the OnUpdate events stop firing.  This is done to keep the number of OnUpdate events down to a minimum for
 -- better performance.
 if (allInactive and frame:IsVisible()) then
  frame:Hide();
 end
end


-- **********************************************************************************
-- Called when the mod is fully loaded (variables loaded).
-- **********************************************************************************
function MikSBT.Init()
 -- Register slash commands
 SLASH_MSBT1 = MikSBT.COMMAND;
 SlashCmdList["MSBT"] = function (params)
  MikSBT.CommandHandler(params);
 end

 -- Check if there are no saved variables or profiles.
 if (not MikSBT_Save or type(MikSBT_Save) ~= "table") then
  MikSBT_Save = {};
 end

 if (not MikSBT_Save.Profiles or type(MikSBT_Save.Profiles) ~= "table") then
  MikSBT_Save.UserDisabled = false;
  MikSBT_Save.CurrentProfile = MikSBT.DEFAULT_PROFILE_NAME;
  MikSBT_Save.Profiles = {};
  MikSBT_Save.Profiles[MikSBT_Save.CurrentProfile] = {};

  -- Set all the options to their defaults.
  MikSBT.ResetProfile(MikSBT_Save.CurrentProfile);
 end

 -- Ensure current profile exists in profiles table
 if not MikSBT_Save.CurrentProfile or not MikSBT_Save.Profiles[MikSBT_Save.CurrentProfile] then
  MikSBT_Save.CurrentProfile = MikSBT.DEFAULT_PROFILE_NAME;
  if not MikSBT_Save.Profiles[MikSBT_Save.CurrentProfile] then
   MikSBT_Save.Profiles[MikSBT_Save.CurrentProfile] = {};
   MikSBT.ResetProfile(MikSBT_Save.CurrentProfile);
  end
 end

 -- Updates profiles created by older versions.
 MikSBT.UpdateProfiles();

 -- Set the current profile.
 MikSBT.CurrentProfile = MikSBT_Save.Profiles[MikSBT_Save.CurrentProfile];

 MikSBT.ApplyGameDamageFont();

 -- Sets up all of the animation scroll areas.
 MikSBT.SetupAnimationScrollAreas();

 -- Reposition the animation frames to the stored offsets.
 MikSBT.RepositionAnimationFrames();

 -- Register the triggers with the combat event helper.
 MikSBT.RegisterTriggers();

 -- Disable or enable the mod depending on the saved setting.
 MikSBT.SetOptionUserDisabled(MikSBT_Save.UserDisabled)
end


-- **********************************************************************************
-- The font of the game's own damage text (the client reads it at login).
-- **********************************************************************************
function MikSBT.ApplyGameDamageFont()
 local font = MikSBT.AVAILABLE_FONTS[MikSBT.CurrentProfile.BlizzardFontSettings.Normal.FontIndex];
 if font then DAMAGE_TEXT_FONT = font.Path end
end


-- **********************************************************************************
-- Sets up all of the animation scroll areas.
-- **********************************************************************************
function MikSBT.SetupAnimationScrollAreas()
 -- Setup a table for data for each scroll area.
 scrollAreas.Incoming = {};
 scrollAreas.Outgoing = {};
 scrollAreas.Notification = {};

 -- Setup the associated frames.
 scrollAreas.Incoming.AssociatedFrame = "MSBTFrameIncoming";
 scrollAreas.Outgoing.AssociatedFrame = "MSBTFrameOutgoing";
 scrollAreas.Notification.AssociatedFrame = "MSBTFrameNotification";

 -- Setup the display settings.
 scrollAreas.Incoming.DisplaySettings = MikSBT.CurrentProfile.DisplaySettings.Incoming;
 scrollAreas.Outgoing.DisplaySettings = MikSBT.CurrentProfile.DisplaySettings.Outgoing;
 scrollAreas.Notification.DisplaySettings = MikSBT.CurrentProfile.DisplaySettings.Notification;


 -- Loop through the scroll areas.
 for _, scrollArea in scrollAreas do
  getglobal(scrollArea.AssociatedFrame).MSBTScrollArea = scrollArea;

  -- Initialize the next available animation display object.
  scrollArea.NextAnimationDisplay = 1;

  -- Initialize the next available sticky animation display object.
  scrollArea.FirstSticky = 11;
  scrollArea.NextSticky = scrollArea.FirstSticky;

  -- Create arrays for the animation display info.
  scrollArea.AnimationDisplayArray = {};

  -- Associate the appropriate font string object for each animation display object.
  for x = 1, NUM_FONT_STRINGS do
   scrollArea.AnimationDisplayArray[x] = {};
   scrollArea.AnimationDisplayArray[x].FontObject = getglobal(scrollArea.AssociatedFrame .. "Text" .. x);
   scrollArea.AnimationDisplayArray[x].LastUpdated = 0;
  end
 end
end


-- **********************************************************************************
-- Repositions the animation frames based on the stored offsets.
-- **********************************************************************************
function MikSBT.RepositionAnimationFrames()
 -- Loop through each scroll area and reposition its associated frame.
 for _, scrollArea in scrollAreas do
  getglobal(scrollArea.AssociatedFrame):SetPoint("BOTTOM", "UIParent", "CENTER", scrollArea.DisplaySettings.FrameOffsets.x, scrollArea.DisplaySettings.FrameOffsets.y);
 end
end


-- **********************************************************************************
-- Receive combat events from Mik's combat event helper.
-- **********************************************************************************
function MikSBT.CombatEventsHandler(combatEvent)
 if not MikSBT.CurrentProfile or (MikSBT_Save and MikSBT_Save.UserDisabled) then return end;
 -- Get a recycled table from the events recycler object.
 local animationEvent = eventsRecycler:AcquireTable();

 -- Look up the scroll area and event type string via pre-built tables (no string concatenation).
 local dirType = combatEvent.DirectionType;
 local scrollAreaKey = DIRECTION_SCROLLAREA_KEY[dirType];
 if (scrollAreaKey) then
  animationEvent.ScrollArea = scrollAreas[scrollAreaKey];
 end

 local eventTypeString;

 -- Check if it's a damage event.
 if (combatEvent.EventType == MikCEH.EVENTTYPE_DAMAGE) then
  local actionType = combatEvent.ActionType;

  -- Check for environmental damage (sets EffectName as side effect).
  local envName = ENVIRONMENTAL_NAMES[actionType];
  if (envName) then
   combatEvent.EffectName = envName;
   eventTypeString = dmgEventStr[dirType] and dmgEventStr[dirType]["ENVIRONMENTAL"];
  else
   -- Determine the action suffix.
   local suffix;
   if (actionType == MikCEH.ACTIONTYPE_HIT) then
    suffix = (combatEvent.HitType == MikCEH.HITTYPE_OVER_TIME) and "DOT" or "DAMAGE";
   else
    suffix = ACTION_SUFFIX[actionType];
   end

   -- Use spell or non-spell variant based on whether there is an effect name.
   if (suffix) then
    if (combatEvent.EffectName ~= nil) then
     eventTypeString = dmgEventStrSpell[dirType] and dmgEventStrSpell[dirType][suffix];
    else
     eventTypeString = dmgEventStr[dirType] and dmgEventStr[dirType][suffix];
    end
   end
  end

 -- Heal event.
 elseif (combatEvent.EventType == MikCEH.EVENTTYPE_HEAL) then
  local suffix = (combatEvent.HealType == MikCEH.HEALTYPE_OVER_TIME) and "HOT" or "HEAL";
  eventTypeString = healEventStr[dirType] and healEventStr[dirType][suffix];

 -- Notification event.
 elseif (combatEvent.EventType == MikCEH.EVENTTYPE_NOTIFICATION) then
  animationEvent.ScrollArea = scrollAreas.Notification;
  local notifType = combatEvent.NotificationType;

  -- Special case: combo points at max.
  if (notifType == MikCEH.NOTIFICATIONTYPE_CP_GAIN and combatEvent.Amount == MAX_COMBO_POINTS) then
   eventTypeString = notifEventStr["CP_FULL"];
  else
   eventTypeString = notifEventStr[notifType];
   -- Fallback for unknown notification types.
   if (not eventTypeString and notifType ~= nil) then
    eventTypeString = "MSBT_EVENTTYPE_NOTIFICATION_" .. notifType;
   end
  end
 end

 -- Check if the event is a crit and set the crit field appropriately
 if (combatEvent.IsCrit or combatEvent.HitType == MikCEH.HITTYPE_CRIT or combatEvent.HealType == MikCEH.HEALTYPE_CRIT) then
  animationEvent.IsCrit = true;
 end

 -- Copy the amount, effect name, and player/enemy name from the passed combat event data.
 animationEvent.Amount = combatEvent.Amount;
 animationEvent.EffectName = combatEvent.EffectName;
 animationEvent.Name = combatEvent.Name;
 animationEvent.UnitGUID = combatEvent.UnitGUID;
 animationEvent.SpellId = combatEvent.SpellId;
 animationEvent.IsSpellManaGain = combatEvent.IsSpellManaGain;

 -- Check if there is a damage type and get the appropriate string.
 if (combatEvent.DamageType ~= nil) then
  animationEvent.DamageType = MikCEH.GetDamageTypeString(combatEvent.DamageType);
 end
 
 -- If there are partial action types set the partial effect text appropriately.
 if (combatEvent.PartialActionType == MikCEH.PARTIALACTIONTYPE_ABSORB) then
  if (ABSORB_TRAILER) then
   animationEvent.PartialEffectText = "\124cffFAFA00\124h"..string_gsub(ABSORB_TRAILER, "%%d", combatEvent.PartialAmount).."\124h\124r";
  end
 elseif (combatEvent.PartialActionType == MikCEH.PARTIALACTIONTYPE_BLOCK) then
  if (BLOCK_TRAILER) then
   animationEvent.PartialEffectText = "\124cff7F00FF\124h"..string_gsub(BLOCK_TRAILER, "%%d", combatEvent.PartialAmount).."\124h\124r";
  end
 elseif (combatEvent.PartialActionType == MikCEH.PARTIALACTIONTYPE_RESIST) then
  if (RESIST_TRAILER) then
   animationEvent.PartialEffectText = " \124cff81007F\124h"..string_gsub(RESIST_TRAILER, "%%d", combatEvent.PartialAmount).."\124h\124r";
  end
 elseif (combatEvent.PartialActionType == MikCEH.PARTIALACTIONTYPE_CRUSHING) then
  if (CRUSHING_TRAILER) then
   animationEvent.PartialEffectText = "\124cff7D0000\124h"..CRUSHING_TRAILER.."\124h\124r";
  end
 elseif (combatEvent.PartialActionType == MikCEH.PARTIALACTIONTYPE_GLANCING) then
  if (GLANCING_TRAILER) then
   animationEvent.PartialEffectText = "\124cffFA0000\124h"..GLANCING_TRAILER.."\124h\124r";
  end
 end



 -- Check if there is profile data for the event type.
 if (MikSBT.CurrentProfile.EventSettings[eventTypeString]) then
  -- Set the event type, the settings for it, its unformatted text and dispatch it to the animation system.
  animationEvent.EventType = eventTypeString;
  animationEvent.EventSettings = MikSBT.CurrentProfile.EventSettings[animationEvent.EventType];
  animationEvent.UnformattedText = animationEvent.EventSettings.Message;

  -- Dispatch the event to the animation system.
  MikSBT.DispatchAnimationEvent(animationEvent);
 else
  -- Print an error message and reclaim the animation event table to the table recycler.
  MikSBT.Print("No profile data found for " .. tostring(eventTypeString), 1, 0, 0)
  eventsRecycler:ReclaimTable(animationEvent);
 end
end



-- **********************************************************************************
-- Receive trigger events from Mik's trigger helper.
-- **********************************************************************************
function MikSBT.TriggerHandler(triggerEvent)
 if not MikSBT.CurrentProfile or (MikSBT_Save and MikSBT_Save.UserDisabled) or
    not MikSBT.CurrentProfile.Triggers[triggerEvent.TriggerKey] then return end;
 -- Get a recycled table from the events recycler object.
 local animationEvent = eventsRecycler:AcquireTable();

 -- Check if the trigger require a stance
 if (MikSBT.CurrentProfile.Triggers[triggerEvent.TriggerKey].TriggerSettings.Stance) then
	local _,_,isActive = GetShapeshiftFormInfo(MikSBT.CurrentProfile.Triggers[triggerEvent.TriggerKey].TriggerSettings.Stance)
	if not isActive then
		-- Reclaim the animation event table to the table recycler.
		eventsRecycler:ReclaimTable(animationEvent);
		return
	end
 end
 
 -- Check if there is profile data for the trigger.
 if (MikSBT.CurrentProfile.Triggers[triggerEvent.TriggerKey].EventSettings) then
  -- Set the scroll area, event settings, and output text.
  animationEvent.ScrollArea = scrollAreas.Notification;
  animationEvent.EventSettings = MikSBT.CurrentProfile.Triggers[triggerEvent.TriggerKey].EventSettings;
  MikSBT.FormatTriggerText(animationEvent, triggerEvent);
  
  if (MikSBT.CurrentProfile.Triggers[triggerEvent.TriggerKey].Texture) then
	 animationEvent.Texture = MikSBT.CurrentProfile.Triggers[triggerEvent.TriggerKey].Texture
  end

  -- Dispatch the event to the animation system.
  MikSBT.DispatchAnimationEvent(animationEvent);
 else
  -- Print an error message and reclaim the animation event table to the table recycler.
  MikSBT.Print("No profile data found for trigger key " .. triggerEvent.TriggerKey, 1, 0, 0);
  eventsRecycler:ReclaimTable(animationEvent);  
 end
end


-------------------------------------------------------------------------------------
-- Utility functions.
-------------------------------------------------------------------------------------

-- **********************************************************************************
-- This function copies a table.
-- **********************************************************************************
function MikSBT.CopyTable(srcTable)
 -- Create a new table.
 local newTable = {};

 -- Loop through all of the entires in the table.
 for key, value in srcTable do
  -- Check if it's a nested table.
  if (type(value) == "table") then
   -- Recursively call the function to copy the nested table.
   value = MikSBT.CopyTable(value);
  end

  -- Make a copy of the value into the new table.
  newTable[key] = value;
 end

 -- Return the new table.
 return newTable;
end


-- **********************************************************************************
-- Merges like animation events.
-- **********************************************************************************
function MikSBT.MergeEvents(mergeData, unmergedEvents, numEvents)
  if type(unmergedEvents) == "number" then
    numEvents = unmergedEvents
    unmergedEvents = mergeData.UnmergedEvents
  end
  unmergedEvents = unmergedEvents or (mergeData and mergeData.UnmergedEvents)
  if not unmergedEvents then return end
  numEvents = numEvents or #unmergedEvents

  -- Hold whether or not the event was merged.
  local eventMerged = false;
 
  -- Don't attempt to merge any more events than were available when the function was called since
  -- more events may get added while the merge is taking place.
  for x = 1, numEvents do
 
   -- Loop through all of the events in the merged events array.
   for _, animationEvent in ipairs(mergeData.MergedEvents) do
     local unmergedEventMatched = false;
 
     -- Check if the event types match and the effect names are the same.
    if ((unmergedEvents[x].EventType == animationEvent.EventType) and
        (unmergedEvents[x].EffectName == animationEvent.EffectName) and
        (unmergedEvents[x].SpellId == animationEvent.SpellId)) then
 
     -- Check if there is no effect name
     if (unmergedEvents[x].EffectName == nil) then
      -- Check if the affected unit name is the same.
      if ((unmergedEvents[x].UnitGUID and unmergedEvents[x].UnitGUID == animationEvent.UnitGUID) or
          (not unmergedEvents[x].UnitGUID and not animationEvent.UnitGUID and
           unmergedEvents[x].Name == animationEvent.Name and unmergedEvents[x].Name ~= nil)) then
       -- Do Merge.
       eventMerged = true;
       unmergedEventMatched = true;
      end -- Same name.
 
     -- There is an effect name.
     else
      -- Check if there is a name and replace it with the multiple targets string.
      if animationEvent.UnitGUID ~= unmergedEvents[x].UnitGUID or
         animationEvent.Name ~= unmergedEvents[x].Name then
       animationEvent.Name = MikSBT.MSG_MULTIPLE_TARGETS;
       animationEvent.UnitGUID = nil;
      end
 
      -- Do Merge.
      eventMerged = true;
      unmergedEventMatched = true;
     end -- Effect name?
    end -- Event types match and effect names the same.
 
 
    -- Check if the event should be merged.
    if (unmergedEventMatched) then
     -- Set the event merged flag for the event being merged.
     unmergedEvents[x].EventMerged = true;
 
     -- If the events have an amount then total them.
     if (animationEvent.Amount ~= nil and unmergedEvents[x].Amount ~= nil) then
      local aAmt = tonumber(animationEvent.Amount)
      local uAmt = tonumber(unmergedEvents[x].Amount)
      if aAmt and uAmt then
        animationEvent.Amount = aAmt + uAmt;
      end
     end
 
     -- Clear any partial effect text.
     animationEvent.PartialEffectText = nil;
 
     
     -- Increment the number of merged events.
     animationEvent.NumMerged = animationEvent.NumMerged + 1;
 
     -- Check if the event being merged is a crit and increment the number of crits.
     if (unmergedEvents[x].IsCrit) then
      animationEvent.NumCrits = animationEvent.NumCrits + 1;
     end
 
     -- Make sure the merged event is not flagged as a crit.
     animationEvent.IsCrit = false;
     break;
    end -- Do Merge.
   end -- Loop through all merged events.
 
 
   -- If the event wasn't merged add it to the end of the merged events array.
   if (not eventMerged) then
    local animationEvent = unmergedEvents[x];
    animationEvent.NumMerged = 0;
 
    -- Check if the event is a crit and set the number of crits appropriately.
    if (animationEvent.IsCrit) then
     animationEvent.NumCrits = 1;
    else
     animationEvent.NumCrits = 0;
    end
 
    -- Add the animation event to the end of the merged events array.
    table_insert(mergeData.MergedEvents, animationEvent);
   end
 
   -- Reset the event merged flag.
   eventMerged = false;
  end


 -- Loop through each event in the merged events array.
 for _, animationEvent in ipairs(mergeData.MergedEvents) do
  -- Check if there were any events merged.
  if (animationEvent.NumMerged > 0) then
   -- Create trailer text with the number of merged events.
   local trailerText = " [" .. 1 + animationEvent.NumMerged.. " " .. MikSBT.MSG_HITS;

   -- Check if there were any crits merged.
   if (animationEvent.NumCrits > 1) then
    trailerText = trailerText .. ", " .. animationEvent.NumCrits .. " " .. MikSBT.MSG_CRITS;
   elseif (animationEvent.NumCrits == 1) then
    trailerText = trailerText .. ", " .. animationEvent.NumCrits .. " " .. MikSBT.MSG_CRIT;
   end

   -- Close the merge string.
   trailerText = trailerText .. "]";

   -- Set the animation event's merge trailer text field.
   animationEvent.MergeTrailerText = trailerText;
  end
 end


 -- Remove the processed animation events from unmerged events queue.
 for x = 1, numEvents do
  -- Check if the event was merged into a different animation event.
  if (unmergedEvents[x] and unmergedEvents[x].EventMerged) then
   -- Reclaim the animation event table to the events recycler.
   eventsRecycler:ReclaimTable(unmergedEvents[x]);
  end

  unmergedEvents[x] = nil;
 end
 if table_setn then pcall(table_setn, unmergedEvents, 0); end
end


-- **********************************************************************************
-- Font settings inherit event -> scroll area -> master; 0 means inherit.
-- **********************************************************************************
local function InheritedFontValue(scrollArea, eventSettings, isCrit, field)
 local kind = isCrit and "Crit" or "Normal";
 local value = 0;
 if (eventSettings ~= nil and eventSettings.FontSettings[kind] ~= nil) then
  value = eventSettings.FontSettings[kind][field] or 0;
 end
 if (value == 0) then value = scrollArea.DisplaySettings.FontSettings[kind][field] end
 if (value == 0) then value = MikSBT.CurrentProfile.MasterFontSettings[kind][field] end
 return value;
end

function MikSBT.GetFontSize(scrollArea, eventSettings, isCrit)
 return InheritedFontValue(scrollArea, eventSettings, isCrit, "FontSize");
end

function MikSBT.GetFontPath(scrollArea, eventSettings, isCrit)
 local font = MikSBT.AVAILABLE_FONTS[InheritedFontValue(scrollArea, eventSettings, isCrit, "FontIndex")];
 return (font or MikSBT.AVAILABLE_FONTS[1]).Path;
end

function MikSBT.GetFontOutline(scrollArea, eventSettings, isCrit)
 return MikSBT.AVAILABLE_OUTLINES[InheritedFontValue(scrollArea, eventSettings, isCrit, "OutlineIndex")].Style;
end


-- **********************************************************************************
-- This function substitutes the codes in the unformatted text of the passed
-- animation event with the values in its fields.
-- **********************************************************************************
function MikSBT.FormatEventText(animationEvent)
 local outputString = animationEvent.UnformattedText;
 
 -- Print(animationEvent)
 
 -- Check if there is no unformatted text and bail.
 if (outputString == nil) then
  return;
 end

	outputString = string_gsub(outputString, "-%%a", "\124cffff0000\124h-\124h\124r%%a");
	
	if animationEvent.DamageType then
		local color = GetDamageTypeColor(animationEvent.DamageType)
		if color then
			outputString = string_gsub(outputString, "%%a", color .. "%%a\124h\124r")
		end
	end
 
 -- Substitute amount.
 if (animationEvent.Amount ~= nil) then
  outputString = string_gsub(outputString, "%%a", animationEvent.Amount);
 end

 -- Substitute enemy/player names.
 local unitID, unitName;
 if animationEvent.UnitGUID then
  if UnitExists(animationEvent.UnitGUID) then unitID = animationEvent.UnitGUID end;
  unitName = animationEvent.Name;
 else
  unitName = animationEvent.Name;
 end
 if unitName and (not unitID or not UnitIsUnit(unitID, "player")) then
  local formattedName = unitName;
  if unitID then
   local _, class = UnitClass(unitID);
   local colorPrefix = class and CLASS_COLORS[class];
   if colorPrefix then formattedName = colorPrefix .. unitName .. "|h|r" end;
  end
  outputString = string_gsub(outputString, "%%n", function() return formattedName end);
 else
  outputString = string_gsub(outputString, "%(%%n%)", "");
  outputString = string_gsub(outputString, "%%n", "");
 end

 -- Substitute effect names.
 if (animationEvent.EffectName ~= nil) then
  outputString = string_gsub(outputString, "%%s", animationEvent.EffectName);
 end

 -- Substitute damage types.
 if (animationEvent.DamageType ~= nil) then
  outputString = string_gsub(outputString, "%%t", animationEvent.DamageType);
 end

 -- Check if there is partial effect text and the show partial effects flag is on and append it.
 if (animationEvent.PartialEffectText ~= nil and MikSBT.CurrentProfile.ShowPartialEffects) then
  outputString = outputString .. animationEvent.PartialEffectText;
 end


 -- Check if there is merge trailer text and append it.
 if (animationEvent.MergeTrailerText ~= nil) then
  outputString = outputString .. animationEvent.MergeTrailerText;
 end

 -- Set the event's output text.
 animationEvent.Text = outputString;
end


-- **********************************************************************************
-- This function returns the output message for the passed trigger event with all
-- %1-9 codes substituted with captured data.
-- **********************************************************************************
function MikSBT.FormatTriggerText(animationEvent, triggerEvent)
 local outputString = animationEvent.EventSettings.Message;

 -- Check if there is no text and bail.
 if (outputString == nil) then
  return;
 end

 -- Loop through all of the captures in the trigger event.
 for i = 1, triggerEvent.NumCaptures do
  local value = triggerEvent["CapturedData" .. i];
  if value ~= nil then outputString = string_gsub(outputString, "%%" .. i, function() return tostring(value) end) end;
 end

 -- Set the event's output text.
 animationEvent.Text = outputString;
end


-- **********************************************************************************
-- Registers the triggers in the current profile with combat event lib.
-- **********************************************************************************
function MikSBT.RegisterTriggers()
 -- Unregister all of the triggers from the combat event helper.
 MikCEH.UnregisterAllTriggers();

 -- Loop through all of the triggers in the current profile.
 for triggerKey, triggerData in MikSBT.CurrentProfile.Triggers do
  -- Make sure the trigger is being shown and register it with the combat event helper.
  if (triggerData.EventSettings.Show) then
   MikCEH.RegisterTrigger(triggerKey, triggerData.TriggerSettings);
  end
 end
end


-------------------------------------------------------------------------------------
-- Profile functions.
-------------------------------------------------------------------------------------

-- **********************************************************************************
-- Updates profiles created with older versions.
-- **********************************************************************************
function MikSBT.UpdateProfiles()
 local function RetireSettings(profile)
  -- Show Vigor Gains is now only the Vigor suppression.
  if (profile.ShowVigorGains == false and type(profile.Suppressions) == "table") then
   profile.Suppressions.MSBT_SUPPRESSION_ROGUE_VIGOR = {Enabled = true, SearchPattern = "Vigor"};
  end
  profile.ShowVigorGains = nil;
  profile.ShowOverheals = nil;
  profile.CreationVersion = nil;
  if (type(profile.EventSettings) == "table") then
   profile.EventSettings.MSBT_EVENTTYPE_NOTIFICATION_ITEM_BUFF = nil;
  end
  -- The Wisdom suppression guessed amounts (+30/33/39/50/53/59 of any mana);
  -- it now names the Judgement of Wisdom mana return.
  local wisdom = type(profile.Suppressions) == "table" and profile.Suppressions.MSBT_SUPPRESSION_WISDOM_MANA_GAINS;
  if (wisdom and wisdom.SearchPattern == "+[35][039] " .. MANA) then
   wisdom.SearchPattern = "Judgement of Wisdom";
  end
 end
 -- Saved default triggers that still parse chat text use the event types now.
 local CHAT_TRIGGERS = {
  MSBT_TRIGGER_COUNTER_ATTACK = {"VSPARRYOTHERSELF", 9},
  MSBT_TRIGGER_RIPOSTE = {"VSPARRYOTHERSELF", 9},
  MSBT_TRIGGER_MONGOOSE_BITE = {"VSDODGEOTHERSELF", 8},
  MSBT_TRIGGER_OVERPOWER = {"VSDODGESELFOTHER", 10},
  MSBT_TRIGGER_CLEARCAST = {"Clearcasting", 7},
  MSBT_TRIGGER_WINDFURY = {"Windfury Totem", 7},
  MSBT_TRIGGER_NIGHTFALL = {"Shadow Trance", 7},
 };
 local function MigrateTriggers(profile)
  for key, old in pairs(CHAT_TRIGGERS) do
   local trigger = type(profile.Triggers) == "table" and profile.Triggers[key];
   local settings = trigger and trigger.TriggerSettings;
   if (settings and settings.TriggerType == 6 and settings.SearchPatterns) then
    local pattern, newType = old[1], old[2];
    if (newType == 7) then pattern = string.format(AURAADDEDSELFHELPFUL, pattern) end
    if (settings.SearchPatterns[1] == pattern) then
     settings.TriggerType = newType;
     settings.AuraName = (newType == 7) and old[1] or nil;
     settings.TriggerEvents, settings.SearchPatterns = nil, nil;
    end
   end
  end
 end
 local function FillMissing(target, defaults)
  for key, value in pairs(defaults) do
   if target[key] == nil then
    target[key] = type(value) == "table" and MikSBT.CopyTable(value) or value;
   elseif type(target[key]) == "table" and type(value) == "table" and
          key ~= "Triggers" and key ~= "Suppressions" then
    FillMissing(target[key], value);
   end
  end
 end
 for _, profile in pairs(MikSBT_Save.Profiles or {}) do
  if type(profile) == "table" then
   RetireSettings(profile);
   MigrateTriggers(profile);
   FillMissing(profile, MikSBT.DEFAULT_CONFIG);
  end
 end
end


-- **********************************************************************************
-- Returns whether or not the passed profile exists.
-- **********************************************************************************
function MikSBT.ProfileExists(profileName)
 if (MikSBT_Save and MikSBT_Save.Profiles and profileName and MikSBT_Save.Profiles[profileName] ~= nil) then
  return true;
 end
 return false;
end


-- **********************************************************************************
-- Resets the passed profile to its defaults.
-- **********************************************************************************
function MikSBT.ResetProfile(profileName, showOutput)
 -- Get whether or not the profile exists.
 local profileExists = MikSBT.ProfileExists(profileName);

 -- Check if the profile exists.
 if (profileExists) then
  if profileName == MikSBT_Save.CurrentProfile then MikSBT.ClearPendingEvents() end;

  -- Reset the profile.
  MikSBT_Save.Profiles[profileName] = MikSBT.CopyTable(MikSBT.DEFAULT_CONFIG);

  -- Check if it's the current profile being reset.
  if (profileName == MikSBT_Save.CurrentProfile) then
   -- Reset the current profile pointer.
   MikSBT.CurrentProfile = MikSBT_Save.Profiles[MikSBT_Save.CurrentProfile];

   -- Reassociate the display settings if the scroll areas have been setup.
   if (scrollAreas.Incoming ~= nil) then
    -- Setup the display settings.
    scrollAreas.Incoming.DisplaySettings = MikSBT.CurrentProfile.DisplaySettings.Incoming;
    scrollAreas.Outgoing.DisplaySettings = MikSBT.CurrentProfile.DisplaySettings.Outgoing;
    scrollAreas.Notification.DisplaySettings = MikSBT.CurrentProfile.DisplaySettings.Notification;
   end

   -- Reposition the animation frames.
   MikSBT.RepositionAnimationFrames();

   -- Register the triggers with the combat event helper.
   MikSBT.RegisterTriggers();

   MikSBT.ApplyGameDamageFont();
  end

  -- Check if the output text is to be shown.
  if (showOutput) then
   -- Print the profile reset string.
   MikSBT.Print(profileName .. " " .. MikSBT.MSG_PROFILE_RESET, 0, 1, 0);
  end
 end 
end


-- **********************************************************************************
-- Selects the passed profile.
-- **********************************************************************************
function MikSBT.SelectProfile(profileName)
 -- Get whether or not the profile exists.
 local profileExists = MikSBT.ProfileExists(profileName);

 -- Check if the profile exists.
 if (profileExists) then
  MikSBT.ClearPendingEvents();

  -- Set the current profile name to the one being selected.
  MikSBT_Save.CurrentProfile = profileName;

  -- Reset the current profile pointer.
  MikSBT.CurrentProfile = MikSBT_Save.Profiles[MikSBT_Save.CurrentProfile];

  -- Reassociate the display settings if the scroll areas have been setup.
  if (scrollAreas.Incoming ~= nil) then
   -- Setup the display settings.
   scrollAreas.Incoming.DisplaySettings = MikSBT.CurrentProfile.DisplaySettings.Incoming;
   scrollAreas.Outgoing.DisplaySettings = MikSBT.CurrentProfile.DisplaySettings.Outgoing;
   scrollAreas.Notification.DisplaySettings = MikSBT.CurrentProfile.DisplaySettings.Notification;
  end

  -- Reposition the animation frames.
  MikSBT.RepositionAnimationFrames();

  -- Register the triggers with the combat event helper.
  MikSBT.RegisterTriggers();

  MikSBT.ApplyGameDamageFont();
 end
end


-- **********************************************************************************
-- Creates a profile for the passed name.
-- **********************************************************************************
function MikSBT.CreateProfile(profileName)
 -- Get whether or not the profile exists.
 local profileExists = MikSBT.ProfileExists(profileName);

 -- Make sure a profile name was passed and it doesn't already exist.
 if (not profileExists and profileName ~= nil and profileName ~= "") then
  -- Create an array for the profile.
  MikSBT_Save.Profiles[profileName] = {};
  
  if profileName == MikSBT_Save.CurrentProfile then MikSBT.ClearPendingEvents() end;

  -- Reset the profile.
  MikSBT.ResetProfile(profileName);
 end
end


-- **********************************************************************************
-- Deletes the passed profile.
-- **********************************************************************************
function MikSBT.DeleteProfile(profileName)
 -- Check if the passed profile is the default one.
 if (profileName == MikSBT.DEFAULT_PROFILE_NAME) then
  return;
 end

 -- Get whether or not the profile exists.
 local profileExists = MikSBT.ProfileExists(profileName);

 -- Check if the profile exists.
 if (profileExists) then
  -- Check if the profile being deleted is the current one.
  if (profileName == MikSBT_Save.CurrentProfile) then
   -- Select the default profile.
   MikSBT.SelectProfile(MikSBT.DEFAULT_PROFILE_NAME);
  end

  -- Delete the profile.
  MikSBT_Save.Profiles[profileName] = nil;
 end
end


-------------------------------------------------------------------------------------
-- Option functions.
-------------------------------------------------------------------------------------

-- **********************************************************************************
-- Set the user disabled option
-- **********************************************************************************
function MikSBT.SetOptionUserDisabled(isDisabled)
 MikSBT_Save.UserDisabled = isDisabled;

 -- Check if the mod is being set to disabled.
 if (isDisabled) then
  MikSBT.ClearPendingEvents();
  -- Unregister all events.
  MikSBT.UnregisterEvents();
  MikCEH.UnregisterEvents();

  -- Turn on the game's display of outgoing damage.
  SetCVar("CombatDamage", 1);

  -- Blizzard/UnitXP floating text keeps its independently chosen enabled state.
 else
  -- Reregister events.
  MikSBT.RegisterEvents();
  MikCEH.RegisterEvents();

  -- Turn the game damage display on or off depending on the user setting.
  MikSBT.SetOptionShowGameDamage(MikSBT.CurrentProfile.ShowGameDamage);
  
  -- Blizzard/UnitXP floating text keeps its independently chosen enabled state.
 end
end


-- **********************************************************************************
-- Set the game damage disabled option
-- **********************************************************************************
function MikSBT.SetOptionShowGameDamage(showDamage)
 MikSBT.CurrentProfile.ShowGameDamage = showDamage;
 MikSBT.ApplyGameDamageSetting();
end


-- **********************************************************************************
-- Apply the effective game damage CVar. A disabled MSBT always restores the
-- game's own damage text; otherwise the profile preference decides.
-- **********************************************************************************
function MikSBT.ApplyGameDamageSetting()
 if (MikSBT_Save.UserDisabled or MikSBT.CurrentProfile.ShowGameDamage) then
  SetCVar("CombatDamage", 1);
 else
  SetCVar("CombatDamage", 0);
 end
end


-- **********************************************************************************
-- This function takes a string version of a variable path
-- and returns its value from the current profile.
-- **********************************************************************************
function MikSBT.GetOptionFromVarPath(varPath)
 -- Set the current table to the current profile.
 local currentTable = MikSBT.CurrentProfile;

 -- Index into each sub table until we reach the actual variable wanted.
 for varName in string.gfind(varPath, "[%w_]+") do
  if (type(currentTable[varName]) == "table") then
   currentTable = currentTable[varName];
  else
   return currentTable[varName];
  end
 end

 return nil;
end


-- **********************************************************************************
-- This function takes a string version of a variable path
-- and sets its value in the current profile to the passed value.
-- **********************************************************************************
function MikSBT.SetOptionFromVarPath(varPath, newValue)
 local currentTable = MikSBT.CurrentProfile;
 if (not currentTable or not varPath) then return end

 local keys = {};
 for varName in string.gfind(varPath, "[%w_]+") do
  table.insert(keys, varName);
 end

 local numKeys = #keys;
 if (numKeys == 0) then return end

 for i = 1, numKeys - 1 do
  local k = keys[i];
  if (type(currentTable[k]) ~= "table") then
   currentTable[k] = {};
  end
  currentTable = currentTable[k];
 end

 currentTable[keys[numKeys]] = newValue;
end


-------------------------------------------------------------------------------------
-- Animation functions.
-------------------------------------------------------------------------------------

-- **********************************************************************************
-- Adds the passed animation event to the animation system for the appropriate scroll
-- area.
--
-- animationEvent Possible Fields:
--  ScrollArea		- The scroll area to use for the event.
--  EventType		- The event type.
--  EventSettings		- The event settings for the event.
--  IsCrit			- Whether or not the event is a crit.
--  UnformattedText	- The unformatted text to display.
--  Amount			- The amount of the attack, heal, gain, loss, etc.
--  EffectName		- The name of the spell, ability, buff, debuff, power type, etc.
--  Name			- The name of the enemy/player.
--  DamageType		- The type of damage.
--  PartialEffectText	- Partial effect text to be appended. (partial resists, absorbs, blocks)
-- **********************************************************************************
-- Asynchronous merge workers using C_Timer.After to eradicate per-frame polling.
-- **********************************************************************************
local ScheduleMerge;

function MikSBT.ClearPendingEvents()
 for _, data in pairs(animationMergeData) do
  data.Generation = data.Generation + 1;
  if data.Timer then data.Timer:Cancel(); data.Timer = nil end;
  data.TimerPending = false;
  for _, events in ipairs({data.UnmergedEvents, data.SpareEvents, data.MergedEvents}) do
   for i, item in pairs(events) do eventsRecycler:ReclaimTable(item); events[i] = nil end
  end
 end
 for _, area in pairs(scrollAreas) do
  for _, info in ipairs(area.AnimationDisplayArray) do
   info.IsActive = false;
   info.timeLastJiggled, info.originalPositionX, info.originalPositionY = nil, nil, nil;
   info.FontObject:SetAlpha(0);
   if info.Texture then info.Texture:SetAlpha(0) end
  end
  getglobal(area.AssociatedFrame):Hide();
 end
end

local function ProcessMerge(mergeData)
 if not mergeData or stillMerging then return end;
 stillMerging = true;
 local generation = mergeData.Generation;
 local unmerged = mergeData.UnmergedEvents;
 mergeData.UnmergedEvents = mergeData.SpareEvents;
 mergeData.SpareEvents = unmerged;
 local numEvents = #unmerged;
 if numEvents > 0 then
  MikSBT.MergeEvents(mergeData, unmerged, numEvents);
  for i, animationEvent in ipairs(mergeData.MergedEvents) do
   mergeData.MergedEvents[i] = nil;
   if generation == mergeData.Generation then MikSBT.AddAnimation(animationEvent);
   else eventsRecycler:ReclaimTable(animationEvent); end
  end
 end
 stillMerging = false;
 mergeData.TimerPending = false;
 if #mergeData.UnmergedEvents > 0 then ScheduleMerge(mergeData) end;
end

ScheduleMerge = function(data)
 if data.TimerPending then return end;
 data.TimerPending = true;
 local generation = data.Generation;
 data.Timer = C_Timer.NewTimer(MERGE_DELAY_TIME, function()
  if data.Generation ~= generation then return end;
  data.Timer = nil;
  ProcessMerge(data);
 end);
end

-- **********************************************************************************
-- Dispatches an animation event to the animation system or the unmerged events queue.
-- **********************************************************************************
--  ScrollArea		- The scroll area the animation event should be added to.
--  EventSettings	- Event settings from the current profile.
--  IsCrit			- Flag for whether or not it's a crit.
--  IsSticky		- Flag for whether or not it's a sticky.
--  Amount			- The amount of damage, heal, etc.
--  EffectName		- The name of the spell, ability, buff, debuff, power type, etc.
--  Name			- The name of the enemy/player.
--  DamageType		- The type of damage.
--  PartialEffectText	- Partial effect text to be appended. (partial resists, absorbs, blocks)
--  Text			- The formatted text to display.
-- **********************************************************************************
function MikSBT.DispatchAnimationEvent(animationEvent)
 -- Check if the event is to be shown.
 if (animationEvent.EventSettings.Show and animationEvent.ScrollArea.DisplaySettings.Show) then

  -- If it's an incoming or outgoing event add it to the associated scroll area's events array
  -- for potential merging.
  if (animationEvent.ScrollArea == scrollAreas.Incoming) then
   table_insert(animationMergeData.Incoming.UnmergedEvents, animationEvent);
   ScheduleMerge(animationMergeData.Incoming);
  elseif (animationEvent.ScrollArea == scrollAreas.Outgoing) then
   table_insert(animationMergeData.Outgoing.UnmergedEvents, animationEvent);
   ScheduleMerge(animationMergeData.Outgoing);

  -- Add the event to the animation system.
  else
   MikSBT.AddAnimation(animationEvent);
  end
 else
  eventsRecycler:ReclaimTable(animationEvent);
 end
end


-- **********************************************************************************
-- Add the event to the appropriate scroll area's animation display array.
-- **********************************************************************************

function MikSBT.PatternMatches(text, pattern)
 if type(text) ~= "string" or type(pattern) ~= "string" then return false end;
 local ok, first = pcall(string_find, text, pattern);
 return ok and first ~= nil;
end

function MikSBT.AddAnimation(animationEvent)
 -- Format the animation event's output text.
 MikSBT.FormatEventText(animationEvent);

 -- Loop through all of the suppression entries and look for a match.
 for _, suppressionSettings in pairs(MikSBT.CurrentProfile.Suppressions or {}) do
  -- Check if the suppression's search pattern is a match.
  if (suppressionSettings.Enabled and (MikSBT.PatternMatches(animationEvent.Text, suppressionSettings.SearchPattern))) then
   -- Reclaim the animation event table to the events recycler and leave the function.
   eventsRecycler:ReclaimTable(animationEvent);
   return;
  elseif (suppressionSettings.Enabled and animationEvent.EffectName and MikSBT.PatternMatches(animationEvent.EffectName, suppressionSettings.SearchPattern)) then
   -- Reclaim the animation event table to the events recycler and leave the function.
   eventsRecycler:ReclaimTable(animationEvent);
   return;
  end
 end
 
 if animationEvent.IsSpellManaGain and MikSBT.CurrentProfile.ShowAllManaGains then
	eventsRecycler:ReclaimTable(animationEvent);
	return
 end




 -- Check if the animation event is to be displayed sticky style.
 if (animationEvent.EventSettings ~= nil and animationEvent.EventSettings.IsSticky) then
  animationEvent.IsSticky = true;
 end

 -- Get the next available animation display info object for the scroll area.
 local animDisplayInfo = MikSBT.GetNextAnimationDisplayInfo(animationEvent);
 animDisplayInfo.timeLastJiggled, animDisplayInfo.originalPositionX, animDisplayInfo.originalPositionY = nil, nil, nil;
 animDisplayInfo.DecalageX, animDisplayInfo.DecalageY, animDisplayInfo.DeltaTime = nil, nil, nil;

 -- Get the scroll function to use.
 animDisplayInfo.ScrollFunction = MikSBT.GetScrollFunction(animationEvent);

 -- Get the starting X and Y positions.
 animDisplayInfo.PositionX, animDisplayInfo.PositionY = MikSBT.GetAnimationStartingPosition(animationEvent)


 -- Check if the animation event has event settings associated with it.
 if (animationEvent.EventSettings ~= nil) then
  -- Get the font size for the event.
  animDisplayInfo.FontSize = MikSBT.GetFontSize(animationEvent.ScrollArea, animationEvent.EventSettings, animationEvent.IsCrit);

  -- Get the font path for the event.
  animDisplayInfo.FontPath = MikSBT.GetFontPath(animationEvent.ScrollArea, animationEvent.EventSettings, animationEvent.IsCrit);

  -- Get the font outline style for the event.
  animDisplayInfo.FontOutline = MikSBT.GetFontOutline(animationEvent.ScrollArea, animationEvent.EventSettings, animationEvent.IsCrit);

  -- Set the r, g, and b color for the animation display object.
  animDisplayInfo.ColorR = animationEvent.EventSettings.FontSettings.Color.r;
  animDisplayInfo.ColorG = animationEvent.EventSettings.FontSettings.Color.g;
  animDisplayInfo.ColorB = animationEvent.EventSettings.FontSettings.Color.b;

  -- Override font color based on spell school damage type.
  if animationEvent.DamageType and animationEvent.EventType then
   local dtColor = GetDamageTypeFontColor(animationEvent.DamageType)
   if dtColor then
    animDisplayInfo.ColorR = dtColor.r
    animDisplayInfo.ColorG = dtColor.g
    animDisplayInfo.ColorB = dtColor.b
   end
  end

 -- No event type associated with the event so get the display info from the animation event itself.
 else
  -- Get the font size for the event.
  animDisplayInfo.FontSize = animationEvent.FontSize;

  -- Get the font path for the event.
  animDisplayInfo.FontPath = animationEvent.FontPath;

  -- Get the font outline style for the event.
  animDisplayInfo.FontOutline = animationEvent.FontOutline;

  -- Set the r, g, and b color for the animation display object.
  animDisplayInfo.ColorR = animationEvent.ColorR;
  animDisplayInfo.ColorG = animationEvent.ColorG;
  animDisplayInfo.ColorB = animationEvent.ColorB;
 end


 -- Set the animation display alpha, anchor point, crit flag, and sticky flag.
 animDisplayInfo.Alpha = 0;
 animDisplayInfo.AnchorPoint = MikSBT.AVAILABLE_TEXT_ALIGNS[animationEvent.ScrollArea.DisplaySettings.FontSettings.TextAlignIndex].AnchorPoint;
 animDisplayInfo.IsCrit = animationEvent.IsCrit;
 animDisplayInfo.IsSticky = animationEvent.IsSticky;

 if (animationEvent.EventType == "MSBT_EVENTTYPE_OUTGOING_SPELL_RESIST") then 
  -- play sound if enabled
  if MikSBT.CurrentProfile.ResistSound then
    if animationEvent.EffectName then
      if (string_find(animationEvent.EffectName, "Cone of Cold") or string_find(animationEvent.EffectName, "Frost Nova")) then
        PlaySoundFile("Interface\\AddOns\\MikScrollingBattleText\\sounds\\Resist.mp3");
      end
    end
  end
 end
  
 -- Set the font object properties.
 animDisplayInfo.FontObject:ClearAllPoints();
 -- SetTextHeight does NOT apply if the original font size wouldn't be changed by it
 -- FontSize tops out at 32 and in vanilla doesn't seem to apply at all - every different size I've tried has refused to work
 -- TextHeight does scale past 32, but expectedly becomes blurry - still better than unreadable numbers on a 4k display
 local fontSize = animDisplayInfo.FontSize;
 if (not fontSize or fontSize < 2) then fontSize = 18; end
 animDisplayInfo.FontObject:SetFont(animDisplayInfo.FontPath, fontSize-1, animDisplayInfo.FontOutline);
 -- Fall back to default font if the configured font file was not found.
 if (not animDisplayInfo.FontObject:GetFont()) then
  animDisplayInfo.FontObject:SetFont("Fonts\\FRIZQT__.TTF", fontSize-1, animDisplayInfo.FontOutline);
 end
 animDisplayInfo.FontObject:SetTextColor(animDisplayInfo.ColorR, animDisplayInfo.ColorG, animDisplayInfo.ColorB);
 animDisplayInfo.FontObject:SetText(animationEvent.Text);
 animDisplayInfo.FontObject:SetTextHeight(animDisplayInfo.FontSize);
 animDisplayInfo.FontObject:SetAlpha(animDisplayInfo.Alpha);
 animDisplayInfo.FontObject:SetPoint(animDisplayInfo.AnchorPoint, animDisplayInfo.PositionX, animDisplayInfo.PositionY);
 animDisplayInfo.PlacedX, animDisplayInfo.PlacedY = animDisplayInfo.PositionX, animDisplayInfo.PositionY;
 animDisplayInfo.Phase = nil;
 
 -- Spell icon: the trigger's own texture, else the spell's icon by ID.
 local texture = animationEvent.Texture or MikCEH.GetSpellIcon(animationEvent.SpellId);

	if texture then
		if not animDisplayInfo.Texture then
			animDisplayInfo.Texture = getglobal(animationEvent.ScrollArea.AssociatedFrame):CreateTexture(nil, "ARTWORK")
		end
		animDisplayInfo.Texture:ClearAllPoints();
		animDisplayInfo.Texture:SetTexture(texture);
		animDisplayInfo.Texture:SetWidth(animDisplayInfo.FontSize);
		animDisplayInfo.Texture:SetHeight(animDisplayInfo.FontSize);
		animDisplayInfo.Texture:SetTexCoord(0.125, 0.875, 0.125, 0.875)
		animDisplayInfo.Texture:SetPoint("RIGHT", animDisplayInfo.FontObject, "LEFT", -4, 0);
		animDisplayInfo.Texture:SetDrawLayer(animDisplayInfo.IsSticky and "OVERLAY" or animDisplayInfo.IsCrit and "OVERLAY" or "ARTWORK");
	elseif animDisplayInfo.Texture then
		animDisplayInfo.Texture:SetTexture(nil);
	end

	animDisplayInfo.LastUpdated = GetTime();
	animDisplayInfo.IsActive = true;

	if (not getglobal(animationEvent.ScrollArea.AssociatedFrame):IsVisible()) then
		getglobal(animationEvent.ScrollArea.AssociatedFrame):Show();
	end

	if (animDisplayInfo.IsSticky or (animDisplayInfo.IsCrit and MikSBT.CurrentProfile.UseStickyCrits)) then
		MikSBT.RepositionStickyAnimDisplayInfo(animationEvent.ScrollArea);
	else
		MikSBT.RepositionAnimDisplayInfo(animationEvent.ScrollArea);
	end

	eventsRecycler:ReclaimTable(animationEvent);
end


-- **********************************************************************************
-- This function gets the next animation display info object for the correct
-- scroll area.
-- **********************************************************************************
function MikSBT.GetNextAnimationDisplayInfo(animationEvent)
 -- Holds the next animation display info object.
 local animDisplayInfo;

 -- Check if it's a sticky or it's a crit and sticky crits are enabled.
 if (animationEvent.IsSticky or (animationEvent.IsCrit and MikSBT.CurrentProfile.UseStickyCrits)) then
  -- Get the next available animation display object for stickies.
  -- This is done so that stickies use the last set of font strings to avoid normal hits
  -- overlapping them.
  animDisplayInfo = animationEvent.ScrollArea.AnimationDisplayArray[animationEvent.ScrollArea.NextSticky];

  -- Increment to the next sticky animation display object.
  animationEvent.ScrollArea.NextSticky = animationEvent.ScrollArea.NextSticky + 1;
 
  -- Loop back around to the first sticky animation display object.
  if (animationEvent.ScrollArea.NextSticky > NUM_FONT_STRINGS) then
   animationEvent.ScrollArea.NextSticky = animationEvent.ScrollArea.FirstSticky;
  end

 -- Not a sticky.
 else
  -- Get the next available animation display object.
  animDisplayInfo = animationEvent.ScrollArea.AnimationDisplayArray[animationEvent.ScrollArea.NextAnimationDisplay];

  -- Increment to the next animation display object.
  animationEvent.ScrollArea.NextAnimationDisplay = animationEvent.ScrollArea.NextAnimationDisplay + 1;
 
  -- Loop back around to the first animation display object.
  if (animationEvent.ScrollArea.NextAnimationDisplay > (animationEvent.ScrollArea.FirstSticky - 1)) then
   animationEvent.ScrollArea.NextAnimationDisplay = 1;
  end
 end

 -- Return the animation display info object.
 return animDisplayInfo;
end


-- **********************************************************************************
-- This function gets the scroll function to use for the event.
-- **********************************************************************************
function MikSBT.GetScrollFunction(animationEvent)
 -- Straight animation style.
 if (animationEvent.ScrollArea.DisplaySettings.AnimationStyle == ANIMATION_STYLE_STRAIGHT) then
  -- Text is scrolling down.
  if (animationEvent.ScrollArea.DisplaySettings.ScrollDirection == SCROLL_DIRECTION_DOWN) then
   -- Return the appropriate animation function.
   return MikSBT.ScrollStraightDown;
  -- Text is scrolling up.
  else
   -- Return the appropriate animation function.
   return MikSBT.ScrollStraightUp;
  end

 -- Left parabola animation style.
 elseif (animationEvent.ScrollArea.DisplaySettings.AnimationStyle == ANIMATION_STYLE_LEFT_PARABOLA) then
  -- Text is scrolling down.
  if (animationEvent.ScrollArea.DisplaySettings.ScrollDirection == SCROLL_DIRECTION_DOWN) then
   -- Return the appropriate animation function.
   return MikSBT.ScrollLeftParabolaDown;
  -- Text is scrolling up.
  else
   -- Return the appropriate animation function.
   return MikSBT.ScrollLeftParabolaUp;
  end

 -- Right parabola animation style.
 elseif (animationEvent.ScrollArea.DisplaySettings.AnimationStyle == ANIMATION_STYLE_RIGHT_PARABOLA) then
  -- Text is scrolling down.
  if (animationEvent.ScrollArea.DisplaySettings.ScrollDirection == SCROLL_DIRECTION_DOWN) then
   -- Return the appropriate animation function.
   return MikSBT.ScrollRightParabolaDown;
  -- Text is scrolling up.
  else
   -- Return the appropriate animation function.
   return MikSBT.ScrollRightParabolaUp;
  end

 end

 -- Default to the straight up animation style although the function should never get
 -- to this point.
 return MikSBT.ScrollStraightUp;
end


-- **********************************************************************************
-- This function gets the starting animation x and and y position.
-- **********************************************************************************
function MikSBT.GetAnimationStartingPosition(animationEvent)
 -- Holds where to start the animation at.
 local startPositionX, startPositionY;

 -- Check which animation style is selected for the scroll area.
 if (animationEvent.ScrollArea.DisplaySettings.AnimationStyle == ANIMATION_STYLE_STRAIGHT or
     animationEvent.ScrollArea.DisplaySettings.AnimationStyle == ANIMATION_STYLE_LEFT_PARABOLA or
     animationEvent.ScrollArea.DisplaySettings.AnimationStyle == ANIMATION_STYLE_RIGHT_PARABOLA) then

  -- Check if the text is scrolling down.
  if (animationEvent.ScrollArea.DisplaySettings.ScrollDirection == SCROLL_DIRECTION_DOWN) then
   -- Set the starting X and Y positions.
   startPositionX = 0;
   startPositionY = animationEvent.ScrollArea.DisplaySettings.ScrollHeight;
  -- Text is scrolling up.
  else
   -- Set the starting X and Y positions.
   startPositionX = 0;
   startPositionY = 0;
  end

  -- Check if it's a sticky or a crit and sticky crits are enabled.
  if (animationEvent.IsSticky or (animationEvent.IsCrit and MikSBT.CurrentProfile.UseStickyCrits)) then
   -- Set the sticky to the center.
   startPositionY = math_ceil(animationEvent.ScrollArea.DisplaySettings.ScrollHeight / 2);
  end
 end

 -- Return the x and y starting positions.
 return startPositionX, startPositionY;
end


-- **********************************************************************************
-- This function makes sure there is no overlapping text.
-- **********************************************************************************
function MikSBT.RepositionAnimDisplayInfo(scrollArea)
 -- Construct a table with the non sticky animation display info in the same order the events were added.
 for x = scrollArea.NextAnimationDisplay, scrollArea.FirstSticky-1 do
  local animDisplayInfo = scrollArea.AnimationDisplayArray[x];
  if (animDisplayInfo.IsActive) then
   table_insert(activeNonStickies, animDisplayInfo);
  end
 end

 for x = 1, scrollArea.NextAnimationDisplay-1 do
  local animDisplayInfo = scrollArea.AnimationDisplayArray[x];
  if (animDisplayInfo.IsActive) then
   table_insert(activeNonStickies, animDisplayInfo);
  end
 end

 -- Get the number of active non sticky data objects.
 local numNonStickies = #activeNonStickies;

 -- Animation style straight, left parabola, or right parabola.
 if (scrollArea.DisplaySettings.AnimationStyle == ANIMATION_STYLE_STRAIGHT or 
     scrollArea.DisplaySettings.AnimationStyle == ANIMATION_STYLE_LEFT_PARABOLA or 
     scrollArea.DisplaySettings.AnimationStyle == ANIMATION_STYLE_RIGHT_PARABOLA) then

  -- Scrolling down.
  if (scrollArea.DisplaySettings.ScrollDirection == SCROLL_DIRECTION_DOWN) then

   -- Check if there is more than 1 active non sticky animation.
   if (numNonStickies > 1) then
    -- Loop backwards through the active non sticky animation display objects and move the ones that are colliding.
    for x = numNonStickies, 2, -1 do
     local bottomPointCurrent = activeNonStickies[x].PositionY;
     local topPointNext = activeNonStickies[x-1].PositionY + activeNonStickies[x-1].FontSize + MIN_VERTICAL_SPACING;
     if (topPointNext > bottomPointCurrent) then
      activeNonStickies[x-1].PositionY = bottomPointCurrent - activeNonStickies[x-1].FontSize - MIN_VERTICAL_SPACING;
     end
    end
   end

  -- Scrolling up.
  else

   -- Check if there is more than 1 active non sticky animation.
   if (numNonStickies > 1) then
    -- Loop backwards through the active non sticky animation display objects and move the ones that are colliding.
    for x = numNonStickies, 2, -1 do
     local topPointCurrent = activeNonStickies[x].PositionY + activeNonStickies[x].FontSize + MIN_VERTICAL_SPACING;
     local bottomPointNext = activeNonStickies[x-1].PositionY;
     if (bottomPointNext < topPointCurrent) then
      activeNonStickies[x-1].PositionY = topPointCurrent;
     end
    end
   end

  end -- Scrolling Direction
 end -- Animation Style

 -- Clear the temp non stickies table.
 table.wipe(activeNonStickies);
end


-- **********************************************************************************
-- This function makes sure stickies don't overlap.
-- **********************************************************************************
function MikSBT.RepositionStickyAnimDisplayInfo(scrollArea)
 -- Construct a table with the sticky animation display info in the same order the events were added.
 for x = scrollArea.NextSticky, NUM_FONT_STRINGS do
  local animDisplayInfo = scrollArea.AnimationDisplayArray[x];
  if (animDisplayInfo.IsActive) then
   table_insert(activeStickies, animDisplayInfo);
  end
 end

 for x = scrollArea.FirstSticky, scrollArea.NextSticky-1 do
  local animDisplayInfo = scrollArea.AnimationDisplayArray[x];
  if (animDisplayInfo.IsActive) then
   table_insert(activeStickies, animDisplayInfo);
  end
 end

 -- Get the number of active stickies.
 local numStickies = #activeStickies;


 -- Animation style straight, left parabola, or right parabola.
 if (scrollArea.DisplaySettings.AnimationStyle == ANIMATION_STYLE_STRAIGHT or 
     scrollArea.DisplaySettings.AnimationStyle == ANIMATION_STYLE_LEFT_PARABOLA or 
     scrollArea.DisplaySettings.AnimationStyle == ANIMATION_STYLE_RIGHT_PARABOLA) then

  -- Scrolling down.
  if (scrollArea.DisplaySettings.ScrollDirection == SCROLL_DIRECTION_DOWN) then

   -- Check if there is more than 1 active sticky animation.
   if (numStickies > 1) then
    -- Get the middle active sticky.
    local middleSticky = math_floor((numStickies + 1) / 2);

    -- Set the middle sticky to the center of the scroll area.
    activeStickies[middleSticky].PositionY = scrollArea.DisplaySettings.ScrollHeight / 2;

    -- Loop backwards from the middle sticky.
    for x = middleSticky - 1, 1, -1 do
     activeStickies[x].PositionY = activeStickies[x+1].PositionY - activeStickies[x].FontSize - MIN_VERTICAL_SPACING;
    end

    -- Loop forwards from the middle sticky.
    for x = middleSticky + 1, numStickies do
     activeStickies[x].PositionY = activeStickies[x-1].PositionY + activeStickies[x-1].FontSize + MIN_VERTICAL_SPACING;
    end
   end

  -- Scrolling up.
  else

   -- Check if there is more than 1 active sticky animation.
   if (numStickies > 1) then
    -- Get the middle active sticky.
    local middleSticky = math_ceil((numStickies + 1) / 2);

    -- Set the middle sticky to the center of the scroll area.
    activeStickies[middleSticky].PositionY = scrollArea.DisplaySettings.ScrollHeight / 2;
   
    -- Loop backwards from the middle sticky.
    for x = middleSticky - 1, 1, -1 do
     activeStickies[x].PositionY = activeStickies[x+1].PositionY + activeStickies[x+1].FontSize + MIN_VERTICAL_SPACING;
    end

    -- Loop forwards from the middle sticky.
    for x = middleSticky + 1, numStickies do
     activeStickies[x].PositionY = activeStickies[x-1].PositionY - activeStickies[x-1].FontSize - MIN_VERTICAL_SPACING;
    end
   end

  end -- Scrolling Direction
 end -- Animation Style

 -- Clear the temp stickies table.
 table.wipe(activeStickies);
end


-- Moves a sticky's text only when its position changed since the last write.
local function PlaceSticky(animDisplayInfo)
 if (animDisplayInfo.PlacedX ~= animDisplayInfo.PositionX or animDisplayInfo.PlacedY ~= animDisplayInfo.PositionY) then
  animDisplayInfo.FontObject:SetPoint(animDisplayInfo.AnchorPoint, animDisplayInfo.PositionX, animDisplayInfo.PositionY);
  animDisplayInfo.PlacedX, animDisplayInfo.PlacedY = animDisplayInfo.PositionX, animDisplayInfo.PositionY;
 end
end


-- **********************************************************************************
-- Animates the passed animation display data.
-- **********************************************************************************
function MikSBT.DoAnimation(animDisplayInfo, scrollArea)

 -- Get the current and elapsed times since the last update.
 local currentTime = GetTime();
 local elapsedTime = currentTime - animDisplayInfo.LastUpdated;

 -- Stickies: the size pops in, holds while the crit jiggles, then fades. Widget
 -- values are written when the phase or position changes, not every frame.
 if (animDisplayInfo.IsSticky or (animDisplayInfo.IsCrit and MikSBT.CurrentProfile.UseStickyCrits)) then
  local fontObject, texture = animDisplayInfo.FontObject, animDisplayInfo.Texture;

  if (elapsedTime <= STICKY_FADE_IN_TIME) then
   local size = animDisplayInfo.FontSize * (2 - (elapsedTime / STICKY_FADE_IN_TIME));
   if (animDisplayInfo.Phase ~= 1) then
    animDisplayInfo.Phase = 1;
    fontObject:SetAlpha(1);
    if texture then texture:SetAlpha(1) end
   end
   fontObject:SetTextHeight(size);
   if texture then texture:SetWidth(size); texture:SetHeight(size) end
   PlaceSticky(animDisplayInfo);
   return;

  elseif (elapsedTime <= (STICKY_DISPLAY_TIME + STICKY_FADE_IN_TIME)) then
   if (animDisplayInfo.Phase ~= 2) then
    animDisplayInfo.Phase = 2;
    fontObject:SetAlpha(1);
    fontObject:SetTextHeight(animDisplayInfo.FontSize);
    if texture then
     texture:SetAlpha(1);
     texture:SetWidth(animDisplayInfo.FontSize);
     texture:SetHeight(animDisplayInfo.FontSize);
    end
   end
   if animDisplayInfo.IsCrit then
    if not animDisplayInfo.timeLastJiggled then
     animDisplayInfo.originalPositionX = animDisplayInfo.PositionX
     animDisplayInfo.originalPositionY = animDisplayInfo.PositionY
     animDisplayInfo.DecalageX = 0
     animDisplayInfo.DecalageY = 0
     animDisplayInfo.timeLastJiggled = 0
    end
    -- Another sticky moved this one: jiggle around the new spot.
    if animDisplayInfo.PositionY ~= (animDisplayInfo.originalPositionY + animDisplayInfo.DecalageY) then
     animDisplayInfo.originalPositionX = animDisplayInfo.PositionX
     animDisplayInfo.originalPositionY = animDisplayInfo.PositionY
    end
    if (elapsedTime - animDisplayInfo.timeLastJiggled > 0.05) then
     animDisplayInfo.DecalageX = math_random(-1, 1);
     animDisplayInfo.DecalageY = math_random(-1, 1);
     animDisplayInfo.PositionX = animDisplayInfo.originalPositionX + animDisplayInfo.DecalageX;
     animDisplayInfo.PositionY = animDisplayInfo.originalPositionY + animDisplayInfo.DecalageY;
     animDisplayInfo.timeLastJiggled = elapsedTime;
    end
   end
   PlaceSticky(animDisplayInfo);
   return;

  elseif (elapsedTime <= (STICKY_DISPLAY_TIME + STICKY_FADE_IN_TIME + STICKY_FADE_OUT_TIME)) then
   local alpha = 1 - ((elapsedTime - STICKY_DISPLAY_TIME - STICKY_FADE_IN_TIME) / STICKY_FADE_OUT_TIME);
   animDisplayInfo.Phase = 3;
   animDisplayInfo.timeLastJiggled = nil
   fontObject:SetAlpha(alpha);
   if texture then texture:SetAlpha(alpha) end
   PlaceSticky(animDisplayInfo);
   return;
  end

  -- Deactivate the animation.
  fontObject:SetAlpha(0);
  if texture then texture:SetAlpha(0) end
  animDisplayInfo.IsActive = false;
  return;
 end


 -- Check if it's time to update.
 if (elapsedTime > ANIMATION_SPEED) then
  -- Scroll the text with delta-time normalization for DXVK frame pacing smoothing.
  animDisplayInfo.DeltaTime = elapsedTime;
  local animationComplete = animDisplayInfo.ScrollFunction(animDisplayInfo, scrollArea);


  -- Check if the animation is complete.
  if (animationComplete) then
   -- Set the font object's alpha.
   animDisplayInfo.FontObject:SetAlpha(0);
   if animDisplayInfo.Texture then
	animDisplayInfo.Texture:SetAlpha(0);
   end

   -- Deactive the animation.
   animDisplayInfo.IsActive = false;
  else
   -- Move the font object and set its alpha.
   animDisplayInfo.FontObject:SetPoint(animDisplayInfo.AnchorPoint, animDisplayInfo.PositionX, animDisplayInfo.PositionY);
   animDisplayInfo.FontObject:SetAlpha(animDisplayInfo.Alpha);
   if animDisplayInfo.Texture then
	animDisplayInfo.Texture:SetAlpha(animDisplayInfo.Alpha);
   end
  end

  -- Set the last update to the current time.
  animDisplayInfo.LastUpdated = currentTime;
 end -- Time for update.
end


-- **********************************************************************************
-- Moves the passed animation display info upward and fades the alpha correctly.
-- Returns true when the animation is complete.
-- **********************************************************************************
function MikSBT.ScrollUp(animDisplayInfo, scrollArea)
 -- Calculate the animation midpoint.
 local animationMidPoint = scrollArea.DisplaySettings.ScrollHeight / 2;

 -- Increment the Y position by the step.
 local dtScale = (animDisplayInfo.DeltaTime and animDisplayInfo.DeltaTime > 0) and (animDisplayInfo.DeltaTime / 0.02) or 1;
 animDisplayInfo.PositionY = animDisplayInfo.PositionY + (MikSBT.CurrentProfile.AnimationStep * dtScale);

 -- Start fading out the text on the upper half.
 if (animDisplayInfo.PositionY >= animationMidPoint) then
  animDisplayInfo.Alpha = 1 - ((animDisplayInfo.PositionY - animationMidPoint) / animationMidPoint);
 else
  animDisplayInfo.Alpha = 1;
 end

 -- Check if the animation is complete.
 if (animDisplayInfo.PositionY >= scrollArea.DisplaySettings.ScrollHeight) then
  -- Return true to indicated the animation is complete.
  return true;
 end

 -- Return false to indicate the animation is NOT complete.
 return false;
end


-- **********************************************************************************
-- Moves the passed animation display info downward and fades the alpha correctly.
-- Returns true when the animation is complete.
-- **********************************************************************************
function MikSBT.ScrollDown(animDisplayInfo, scrollArea)
 -- Calculate the animation midpoint.
 local animationMidPoint = scrollArea.DisplaySettings.ScrollHeight / 2;

 -- Decrement the Y position by the step.
 local dtScale = (animDisplayInfo.DeltaTime and animDisplayInfo.DeltaTime > 0) and (animDisplayInfo.DeltaTime / 0.02) or 1;
 animDisplayInfo.PositionY = animDisplayInfo.PositionY - (MikSBT.CurrentProfile.AnimationStep * dtScale);

 -- Start fading out the text on the bottom half.
 if (animDisplayInfo.PositionY < animationMidPoint) then
  animDisplayInfo.Alpha = 1 - ((animationMidPoint - animDisplayInfo.PositionY) / animationMidPoint);
 else
  animDisplayInfo.Alpha = 1;
 end

 -- Check if the animation is complete.
 if (animDisplayInfo.PositionY <= 0) then
  -- Return true to indicated the animation is complete.
  return true;
 end

 -- Return false to indicate the animation is NOT complete.
 return false;
end


-- **********************************************************************************
-- Moves the passed animation display info straight up. Returns true when the
-- animation is complete.
-- **********************************************************************************
function MikSBT.ScrollStraightUp(animDisplayInfo, scrollArea)
 -- Returns the result of the scroll up function.
 return MikSBT.ScrollUp(animDisplayInfo, scrollArea);
end


-- **********************************************************************************
-- Moves the passed animation display info straight down.  Returns true when the
-- animation is complete.
-- **********************************************************************************
function MikSBT.ScrollStraightDown(animDisplayInfo, scrollArea)
 -- Returns the result of the scroll down function.
 return MikSBT.ScrollDown(animDisplayInfo, scrollArea);
end


-- **********************************************************************************
-- Moves the passed animation display info in a left parabolic shape going upwards.
-- Returns true when the animation is complete.
-- **********************************************************************************
function MikSBT.ScrollLeftParabolaUp(animDisplayInfo, scrollArea)
 -- Scroll the animation display info straight up and set the alpha correctly.
 local animationComplete = MikSBT.ScrollUp(animDisplayInfo, scrollArea);

 -- Calculate the animation midpoint.
 local animationMidPoint = scrollArea.DisplaySettings.ScrollHeight / 2;

 -- Calculate the new x position based on equation of a parabola.
 -- Equation of a parabola at vertex 0,0: x = y^2 / 4a
 local parabolaMaxX = math_ceil((animationMidPoint * animationMidPoint) / (4 * animationMidPoint));
 local parabolaY = animDisplayInfo.PositionY - animationMidPoint;
 local newX = parabolaMaxX - math_ceil((parabolaY * parabolaY) / (4 * animationMidPoint));

 -- Set the new x position.
 animDisplayInfo.PositionX = newX * -1;

 -- Return whether or not the animation is complete.
 return animationComplete;
end


-- **********************************************************************************
-- Moves the passed animation display info in a left parabolic shape going downwards.
-- Returns true when the animation is complete.
-- **********************************************************************************
function MikSBT.ScrollLeftParabolaDown(animDisplayInfo, scrollArea)
 -- Scroll the animation display info straight up and set the alpha correctly.
 local animationComplete = MikSBT.ScrollDown(animDisplayInfo, scrollArea);

 -- Calculate the animation midpoint.
 local animationMidPoint = scrollArea.DisplaySettings.ScrollHeight / 2;

 -- Calculate the new x position based on equation of a parabola.
 -- Equation of a parabola at vertex 0,0: x = y^2 / 4a
 local parabolaMaxX = math_ceil((animationMidPoint * animationMidPoint) / (4 * animationMidPoint));
 local parabolaY = animDisplayInfo.PositionY - animationMidPoint;
 local newX = parabolaMaxX - math_ceil((parabolaY * parabolaY) / (4 * animationMidPoint));

 -- Set the new x position.
 animDisplayInfo.PositionX = newX * -1;

 -- Return whether or not the animation is complete.
 return animationComplete;
end


-- **********************************************************************************
-- Moves the passed animation display info in a right parabolic shape going upwards.
-- Returns true when the animation is complete.
-- **********************************************************************************
function MikSBT.ScrollRightParabolaUp(animDisplayInfo, scrollArea)
 -- Scroll the animation display info straight up and set the alpha correctly.
 local animationComplete = MikSBT.ScrollUp(animDisplayInfo, scrollArea);

 -- Calculate the animation midpoint.
 local animationMidPoint = scrollArea.DisplaySettings.ScrollHeight / 2;

 -- Calculate the new x position based on equation of a parabola.
 -- Equation of a parabola at vertex 0,0: x = y^2 / 4a
 local parabolaMaxX = math_ceil((animationMidPoint * animationMidPoint) / (4 * animationMidPoint));
 local parabolaY = animDisplayInfo.PositionY - animationMidPoint;
 local newX = parabolaMaxX - math_ceil((parabolaY * parabolaY) / (4 * animationMidPoint));

 -- Set the new x position.
 animDisplayInfo.PositionX = newX;

 -- Return whether or not the animation is complete.
 return animationComplete;
end


-- **********************************************************************************
-- Moves the passed animation display info in a right parabolic shape going downwards.
-- Returns true when the animation is complete.
-- **********************************************************************************
function MikSBT.ScrollRightParabolaDown(animDisplayInfo, scrollArea)
 -- Scroll the animation display info straight up and set the alpha correctly.
 local animationComplete = MikSBT.ScrollDown(animDisplayInfo, scrollArea);

 -- Calculate the animation midpoint.
 local animationMidPoint = scrollArea.DisplaySettings.ScrollHeight / 2;

 -- Calculate the new x position based on equation of a parabola.
 -- Equation of a parabola at vertex 0,0: x = y^2 / 4a
 local parabolaMaxX = math_ceil((animationMidPoint * animationMidPoint) / (4 * animationMidPoint));
 local parabolaY = animDisplayInfo.PositionY - animationMidPoint;
 local newX = parabolaMaxX - math_ceil((parabolaY * parabolaY) / (4 * animationMidPoint));

 -- Set the new x position.
 animDisplayInfo.PositionX = newX;

 -- Return whether or not the animation is complete.
 return animationComplete;
end


-------------------------------------------------------------------------------------
-- Command handler functions.
-------------------------------------------------------------------------------------

-- **********************************************************************************
-- Returns the current and remaining parameters from the passed string.
-- **********************************************************************************
function MikSBT.GetNextParameter(paramString)
 local remainingParams;
 local currentParam = paramString;

 -- Look for a space.
 local idx = string_find(paramString, " ");

 if (idx) then
  -- Get the current and remaing parameters.
  currentParam = string.sub(paramString, 1, idx-1);
  remainingParams = string.sub(paramString, idx+1);
 end

 -- Return the current parameter and the remaining ones.
 return currentParam, remainingParams;
end


-- **********************************************************************************
-- Called to handle commands.
-- **********************************************************************************
function MikSBT.CommandHandler(params)
 -- Get the parameter.
 local currentParam;
 local remainingParams;
 currentParam, remainingParams = MikSBT.GetNextParameter(params);

 -- Flag for whether or not to show usage info.
 local showUsage = true;

 -- Make sure there is a current parameter and lower case it.
 if (currentParam) then
  currentParam = string.lower(currentParam);
 end

 -- Look for the recognized parameters.
 if (currentParam == "") then
  if (MSBTFrameOptions) then
   if (MSBTFrameOptions:IsShown()) then
    MSBTFrameOptions:Hide();
   else
    if (MSBTScrollAreaMoverControlFrame and not MSBTScrollAreaMoverControlFrame:IsShown()) or (not MSBTScrollAreaMoverControlFrame) then
     MSBTFrameOptions:Show();
    end
   end
  end

  -- Don't show the usage info.
  showUsage = false;

 elseif (currentParam == MikSBT.COMMAND_RESET) then
  -- Reset the current profile.
  MikSBT.ResetProfile(MikSBT_Save.CurrentProfile, true);

  -- Don't show the usage info.
  showUsage = false;

 elseif (currentParam == MikSBT.COMMAND_DISABLE) then
  -- Set the user disabled option.
  MikSBT.SetOptionUserDisabled(true);

  -- Output an informative message.
  MikSBT.Print(MikSBT.MSG_DISABLE, 1,1,1);

  -- Don't show the usage info.
  showUsage = false;

 elseif (currentParam == MikSBT.COMMAND_ENABLE) then
  -- Unset the user disabled option.
  MikSBT.SetOptionUserDisabled(false);

  -- Output an informative message.
  MikSBT.Print(MikSBT.MSG_ENABLE, 1,1,1);

  -- Don't show the usage info.
  showUsage = false;

 elseif (currentParam == MikSBT.COMMAND_SHOWVER) then
  -- Output the current version number.
  MikSBT.Print(MikSBT.VERSION_STRING, 1,1,1);

  -- Don't show the usage info.
  showUsage = false;

 elseif (currentParam == MikSBT.COMMAND_SEARCH) then
  -- Check if there is any filter text
  if (remainingParams and remainingParams ~= "") then
   -- Turn on event searching mode.
   MikCEH.EnableEventSearching(remainingParams);
   MikSBT.Print(MikSBT.MSG_SEARCH_ENABLE .. remainingParams, 1, 1, 1);
  else
   -- Turn off event searching mode.
   MikCEH.DisableEventSearching();
   MikSBT.Print(MikSBT.MSG_SEARCH_DISABLE, 1, 1, 1);
  end

  -- Don't show the usage info.
  showUsage = false;

 end

 -- Check if the usage information should be shown.
 if (showUsage) then
  MikSBT.PrintUsage();
 end
end


-- **********************************************************************************
-- Prints out the usage information.
-- **********************************************************************************
function MikSBT.PrintUsage()
 -- Loop through all of the entries in the command usage list.
 for _, msg in MikSBT.COMMAND_USAGE do
  MikSBT.Print(msg, 1, 1, 1);
 end
end



-------------------------------------------------------------------------------------
-- Public Access functions.
-------------------------------------------------------------------------------------

-- **********************************************************************************
-- Displays the passed message in the passed scroll area with the passed parameters.
-- This function is for easy displaying of messages from external sources.
-- **********************************************************************************
function MikSBT.DisplayMessage(message, displayType, isSticky, colorR, colorG, colorB, fontSize, fontIndex, outlineIndex, Texture)
 if not MikSBT.CurrentProfile or (MikSBT_Save and MikSBT_Save.UserDisabled) then return end;
 -- Check if no message was passed and do nothing.
 if (message == nil) then
  return;
 end

 -- Check if the passed display type is invalid..
 if (displayType ~= MikSBT.DISPLAYTYPE_INCOMING and displayType ~= MikSBT.DISPLAYTYPE_OUTGOING and
     displayType ~= MikSBT.DISPLAYTYPE_NOTIFICATION) then

  -- Set the display type to the default.
  displayType = MikSBT.DISPLAYTYPE_NOTIFICATION;
 end

 -- Get the correct scroll area for the event.
 local scrollArea;
 if (displayType == MikSBT.DISPLAYTYPE_INCOMING) then
  scrollArea = scrollAreas.Incoming;  
 elseif (displayType == MikSBT.DISPLAYTYPE_OUTGOING) then
  scrollArea = scrollAreas.Outgoing;
 elseif (displayType == MikSBT.DISPLAYTYPE_NOTIFICATION) then
  scrollArea = scrollAreas.Notification;
 end

 -- Check if the scroll area is hiding events.
 if (not scrollArea.DisplaySettings.Show) then
  return;
 end

 -- Check if the red color value is invalid.
 if (colorR == nil or colorR < 0 or colorR > 255) then
  -- Set the red color value to the default.
  colorR = 255;
 end

 -- Check if the green color value is invalid.
 if (colorG == nil or colorG < 0 or  colorG > 255) then
  -- Set the green color value to the default.
  colorG = 255;
 end

 -- Check if the blue color value is invalid.
 if (colorB == nil or colorB < 0 or  colorB > 255) then
  -- Set the blue color value to the default.
  colorB = 255;
 end

 -- Check if the font size is invalid.
 if (fontSize == nil or fontSize < 12 or fontSize > 64) then
  fontSize = MikSBT.GetFontSize(scrollArea, nil, false);
 end

 local fontPath;
 -- Check if the font index in invalid.
 if (fontIndex == nil or MikSBT.AVAILABLE_FONTS[fontIndex] == nil) then
  fontPath = MikSBT.GetFontPath(scrollArea, nil, false);
 -- Font index is valid.
 else
  fontPath = MikSBT.AVAILABLE_FONTS[fontIndex].Path;
 end

 local fontOutline;
 -- Check if the outline index in invalid.
 if (outlineIndex == nil or MikSBT.AVAILABLE_OUTLINES[outlineIndex] == nil) then
  fontOutline = MikSBT.GetFontOutline(scrollArea, nil, false);
 else
  fontOutline = MikSBT.AVAILABLE_OUTLINES[outlineIndex].Style;
 end


 -- Get a recycled table from the events recycler object.
 local animationEvent = eventsRecycler:AcquireTable();

 -- Populate the animation event data.
 animationEvent.ScrollArea = scrollArea;
 animationEvent.IsCrit = false;
 animationEvent.IsSticky = isSticky;
 animationEvent.Text = message;
 animationEvent.FontSize = fontSize;
 animationEvent.FontPath = fontPath;
 animationEvent.FontOutline = fontOutline;
 -- The public interface takes 0-255 channels; FontString:SetTextColor takes 0-1.
 animationEvent.ColorR = colorR / 255;
 animationEvent.ColorG = colorG / 255;
 animationEvent.ColorB = colorB / 255;
 animationEvent.Texture = Texture;


 -- Add the event to the animation system.
 MikSBT.AddAnimation(animationEvent);
end
