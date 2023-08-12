local name, addon = ...;


Mixin(addon, CallbackRegistryMixin)
addon:GenerateCallbackEvents({
    "Database_OnInitialised",
    "Database_OnCharacterAdded",
    "Database_OnConfigChanged",

    "Character_OnTotemDataReceived",
    "Character_OnTotemAssignment",
    "Character_OnShieldAssignment",
    "Character_OnEmbueAssignment",

    "Player_Regen_Disabled",
    "Player_Regen_Enabled",

    "OnRaidRosterUpdate",
    "OnPartyRosterUpdate",
})
CallbackRegistryMixin.OnLoad(addon);