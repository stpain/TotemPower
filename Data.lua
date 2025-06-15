

local addonName, TotemPower = ...;

BINDING_HEADER_TOTEMPOWER = addonName
_G["BINDING_NAME_CLICK TotemPowerTotemBarActionButtonSlot1:LeftButton"] = "Earth"
_G["BINDING_NAME_CLICK TotemPowerTotemBarActionButtonSlot2:LeftButton"] = "Fire"
_G["BINDING_NAME_CLICK TotemPowerTotemBarActionButtonSlot3:LeftButton"] = "Water"
_G["BINDING_NAME_CLICK TotemPowerTotemBarActionButtonSlot4:LeftButton"] = "Air"
_G["BINDING_NAME_CLICK TotemPowerTotemBarTotemSetSelectorButton:LeftButton"] = "Swap totem sets"

TotemPower.Client = "Vanilla"

if WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
    TotemPower.Client = "Tbc";
end

TotemPower.Elements = {
    "Earth",
    "Fire",
    "Water",
    "Air",
}

TotemPower.Layouts = {
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
    Tooltip = {
        TopLeftCorner =	{ atlas = "Tooltip-NineSlice-CornerTopLeft", x=-3, y=3 },
        TopRightCorner =	{ atlas = "Tooltip-NineSlice-CornerTopRight", x=3, y=3 },
        BottomLeftCorner =	{ atlas = "Tooltip-NineSlice-CornerBottomLeft", x=-3, y=-3 },
        BottomRightCorner =	{ atlas = "Tooltip-NineSlice-CornerBottomRight", x=3, y=-3 },
        TopEdge = { atlas = "_Tooltip-NineSlice-EdgeTop", },
        BottomEdge = { atlas = "_Tooltip-NineSlice-EdgeBottom", },
        LeftEdge = { atlas = "!Tooltip-NineSlice-EdgeLeft", },
        RightEdge = { atlas = "!Tooltip-NineSlice-EdgeRight", },
    },
    ListviewMetal = {
        TopLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopLeft", x=-15, y=15 },
        TopRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopRight", x=15, y=15 },
        BottomLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomLeft", x=-15, y=-15 },
        BottomRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomRight", x=15, y=-15 },
        TopEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeTop", },
        BottomEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeBottom", },
        LeftEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeLeft", },
        RightEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeRight", },
        Center = { layer = "BACKGROUND", atlas = "ClassHall_InfoBoxMission-BackgroundTile", x = -20, y = 20, x1 = 20, y1 = -20 },
    },
    GenericMetal = {
		TopLeftCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = -6, y = 6, mirrorLayout = true, },
		TopRightCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = 6, y = 6, mirrorLayout = true, },
		BottomLeftCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = -6, y = -6, mirrorLayout = true, },
		BottomRightCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = 6, y = -6, mirrorLayout = true, },
		TopEdge = { atlas = "_UI-Frame-GenericMetal-EdgeTop", },
		BottomEdge = { atlas = "_UI-Frame-GenericMetal-EdgeBottom", },
		LeftEdge = { atlas = "!UI-Frame-GenericMetal-EdgeLeft", },
		RightEdge = { atlas = "!UI-Frame-GenericMetal-EdgeRight", },
	},
}

TotemPower.TotemData = {
    Vanilla = {
        Earth = {
            10408, --stoneskin
            10442, --strength
            10428, --stoneclaw
            2484, --earthbind
            8143, --tremor
        },
        Fire = {
            16387, --flametongue
            10479, --frost res
            10438, --searing
            10587, --magma
            11315, --fire nova
        },
        Water = {
            10538, --fire res
            10463, --healing stream
            10497, --mana spring
            8170, --disease cleansing
            8166, --poison cleansing
        },
        Air = {
            25359, --grace of air
            10601, --nature res
            15112, --windwall
            10614, --windfury
            8177, --grounding
            25908, --tranquil
        },
    },
    Tbc = {

    },
    Wrath = {

    },
}
function TotemPower.GetTotemSpellIDFromElementIndex(element, index)
    if TotemPower.TotemData[TotemPower.Client][element] and TotemPower.TotemData[TotemPower.Client][element][index] then
        return TotemPower.TotemData[TotemPower.Client][element][index]
    end
end


TotemPower.TalentData = {
    Vanilla = {
        { 16038, 16160, 16161, }, --call of flame - increase fire totem damage
        { 16086, 16544, }, --improved fire totems
        { 16089, }, --elemental fury
        { 16258, 16293, }, --guardian totems
        { 16259, 16295, }, --enhancing totems
        { 29192, 29193, }, --enhanced weapons
        { 16173, 16222, 16223, 16224, 16225, }, --totemic focus
        { 16189, }, --totemic mastery
        { 16187, 16205, 16206, 16207, 16208, }, --restore totems
        { 16190, }, --mana tide


        --testing
        { 8940, },
        { 3627, },
    }
}





--[[
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
]]