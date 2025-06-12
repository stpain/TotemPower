

local name, TotemPower = ...;

local Comms = TotemPower.Comms;

local client = "Vanilla";



TBDBaseTooltipMixin = {}
function TBDBaseTooltipMixin:OnEnter()
    if self.SpellID then
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
        GameTooltip:SetSpellByID(self.SpellID)
        GameTooltip:Show()
    end
end





--[[
    TotemSelectorButton

    This is the button players click in the group UI to set each players totem for each element.
    When the button is clicked, a message is sent to group members so their UI is kept updated.
]]
TotemPowerTotemSelectorButtonMixin = {}
function TotemPowerTotemSelectorButtonMixin:OnLoad()
    self.SelectedIndex = 1
    if self.Element then
        self.TotemData = TotemPower.TotemData[client][self.Element]
    end
    self:SetNormalTexture(310733)
    self:RegisterForClicks("AnyDown")
    TotemPower.CallbackRegistry:RegisterCallback("CharacterTotem_OnSelectionChanged", self.CharacterTotem_OnSelectionChanged, self)
end

function TotemPowerTotemSelectorButtonMixin:OnClick()

    if self.TotemData then
        self.SelectedIndex = self.SelectedIndex + 1;
        if self.SelectedIndex > #self.TotemData then
            self.SelectedIndex = 1
        end

        Comms:Transmit({
            Event = "CharacterTotem_OnSelectionChanged",
            Payload = {
                TargetPlayer = self:GetParent().Player,
                Element = self.Element,
                SelectedIndex = self.SelectedIndex,
                SpellID = self.TotemData[self.SelectedIndex]
            },
        }, "WHISPER", UnitName("player"))
    end

end

function TotemPowerTotemSelectorButtonMixin:CharacterTotem_OnSelectionChanged(info)

    if info.TargetPlayer ~= self:GetParent().Player then
        return
    end

    if info.Element ~= self.Element then
        return
    end
    
    if info.SelectedIndex and self.TotemData and self.TotemData[self.SelectedIndex] then
        self.SelectedIndex = info.SelectedIndex
        local spellID = self.TotemData[self.SelectedIndex]
        self:SetNormalTexture(C_Spell.GetSpellTexture(spellID))
    end
end



TotemPowerCharacterMixin = {}
function TotemPowerCharacterMixin:OnLoad()

    self.TalentButtons = {}
    local lastButton;
    for k, talents in ipairs(TotemPower.TalentData[client]) do
        local button = CreateFrame("Frame", nil, self, "TotemPowerBaseTooltipFrame")
        if not lastButton then
            button:SetPoint("BOTTOMLEFT", 1, 1)
            lastButton = button
        else
            button:SetPoint("LEFT", lastButton, "RIGHT", 2, 0)
            lastButton = button
        end
        button.Talents = talents;
        table.insert(self.TalentButtons, button)
    end

end
function TotemPowerCharacterMixin:SetDataBinding(binding, height)
    self.Player = binding.Name;
    self.Name:SetText(binding.Name)
end

function TotemPowerCharacterMixin:ResetDataBinding()
    self.Player = nil
    self.Name:SetText("")
end







--[[
    TotemPowerSecureButton

    Secure Action Button, this is the action bar type button, its used in the totem bar (like in wrath with the 4 elements)
]]
TotemPowerSecureButtonMixin = {}
function TotemPowerSecureButtonMixin:OnLoad()
    self:RegisterForClicks("AnyUp", "AnyDown")
    TotemPower.CallbackRegistry:RegisterCallback("CharacterTotem_OnSelectionChanged", self.CharacterTotem_OnSelectionChanged, self)
end

function TotemPowerSecureButtonMixin:CharacterTotem_OnSelectionChanged(info)

    if info.TargetPlayer ~= UnitName("player") then
        return
    end

    if info.Element ~= self.Element then
        return
    end

    local spell = Spell:CreateFromSpellID(info.SpellID)
    if not spell:IsSpellEmpty() then
        spell:ContinueOnSpellLoad(function()
            self.Icon:SetTexture(C_Spell.GetSpellTexture(info.SpellID))
            self:SetAttribute("type", "spell")
            self:SetAttribute("spell", C_Spell.GetSpellName(info.SpellID))
        end)
    end
end









--[[

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

    local shields = {
        [1] = 49281, --lightning
        [2] = 57960, --water
        --[3] = 49284, --earth
    }



    local embues = {
        [1] = 58790, --flametongue
        [2] = 58804, --windfury
        [3] = 58796, --frostbrand
        [4] = 51994, --earthliving
    }

]]