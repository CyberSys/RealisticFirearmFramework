--[[- Configuration and settings functions.

@module RFF.Config
@author Fenris_Wolf
@release 1.0-alpha
@copyright 2018

]]

local Config = {}


-- extra requirements
local EventSystem = require(ENV_RFF_PATH .. "events")
local Const = require(ENV_RFF_PATH .. "constants")
local Logger = require(ENV_RFF_PATH .. "interface/logger")


-- local tables 
local Options = {}
local Settings = {}

-- LogLevel: This controls how much text ORGM prints to the console and log file.
-- valid options are Const.ERROR, Const.WARN, Const.INFO, Const.DEBUG, Const.VERBOSE (default Const.INFO)
-- NOTE: the logging level setting is messy business, since we need to manually copy it over to the Logger table.
Options.LogLevel = {type='integer', min=0, max=4, default=Const.VERBOSE}
Settings.LogLevel = Options.LogLevel.default
Logger.level = Options.LogLevel.default


--[[- adds a new configuration setting with defaults and value limits.

@tparam string key
@tparam table data

]]
Config.add = function(key, data)
    -- TODO: validate data key names (error checking)
    -- TODO: overwrite protection?
    Logger.verbose("Config: adding option " .. key)
    Options[key] = data 
    Settings[key] = data.default
end

--[[- gets a configuration option. 

@tparam string key

@treturn nil|table

]]
Config.option = function(key)
    return Options[key]
end

--[[- resets all configuration options to default. 

This will trigger the "ConfigReset" event

]]
Config.reset = function()
    for key, data in pairs(Options) do
        Settings[key] = data.default
    end
    Logger.level = Settings.LogLevel -- keep our logger in sync
    EventSystem.trigger("ConfigReset")
end


--[[- changes a configuration option. 

This will trigger the "ConfigChange" event (halts on true).

@tparam string key
@tparam string|number|boolean value

@treturn boolean true if changes were applied

]]
Config.set = function(key, value) 
    if not Options[key] then return nil end
    local current = Settings[key]
    Logger.verbose("Config: attempting set " .. key .. " to " .. tostring(value))

    value = Config.validate(key, value)
    if current == value or EventSystem.triggerHalt("ConfigChange", key, current, value) then 
        Logger.verbose("Config: change cancelled " .. key .. " to " .. tostring(value))
        return false 
    end
    Settings[key] = value
    Logger.level = Settings.LogLevel -- keep our logger in sync
    Logger.debug("Config: " .. key .. " set to " .. tostring(value))
    return true    
end


--[[- gets the current value for a configuration option. 

@tparam string key

@treturn nil|string|number|boolean

]]
Config.get = function(key)
    return Settings[key]
end


--[[- gets the default value for a configuration option. 

@tparam string key

@treturn nil|string|number|boolean

]]
Config.default = function(key) 
    if not Options[key] then return nil end
    return Options[key].default
end


--[[- checks if a value is valid for a configuration option, and returns a valid version.

@tparam string key
@tparam string|number|boolean value

@treturn nil|string|number|boolean

]]
Config.validate = function(key, value) 
    local options = Options[key]
    if not options then
        Logger.error("Config: attempted to validate non-existant option " .. key) 
        return nil 
    end
    local validType = options.type
    Logger.verbose("Config: validating key "..key)

    if validType == 'integer' or validType == 'float' then validType = 'number' end
    if type(value) ~= validType then -- wrong type
        value = options.default
        Logger.error("Config: " .. key .. " is invalid type (value "..tostring(value).." should be type "..options.type.."). Setting to default "..tostring(options.default))
    end
    
    if options.type == 'integer' and value ~= math.floor(value) then
        value = math.floor(value)
        Logger.error("Config: " .. key .. " is invalid type (value "..tostring(value).." should be integer not float). Setting to default "..tostring(math.floor(value)))
    end
    if validType == 'number' then
        if (options.min and value < options.min) or (options.max and value > options.max) then
            value = options.default -- TODO: this should actually just clamp in the range instead of reverting to default.
            Logger.error("Config: " .. key .. " is invalid range (value "..tostring(value).." should be between min:"..(options.min or '')..", max:" ..(options.max or '').."). Setting to default "..tostring(options.default))
        end
    end
    return value
end


return Config
