local addonName, addon = ...;

local Database = addon.Database;
local Talents = addon.Talents;

--create these at addon level
addon.thisCharacter = "";

addon.api = {
    classic = {},
    wrath = {},
}


--taken from blizz to use for classic
function addon.api.extractLink(text)
    -- linkType: |H([^:]*): matches everything that's not a colon, up to the first colon.
    -- linkOptions: ([^|]*)|h matches everything that's not a |, up to the first |h.
    -- displayText: (.*)|h matches everything up to the second |h.
    -- Ex: |cffffffff|Htype:a:b:c:d|htext|h|r becomes type, a:b:c:d, text
    return string.match(text, [[|H([^:]*):([^|]*)|h(.*)|h]]);
end

function addon.api.makeTableUnique(t)
    
    local temp, ret = {}, {}
    for k, v in ipairs(t) do
        temp[v] = true
    end
    for k, v in pairs(temp) do
        table.insert(ret, k)
    end
    return ret;
end

function addon.api.trimTable(tab, num, reverse)

    if type(tab) == "table" then
        
        local t = {}
        if reverse then
            for i = #tab, (#tab - num), -1 do
                table.insert(t, tab[i])
            end

        else
            for i = 1, num do
                table.insert(t, tab[i])
            end
        end

        tab = nil;
        return t;
    end
end

function addon.api.trimNumber(num)
    if type(num) == 'number' then
        local trimmed = string.format("%.1f", num)
        return tonumber(trimmed)
    else
        return 1
    end
end

function addon.api.characterIsMine(name)
    if Database.db.myCharacters[name] == true or Database.db.myCharacters[name] == false then
        return true;
    end
    return false;
end


function addon.api.getPlayerItemLevel()
    local itemLevel, itemCount = 0, 0
	for k, v in ipairs(addon.data.inventorySlots) do
		local link = GetInventoryItemLink('player', GetInventorySlotInfo(v.slot)) or false
		if link then
			local _, _, _, ilvl = GetItemInfo(link)
            if not ilvl then ilvl = 0 end
			itemLevel = itemLevel + ilvl
			itemCount = itemCount + 1
		end
    end
    -- due to an error with LibSerialize which is now fixed we make sure we return a number
    if math.floor(itemLevel/itemCount) > 0 then
        return addon.api.trimNumber(itemLevel/itemCount)
    else
        return 0
    end
end


function addon.api.classic.getPlayerTalents()
    local talents = {}
    local tabs = {}
    for tabIndex = 1, GetNumTalentTabs() do
        local spec, texture, pointsSpent, fileName = GetTalentTabInfo(tabIndex)
        local engSpec = Talents.TalentBackgroundToSpec[fileName]
        table.insert(tabs, {
            fileName = fileName,
            pointsSpent = pointsSpent,
        })
        for talentIndex = 1, GetNumTalents(tabIndex) do
            local name, iconTexture, row, column, rank, maxRank, isExceptional, available = GetTalentInfo(tabIndex, talentIndex)
            local spellId = Talents:GetTalentSpellId(fileName, row, column, rank)
            table.insert(talents, {
                tabID = tabIndex,
                row = row,
                col = column,
                rank = rank,
                maxRank = maxRank,
                spellId = spellId,
            })
        end
    end
    -- find the tab with most points and set spec if not already set, the user can always change this if wrong and this will probably cause them to actually update it.
    table.sort(tabs, function(a, b)
        return a.pointsSpent > b.pointsSpent;
    end)
    return {
        tabs = tabs,
        talents = talents,
    }
end

function addon.api.wrath.getPlayerTalents(...)
    local newSpec, previousSpec = ...;

	if type(newSpec) ~= "number" then
		newSpec = GetActiveTalentGroup()
	end
	if type(newSpec) ~= "number" then
		newSpec = 1
	end

    local tabs, talents = {}, {}
    for tabIndex = 1, GetNumTalentTabs() do
        local spec, texture, pointsSpent, fileName = GetTalentTabInfo(tabIndex)
        local engSpec = Talents.TalentBackgroundToSpec[fileName]
        table.insert(tabs, {
            fileName = fileName,
            pointsSpent = pointsSpent,
        })
        for talentIndex = 1, GetNumTalents(tabIndex) do
            local name, iconTexture, row, column, rank, maxRank, isExceptional, available = GetTalentInfo(tabIndex, talentIndex)
            local spellId = Talents:GetTalentSpellId(fileName, row, column, rank)
            table.insert(talents, {
                tabID = tabIndex,
                row = row,
                col = column,
                rank = rank,
                maxRank = maxRank,
                spellId = spellId,
            })
        end
    end

    return newSpec, tabs, talents;

end

function addon.api.wrath.getTotemsForSlotIndex(slotIndex)

    local totem1, totem2, totem3, totem4, totem5, totem6, totem7 = GetMultiCastTotemSpells(slotIndex)

    return {
        [1] = totem1,
        [2] = totem2,
        [3] = totem3,
        [4] = totem4,
        [5] = totem5,
        [6] = totem6,
        [7] = totem7,
    }

end


function addon.api.wrath.getAllAvailableTotemsForPlayer()

    local playerTotems = {}

    local elements = {}
    for i = 133, 136, 1 do
        local totems = addon.api.wrath.getTotemsForSlotIndex(i)
        table.insert(elements, totems)
    end
    table.insert(playerTotems, elements)

    local ancestors = {}
    for i = 137, 140, 1 do
        local totems = addon.api.wrath.getTotemsForSlotIndex(i)
        table.insert(ancestors, totems)
    end
    table.insert(playerTotems, ancestors)

    local spirits = {}
    for i = 141, 144, 1 do
        local totems = addon.api.wrath.getTotemsForSlotIndex(i)
        table.insert(spirits, totems)
    end
    table.insert(playerTotems, spirits)

    return playerTotems;

end





addon.data = {}
addon.data.inventorySlots = {
    {
        slot = "HEADSLOT",
        icon = 136516,
    },
    {
        slot = "NECKSLOT",
        icon = 136519,
    },
    {
        slot = "SHOULDERSLOT",
        icon = 136526,
    },
    {
        slot = "SHIRTSLOT",
        icon = 136525,
    },
    {
        slot = "CHESTSLOT",
        icon = 136512,
    },
    {
        slot = "WAISTSLOT",
        icon = 136529,
    },
    {
        slot = "LEGSSLOT",
        icon = 136517,
    },
    {
        slot = "FEETSLOT",
        icon = 136513,
    },
    {
        slot = "WRISTSLOT",
        icon = 136530,
    },
    {
        slot = "HANDSSLOT",
        icon = 136515,
    },
    {
        slot = "FINGER0SLOT",
        icon = 136514,
    },
    {
        slot = "FINGER1SLOT",
        icon = 136523,
    },
    {
        slot = "TRINKET0SLOT",
        icon = 136528,
    },
    {
        slot = "TRINKET1SLOT",
        icon = 136528,
    },
    {
        slot = "BACKSLOT",
        icon = 136521,
    },
    {
        slot = "MAINHANDSLOT",
        icon = 136518,
    },
    {
        slot = "SECONDARYHANDSLOT",
        icon = 136524,
    },
    {
        slot = "RANGEDSLOT",
        icon = 136520,
    },
    {
        slot = "TABARDSLOT",
        icon = 136527,
    },
    -- {
    --     slot = "RELICSLOT",
    --     icon = 136522,
    -- },
}
