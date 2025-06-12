

local addonName, TotemPower = ...;

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
    }
}