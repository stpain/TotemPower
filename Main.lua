

local addonName, TotemPower = ...;

local Comms = TotemPower.Comms;


BINDING_HEADER_TOTEMPOWER = addonName
_G["BINDING_NAME_CLICK TotemPowerTotemBarActionButtonSlot1:LeftButton"] = "Earth"
_G["BINDING_NAME_CLICK TotemPowerTotemBarActionButtonSlot2:LeftButton"] = "Fire"
_G["BINDING_NAME_CLICK TotemPowerTotemBarActionButtonSlot3:LeftButton"] = "Water"
_G["BINDING_NAME_CLICK TotemPowerTotemBarActionButtonSlot4:LeftButton"] = "Air"


TotemPowerTotemBarMixin = {}
function TotemPowerTotemBarMixin:OnLoad()
    self:RegisterForDrag("LeftButton")
    self.ActionButtons = {}
    local lastButton;
    for i = 1, 4 do
        local button = CreateFrame("CheckButton", "TotemPowerTotemBarActionButtonSlot"..i, self, "TotemPowerSecureButton")
        button:SetNormalAtlas("search-iconframe-large")
        button.Element = TotemPower.Elements[i]
        if not lastButton then
            button:SetPoint("BOTTOMLEFT", 2, 0)
            lastButton = button;
        else
            button:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", 4, 0)
            lastButton = button;
        end
        self.ActionButtons[i] = button;
    end

    self.HeaderBar = CreateFrame("Frame", nil, self)
    self.HeaderBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT")
    self.HeaderBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT")
    self.HeaderBar:SetHeight(14)
    self.HeaderBar:SetScript("OnMouseDown", function(f)
        f:GetParent():StartMoving()
    end)
    self.HeaderBar:SetScript("OnMouseUp", function(f)
        f:GetParent():StopMovingOrSizing()
    end)

    self.HeaderBar.Title = self.HeaderBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.HeaderBar.Title:SetPoint("TOP")
    self.HeaderBar.Title:SetText(addonName)

    self.HeaderBar.Background = self.HeaderBar:CreateTexture(nil, "BACKGROUND")
    self.HeaderBar.Background:SetColorTexture(0.1, 0.1, 0.1, 0.6)
    self.HeaderBar.Background:SetAllPoints()
    
    self.HeaderBar.MenuButton = CreateFrame("Button", nil, self.HeaderBar)
    self.HeaderBar.MenuButton:SetPoint("TOPRIGHT")
    self.HeaderBar.MenuButton:SetSize(14, 14)
    self.HeaderBar.MenuButton:SetNormalAtlas("OptionsIcon-Brown")
    self.HeaderBar.MenuButton:SetScript("OnClick", function(f)
        MenuUtil.CreateContextMenu(f, function(f, rootDescription)
            rootDescription:CreateTitle(addonName, WHITE_FONT_COLOR)
            rootDescription:CreateDivider()
            rootDescription:CreateButton("Open Assignments", function()
                TotemPowerUi:Show()
            end)
        end)
    end)
end













TotemPowerMixin = {}
function TotemPowerMixin:OnLoad()

    self:RegisterEvent("GROUP_ROSTER_UPDATE")

    TotemPower.Comms:Init()

    self:RegisterForDrag("LeftButton")
    NineSliceUtil.ApplyLayout(self, TotemPower.Layouts.ListviewMetal)

    self.Title:SetText(string.format("%s v%s", addonName, C_AddOns.GetAddOnMetadata(addonName, "Version")))

    self.GroupMembers = {}
    self.MyGroupID = nil;

    local function OnTabSelected(tabID)
        if tabID == 1 then
            self.CharacterList:Show()
            self.TotemSetsList:Hide()
            return
        end
        if tabID == 2 then
            self.CharacterList:Hide()
            self.TotemSetsList:Show()
            return
        end
    end

    self.TabSystem:SetTabSelectedCallback(OnTabSelected)
    self.TabSystem:AddTab("Assignments")
    self.TabSystem:AddTab("Totem Sets")
    self.TabSystem:SetTab(1)

    self.CharacterList.GroupSelectionButton:SetScript("OnClick", function(f)
        if next(self.GroupMembers) ~= nil then
            MenuUtil.CreateContextMenu(f, function(f, rootDescription)
                rootDescription:CreateTitle("Select Group")
                for i = 1, 8 do
                    if self.GroupMembers[i] then
                        rootDescription:CreateButton(string.format("Group %d", i), function()
                            self.CharacterList.scrollView:SetDataProvider(CreateDataProvider(self.GroupMembers[i]))
                        end)
                    end
                end
            end)
        end
    end)

    self.CharacterList.scrollView:SetPadding(1, 1, 1, 1, 6);
    self.CharacterList:SetScript("OnShow", function()
        self:OnShow()
    end)

    self:LoadDummyCharacters()

end

function TotemPowerMixin:OnEvent(event, ...)
    if event == "GROUP_ROSTER_UPDATE" then
        self:ParseGroupMembers()
        self:TransmitTalents()
    end
end

function TotemPowerMixin:OnShow()
    if IsInGroup() then
        self:ParseGroupMembers()
        self:TransmitTalents()
    end
end

function TotemPowerMixin:TransmitTalents()
    local MyTalents = {}
    for k, talents in ipairs(TotemPower.TalentData[TotemPower.Client]) do
        local Entry = {}
        for rank, spellID in ipairs(talents) do
            if IsPlayerSpell(spellID) then
                Entry.SpellID = spellID
                Entry.Rank = rank
            end
        end
        if Entry.SpellID and Entry.Rank then
            table.insert(MyTalents, Entry)
        end
    end
    Comms:Transmit({
        Event = "CharacterTalents_OnBroadcast",
        Payload = {
            TargetPlayer = UnitName("player"),
            Talents = MyTalents,
        },
    }, Comms.Group)
end

function TotemPowerMixin:ParseGroupMembers()

    self.GroupMembers = {}
    self.MyGroupID = nil;

    for i = 1, MAX_RAID_MEMBERS do
        local name, rank, subgroup, level, _, globalClassName = GetRaidRosterInfo(i)

        if name == UnitName("player") then
            self.MyGroupID = subgroup;
        end

        if globalClassName == "SHAMAN" then
            if not self.GroupMembers[subgroup] then
                self.GroupMembers[subgroup] = {}
            end

            table.insert(self.GroupMembers[subgroup], {
                Name = name,
                Level = level,
            })

            table.sort(self.GroupMembers[subgroup], function(a, b)
                return a.Name < b.Name
            end)
        end
    end

    if self.MyGroupID ~= nil then
        self.CharacterList.scrollView:SetDataProvider(CreateDataProvider(self.GroupMembers[self.MyGroupID]))
    end

end

function TotemPowerMixin:LoadDummyCharacters()

    local characters = {
        {
            Name = "Party1",
        },
        {
            Name = "Party2",
        },
        {
            Name = "Party3",
        },
        {
            Name = "Party4",
        },
        {
            Name = UnitName("player"),
        }
    }

    self.CharacterList.scrollView:SetDataProvider(CreateDataProvider(characters))
end