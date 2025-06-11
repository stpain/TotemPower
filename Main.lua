

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
}


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
        button.Icon:SetAtlas("collections-itemborder-uncollected-innerglow")
        button.Element = Elements[i]
        if not lastButton then
            button:SetPoint("BOTTOMLEFT")
            lastButton = button;
        else
            button:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", 4, 0)
            lastButton = button;
        end
        self.ActionButtons[i] = button;
    end
end













TotemPowerMixin = {}
function TotemPowerMixin:OnLoad()

    TotemPower.Comms:Init()

    self:RegisterForDrag("LeftButton")
    NineSliceUtil.ApplyLayout(self, Layouts.Flyout)

    self.Title:SetText(string.format("%s v%s", addonName, C_AddOns.GetAddOnMetadata(addonName, "Version")))


    self:LoadDummyCharacters()

end


function TotemPowerMixin:LoadDummyCharacters()

    local characters = {
        {
            name = "Tom",
        },
        {
            name = "Dick",
        },
        {
            name = "Harry",
        },
        {
            name = UnitName("player"),
        }
    }

    self.CharacterList.scrollView:SetDataProvider(CreateDataProvider(characters))
end