

local name, TotemPower = ...;

local AceComm = LibStub:GetLibrary("AceComm-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub:GetLibrary("LibSerialize")

local Comms = {
    Prefix = "TotemPower", --name var was to long
    Version = 1,
    Paused = false,

    Group = "RAID",
    Whisper = "WHISPER",
};


TotemPower.PlayerTalentsCache = {}
TotemPower.PlayerTotemsCache = {}


function Comms:Init()
    
    AceComm:Embed(self);
    self:RegisterComm(self.Prefix);

    self.Version = tonumber(C_AddOns.GetAddOnMetadata(name, "Version"));

end

function Comms:Player_Regen_Enabled()
    self.Paused = false;
end

function Comms:Player_Regen_Disabled()
    self.Paused = true;
end


function Comms:Transmit(msg, channel, target)

    msg.Version = self.Version;

    local serialized = LibSerialize:Serialize(msg);
    local compressed = LibDeflate:CompressDeflate(serialized);
    local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
    self:SendCommMessage(self.Prefix, encoded, channel, target, "NORMAL")
end

local CallbackEvents = {
    CharacterTotem_OnSelectionChanged = function(sender, payload)
        if not TotemPower.PlayerTotemsCache[payload.TargetPlayer] then
            TotemPower.PlayerTotemsCache[payload.TargetPlayer] = {}
        end
        TotemPower.PlayerTotemsCache[payload.TargetPlayer][payload.Element] = payload
        TotemPower.CallbackRegistry:TriggerEvent("CharacterTotem_OnSelectionChanged", payload)
    end,
    CharacterTalents_OnBroadcast = function(sender, payload)
        TotemPower.PlayerTalentsCache[payload.TargetPlayer] = payload;
        TotemPower.CallbackRegistry:TriggerEvent("CharacterTalents_OnBroadcast", payload)
    end,
}

function Comms:OnCommReceived(Prefix, message, distribution, sender)

    if Prefix ~= self.Prefix then 
        return 
    end
    local decoded = LibDeflate:DecodeForWoWAddonChannel(message);
    if not decoded then
        return;
    end
    local decompressed = LibDeflate:DecompressDeflate(decoded);
    if not decompressed then
        return;
    end
    local success, data = LibSerialize:Deserialize(decompressed);
    if not success or type(data) ~= "table" then
        return;
    end

    data.sender = sender;

    if CallbackEvents[data.Event] then
        CallbackEvents[data.Event](sender, data.Payload)
    end

    -- print("------------------------")
    -- print(sender)
    -- print("------------------------")
    -- DevTools_Dump(data)
    -- print("========================")
end




TotemPower.Comms = Comms;