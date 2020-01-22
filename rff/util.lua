local Util = {}

local pairs = pairs
--[[- Checks if a value is in the specified table.

This is for scanning unsorted lists/dictionary tables by using a pairs() loop.

@tparam table thisTable table to check
@tparam any value data value to look for

@treturn bool

@usage local result = Util.tableContains({"a", "b", "c"}, "b")

]]
Util.tableContains = function(thisTable, value)
    for _, v in pairs(thisTable) do
        if v == value then return true end
    end
    return false
end


--[[- Removes a entry by value in a table.

@tparam table thisTable table to check
@tparam any value data value to remove

@treturn bool true if removed

@usage Util.tableRemove({"a", "b", "c"}, "b")

]]
Util.tableRemove = function(thisTable, value)
    for _, v in pairs(thisTable) do
        if v == value then return true end
    end
    return false
end

Util.isSuperSonic = function(speed, temp)
    -- speed is projectile vel in meters per sec, temp is C
    local sound = (331.3+0.606 * temp)
    return speed >= sound 
end

return Util
