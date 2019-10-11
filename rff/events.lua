local EventSystem = {}

local Logger = require(ENV_RFF_PATH .. "interface/logger")

local EventTable = { }
    -- predefined events:
EventTable.MagazineInsert = { }
EventTable.MagazineEject = { }
EventTable.MagazineLoad = { }
EventTable.MagazineUnload = { }
EventTable.FirearmReload = { }
EventTable.FirearmUnload = { }
EventTable.RoundChambered = { }

EventTable.TriggerPulled = { }
EventTable.ShotFired = { }

EventTable.BoltOpened = { }
EventTable.BoltClosed = { }
EventTable.HammerCocked = { }
EventTable.HammerReleased = { }


EventTable.ConfigChange = { }
EventTable.ConfigReset = { }

local ipairs = ipairs
local table = table
 
local find = function(tbl, value)
    for i,v in ipairs(tbl) do
        if v == value then return i end
    end
    return nil
end

EventSystem.trigger = function(type, ...)
    local event = EventTable[type] or { }
    Logger.verbose("EventSystem: triggering " .. type)
    for _, callback in ipairs(event) do
        callback(...)
    end
end

EventSystem.triggerHalt = function(type, ...)
    local event = EventTable[type] or { }
    local result = false
    Logger.verbose("EventSystem: triggering " .. type .. " (with halt)")
    for _, callback in ipairs(event) do
        result = callback(...)
        if result then return result end
    end
    return result
end


EventSystem.add = function(type, callback)
    EventTable[type] = EventTable[type] or { }
    table.insert(EventTable[type], callback)
    Logger.verbose("EventSystem: adding callback for " .. type)
end

EventSystem.remove = function(type, callback)
    local event = EventTable[type] or { }
    table.remove(event, callback)
    Logger.verbose("EventSystem: removing callback for " .. type)
end

-- TODO: add insert, replace functions.

return EventSystem
