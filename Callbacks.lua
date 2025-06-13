local name, TotemPower = ...;

TotemPower.CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
TotemPower.CallbackRegistry:OnLoad()
TotemPower.CallbackRegistry:GenerateCallbackEvents({
    "CharacterTotem_OnSelectionChanged",
    "CharacterTalents_OnBroadcast",
})
