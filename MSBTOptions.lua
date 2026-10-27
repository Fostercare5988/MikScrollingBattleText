-------------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text: settings window (ForgeUI)
-- Author: Mik, Fostercare5988
-- Maintainer: Fostercare5988
-------------------------------------------------------------------------------------

-- ClassicAPIRequirement.lua checks the DLLs.
if not MSBT_REQUIREMENTS_MET then return end

local addonName, ns = ...
local UI = ns.UI

local WIDTH = 600
local ROWS_PER_PAGE = 10
local AREAS = {"Incoming", "Outgoing", "Notification"}
local AREA_LABELS = {Incoming = "Incoming", Outgoing = "Outgoing", Notification = "Notices"}

local panel, ShowTab, fontEditor, triggerEditor
local refresh = {}
local selectedArea = "Incoming"
local moversShown = false

local function Profile() return MikSBT.CurrentProfile end

local function Count(t)
 local n = 0
 for _ in pairs(t) do n = n + 1 end
 return n
end

-- Sorted keys, so list rows keep their order between refreshes.
local function SortedKeys(t)
 local keys = {}
 for key in pairs(t) do table.insert(keys, key) end
 table.sort(keys)
 return keys
end

-------------------------------------------------------------------------------------
-- Small widgets on top of the kit: text box, color swatch, cycle, pager.
-------------------------------------------------------------------------------------

local function TextBox(name, parent, x, y, width, onAccept)
 local box = CreateFrame("EditBox", name, parent)
 box:SetWidth(width); box:SetHeight(20)
 box:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
 box:SetAutoFocus(false)
 box:SetFontObject(GameFontHighlightSmall)
 box:SetTextInsets(6, 6, 0, 0)
 UI.Rounded(box, "BACKGROUND", 6, UI.track)
 box:SetScript("OnEscapePressed", function() box:ClearFocus() end)
 box:SetScript("OnEnterPressed", function()
  box:ClearFocus()
  if onAccept then onAccept(box:GetText()) end
 end)
 return box
end

local function Swatch(name, parent, onClick)
 local button = CreateFrame("Button", name, parent)
 button:SetWidth(16); button:SetHeight(16)
 button:RegisterForClicks("LeftButtonUp")
 UI.Disc(button, "BACKGROUND", 16, UI.edge):SetPoint("CENTER", button, "CENTER", 0, 0)
 button.fill = UI.Disc(button, "ARTWORK", 12, UI.white)
 button.fill:SetPoint("CENTER", button, "CENTER", 0, 0)
 UI.Disc(button, "HIGHLIGHT", 22, UI.halo):SetPoint("CENTER", button, "CENTER", 0, 0)
 button:SetScript("OnClick", onClick)
 return button
end

local function PaintSwatch(button, color)
 button.fill:SetVertexColor(color.r, color.g, color.b, 1)
end

-- "<  value  >": onStep(-1 or 1) changes the value; the mouse wheel steps too.
local function Cycle(name, parent, x, y, width, onStep)
 local frame = CreateFrame("Frame", name, parent)
 frame:SetWidth(width); frame:SetHeight(22)
 frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
 UI.Rounded(frame, "BACKGROUND", 11, UI.track)
 local style = {ghost = true}
 UI.Button(name .. "Prev", frame, "<", 2, 0, 24, function() onStep(-1) end, style)
 local nextButton = UI.Button(name .. "Next", frame, ">", width - 26, 0, 24, function() onStep(1) end, style)
 frame.text = frame:CreateFontString(name .. "Text", "OVERLAY", "GameFontHighlightSmall")
 frame.text:SetPoint("LEFT", frame, "LEFT", 28, 0)
 frame.text:SetPoint("RIGHT", nextButton, "LEFT", -2, 0)
 UI.Color(frame.text, "text")
 frame:EnableMouseWheel(true)
 frame:SetScript("OnMouseWheel", function() onStep(arg1 > 0 and -1 or 1) end)
 return frame
end

local function Pager(name, parent, onPage)
 local pager = {page = 1, pages = 1}
 local text = parent:CreateFontString(name .. "Text", "OVERLAY", "GameFontDisableSmall")
 text:SetPoint("BOTTOM", parent, "BOTTOM", 0, 22)
 UI.Color(text, "hint")
 local style = {ghost = true}
 local prev = UI.Button(name .. "Prev", parent, "<", 0, 0, 24, function() onPage(-1) end, style)
 prev:ClearAllPoints(); prev:SetPoint("RIGHT", text, "LEFT", -8, 0)
 local nextButton = UI.Button(name .. "Next", parent, ">", 0, 0, 24, function() onPage(1) end, style)
 nextButton:ClearAllPoints(); nextButton:SetPoint("LEFT", text, "RIGHT", 8, 0)
 function pager:Set(total)
  self.pages = math.max(1, math.ceil(total / ROWS_PER_PAGE))
  if self.page > self.pages then self.page = self.pages end
  if self.page < 1 then self.page = 1 end
  text:SetText("Page " .. self.page .. " of " .. self.pages)
  UI.SetEnabled(prev, self.page > 1)
  UI.SetEnabled(nextButton, self.page < self.pages)
  return (self.page - 1) * ROWS_PER_PAGE
 end
 return pager
end

-- One text box shared by every list: it opens over the clicked message,
-- Enter saves, Escape or leaving the box keeps the old text.
local inlineEdit, inlineAccept
local function EditInline(anchor, text, onAccept)
 inlineAccept = onAccept
 inlineEdit:SetParent(anchor:GetParent())
 inlineEdit:ClearAllPoints()
 inlineEdit:SetPoint("LEFT", anchor, "LEFT", -4, 0)
 inlineEdit:SetWidth(anchor:GetWidth() + 8)
 inlineEdit:SetFrameLevel(anchor:GetFrameLevel() + 5)
 inlineEdit:SetText(text or "")
 inlineEdit:Show()
 inlineEdit:SetFocus()
