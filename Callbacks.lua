local name, TotemPower = ...;

TotemPower.CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
TotemPower.CallbackRegistry:OnLoad()
TotemPower.CallbackRegistry:GenerateCallbackEvents({
    "CharacterTotem_OnTotemAssignmentChanged",
    "CharacterTalents_OnBroadcast",
    "TotemSet_OnSetAdded",
    "TotemSet_OnSetChanged",
    "TotemSet_OnSetRemoved",
})
