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

return Const