end

local function MessageButton(name, parent, x, width, onClick)
 local button = UI.Button(name, parent, "", x, -2, width, onClick, {ghost = true})
 local label = button:GetFontString()
 label:ClearAllPoints()
 label:SetPoint("LEFT", button, "LEFT", 6, 0)
 label:SetPoint("RIGHT", button, "RIGHT", -6, 0)
 label:SetJustifyH("LEFT")
 return button
end

-------------------------------------------------------------------------------------
-- Color picker. ColorPickerFrame is shared by every addon: MSBT remembers which
-- profile and color it opened for, so a late callback never writes elsewhere.
-------------------------------------------------------------------------------------

local pickerOwner

local function ApplyPickedColor(owner, r, g, b)
 owner.color.r, owner.color.g, owner.color.b = r, g, b
 if owner.profile == Profile() then PaintSwatch(owner.swatch, owner.color) end
end

function MikSBTOpt.OnPickerColor()
 local owner = pickerOwner
 if not owner or owner.profile ~= Profile() then return end
 ApplyPickedColor(owner, ColorPickerFrame:GetColorRGB())
end

function MikSBTOpt.OnPickerCancel()
 local owner = pickerOwner
 if not owner then return end
 pickerOwner = nil
 ApplyPickedColor(owner, owner.previous.r, owner.previous.g, owner.previous.b)
end

-- Closes MSBT's picker. restore puts the original color back (profile load,
-- reset, delete); otherwise the chosen color stays (closing the window).
-- Another addon's open picker is never touched.
function MikSBTOpt.RetireColorPicker(restore)
 local owner = pickerOwner
 if not owner then return end
 pickerOwner = nil
 if ColorPickerFrame:IsShown() and ColorPickerFrame.func == MikSBTOpt.OnPickerColor then
  HideUIPanel(ColorPickerFrame)
  if restore then ApplyPickedColor(owner, owner.previous.r, owner.previous.g, owner.previous.b) end
 end
end

local function PickColor(swatch, color)
 MikSBTOpt.RetireColorPicker(false)
 pickerOwner = {profile = Profile(), color = color, swatch = swatch,
  previous = {r = color.r, g = color.g, b = color.b}}
 ColorPickerFrame.func = MikSBTOpt.OnPickerColor
 ColorPickerFrame.cancelFunc = MikSBTOpt.OnPickerCancel
 ColorPickerFrame.opacityFunc = nil
 ColorPickerFrame.hasOpacity = nil
 ColorPickerFrame.previousValues = pickerOwner.previous
 ColorPickerFrame:SetColorRGB(color.r, color.g, color.b)
 ShowUIPanel(ColorPickerFrame)
end

-------------------------------------------------------------------------------------
-- Font editor: font, outline and size for normal and critical text. 0 means
-- inherit from the next table in the chain (event -> area -> master).
-------------------------------------------------------------------------------------

local OUTLINE_LABELS = {"None", "Thin", "Thick"}
local OUTLINE_LABELS_INHERIT = {"Inherit", "None", "Thin", "Thick"}

local function Resolve(chain, kind, field)
 for _, settings in ipairs(chain) do
  local fs = settings[kind]
  if fs and fs[field] and fs[field] ~= 0 then return fs[field] end
 end
end

