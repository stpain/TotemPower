

local name, addon = ...;

local Comms = addon.Comms;

TotemPowerSecureButtonMixin = {}
function TotemPowerSecureButtonMixin:OnLoad()
    
    self:SetAttribute("type", "macro")
    --self:SetAttribute("macrotext", macro)
end

function TotemPowerSecureButtonMixin:SetTotem(slot, spellID)

    --SetMultiCastSpell(slot, spellID)
    
    local spell = Spell:CreateFromSpellID(spellID)
    if not spell:IsSpellEmpty() then
        spell:ContinueOnSpellLoad(function()
            local name, rank, icon = GetSpellInfo(spellID)
            self.icon:SetTexture(icon)
            if name then
                self:SetScript("OnClick", function()
                    SetMultiCastSpell(slot, spellID)
                end)
            end
        end)
    end
end

function TotemPowerSecureButtonMixin:SetTotems(totems)
    self.totems = totems;
    for slot, spellID in pairs(self.totems) do
        SetMultiCastSpell(slot, spellID)
    end
    self:SetScript("OnClick", function()
        for slot, spellID in pairs(self.totems) do
            SetMultiCastSpell(slot, spellID)
        end
    end)
end

function TotemPowerSecureButtonMixin:SetShield(spellID, target)
    
    local spell = Spell:CreateFromSpellID(spellID)
    if not spell:IsSpellEmpty() then
        spell:ContinueOnSpellLoad(function()
            local name, rank, icon = GetSpellInfo(spellID)
            self.icon:SetTexture(icon)
            if name then
                if target == false then
                    local macro = string.format([[/cast [@player] %s]], name)
                    self:SetAttribute("macrotext", macro)
                else
                    local macro = string.format([[/cast [@player] %s]], name)
                    self:SetAttribute("macrotext", macro)
                end
            end
        end)
    end
end

function TotemPowerSecureButtonMixin:SetEmbue(spellID, target)
    
    local spell = Spell:CreateFromSpellID(spellID)
    if not spell:IsSpellEmpty() then
        spell:ContinueOnSpellLoad(function()
            local name, rank, icon = GetSpellInfo(spellID)
            self.icon:SetTexture(icon)
            if name then
                --if not target then
                    local macro = string.format([[
/cast %s
/use %d]], name, target)
                    self:SetAttribute("macrotext", macro)
                --else

                --end
            end
        end)
    end
end




