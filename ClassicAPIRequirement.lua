-- MSBT runs on ClassicAPI 1.17.7+, SuperWoW and NamPower 4.6.2+. The later
-- files load only when MSBT_REQUIREMENTS_MET is set here.
local missing
if type(CLASSIC_API_VERSION) ~= "number" or CLASSIC_API_VERSION < 11707 then
    missing = "ClassicAPI 1.17.7 or later"
elseif not SUPERWOW_VERSION then
    missing = "SuperWoW"
elseif not GetNampowerVersion then
    missing = "NamPower 4.6.2 or later"
else
    local major, minor, patch = GetNampowerVersion()
    if major * 10000 + minor * 100 + patch < 40602 then missing = "NamPower 4.6.2 or later" end
end
if missing then
    local message = "MikScrollingBattleText needs " .. missing .. ". Update it and restart the game."
    DEFAULT_CHAT_FRAME:AddMessage("|cffff2020MSBT:|r " .. message, 1, 0.2, 0.2)
    error(message, 0)
end
MSBT_REQUIREMENTS_MET = true