local function CreateFontEditor()
 local editor = UI.Window("MSBT_FontEditor", "Fonts", 420, 330)
 editor:SetPoint("TOP", UIParent, "CENTER", 260, 190)
 editor.sections = {}

 local function Section(kind, y)
  local s = {kind = kind}
  s.heading = UI.Heading(editor, kind == "Crit" and "Critical hits" or "Normal hits", 28, y)
  s.font = Cycle("MSBT_Font" .. kind .. "Face", editor, 28, y - 22, 220, function(step)
   local fs = editor.target.own[kind]
   local low = editor.target.inherit and 0 or 1
   local value = (fs.FontIndex or 0) + step
   if value > table.getn(MikSBT.AVAILABLE_FONTS) then value = low elseif value < low then value = table.getn(MikSBT.AVAILABLE_FONTS) end
   fs.FontIndex = value
   editor.Changed()
  end)
  s.outlineButtons, s.SelectOutline, s.outlineTrack = UI.Segmented("MSBT_Font" .. kind .. "Outline", editor,
   OUTLINE_LABELS_INHERIT, 264, y - 22, 128, function(index)
    local fs = editor.target.own[kind]
    fs.OutlineIndex = editor.target.inherit and index - 1 or index
    editor.Changed()
   end, {height = 22})
  s.outlineButtons3, s.SelectOutline3, s.outlineTrack3 = UI.Segmented("MSBT_Font" .. kind .. "Outline3", editor,
   OUTLINE_LABELS, 264, y - 22, 128, function(index)
    editor.target.own[kind].OutlineIndex = index
    editor.Changed()
   end, {height = 22})
  s.inherit = UI.Switch("MSBT_Font" .. kind .. "InheritSize", editor, "Inherit size",
   "Use the size of the area or master font.", 28, y - 56, function(value)
    local fs = editor.target.own[kind]
    fs.FontSize = value and 0 or (Resolve(editor.target.chain, kind, "FontSize") or 18)
    editor.Changed()
   end, 110)
  s.size = UI.Slider("MSBT_Font" .. kind .. "Size", editor, "Size", 160, y - 54, 232, 12, 64, 2, function(value)
   editor.target.own[kind].FontSize = value
   editor.Changed(true)
  end)
  s.preview = editor:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  s.preview:SetPoint("TOPLEFT", editor, "TOPLEFT", 28, y - 92)
  s.preview:SetText(kind == "Crit" and "12345 Crit!" or "1234 Normal")
  editor.sections[kind] = s
  return s
 end
 Section("Normal", -56)
 Section("Crit", -186)
 editor.note = UI.Label(editor, "The game damage font changes after you log in again.", 28, -90, "GameFontDisableSmall")

 local function ShowSection(s, shown)
  local widgets = {s.heading, s.font, s.outlineTrack, s.outlineTrack3, s.inherit, s.inherit.label, s.size, s.size.label, s.size.valueText, s.preview}
  for _, w in ipairs(widgets) do if shown then w:Show() else w:Hide() end end
 end

 function editor.Refresh()
  local target = editor.target
  for _, kind in ipairs({"Normal", "Crit"}) do
   local s, fs = editor.sections[kind], target.own[kind]
   ShowSection(s, fs ~= nil)
   if fs then
    local index = fs.FontIndex or 0
    local face = MikSBT.AVAILABLE_FONTS[index]
    local resolved = MikSBT.AVAILABLE_FONTS[Resolve(target.chain, kind, "FontIndex") or 1] or MikSBT.AVAILABLE_FONTS[1]
    s.font.text:SetText(face and face.Name or ("Inherit: " .. resolved.Name))
    if target.blizzard then
     s.outlineTrack:Hide(); s.outlineTrack3:Hide(); s.inherit:Hide(); s.inherit.label:Hide()
     s.size:Hide(); s.size.label:Hide(); s.size.valueText:Hide()
    elseif target.inherit then
     s.outlineTrack3:Hide(); s.SelectOutline((fs.OutlineIndex or 0) + 1)
     UI.Sync(s.inherit, (fs.FontSize or 0) == 0)
    else
     s.outlineTrack:Hide(); s.SelectOutline3(fs.OutlineIndex or 1)
     s.inherit:Hide(); s.inherit.label:Hide()
    end
    local size = Resolve(target.chain, kind, "FontSize") or 18
    if not target.blizzard then
     UI.SetSlider(s.size, size)
     UI.SetEnabled(s.size, not target.inherit or (fs.FontSize or 0) ~= 0)
    end
    local outline = MikSBT.AVAILABLE_OUTLINES[Resolve(target.chain, kind, "OutlineIndex") or 1] or MikSBT.AVAILABLE_OUTLINES[1]
    s.preview:SetFont(resolved.Path, target.blizzard and 18 or size, outline.Style)
   end
  end
  if target.blizzard then editor.note:Show() else editor.note:Hide() end
  editor:SetHeight(target.own.Crit and 330 or (target.blizzard and 130 or 200))
 end

 -- sizeOnly: a slider drag; the slider already shows the value.
 function editor.Changed(sizeOnly)
  if editor.target.blizzard then MikSBT.ApplyGameDamageFont() end
  editor.Refresh()
 end
 return editor
end

-- target: title, own = {Normal=..., Crit=...}, chain = font tables to resolve
-- through (own first), inherit = whether 0 (inherit) is allowed, blizzard.
local function EditFonts(target)
 if not fontEditor then fontEditor = CreateFontEditor() end
 fontEditor.target = target
 fontEditor.title:SetText(target.title)
 fontEditor.Refresh()
 fontEditor:Show()
end
MikSBTOpt.EditFonts = EditFonts

local function MasterChain()
 return {Profile().MasterFontSettings}
end

local function AreaChain(area)
 return {Profile().DisplaySettings[area].FontSettings, Profile().MasterFontSettings}
end

function MikSBTOpt.EditEventFonts(area, eventType)
 local settings = Profile().EventSettings[eventType].FontSettings
 local chain = AreaChain(area)
 table.insert(chain, 1, settings)
 EditFonts({title = eventType, own = {Normal = settings.Normal, Crit = settings.Crit}, chain = chain, inherit = true})
end

-------------------------------------------------------------------------------------
-- General tab.
-------------------------------------------------------------------------------------

local function BuildGeneral(page)
 local switches = {}
 UI.Heading(page, "Display", 28, -98)
 local enabled = UI.Switch("MSBT_Enabled", page, "Enable MSBT", "Show scrolling combat text.", 28, -122, function(value)
  MikSBT.SetOptionUserDisabled(not value)
  refresh[1]()
 end)
 local function ProfileSwitch(key, text, tip, x, y, after)
  switches[key] = UI.Switch("MSBT_" .. key, page, text, tip, x, y, function(value)
   Profile()[key] = value
   if after then after(value) end
  end)
 end
 ProfileSwitch("ShowPartialEffects", "Partial effects", "Add absorbed, blocked, resisted, crushing and glancing amounts.", 28, -158)
 ProfileSwitch("UseStickyCrits", "Sticky criticals", "Critical hits pop in the middle of the area instead of scrolling.", 28, -194)
 ProfileSwitch("ShowAllManaGains", "All mana gains", "Show every mana increase, including regeneration and drinking.", 28, -230, function(value)
  -- Mana is not observed while this is off; start from the current amount.
  if value then MikCEH.ResetManaBaseline() end
 end)
 local gameDamage = UI.Switch("MSBT_ShowGameDamage", page, "Game damage text", "Keep the game's own damage numbers above enemies.", 28, -266, function(value)
  MikSBT.SetOptionShowGameDamage(value)
 end)

 UI.Heading(page, "Sounds", 264, -98)
 ProfileSwitch("LowHealthSound", "Low health", "Play a sound when a low health trigger fires.", 264, -122)
 ProfileSwitch("LowManaSound", "Low mana", "Play a sound when a low mana trigger fires.", 264, -158)
 ProfileSwitch("ResistSound", "Frost resists", "Play a sound when your Cone of Cold or Frost Nova is resisted.", 264, -194)

 local speed = UI.Slider("MSBT_AnimationStep", page, "Scroll speed", 28, -310, 210, 1, 5, 0.5, function(value)
  Profile().AnimationStep = value
 end)

 UI.Button("MSBT_MasterFonts", page, "Fonts", 300, -306, 172, function()
  local fonts = Profile().MasterFontSettings
  EditFonts({title = "Master fonts", own = {Normal = fonts.Normal, Crit = fonts.Crit}, chain = MasterChain(), inherit = false})
 end)
 UI.Button("MSBT_GameDamageFont", page, "Game damage font", 300, -336, 172, function()
  local fonts = Profile().BlizzardFontSettings
  EditFonts({title = "Game damage font", own = {Normal = fonts.Normal}, chain = {fonts}, inherit = false, blizzard = true})
 end)

 return function()
  local enabledNow = not MikSBT_Save.UserDisabled
  UI.Sync(enabled, enabledNow)
  for key, widget in pairs(switches) do UI.Sync(widget, Profile()[key], enabledNow) end
  UI.Sync(gameDamage, Profile().ShowGameDamage, enabledNow)
  UI.SetSlider(speed, Profile().AnimationStep)
 end
