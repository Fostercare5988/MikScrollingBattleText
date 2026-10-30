-- MSBT runs on ClassicAPI (combat log, GetSpellInfo, UnitGUID). The
-- later files load only when MSBT_REQUIREMENTS_MET is set here.
if type(CLASSIC_API_VERSION) ~= "number" then
    local message = "MikScrollingBattleText needs ClassicAPI. Update it and restart the game."
    DEFAULT_CHAT_FRAME:AddMessage("|cffff2020MSBT:|r " .. message, 1, 0.2, 0.2)
    error(message, 0)
end
MSBT_REQUIREMENTS_MET = true
