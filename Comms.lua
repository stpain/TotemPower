

local name, TotemPower = ...;

local AceComm = LibStub:GetLibrary("AceComm-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub:GetLibrary("LibSerialize")

local Comms = {
    prefix = "TotemPower", --name var was to long
    version = 1,
    paused = false,
};


function Comms:Init()
    
    AceComm:Embed(self);
    self:RegisterComm(self.prefix);

    self.version = tonumber(C_AddOns.GetAddOnMetadata(name, "Version"));

end

function Comms:Player_Regen_Enabled()
    self.paused = false;
end

function Comms:Player_Regen_Disabled()
    self.paused = true;
end


function Comms:Transmit(msg, channel, target)

    msg.version = self.version;
    msg.senderGuid = UnitGUID("player");

    local serialized = LibSerialize:Serialize(msg);
    local compressed = LibDeflate:CompressDeflate(serialized);
    local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
    self:SendCommMessage(self.prefix, encoded, channel, target, "NORMAL")
end

local CallbackEvents = {
    CharacterTotem_OnSelectionChanged = function(payload)
        TotemPower.CallbackRegistry:TriggerEvent("CharacterTotem_OnSelectionChanged", payload)
    end,
}

function Comms:OnCommReceived(prefix, message, distribution, sender)

    if prefix ~= self.prefix then 
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
        CallbackEvents[data.Event](data.Payload)
    end

    --DevTools_Dump(data)
end




TotemPower.Comms = Comms;