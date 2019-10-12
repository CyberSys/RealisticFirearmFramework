--[[- Various constant values.

@module RFF.Const
@author Fenris_Wolf
@release 1.0-alpha
@copyright 2018

]]
local Const = { }

--[[- Logging Constants.
These are passed to and checked when making calls to the default logging function.
@section Logging
]]

--- integer 0
Const.ERROR = 0
--- integer 1
Const.WARN = 1
--- integer 2
Const.INFO = 2
--- integer 3
Const.DEBUG = 3
--- integer 4
Const.VERBOSE = 4

Const.LogLevelStrings = { [0] = "ERROR", [1] = "WARN", [2] = "INFO", [3] = "DEBUG", [4] = "VERBOSE"}

--- Category Constants
-- @section Category

--- integer 1
Const.REVOLVER = 1
--- integer 2
Const.PISTOL = 2
--- integer 4
Const.MACHINEPISTOL = 4
--- integer 8
Const.SUBMACHINEGUN = 8
--- integer 16
Const.RIFLE = 16
--- integer 32
Const.SHOTGUN = 32
--- integer 64
Const.LIGHTMACHINEGUN = 64


return Const