end

-------------------------------------------------------------------------------------
-- Areas tab: layout of the three scroll areas, movers and preview.
-------------------------------------------------------------------------------------

local movers = {}

local function PlaceMover(area)
 local settings = Profile().DisplaySettings[area]
 local mover = movers[area]
 mover:ClearAllPoints()
 mover:SetPoint("BOTTOM", UIParent, "CENTER", settings.FrameOffsets.x, settings.FrameOffsets.y)
 mover:SetHeight(settings.ScrollHeight)
 mover.label:SetText(AREA_LABELS[area] .. " (" .. settings.FrameOffsets.x .. ", " .. settings.FrameOffsets.y .. ")")
end

local function CreateMover(area)
 local mover = CreateFrame("Frame", "MSBT_Mover" .. area, UIParent)
 mover:SetWidth(80)
 mover:SetFrameStrata("DIALOG")
 mover:EnableMouse(true); mover:SetMovable(true); mover:SetClampedToScreen(true)
 mover:RegisterForDrag("LeftButton")
 UI.Rounded(mover, "BACKGROUND", 8, UI.selected)
 mover.label = mover:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 mover.label:SetPoint("BOTTOM", mover, "TOP", 0, 4)
 UI.Color(mover.label, "heading")
 mover:SetScript("OnDragStart", function() mover:StartMoving() end)
 mover:SetScript("OnDragStop", function()
  mover:StopMovingOrSizing()
  local centerX, centerY = UIParent:GetCenter()
  local offsets = Profile().DisplaySettings[area].FrameOffsets
  offsets.x = math.floor(mover:GetCenter() - centerX)
  offsets.y = math.ceil(mover:GetBottom() - centerY)
  MikSBT.RepositionAnimationFrames()
  PlaceMover(area)
 end)
 mover:Hide()
 movers[area] = mover
end

local function ShowMovers(shown)
 moversShown = shown
 for _, area in ipairs(AREAS) do
  if not movers[area] then CreateMover(area) end
  if shown then PlaceMover(area); movers[area]:Show() else movers[area]:StopMovingOrSizing(); movers[area]:Hide() end
 end
end

local function BuildAreas(page)
 local areaButtons, SelectArea = UI.Segmented("MSBT_Area", page, {"Incoming", "Outgoing", "Notices"}, 28, -98, 300, function(index)
  selectedArea = AREAS[index]
  refresh[2]()
 end, {height = 26})
 local function Settings() return Profile().DisplaySettings[selectedArea] end
 local show = UI.Switch("MSBT_AreaShow", page, "Show this area", "Show the events of this area.", 352, -104, function(value)
  Settings().Show = value
 end)

 UI.Heading(page, "Movement", 28, -144)
 local _, SelectStyle = UI.Segmented("MSBT_AreaStyle", page, {"Straight", "Curve left", "Curve right"}, 28, -164, 300, function(index)
  Settings().AnimationStyle = index
  refresh[2]()
 end, {height = 24})
 local _, SelectDirection = UI.Segmented("MSBT_AreaDirection", page, {"Up", "Down"}, 352, -164, 120, function(index)
  Settings().ScrollDirection = index
  refresh[2]()
 end, {height = 24})
 UI.Heading(page, "Text", 28, -204)
 local _, SelectAlign = UI.Segmented("MSBT_AreaAlign", page, {"Left", "Center", "Right"}, 28, -224, 300, function(index)
  Settings().FontSettings.TextAlignIndex = index
  refresh[2]()
 end, {height = 24})
 local height = UI.Slider("MSBT_AreaHeight", page, "Scroll height", 28, -264, 300, 100, 600, 10, function(value)
  Settings().ScrollHeight = value
  if moversShown then PlaceMover(selectedArea) end
 end)

 local unlock = UI.Button("MSBT_AreaUnlock", page, "Move areas", 352, -264, 120, function()
  ShowMovers(not moversShown)
  refresh[2]()
 end)
 UI.Button("MSBT_AreaPreview", page, "Preview", 352, -294, 120, function()
  MikSBT.DisplayMessage("Incoming", MikSBT.DISPLAYTYPE_INCOMING, false, 255, 80, 80)
  MikSBT.DisplayMessage("Outgoing", MikSBT.DISPLAYTYPE_OUTGOING, false, 255, 255, 255)
  MikSBT.DisplayMessage("Notices", MikSBT.DISPLAYTYPE_NOTIFICATION, false, 255, 220, 120)
 end)
 UI.Button("MSBT_AreaFonts", page, "Area fonts", 352, -324, 120, function()
  local fonts = Profile().DisplaySettings[selectedArea].FontSettings
  EditFonts({title = AREA_LABELS[selectedArea] .. " fonts", own = {Normal = fonts.Normal, Crit = fonts.Crit},
   chain = AreaChain(selectedArea), inherit = true})
 end)
 UI.Button("MSBT_AreaReset", page, "Reset positions", 28, -324, 140, function()
  for _, area in ipairs(AREAS) do
   local default = MikSBT.DEFAULT_CONFIG.DisplaySettings[area].FrameOffsets
   Profile().DisplaySettings[area].FrameOffsets.x = default.x
   Profile().DisplaySettings[area].FrameOffsets.y = default.y
  end
  MikSBT.RepositionAnimationFrames()
  if moversShown then ShowMovers(true) end
 end)
 UI.Label(page, "Move areas shows a handle per area; drag it to place the area.", 28, -362, "GameFontDisableSmall")

 return function()
  local settings = Settings()
  for i, area in ipairs(AREAS) do if area == selectedArea then SelectArea(i) end end
  UI.Sync(show, settings.Show)
  SelectStyle(settings.AnimationStyle)
  SelectDirection(settings.ScrollDirection)
  SelectAlign(settings.FontSettings.TextAlignIndex)
  UI.SetSlider(height, settings.ScrollHeight)
  UI.Select(unlock, moversShown)
 end
