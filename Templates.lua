

local name, TotemPower = ...;

local Comms = TotemPower.Comms;


TotemPowerBaseTooltipMixin = {}
function TotemPowerBaseTooltipMixin:OnEnter()
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
TotemPowerTotemAssignmentButtonMixin = {}
function TotemPowerTotemAssignmentButtonMixin:OnLoad()
    self.SelectedIndex = 1
    if self.Element then
        self.TotemData = TotemPower.TotemData[TotemPower.Client][self.Element]
    end
    self:SetNormalTexture(310733)
    self:RegisterForClicks("AnyDown")
    TotemPower.CallbackRegistry:RegisterCallback("CharacterTotem_OnTotemAssignmentChanged", self.CharacterTotem_OnTotemAssignmentChanged, self)
end

function TotemPowerTotemAssignmentButtonMixin:OnClick()

    if self.TotemData then
        self.SelectedIndex = self.SelectedIndex + 1;
        if self.SelectedIndex > #self.TotemData then
            self.SelectedIndex = 1
        end

        Comms:Transmit({
            Event = "CharacterTotem_OnTotemAssignmentChanged",
            Payload = {
                TargetPlayer = self:GetParent().Player,
                Element = self.Element,
                SelectedIndex = self.SelectedIndex,
                SpellID = self.TotemData[self.SelectedIndex]
            },
        }, Comms.Group)
    end

end

function TotemPowerTotemAssignmentButtonMixin:CharacterTotem_OnTotemAssignmentChanged(info)

    if info.TargetPlayer ~= self:GetParent().Player then
        return
    end

    if info.Element ~= self.Element then
        return
    end
    
    if info.SelectedIndex and self.TotemData and self.TotemData[self.SelectedIndex] then
        self.SelectedIndex = info.SelectedIndex
        self.SpellID = self.TotemData[self.SelectedIndex]
        self:SetNormalTexture(C_Spell.GetSpellTexture(self.SpellID))
    end
end

function TotemPowerTotemAssignmentButtonMixin:ResetTotem()
    self.SelectedIndex = 1;
    self:SetNormalTexture(310733)
    self.SpellID = nil
end







local function TalentIconFrameResetFunc(_, frame)
    frame.SpellID = nil;
    if frame.Rank then
        frame.Rank:SetText("")
    end
    frame:ClearAllPoints()
    frame:Hide()
end

local function InitTalentIconFrame(frame)
    frame:SetSize(16, 16)
    frame.Rank = frame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
    frame.Rank:SetPoint("LEFT", frame, "RIGHT", 2, 0)
    frame.Rank:SetText("0")
    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:SetAllPoints()
end

TotemPowerCharacterMixin = {}
function TotemPowerCharacterMixin:OnLoad()

    NineSliceUtil.ApplyLayout(self, TotemPower.Layouts.Tooltip)

    TotemPower.CallbackRegistry:RegisterCallback("CharacterTalents_OnBroadcast", self.CharacterTalents_OnBroadcast, self)

    self.TalentIcons = CreateFramePool("Frame", self, "TotemPowerBaseTooltipFrame", TalentIconFrameResetFunc, false, InitTalentIconFrame)

end

function TotemPowerCharacterMixin:CharacterTalents_OnBroadcast(info)

    if info.TargetPlayer ~= self.Player then
        return
    end

    self:SetTalentInfo(info)

end

function TotemPowerCharacterMixin:SetTalentInfo(info)
    if info.Talents then
        local lastIcon;
        for k, v in ipairs(info.Talents) do
            local icon = self.TalentIcons:Acquire()
            icon.Icon:SetTexture(C_Spell.GetSpellTexture(v.SpellID))
            if not lastIcon then
                icon:SetPoint("BOTTOMLEFT", 4, 4)
                lastIcon = icon
            else
                icon:SetPoint("LEFT", lastIcon, "RIGHT", 18, 0)
                lastIcon = icon
            end
            icon.SpellID = v.SpellID
            icon.Rank:SetText(v.Rank)
            icon:Show()
        end
    end
end

function TotemPowerCharacterMixin:SetDataBinding(binding, height)
    self.Player = binding.Name;
    self.Name:SetText(binding.Name)

    if TotemPower.PlayerTalentsCache[binding.Name] then
        self:SetTalentInfo(TotemPower.PlayerTalentsCache[binding.Name])
    end

    if TotemPower.PlayerTotemsCache[binding.Name] then
        for element, info in pairs(TotemPower.PlayerTotemsCache[binding.Name]) do
            self[element]:CharacterTotem_OnTotemAssignmentChanged(info)
        end
    end
