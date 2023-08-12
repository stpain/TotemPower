local name, addon = ...;

local Guild = addon.Guild;
local Character = addon.Character;
local Database = addon.Database;
local Talents = addon.Talents;
local Tradeskills = addon.Tradeskills;

local e = CreateFrame("FRAME");

e:RegisterEvent('ADDON_LOADED')
e:RegisterEvent('PLAYER_ENTERING_WORLD')
e:RegisterEvent('RAID_ROSTER_UPDATE')
e:RegisterEvent('GROUP_ROSTER_UPDATE')
e:RegisterEvent('CHARACTER_POINTS_CHANGED')
e:RegisterEvent("PLAYER_REGEN_DISABLED")
e:RegisterEvent("PLAYER_REGEN_ENABLED")
e:RegisterEvent("SKILL_LINES_CHANGED")


e:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)

function e:RAID_ROSTER_UPDATE()
    addon:TriggerEvent("OnRaidRosterUpdate")
end
function e:GROUP_ROSTER_UPDATE()
    addon:TriggerEvent("OnRaidRosterUpdate")
end

function e:PLAYER_REGEN_DISABLED()
    addon:TriggerEvent("Player_Regen_Disabled")
end

function e:PLAYER_REGEN_ENABLED()
    addon:TriggerEvent("Player_Regen_Enabled")
end

function e:ADDON_LOADED()

end

function e:PLAYER_ENTERING_WORLD()
    local name, realm = UnitFullName("player")
    if not realm then
        realm = GetNormalizedRealmName()
    end
    addon.thisCharacter = string.format("%s-%s", name, realm)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD");

    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.showUpdateDialog then
        StaticPopup_Show("GuildbookUpdated")
    else
        Database:Init()
    end

end

local classFileNameToClassId = {
    WARRIOR	= 1,
    PALADIN	= 2,
    HUNTER = 3,
    ROGUE = 4,
    PRIEST = 5,
    DEATHKNIGHT = 6,
    SHAMAN = 7,
    MAGE = 8,
    WARLOCK	= 9,
    MONK = 10,
    DRUID = 11,
    DEMONHUNTER = 12,
    EVOKER = 13,
}
addon.initialGuildRosterScanned = false

local function setPlayerTalentsAndGlyphs(...)

    local spec, tabs, talents = addon.api.wrath.getPlayerTalents(...)

    --convert the keys to named keys to use as a lookup
    if spec == 1 then
        spec = "primary";
    elseif spec == 2 then
        spec = "secondary"
    else
        spec = "primary"
    end

end

function e:ACTIVE_TALENT_GROUP_CHANGED(...)
	setPlayerTalentsAndGlyphs(...)
end

function e:CHARACTER_POINTS_CHANGED()
    setPlayerTalentsAndGlyphs({})
end

function e:Database_OnInitialised()

    if not Database.db.myCharacters[addon.thisCharacter] then
        Database.db.myCharacters[addon.thisCharacter] = false;
    end

    UIParentLoadAddOn("Blizzard_DebugTools");

    if not PlayerTalentFrame then
        UIParentLoadAddOn("Blizzard_TalentUI")
    end

    PlayerTalentFrame:HookScript("OnHide", function()
        setPlayerTalentsAndGlyphs({})
	end)
	SkillFrame:HookScript("OnShow", function()

	end)
    CharacterFrame:HookScript("OnHide", function()

    end)


end

addon:RegisterCallback("Database_OnInitialised", e.Database_OnInitialised, e)