end

-------------------------------------------------------------------------------------
-- Incoming, Outgoing and Notices tabs: one row per event.
-------------------------------------------------------------------------------------

local function BuildEvents(page, area, tab)
 local rows, pager = {}, nil
 local prefix = "MSBT_" .. area .. "Row"
 UI.Heading(page, "Show / Color / Message (click to edit) / Font", 28, -98)
 for i = 1, ROWS_PER_PAGE do
  local row = UI.Row(prefix .. i, page, 28, -118 - (i - 1) * 28, WIDTH - 56)
  row.show = UI.Switch(prefix .. i .. "Show", row, "", nil, 4, -5, function(value)
   Profile().EventSettings[row.eventType].Show = value
  end, 150)
  row.swatch = Swatch(prefix .. i .. "Color", row, function()
   PickColor(row.swatch, Profile().EventSettings[row.eventType].FontSettings.Color)
  end)
  row.swatch:SetPoint("LEFT", row, "LEFT", 190, 0)
  row.message = MessageButton(prefix .. i .. "Message", row, 214, 220, function()
   EditInline(row.message, Profile().EventSettings[row.eventType].Message, function(text)
    Profile().EventSettings[row.eventType].Message = text
    refresh[tab]()
   end)
  end)
  if area == "Notification" then
   row.sticky = UI.Button(prefix .. i .. "Sticky", row, "Sticky", 438, -2, 52, function()
    local settings = Profile().EventSettings[row.eventType]
    settings.IsSticky = not settings.IsSticky
    refresh[tab]()
   end, {ghost = true})
   UI.Tooltip(row.sticky, "Pop this event in the middle of the area instead of scrolling it.")
  end
  row.font = UI.Button(prefix .. i .. "Font", row, "Font", 494, -2, 44, function()
   MikSBTOpt.EditEventFonts(area, row.eventType)
  end, {ghost = true})
  rows[i] = row
 end
 pager = Pager(prefix .. "Pager", page, function(step) pager.page = pager.page + step; refresh[tab]() end)

 return function()
  local list = MikSBTOpt.EVENTS[area]
  local offset = pager:Set(table.getn(list))
  for i, row in ipairs(rows) do
   local entry = list[offset + i]
   if entry then
    local settings = Profile().EventSettings[entry.Type]
    row.eventType = entry.Type
    row.show.label:SetText(entry.Label)
    UI.Tooltip(row.show, entry.Tip)
    UI.Tooltip(row.message, entry.Codes)
    UI.Sync(row.show, settings.Show)
    PaintSwatch(row.swatch, settings.FontSettings.Color)
    row.message:SetText(settings.Message or "")
    if row.sticky then UI.Select(row.sticky, settings.IsSticky and true or false) end
    row:Show()
   else
    row:Hide()
   end
  end
 end
end

-------------------------------------------------------------------------------------
-- Trigger editor: works on a copy and writes it on Save.
-------------------------------------------------------------------------------------

local CLASSES = {"DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"}
local CLASS_LABELS = {DRUID = "Druid", HUNTER = "Hunter", MAGE = "Mage", PALADIN = "Paladin", PRIEST = "Priest",
 ROGUE = "Rogue", SHAMAN = "Shaman", WARLOCK = "Warlock", WARRIOR = "Warrior"}
local function CopyTable(t)
 return type(t) == "table" and MikSBT.CopyTable(t) or t
end

