local Logger = {}

local Const = require(ENV_RFF_PATH .. "constants")

Logger.level = 2 -- default value, just incase it doesnt get set
--[[- Basic logging function.

By default prints a message to stdout if Logger.level is equal or less then the level arguement.

@tparam int level logging level constant
@tparam string text text message to log.

@usage Logger.log(ORGM.WARN, "this is a warning log message")

]]
Logger.log = function(level, text)
    if not Logger.level or level > Logger.level then return end
    local prefix = "RFF." .. (Const.LogLevelStrings[level] or "") .. ": "
    print(prefix .. text)
end


Logger.verbose = function(text)
    Logger.log(Const.VERBOSE, text)
end

Logger.debug = function(text)
    Logger.log(Const.DEBUG, text)
end

Logger.info = function(text)
    Logger.log(Const.INFO, text)
end

Logger.warn = function(text)
    Logger.log(Const.WARN, text)
end

Logger.error = function(text)
    Logger.log(Const.ERROR, text)
end

return Logger