end

function TotemPowerCharacterMixin:ResetDataBinding()
    self.Player = nil
    self.Name:SetText("")
    self.TalentIcons:ReleaseAll()

    for _, element in ipairs(TotemPower.Elements) do
        self[element]:ResetTotem()
    end

end







--[[
    TotemPowerSecureButton

    Secure Action Button, this is the action bar type button, its used in the totem bar (like in wrath with the 4 elements)
]]
TotemPowerSecureButtonMixin = {}
function TotemPowerSecureButtonMixin:OnLoad()
    self:RegisterForClicks("AnyUp")
    TotemPower.CallbackRegistry:RegisterCallback("CharacterTotem_OnTotemAssignmentChanged", self.CharacterTotem_OnTotemAssignmentChanged, self)
end

function TotemPowerSecureButtonMixin:SetTotemSpellID(spellID)
    self.SpellID = nil
    self.Icon:SetTexture(nil)
    if type(spellID) == "number" then -- and IsPlayerSpell(spellID) then
        local spell = Spell:CreateFromSpellID(spellID)
        if not spell:IsSpellEmpty() then
            spell:ContinueOnSpellLoad(function()
                self.Icon:SetTexture(C_Spell.GetSpellTexture(spellID))
                self:SetAttribute("type", "spell")
                self:SetAttribute("spell", C_Spell.GetSpellName(spellID))
                self.SpellID = spellID
            end)
        end
    end
end

function TotemPowerSecureButtonMixin:CharacterTotem_OnTotemAssignmentChanged(info)

    if self.CommsLocked == true then
        return;
    end

    if info.TargetPlayer ~= UnitName("player") then
        return
    end

    if info.Element ~= self.Element then
        return
    end

    self:SetTotemSpellID(info.SpellID)

end






TotemPowerTotemSetButtonMixin = {}
function TotemPowerTotemSetButtonMixin:OnLoad()
    self.SelectedIndex = 1
    if self.Element then
        self.TotemData = TotemPower.TotemData[TotemPower.Client][self.Element]
    end
    self:SetNormalTexture(310733)
    self:RegisterForClicks("AnyDown")
end

function TotemPowerTotemSetButtonMixin:OnClick()

    if self.TotemData then
        self.SelectedIndex = self.SelectedIndex + 1;
        if self.SelectedIndex > #self.TotemData then
            self.SelectedIndex = 1
        end

        self.SpellID = self.TotemData[self.SelectedIndex]
        self:SetNormalTexture(C_Spell.GetSpellTexture(self.SpellID))

        if self:GetParent().TotemSet then
            self:GetParent().TotemSet.Totems[self.Element] = self.SelectedIndex
        end

    end

end

function TotemPowerTotemSetButtonMixin:SetSelectedIndex(index)
    self.SelectedIndex = index;
    self.SpellID = self.TotemData[self.SelectedIndex]
    self:SetNormalTexture(C_Spell.GetSpellTexture(self.SpellID))
end

function TotemPowerTotemSetButtonMixin:ResetTotem()
    self.SelectedIndex = 1;
    self:SetNormalTexture(310733)
    self.SpellID = nil
end




TotemPowerTotemSetMixin = {}
function TotemPowerTotemSetMixin:OnLoad()
    NineSliceUtil.ApplyLayout(self, TotemPower.Layouts.Tooltip)
end
function TotemPowerTotemSetMixin:SetDataBinding(binding, height)
    self.TotemSet = binding
    self.Name:SetText(binding.TotemSetID)

    for _, element in ipairs(TotemPower.Elements) do
        self[element]:SetSelectedIndex(binding.Totems[element])
    end
end
function TotemPowerTotemSetMixin:ResetDataBinding()
    self.TotemSet = nil
end














TotemPowerPlayerTotemMixin = {}
function TotemPowerPlayerTotemMixin:OnLoad()
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self.Cooldown:SetUseCircularEdge(true)
    self.Cooldown:SetSwipeTexture("Interface/CharacterFrame/TempPortraitAlphaMask", 0.3, 0.6, 1.0, 0.8)
end

function TotemPowerPlayerTotemMixin:OnEvent(event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        --local target, castGUID, _spellID = ...;
        local haveTotem, totemName, startTime, duration, icon, modRate, spellID = GetTotemInfo(self.TotemSlotIndex)
        -- if totemName == "" then
        --     self:Hide()
        --     return
        -- else
        --     self:Show()
        -- end
        if icon then
            self.Icon:SetTexture(icon)
            self.Cooldown:SetCooldown(startTime, duration)
        end
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