local function CreateTriggerEditor()
 local editor = UI.Window("MSBT_TriggerEditor", "Trigger", 460, 360)
 editor:SetPoint("TOP", UIParent, "CENTER", 280, 190)
 local work

 UI.Heading(editor, "Type", 28, -56)
 editor.type = Cycle("MSBT_TriggerType", editor, 28, -74, 220, function(step)
  local types = MikSBT.AVAILABLE_TRIGGER_TYPES
  local count, index = table.getn(types), 1
  for i, info in ipairs(types) do if info.Type == work.TriggerType then index = i end end
  work.TriggerType = types[(index - 1 + step + count) % count + 1].Type
  editor.Refresh()
 end)
 UI.Heading(editor, "Icon", 264, -56)
 editor.icon = TextBox("MSBT_TriggerIcon", editor, 264, -75, 168)
 UI.Tooltip(editor.icon, "Path of an icon to show, such as Interface\\Icons\\Ability_Warrior_Charge. Leave empty for none.")

 UI.Heading(editor, "Classes", 28, -108)
 editor.allClasses = UI.Switch("MSBT_TriggerAllClasses", editor, "All classes", nil, 28, -126, function(value)
  if value then work.Classes = nil else work.Classes = {} end
  editor.Refresh()
 end, 110)
 editor.classes = {}
 for i, class in ipairs(CLASSES) do
  local key = class
  local col, line = (i - 1) % 3, math.floor((i - 1) / 3)
  editor.classes[key] = UI.Switch("MSBT_TriggerClass" .. key, editor, CLASS_LABELS[key], nil, 28 + col * 136, -154 - line * 24, function(value)
   work.Classes[key] = value or nil
  end, 100)
 end

 local y = -236
 editor.thresholdHeading = UI.Heading(editor, "Threshold", 28, y)
 editor.threshold = UI.Slider("MSBT_TriggerThreshold", editor, "Below this percent", 28, y - 20, 404, 1, 100, 1, function(value)
  work.Threshold = value
 end)
 editor.auraHeading = UI.Heading(editor, "Aura name", 28, y)
 editor.aura = TextBox("MSBT_TriggerAura", editor, 28, y - 18, 404)
 UI.Tooltip(editor.aura, "The exact name of the buff, for example Clearcasting.")
 editor.stanceHeading = UI.Heading(editor, "Stance or form", 28, y - 48)
 editor.stance = Cycle("MSBT_TriggerStance", editor, 28, y - 66, 404, function(step)
  local count = table.getn(MikSBT.AVAILABLE_STANCES)
  work.Stance = ((work.Stance or count) - 1 + step + count) % count + 1
  if work.Stance == count then work.Stance = nil end
  editor.Refresh()
 end)

 local save = UI.Button("MSBT_TriggerSave", editor, "Save", 0, 0, 120, function() editor.Save() end)
 save:ClearAllPoints(); save:SetPoint("BOTTOMLEFT", editor, "BOTTOMLEFT", 28, 18)
 local cancel = UI.Button("MSBT_TriggerCancel", editor, "Cancel", 0, 0, 120, function() editor:Hide() end)
 cancel:ClearAllPoints(); cancel:SetPoint("BOTTOMLEFT", editor, "BOTTOMLEFT", 156, 18)

 local function Shown(widget, shown)
  if shown then widget:Show() else widget:Hide() end
  if widget.label then Shown(widget.label, shown) end
  if widget.valueText then Shown(widget.valueText, shown) end
 end

 function editor.Refresh()
  local triggerType = work.TriggerType
  local isThreshold = triggerType <= MikCEH.TRIGGERTYPE_FRIENDLY_HEALTH
  local isAura = triggerType == MikCEH.TRIGGERTYPE_AURA_GAIN
  for _, info in ipairs(MikSBT.AVAILABLE_TRIGGER_TYPES) do
   if info.Type == triggerType then editor.type.text:SetText(info.Name) end
  end
  UI.Sync(editor.allClasses, work.Classes == nil)
  for key, widget in pairs(editor.classes) do
   UI.Sync(widget, work.Classes and work.Classes[key] or false, work.Classes ~= nil)
  end
  for _, w in ipairs({editor.thresholdHeading, editor.threshold}) do Shown(w, isThreshold) end
  for _, w in ipairs({editor.auraHeading, editor.aura}) do Shown(w, isAura) end
  for _, w in ipairs({editor.stanceHeading, editor.stance}) do Shown(w, not isThreshold) end
  if isThreshold then UI.SetSlider(editor.threshold, work.Threshold or 40) end
  local stances = MikSBT.AVAILABLE_STANCES
  editor.stance.text:SetText(stances[work.Stance or table.getn(stances)].Name)
  editor:SetHeight(isThreshold and 330 or 360)
 end

 function editor.Open(triggerKey)
  local trigger = Profile().Triggers[triggerKey]
  editor.key, editor.profile = triggerKey, Profile()
  work = CopyTable(trigger.TriggerSettings)
  editor.title:SetText(trigger.EventSettings.Message or "Trigger")
  editor.icon:SetText(trigger.Texture or "")
  editor.aura:SetText(work.AuraName or "")
  editor.Refresh()
  editor:Show()
 end

 function editor.Save()
  local trigger = editor.profile == Profile() and Profile().Triggers[editor.key]
  if not trigger then editor:Hide(); return end
  local triggerType = work.TriggerType
  local settings = {TriggerType = triggerType, Classes = work.Classes}
  if triggerType <= MikCEH.TRIGGERTYPE_FRIENDLY_HEALTH then
   settings.Threshold = work.Threshold or 40
  else
   settings.Stance = work.Stance
   if settings.Stance and not GetShapeshiftFormInfo(settings.Stance) then
    MikSBT.Print("This character has no such stance, so the trigger will not fire.", 1, 1, 0)
   end
   if triggerType == MikCEH.TRIGGERTYPE_AURA_GAIN then
    settings.AuraName = editor.aura:GetText()
   end
  end
  trigger.TriggerSettings = settings
  local icon = editor.icon:GetText()
  trigger.Texture = icon ~= "" and icon or nil
  MikSBT.RegisterTriggers()
  editor:Hide()
  if refresh[6] then refresh[6]() end
 end
 return editor
end

function MikSBTOpt.EditTrigger(triggerKey)
 if not triggerEditor then triggerEditor = CreateTriggerEditor() end
 triggerEditor.Open(triggerKey)
end

-------------------------------------------------------------------------------------
-- Triggers tab.
-------------------------------------------------------------------------------------

