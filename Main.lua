

local addonName, TotemPower = ...;

local Layouts = {
	Flyout = {
		TopLeftCorner =	{ atlas = "CharacterCreateDropdown-NineSlice-CornerTopLeft", x = -36, y = 20, },
		TopRightCorner =	{ atlas = "CharacterCreateDropdown-NineSlice-CornerTopRight", x = 36, y = 20, },
		BottomLeftCorner =	{ atlas = "CharacterCreateDropdown-NineSlice-CornerBottomLeft", x = -36, y = -40, },
		BottomRightCorner =	{ atlas = "CharacterCreateDropdown-NineSlice-CornerBottomRight", x = 36, y = -40, },
		TopEdge = { atlas = "_CharacterCreateDropdown-NineSlice-EdgeTop", },
		BottomEdge = { atlas = "_CharacterCreateDropdown-NineSlice-EdgeBottom", },
		LeftEdge = { atlas = "!CharacterCreateDropdown-NineSlice-EdgeLeft", },
		RightEdge = { atlas = "!CharacterCreateDropdown-NineSlice-EdgeRight", },
		Center = { atlas = "CharacterCreateDropdown-NineSlice-Center", },
	},
    DarkTooltip = {
        TopLeftCorner =	{ atlas = "ChatBubble-NineSlice-CornerTopLeft", x = -2, y = 2, },
        TopRightCorner =	{ atlas = "ChatBubble-NineSlice-CornerTopRight", x = 2, y = 2, },
        BottomLeftCorner =	{ atlas = "ChatBubble-NineSlice-CornerBottomLeft", x = -2, y = -2, },
        BottomRightCorner =	{ atlas = "ChatBubble-NineSlice-CornerBottomRight", x = 2, y = -2, },
        TopEdge = { atlas = "_ChatBubble-NineSlice-EdgeTop", },
        BottomEdge = { atlas = "_ChatBubble-NineSlice-EdgeBottom"},
        LeftEdge = { atlas = "!ChatBubble-NineSlice-EdgeLeft", },
        RightEdge = { atlas = "!ChatBubble-NineSlice-EdgeRight", },
        Center = { atlas = "ChatBubble-NineSlice-Center", },
	},
    ParentBorder = {
        TopLeftCorner =	{ atlas = "Tooltip-NineSlice-CornerTopLeft", x=-3, y=3 },
        TopRightCorner =	{ atlas = "Tooltip-NineSlice-CornerTopRight", x=3, y=3 },
        BottomLeftCorner =	{ atlas = "Tooltip-NineSlice-CornerBottomLeft", x=-3, y=-3 },
        BottomRightCorner =	{ atlas = "Tooltip-NineSlice-CornerBottomRight", x=3, y=-3 },
        TopEdge = { atlas = "_Tooltip-NineSlice-EdgeTop", },
        BottomEdge = { atlas = "_Tooltip-NineSlice-EdgeBottom", },
        LeftEdge = { atlas = "!Tooltip-NineSlice-EdgeLeft", },
        RightEdge = { atlas = "!Tooltip-NineSlice-EdgeRight", },
    },
}

BINDING_HEADER_TOTEMPOWER = addonName
_G["BINDING_NAME_CLICK TotemPowerTotemBarActionButtonSlot1:LeftButton"] = "Earth"
_G["BINDING_NAME_CLICK TotemPowerTotemBarActionButtonSlot2:LeftButton"] = "Fire"
_G["BINDING_NAME_CLICK TotemPowerTotemBarActionButtonSlot3:LeftButton"] = "Water"
_G["BINDING_NAME_CLICK TotemPowerTotemBarActionButtonSlot4:LeftButton"] = "Air"


local Elements = {
    "Earth",
    "Fire",
    "Water",
    "Air",
}

TotemPowerTotemBarMixin = {}
function TotemPowerTotemBarMixin:OnLoad()
    self:RegisterForDrag("LeftButton")
    self.ActionButtons = {}
    local lastButton;
    for i = 1, 4 do
        local button = CreateFrame("CheckButton", "TotemPowerTotemBarActionButtonSlot"..i, self, "TotemPowerSecureButton")
        button:SetNormalAtlas("search-iconframe-large")
        button.Element = Elements[i]
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
    NineSliceUtil.ApplyLayout(self, Layouts.DarkTooltip)

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
    self.TabSystem:AddTab("Group")
    self.TabSystem:AddTab("Totem Sets")
    self.TabSystem:SetTab(1)


    self.GroupSelectionButton:SetScript("OnClick", function(f)
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

    self:LoadDummyCharacters()

end

function TotemPowerMixin:OnEvent(event, ...)
    if event == "GROUP_ROSTER_UPDATE" then
        self:ParseGroupMembers()
    end
end

function TotemPowerMixin:TransmitTalents()

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
            Name = UnitName("player"),
        }
    }

    self.CharacterList.scrollView:SetDataProvider(CreateDataProvider(characters))
end