TotemPowerCharacterAssignmentMixin = {}
function TotemPowerCharacterAssignmentMixin:OnLoad()
    addon:RegisterCallback("Character_OnTotemDataReceived", self.Character_OnTotemDataReceived, self)

    local sets = {
        "elements",
        "ancestors",
        "spirits",
    }
    local slots = {
        "fire",
        "earth",
        "water",
        "air"
    }

    for k, set in ipairs(sets) do
        for j, slot in ipairs(slots) do
            if self[set] and self[set][slot] then
                self[set][slot].selectedIndex = 0;
                self[set][slot]:SetScript("OnMouseDown", function()
                    if self[set][slot].totems then

                        self[set][slot].selectedIndex = self[set][slot].selectedIndex + 1;
                        if self[set][slot].selectedIndex > #self[set][slot].totems then
                            self[set][slot].selectedIndex = 1
                        end

                        self:SetSelectedIndex(set, slot, "totems", self[set][slot].selectedIndex)

                        local spellID = self[set][slot].totems[self[set][slot].selectedIndex]
                        GameTooltip:SetSpellByID(self[set][slot].totems[self[set][slot].selectedIndex])
                        GameTooltip:Show()

                        local msg = {
                            type = "TOTEM_ASSIGNMENT",
                            payload = {
                                set = set,
                                slot = slot,
                                spellID = spellID,
                            }
                        }
                        Comms:Transmit(msg, "WHISPER", "Brewbolts")
                    end
                end)
                self[set][slot]:SetScript("OnLeave", function()
                    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                end)
                self[set][slot]:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(self[set][slot], "ANCHOR_TOPRIGHT")
                    if self[set][slot].totems and self[set][slot].totems[self[set][slot].selectedIndex] then
                        GameTooltip:SetSpellByID(self[set][slot].spellID)
                        GameTooltip:Show()
                    end
                end)
            end
        end
    end


    local shields = {
        [1] = 49281, --lightning
        [2] = 57960, --water
        --[3] = 49284, --earth
    }


    -- the intention here was to set a target for earth shield however it cant work in this loop so needs a rethink
    for k, v in ipairs({"player"}) do
        self.shields[v].shields = shields;
        self.shields[v].selectedIndex = 0;
        self.shields[v]:SetScript("OnMouseDown", function()
            self.shields[v].selectedIndex = self.shields[v].selectedIndex + 1;
            if self.shields[v].selectedIndex > 2 then
                self.shields[v].selectedIndex = 1;
            end
    
            self:SetSelectedIndex("shields", v, "shields", self.shields[v].selectedIndex)

            local spellID = self.shields[v].shields[self.shields[v].selectedIndex]
            GameTooltip:SetSpellByID(self.shields[v].shields[self.shields[v].selectedIndex])
            GameTooltip:Show()

            local msg = {
                type = "SHIELD_ASSIGNMENT",
                payload = {
                    slot = (v.."Shield"),
                    target = (v == "player") and false or true,
                    spellID = spellID,
                }
            }
            Comms:Transmit(msg, "WHISPER", "Brewbolts")
    
        end)
        self.shields[v]:SetScript("OnLeave", function()
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end)
        self.shields[v]:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self.shields[v], "ANCHOR_TOPRIGHT")
            if self.shields[v].shields and self.shields[v].shields[self.shields[v].selectedIndex] then
                GameTooltip:SetSpellByID(self.shields[v].spellID)
                GameTooltip:Show()
            end
        end) 
    end



    local embues = {
        [1] = 58790, --flametongue
        [2] = 58804, --windfury
        [3] = 58796, --frostbrand
        [4] = 51994, --earthliving
    }

    for k, v in ipairs({"mainHand", "offHand"}) do
        self.embues[v].embues = embues;
        self.embues[v].selectedIndex = 0;
        self.embues[v]:SetScript("OnMouseDown", function()
            self.embues[v].selectedIndex = self.embues[v].selectedIndex + 1;
            if self.embues[v].selectedIndex > 4 then
                self.embues[v].selectedIndex = 1;
            end

            self:SetSelectedIndex("embues", v, "embues", self.embues[v].selectedIndex)

            local spellID = self.embues[v].embues[self.embues[v].selectedIndex]
            GameTooltip:SetSpellByID(self.embues[v].embues[self.embues[v].selectedIndex])
            GameTooltip:Show()

            local msg = {
                type = "EMBUE_ASSIGNMENT",
                payload = {
                    slot = (v.."Embue"),
                    spellID = spellID,
                    target = (v == "mainHand") and 16 or 17,
                }
            }
            Comms:Transmit(msg, "WHISPER", "Brewbolts")

        end)

        self.embues[v]:SetScript("OnLeave", function()
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end)
        self.embues[v]:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self.embues[v], "ANCHOR_TOPRIGHT")
            if self.embues[v].embues and self.embues[v].embues[self.embues[v].selectedIndex] then
                GameTooltip:SetSpellByID(self.embues[v].spellID)
                GameTooltip:Show()
            end
        end)
    end


end

function TotemPowerCharacterAssignmentMixin:SetSelectedIndex(set, slot, key, index)

    self[set][slot].selectedIndex = index;

    local spellID = self[set][slot][key][self[set][slot].selectedIndex]
    local name, rank, icon = GetSpellInfo(spellID)
    self[set][slot].icon:SetTexture(icon)
    self[set][slot].spellID = spellID;

end

function TotemPowerCharacterAssignmentMixin:Character_OnTotemDataReceived(totemData)
    --DevTools_Dump(totemData.payload.totems[1])
    if totemData and totemData.senderGuid and (totemData.sender == self.unitName) then
        self.elements.fire.totems = totemData.payload.totems[1][1]
        self.elements.earth.totems = totemData.payload.totems[1][2]
        self.elements.water.totems = totemData.payload.totems[1][3]
        self.elements.air.totems = totemData.payload.totems[1][4]
        
        self.ancestors.fire.totems = totemData.payload.totems[2][1]
        self.ancestors.earth.totems = totemData.payload.totems[2][2]
        self.ancestors.water.totems = totemData.payload.totems[2][3]
        self.ancestors.air.totems = totemData.payload.totems[2][4]

        self.spirits.fire.totems = totemData.payload.totems[3][1]
        self.spirits.earth.totems = totemData.payload.totems[3][2]
        self.spirits.water.totems = totemData.payload.totems[3][3]
        self.spirits.air.totems = totemData.payload.totems[3][4]
    end
end

function TotemPowerCharacterAssignmentMixin:SetDataBinding(binding, height)
    self.unitName = binding.name;

    self.name:SetText(binding.name)

end

function TotemPowerCharacterAssignmentMixin:ResetDataBinding(binding, height)

end