local function BuildTriggers(page)
 local rows, pager, keys = {}, nil, {}
 UI.Heading(page, "On / Message (click to edit) / Color", 28, -98)
 for i = 1, ROWS_PER_PAGE do
  local row = UI.Row("MSBT_TriggerRow" .. i, page, 28, -118 - (i - 1) * 28, WIDTH - 56)
  local function Trigger() return Profile().Triggers[row.key] end
  row.show = UI.Switch("MSBT_TriggerRow" .. i .. "Show", row, "", "Turn this trigger on or off.", 4, -5, function(value)
   Trigger().EventSettings.Show = value
   MikSBT.RegisterTriggers()
  end, 20)
  row.message = MessageButton("MSBT_TriggerRow" .. i .. "Message", row, 40, 230, function()
   EditInline(row.message, Trigger().EventSettings.Message, function(text)
    Trigger().EventSettings.Message = text
    refresh[6]()
   end)
  end)
  UI.Tooltip(row.message, "%1 shows the health or mana amount.")
  row.swatch = Swatch("MSBT_TriggerRow" .. i .. "Color", row, function()
   PickColor(row.swatch, Trigger().EventSettings.FontSettings.Color)
  end)
  row.swatch:SetPoint("LEFT", row, "LEFT", 278, 0)
  row.sticky = UI.Button("MSBT_TriggerRow" .. i .. "Sticky", row, "Sticky", 300, -2, 52, function()
   Trigger().EventSettings.IsSticky = not Trigger().EventSettings.IsSticky
   refresh[6]()
  end, {ghost = true})
  UI.Button("MSBT_TriggerRow" .. i .. "Font", row, "Font", 356, -2, 44, function()
   local settings = Trigger().EventSettings.FontSettings
   local chain = AreaChain("Notification")
   table.insert(chain, 1, settings)
   EditFonts({title = Trigger().EventSettings.Message, own = {Normal = settings.Normal}, chain = chain, inherit = true})
  end, {ghost = true})
  UI.Button("MSBT_TriggerRow" .. i .. "Edit", row, "Edit", 404, -2, 50, function()
   MikSBTOpt.EditTrigger(row.key)
  end, {ghost = true})
  local delete = UI.Button("MSBT_TriggerRow" .. i .. "Delete", row, "X", 512, -2, 26, function()
   Profile().Triggers[row.key] = nil
   MikSBT.RegisterTriggers()
   refresh[6]()
  end, {ghost = true})
  UI.Tooltip(delete, "Delete this trigger.")
  rows[i] = row
 end
 pager = Pager("MSBT_TriggerPager", page, function(step) pager.page = pager.page + step; refresh[6]() end)
 local add = UI.Button("MSBT_TriggerAdd", page, "Add trigger", 0, 0, 140, function()
  local n = 1
  while Profile().Triggers["MSBT_TRIGGER_CUSTOM" .. n] do n = n + 1 end
  Profile().Triggers["MSBT_TRIGGER_CUSTOM" .. n] = {
   EventSettings = {Show = true, Message = "New trigger", IsSticky = false,
    FontSettings = {Color = {r = 1, g = 0.502, b = 0.502}, Normal = {FontIndex = 0, OutlineIndex = 0, FontSize = 26}}},
   TriggerSettings = {TriggerType = 1, Threshold = 40},
  }
  MikSBT.RegisterTriggers()
  refresh[6]()
  MikSBTOpt.EditTrigger("MSBT_TRIGGER_CUSTOM" .. n)
 end)
 add:ClearAllPoints(); add:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 28, 18)

 return function()
  keys = SortedKeys(Profile().Triggers)
  local offset = pager:Set(table.getn(keys))
  for i, row in ipairs(rows) do
   local key = keys[offset + i]
   if key then
    local settings = Profile().Triggers[key].EventSettings
    row.key = key
    UI.Sync(row.show, settings.Show)
    row.message:SetText(settings.Message or "")
    PaintSwatch(row.swatch, settings.FontSettings.Color)
    UI.Select(row.sticky, settings.IsSticky and true or false)
    row:Show()
   else
    row:Hide()
   end
  end
 end
end

-------------------------------------------------------------------------------------
-- Filters tab (suppressions).
-------------------------------------------------------------------------------------

local function BuildFilters(page)
 local rows, pager = {}, nil
 UI.Heading(page, "Hide text that matches a pattern", 28, -98)
 for i = 1, ROWS_PER_PAGE do
  local row = UI.Row("MSBT_FilterRow" .. i, page, 28, -118 - (i - 1) * 28, WIDTH - 56)
  local function Filter() return Profile().Suppressions[row.key] end
  row.show = UI.Switch("MSBT_FilterRow" .. i .. "On", row, "", "Turn this filter on or off.", 4, -5, function(value)
   Filter().Enabled = value
  end, 20)
  row.pattern = MessageButton("MSBT_FilterRow" .. i .. "Pattern", row, 40, 460, function()
   EditInline(row.pattern, Filter().SearchPattern, function(text)
    Filter().SearchPattern = text
    refresh[7]()
   end)
  end)
  UI.Tooltip(row.pattern, "A Lua pattern matched against the shown text and the spell name.")
  UI.Button("MSBT_FilterRow" .. i .. "Delete", row, "X", 512, -2, 26, function()
   Profile().Suppressions[row.key] = nil
   refresh[7]()
  end, {ghost = true})
  rows[i] = row
 end
 pager = Pager("MSBT_FilterPager", page, function(step) pager.page = pager.page + step; refresh[7]() end)
 local add = UI.Button("MSBT_FilterAdd", page, "Add filter", 0, 0, 140, function()
  local n = 1
  while Profile().Suppressions["MSBT_SUPPRESSION_CUSTOM" .. n] do n = n + 1 end
  Profile().Suppressions["MSBT_SUPPRESSION_CUSTOM" .. n] = {Enabled = true, SearchPattern = "New filter"}
  refresh[7]()
 end)
 add:ClearAllPoints(); add:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 28, 18)

 return function()
  local keys = SortedKeys(Profile().Suppressions)
  local offset = pager:Set(table.getn(keys))
  for i, row in ipairs(rows) do
   local key = keys[offset + i]
   if key then
    local filter = Profile().Suppressions[key]
    row.key = key
    UI.Sync(row.show, filter.Enabled)
    row.pattern:SetText(filter.SearchPattern or "")
    row:Show()
   else
    row:Hide()
   end
  end
 end
