local ItemGroup = {}
ItemGroup._GroupTable = {}

local Logger = require(ENV_RFF_PATH .. "interface/logger")

--[[- The RFF.ItemGroup class is a super-class for organizing items and sub-groups.

It is not intended be used directly, but provides a common code base for various subclasses
such as `RFF.Firearm.FirearmGroup`, `RFF.Magazine.MagazineGroup`, `RFF.Ammo.AmmoGroup`, etc.

This class is provides the core functionality spawn calculations, multi-capacity magazines, multiple ammo
types per gun. To be used in conjunction with the `RFF.ItemType` class

    @classmod Group
    @author Fenris_Wolf
    @release 1.00-alpha
    @copyright 2018
    
]]

--[[- Creates a new group.

@tparam string id the name of the new group
@tparam table data a table containing additional information for this group.

@treturn table a new Group object

]]
function ItemGroup:new(id, data)
    -- TODO: this probably needs a friendly string name now as well as id 
    local o = { }
    o._size = 0 -- track member count, faster then using #self.members

    -- copy all keys from our data table
    for key, value in pairs(data or {}) do o[key] = value end
    setmetatable(o, { __index = self })
    o.type = id -- WARNING: DEPRECIATED, replace all instances! 
    o.id = id
    
    -- add as a subgroup of specified groups
    for gname, weight in pairs(o.Groups or { }) do
        group = o._GroupTable[gname]
        if group then
            group:add(id, weight)
        else
            Logger.warn("Group: " .. id .. " requested to join invalid group "..gname)
        end
    end
    o._GroupTable[id] = o

    o.members = { }
    Logger.verbose("Group: Registered " .. id)
    return o
end


function ItemGroup:len()
    return self._size
end

function ItemGroup:count(recurse, ignore, depth)
    local result = 0
    depth = depth or 0
    if depth > 20 then return nil end
    depth = 1 + depth

    for name, weight in pairs(self.members) do repeat
        if ignore and weight == 0 then break end

        -- check if our result is another Group object, and call recursively
        local group = self._GroupTable[name]
        if not group then
            result = 1 + result
        elseif recurse then
            result = result + group:count(recurse, ignore, depth)
        end

    until true end
    return result
end

--[[- Normalizes the weights of items in the group.

This is generally called during `Group.random` and returns a new table instead of
modifying the existing table which remains in a non-normalized state.

If defined, the filter function should take 3 arguments (self, itemName, weight) and return a float.
Be aware the filter will be called twice, once during the sum checking phase, and again during
normalization of the resulting table

@tparam[opt] table modifiers a table containing Group or ItemType names and multipliers
@tparam[opt] function filter a function that adds or subtracts to the multiplier

@treturn table a table of normalized values

]]
function ItemGroup:normalize(modifiers, filter)
    local sum = 0
    modifiers = modifiers or {}

    -- need to loop through our members twice. once to calculate the sum of all values
    for itemName, weight in pairs(self.members) do
        local mod = (modifiers[itemName] or 1) + (filter and filter(self, itemName, weight) or 0)
        -- TODO: fix year limiter on normalization
        --local year = (self._ItemTable[itemName] and self._ItemTable[itemName].year) or (self._GroupTable[itemName] and self._GroupTable[itemName].year)
        --if Settings.LimitYear and Settings.LimitYear ~= 0 and year and year > Settings.LimitYear then mod = 0 end
        sum = sum + weight * mod
    end
    -- second time we can actually set the new values.
    local members = {}
    for itemName, weight in pairs(self.members) do
        local mod = ((modifiers[itemName] or 1) + (filter and filter(self, itemName, weight) or 0))
        -- TODO: fix year limiter on normalization
        --local year = (self._ItemTable[itemName] and self._ItemTable[itemName].year) or (self._GroupTable[itemName] and self._GroupTable[itemName].year)
        --if Settings.LimitYear and  Settings.LimitYear ~= 0 and year and year > Settings.LimitYear then mod = 0 end
        members[itemName] = weight * mod  / sum
    end
    return members
end


--[[- Adds a item to a group, or adjusts its weight.

This is generally called during `ItemType.new` when creating new items, but can be called
at any point. The weight value is the priority given to that item when `Group.random` is
called.

The effects on spawn tables after calling this function are immediate.

@tparam itemName string the name of the item or sub-group
@tparam integer the weight of this item in the group

]]
function ItemGroup:add(itemName, weight)
    if not self.members[itemName] then self._size = 1 + self._size end
    self.members[itemName] = weight or 1
end


--[[- Removes a item from a group.

The effects on spawn tables after calling this function are immediate.

@tparam itemName string the name of the item or sub-group

]]
function ItemGroup:remove(itemName)
    if self.members[itemName] then self._size = self._size - 1 end
    self.members[itemName] = nil
end


--[[- Randomly, and Recursively selects a ItemType from the groups members.

This is generally called during `Group.random` and returns a new table instead of
modifying the existing table which remains in a non-normalized state.

If defined, the filter function should take 3 arguments (self, itemName, weight) and return a float

@tparam[opt] table modifiers a table passed to `Group.normalize`
@tparam[opt] function filter a function passed to `Group.normalize`
@tparam[opt] integer depth should not be set manually. Used internally by this function during recursion


@treturn nil|table a ItemType class object

]]
function ItemGroup:random(modifiers, filter, depth)
    -- check recursion limit
    if depth == nil then depth = 0 end
    if depth > 20 then return nil end
    depth = 1 + depth

    -- get normalized and filtered group members table
    local members = self.members
    members = self:normalize(modifiers, filter)
    -- fetch a random result
    local sum = 0
    local roll = math.random()
    local result = nil
    for itemName, weight in pairs(members) do
        sum = sum + weight
        if roll <= sum then
            result = itemName
            break
        end
    end

    -- check if our result is another Group object, and call recursively
    local group = self._GroupTable[result]
    if group then
        Logger.verbose("Group: random for '".. self.id .. "' picked '"..group.id .."'")
        return group:random(modifiers, filter, depth)
    end

    -- not a Group, return a ItemType
    local result = self._ItemTable[result]

    Logger.verbose("Group: random for '".. self.id .. "' picked '" ..(result and result.id or "nil").. "'")
    return result
end


--[[- Tests (non-recursively) if a Group contains a specified subgroup or itemtype

@tparam itemName string the name of the item or sub-group

@treturn bool

]]
function ItemGroup:contains(itemName)
    itemName = type(itemName) == 'table' and itemName.id or itemName
    return self.members[itemName] ~= nil
end

return ItemGroup
