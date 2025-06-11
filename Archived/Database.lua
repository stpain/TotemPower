local name, addon = ...;

local json = LibStub('JsonLua-1.0');

local Database = {}

local configUpdates = {

}

function Database:Init()

    local version = tonumber(GetAddOnMetadata(name, "Version"));

    if not TOTEM_POWER_ACCOUNT then
        TOTEM_POWER_ACCOUNT = {
            config = {

            },
            minimapButton = {},
            myCharacters = {},
            characterDirectory = {},
            debug = false,
            version = version,
        }    
    end

    if TOTEM_POWER_ACCOUNT.version < version then
            
    end

    self.db = TOTEM_POWER_ACCOUNT;

    for k, v in pairs(configUpdates) do
        if not self.db.config[k] then
            self.db.config[k] = v;
        end
    end

    addon:TriggerEvent("Database_OnInitialised")
end

function Database:Reset()

    local version = tonumber(GetAddOnMetadata(name, "Version"));

    TOTEM_POWER_ACCOUNT = {
        config = {

        },
        minimapButton = {},
        myCharacters = {},
        characterDirectory = {},
        debug = false,
        version = version,
    }

    self.db = TOTEM_POWER_ACCOUNT;

    addon.guilds = {}
    addon.characters = {}

    addon:TriggerEvent("Database_OnInitialised")
end

function Database:ImportData(data)
    local import = json.decode(data)
    if import then
        if import.name and import.data and import.version then
            DevTools_Dump(import)
        end
    end
end

function Database:InsertCharacter(character)
    if self.db then
        self.db.characterDirectory[character.name] = character;
        addon:TriggerEvent("StatusText_OnChanged", string.format("[InsertCharacter] %s", character.name))
    end
end

function Database:GetCharacter(nameRealm)
    if self.db and self.db.characterDirectory[nameRealm] then
        return self.db.characterDirectory[nameRealm];
    end
end

function Database:SetConfig(conf, val)
    if self.db and self.db.config then
        self.db.config[conf] = val
        addon:TriggerEvent("Database_OnConfigChanged", conf, val)
    end
end

function Database:GetConfig(conf)
    if self.db and self.db.config then
        return self.db.config[conf];
    end
    return false;
end

addon.Database = Database;