end

-------------------------------------------------------------------------------------
-- Profiles tab.
-------------------------------------------------------------------------------------

local function AfterProfileChange()
 if fontEditor then fontEditor:Hide() end
 if triggerEditor then triggerEditor:Hide() end
 if moversShown then ShowMovers(true) end
end

function MikSBTOpt.LoadProfile(name)
 MikSBTOpt.RetireColorPicker(true)
 MikSBT.SelectProfile(name)
 AfterProfileChange()
end

local function BuildProfiles(page)
 local rows, pager = {}, nil
 UI.Heading(page, "Profiles (shared by your characters)", 28, -98)
 for i = 1, ROWS_PER_PAGE do
  local row = UI.Row("MSBT_ProfileRow" .. i, page, 28, -118 - (i - 1) * 28, 300)
  row.radio = UI.Radio("MSBT_ProfileRow" .. i .. "Use", row)
  row.radio:SetPoint("LEFT", row, "LEFT", 4, 0)
  row.radio:SetScript("OnClick", function()
   MikSBTOpt.LoadProfile(row.name)
   refresh[8]()
  end)
  row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.label:SetPoint("LEFT", row.radio, "RIGHT", 8, 0)
  UI.Color(row.label, "text")
  row.delete = UI.Button("MSBT_ProfileRow" .. i .. "Delete", row, "Delete", 236, -2, 60, function()
   MikSBTOpt.RetireColorPicker(true)
   MikSBT.DeleteProfile(row.name)
   AfterProfileChange()
   refresh[8]()
  end, {ghost = true})
  rows[i] = row
 end
 pager = Pager("MSBT_ProfilePager", page, function(step) pager.page = pager.page + step; refresh[8]() end)

 UI.Heading(page, "New profile", 352, -98)
 local name = TextBox("MSBT_ProfileName", page, 352, -118, 172)
 UI.Button("MSBT_ProfileCreate", page, "Create", 352, -146, 172, function()
  local text = name:GetText()
  if text ~= "" and not MikSBT.ProfileExists(text) then
   MikSBT.CreateProfile(text)
   name:SetText("")
   refresh[8]()
  end
 end)
 UI.Label(page, "New profiles start from the defaults.", 352, -174, "GameFontDisableSmall")
 UI.Button("MSBT_ProfileReset", page, "Reset this profile", 352, -210, 172, function()
  MikSBTOpt.RetireColorPicker(true)
  MikSBT.ResetProfile(MikSBT_Save.CurrentProfile, true)
  AfterProfileChange()
  refresh[8]()
 end)

 return function()
  local names = SortedKeys(MikSBT_Save.Profiles)
  local offset = pager:Set(table.getn(names))
  for i, row in ipairs(rows) do
   local profileName = names[offset + i]
   if profileName then
    row.name = profileName
    row.label:SetText(profileName)
    UI.SetCheck(row.radio, profileName == MikSBT_Save.CurrentProfile)
    UI.SetEnabled(row.delete, profileName ~= MikSBT.DEFAULT_PROFILE_NAME)
    row:Show()
   else
    row:Hide()
   end
  end
 end
end

-------------------------------------------------------------------------------------
-- Window.
-------------------------------------------------------------------------------------

local TABS = {
 {label = "General", height = 410, build = BuildGeneral},
 {label = "Areas", height = 410, build = BuildAreas},
 {label = "Incoming", height = 460, build = function(page) return BuildEvents(page, "Incoming", 3) end},
 {label = "Outgoing", height = 460, build = function(page) return BuildEvents(page, "Outgoing", 4) end},
 {label = "Notices", height = 460, build = function(page) return BuildEvents(page, "Notification", 5) end},
 {label = "Triggers", height = 460, build = BuildTriggers},
 {label = "Filters", height = 460, build = BuildFilters},
 {label = "Profiles", height = 460, build = BuildProfiles},
}

local function Create()
 panel = UI.Window("MSBT_Options", "Mik's Scrolling Battle Text", WIDTH, 410, GetAddOnMetadata(addonName, "Version"))
 local pages
 pages, ShowTab = UI.Tabs(panel, "MSBT_", TABS, function(index)
  panel.tab = index
  refresh[index]()
 end)
 for i, tab in ipairs(TABS) do refresh[i] = tab.build(pages[i]) end

 inlineEdit = TextBox("MSBT_InlineEdit", panel, 0, 0, 200, function(text)
  inlineEdit:Hide()
  if inlineAccept then inlineAccept(text) end
 end)
 inlineEdit:SetScript("OnEscapePressed", function() inlineEdit:Hide() end)
 inlineEdit:SetScript("OnEditFocusLost", function() inlineEdit:Hide() end)
 inlineEdit:Hide()

 panel:SetScript("OnShow", function() ShowTab(panel.tab or 1) end)
 panel:SetScript("OnHide", function()
  -- Keep the chosen color, close MSBT's own editors and movers.
  MikSBTOpt.RetireColorPicker(false)
  inlineEdit:Hide()
  if fontEditor then fontEditor:Hide() end
  if triggerEditor then triggerEditor:Hide() end
  if moversShown then ShowMovers(false) end
 end)
end

function MikSBTOpt.Toggle()
 if not panel then Create() end
 if panel:IsShown() then panel:Hide() else panel:Show() end
end

-- Opens a tab (1-8); used by tests and the slash command.
function MikSBTOpt.ShowTab(index)
 if not panel then Create() end
 panel:Show()
 ShowTab(index)
end
