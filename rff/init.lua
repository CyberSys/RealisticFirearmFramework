if not ENV_RFF_PATH then
    ENV_RFF_PATH = ""
end

local RFF = { }
RFF.Const = require(ENV_RFF_PATH .. "constants")
RFF.Config = require(ENV_RFF_PATH .. "config")
RFF.Interface = require(ENV_RFF_PATH .. "interface")
RFF.EventSystem = require(ENV_RFF_PATH .. "events")


return RFF
