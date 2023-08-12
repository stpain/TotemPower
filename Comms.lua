--[[
    Comms:
        The Comms class is used to send and receive data on the GUILD channel and WHISPER channel

        There is a queue system to prevent the addon spamming chat channels and disrupting other addon communications.
        The queue is simple, messages get added to the queue and are held for n number of seconds, during this time
        and new data of the same message type will cause the currently queued message to be updated rather than a new
        message added to the queue.
        Once a message dispatch time arrives the message will be sent and the remaining queued messages will have their
        dispatch time increased by n seconds. This means the addon will only send a message once every n seconds, and 
        where cases exists that a message might be spammed, it'll be caught by the initial delay.

        The guild bank messages ignore the queue and mostly use the WHISPER channel.
]]

local name, addon = ...;

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

    self.version = tonumber(GetAddOnMetadata(name, "Version"));

    -- addon:TriggerEvent("StatusText_OnChanged", "[Comms:Init]")
    -- addon:RegisterCallback("Player_Regen_Enabled", self.Player_Regen_Enabled, self)
end

--pause comms during combat
--this setup doesn't affect guild bank and non queue comms, however checking the banks wouuld likely be done in a city or rested area
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

    if data.type then
        if data.type == "PLAYER_TOTEMS" then
            addon:TriggerEvent("Character_OnTotemDataReceived", data)
        end

        if data.type == "TOTEM_ASSIGNMENT" then
            addon:TriggerEvent("Character_OnTotemAssignment", data)
        end

        if data.type == "SHIELD_ASSIGNMENT" then
            addon:TriggerEvent("Character_OnShieldAssignment", data)
        end

        if data.type == "EMBUE_ASSIGNMENT" then
            addon:TriggerEvent("Character_OnEmbueAssignment", data)
        end
    end

    --DevTools_Dump(data)
end



addon.Comms = Comms;