

--[[
    https://wowpedia.fandom.com/wiki/API_SetMultiCastSpell

    https://wowpedia.fandom.com/wiki/API_GetMultiCastTotemSpells

    https://wowpedia.fandom.com/wiki/API_GetTotemTimeLeft

    https://wowpedia.fandom.com/wiki/API_GetTotemInfo
]]

local addonName, TotemPower = ...;

local Comms = TotemPower.Comms;

local totemSlots = {
    elements = {
        fire = 133,
        earth = 134,
        water = 135,
        air = 136,
    },
    ancestors = {
        fire = 137,
        earth = 138,
        water = 139,
        air = 140,
    },
    spirits = {
        fire = 141,
        earth = 142,
        water = 143,
        air = 144,
    },
}


TotemPowerHudMixin = {
    assignments = {
        elements = {},
        ancestors = {},
        spirits = {},
    }
}

function TotemPowerHudMixin:OnLoad()

    self:SetSize(84, 270)
    
    self:RegisterForDrag("LeftButton")

    self.openAssignments:SetText("Assign")
    self.openAssignments:SetScript("OnClick", function()
        TotemPowerAssignmentsUI:SetShown(not TotemPowerAssignmentsUI:IsVisible())
    end)

    -- self.playerShield:SetShield(57960)
    -- self.targetShield:SetShield(49284)

    -- self.mainHandEmbue:SetEmbue(51994)
    -- self.offHandEmbue:SetEmbue(51994)

    self.elements.icon:SetTexture(310730)
    self.ancestors.icon:SetTexture(310731)
    self.spirits.icon:SetTexture(310732)

    TotemPower:RegisterCallback("Character_OnTotemAssignment", self.Character_OnTotemAssignment, self)
    TotemPower:RegisterCallback("Character_OnShieldAssignment", self.Character_OnShieldAssignment, self)
    TotemPower:RegisterCallback("Character_OnEmbueAssignment", self.Character_OnEmbueAssignment, self)

end


---this is called when a totem assignment is changed
---all this does is update the totem slot with the new spellID and then update the buttons
---@param assignment any
function TotemPowerHudMixin:Character_OnTotemAssignment(assignment)
    if assignment.payload.set and assignment.payload.slot and assignment.payload.spellID then
        local slotID = totemSlots[assignment.payload.set][assignment.payload.slot]
        self.assignments[assignment.payload.set][slotID] = assignment.payload.spellID;
        --print(string.format("set %s %s as %d", assignment.payload.set, assignment.payload.slot, assignment.payload.spellID))
    end
    self.elements:SetTotems(self.assignments.elements)
    self.ancestors:SetTotems(self.assignments.ancestors)
    self.spirits:SetTotems(self.assignments.spirits)
end

function TotemPowerHudMixin:Character_OnShieldAssignment(assignment)
    if assignment.payload.slot and assignment.payload.spellID then
        self[assignment.payload.slot]:SetShield(assignment.payload.spellID, assignment.payload.target)
    end
end

function TotemPowerHudMixin:Character_OnEmbueAssignment(assignment)
    if assignment.payload.target and assignment.payload.slot and assignment.payload.spellID then
        self[assignment.payload.slot]:SetEmbue(assignment.payload.spellID, assignment.payload.target)
    end
end






TotemPowerAssignmentsMixin = {}

function TotemPowerAssignmentsMixin:OnLoad()

    self:RegisterForDrag("LeftButton")
    self.resize:Init(self, 700, 450, 1100, 650)

    local version = tonumber(GetAddOnMetadata(addonName, "Version"));

    self.title:SetText(string.format("%s [v%0.3f]", addonName, version))

    SLASH_TOTEMPOWER1 = '/totempower'
    SLASH_TOTEMPOWER2 = '/topo'
    SlashCmdList['TOTEMPOWER'] = function(msg)
        if msg == "" then
            self:Show()
        end
    end

    
    TotemPower:RegisterCallback("OnRaidRosterUpdate", self.OnRaidRosterUpdate, self)

    Comms:Init()
end


function TotemPowerAssignmentsMixin:OnRaidRosterUpdate()

    local group = {}

    if IsInGroup() and IsInRaid() then

        for i = 1, 40 do
            local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(i)
            if fileName and (fileName == "SHAMAN") then
                table.insert(group, {
                    name = name
                })
            end
        end

        local dp = CreateDataProvider(group)
        self.charactersListview.scrollView:SetDataProvider(dp)

        self:TransmitTotems()

    end
end

function TotemPowerAssignmentsMixin:OnShow()
    self:OnRaidRosterUpdate()
end

function TotemPowerAssignmentsMixin:TransmitTotems()

    local totems = TotemPower.api.wrath.getAllAvailableTotemsForPlayer()

    local msg = {
        type = "PLAYER_TOTEMS",
        payload = {
            totems = totems,
        }
    }

    Comms:Transmit(msg, "RAID", nil)

end