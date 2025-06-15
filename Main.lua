

local addonName, TotemPower = ...;

local Comms = TotemPower.Comms;



--[[
    TotemSetDataProvider

    This is the data provider for user created totem sets.
]]
local TotemSetDataProvider = CreateFromMixins(DataProviderMixin)
function TotemSetDataProvider:FindTotemSetByID(totemSetID)
    local totemSet = self:FindElementDataByPredicate(function(totemSet)
        return totemSet.TotemSetID == totemSetID
    end)
    return totemSet;
end
function TotemSetDataProvider:InsertTotemSet(newTotemSet)
    local totemSetExists = self:FindElementDataByPredicate(function(totemSet)
        return newTotemSet.TotemSetID == totemSet.TotemSetID
    end)
    if not totemSetExists then
        self:Insert(newTotemSet)

        --for now just do a full reload on the listview
        TotemPower.CallbackRegistry:TriggerEvent("TotemSet_OnSetAdded")
    end
end



local SavedVariables = {}
function SavedVariables:Init()
    
    if TotemPowerTotemSetsSavedvariables == nil then
        TotemSetDataProvider:Init({})
        TotemPowerTotemSetsSavedvariables = TotemSetDataProvider:GetCollection()
    else
        local data = TotemPowerTotemSetsSavedvariables;
        TotemSetDataProvider:Init(data)
        TotemPowerTotemSetsSavedvariables = TotemSetDataProvider:GetCollection()
    end

    if TotemPowerTotemBarConfig == nil then
        TotemPowerTotemBarConfig = {
            LastTotemSetID = 1,
            IsCommslocked = true,
        }
    end

    self.TotemBarConfig = TotemPowerTotemBarConfig;

end






local EventsFrame = CreateFrame("Frame")
EventsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventsFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        SavedVariables:Init()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)










TotemPowerTotemBarMixin = {}
function TotemPowerTotemBarMixin:OnLoad()

    self:RegisterForDrag("LeftButton")

    self:RegisterEvent("GROUP_ROSTER_UPDATE")

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

    self.TotemSetSelectorButton = CreateFrame("CheckButton", "TotemPowerTotemBarTotemSetSelectorButton", self, "TotemPowerSecureButton")
    self.TotemSetSelectorButton:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", 4, 0)
    self.TotemSetSelectorButton:SetNormalAtlas("search-iconframe-large")
    self.TotemSetSelectorButton.Icon:SetAtlas("common-icon-undo")
    self.TotemSetSelectorButton.Icon:ClearAllPoints()
    self.TotemSetSelectorButton.Icon:SetPoint("TOPLEFT", 6, -6)
    self.TotemSetSelectorButton.Icon:SetPoint("BOTTOMRIGHT", -6, 6)
    self.TotemSetSelectorButton:SetScript("OnClick", function()
        if InCombatLockdown() or UnitAffectingCombat("player") then
            return;
        end
        --print("click")
        --need to cycle through any totem sets the player has
        local lastTotemSetIndex = SavedVariables.TotemBarConfig.LastTotemSetID;
        --print(lastTotemSetIndex)
        if lastTotemSetIndex then
            local set = TotemSetDataProvider:Find(lastTotemSetIndex)
            if set and set.Totems then
                --DevTools_Dump(set)
                for _, button in ipairs(self.ActionButtons) do
                    if set.Totems[button.Element] then
                        --print(button.Element, set.Totems[button.Element])
                        button:SetTotemSpellID(TotemPower.GetTotemSpellIDFromElementIndex(button.Element, set.Totems[button.Element]))
                    end
                end
                SavedVariables.TotemBarConfig.LastTotemSetID = SavedVariables.TotemBarConfig.LastTotemSetID + 1
                if SavedVariables.TotemBarConfig.LastTotemSetID > TotemSetDataProvider:GetSize() then
                    SavedVariables.TotemBarConfig.LastTotemSetID = 1;
                end
            end
        end
    end)

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
                TotemPowerAssignmentsUi:Show()
            end)
        end)
    end)
end

function TotemPowerTotemBarMixin:ToggleButtonCommsLock(locked)
    for _, button in ipairs(self.ActionButtons) do
        button.Commslocked = locked
    end
    SavedVariables.TotemBarConfig.IsCommslocked = locked;
end

function TotemPowerTotemBarMixin:OnEvent(event, ...)
    if event == "GROUP_ROSTER_UPDATE" then
        if IsInGroup() then
            self:ToggleButtonCommsLock(false)
        else
            self:ToggleButtonCommsLock(true)
        end
    end
end











TotemPowerAssignmentsMixin = {}
function TotemPowerAssignmentsMixin:OnLoad()

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
        self:RefreshGroup()
    end)

    TotemPower.CallbackRegistry:RegisterCallback("TotemSet_OnSetAdded", self.LoadTotemSets, self)
    self.TotemSetsList:SetScript("OnShow", function()
        self:LoadTotemSets()
    end)
    self.TotemSetsList.NewTotemSetButton:SetScript("OnClick", function()
        local newSet = {
            TotemSetID = time(),
            Totems = {
                Earth = 1,
                Fire = 1,
                Water = 1,
                Air = 1,
            }
        }
        TotemSetDataProvider:InsertTotemSet(newSet)
    end)

    self:LoadDummyCharacters()

end

function TotemPowerAssignmentsMixin:OnEvent(event, ...)
    if event == "GROUP_ROSTER_UPDATE" then
        self:RefreshGroup()
    end
end

function TotemPowerAssignmentsMixin:RefreshGroup()
    if IsInGroup() then
        self:ParseGroupMembers()
        self:TransmitTalents()
    end
end

function TotemPowerAssignmentsMixin:OnShow()

end

function TotemPowerAssignmentsMixin:TransmitTalents()
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

function TotemPowerAssignmentsMixin:ParseGroupMembers()

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

function TotemPowerAssignmentsMixin:LoadDummyCharacters()

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


function TotemPowerAssignmentsMixin:LoadTotemSets()
    self.TotemSetsList.scrollView:SetDataProvider(TotemSetDataProvider)
end