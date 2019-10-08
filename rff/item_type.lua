--[[- The RFF.ItemType class is a super-class for tracking item data.

It is not intended be used directly, but provides a common code base for various subclasses
such as `RFF.Firearm.FirearmType`, `RFF.Magazine.MagazineType`, `RFF.Ammo.AmmoType`, etc.

This class is responsable for registering items with the RFF core, and providing methods for
accessing to item's data

    @classmod ItemType
    @author Fenris_Wolf
    @release 4.00
    @copyright 2018 

]]

local Logger = require(ENV_RFF_PATH .. "interface/logger")

local ItemType = {}
ItemType._PropertiesTable = {}
ItemType._GroupTable = {}
ItemType._ItemTable = {}


--[[ copies key/value pairs from a source table to a destination table, with validation.

The properties argument contains the rules used for validation, as well as knowing which
key/values to copy, and any default values for missing keys.

A example properties table used by the AmmoType subclass:
```
local PropertiesTable = {
    MinDamage = {type='float', min=0, max=100, default=0.2},
    MaxDamage = {type='float', min=0, max=100, default=1},
    Range = {type='integer', min=0, max=100, default=20},
    Weight = {type='float', min=0, max=100, default=0.01},
    Recoil = {type='float', min=0, max=100, default=20},
    Penetration = {type='integer', min=0, max=100, default=0},
    MaxHitCount = {type='integer', min=1, max=100, default=1},
    BoxCount = {type='integer', min=0, default=20},
    CanCount = {type='integer', min=0, default=200},
    Icon = {type='string', default=nil},
    category = {type='integer', min=Flags.PISTOL, max=Flags.SHOTGUN, default=Flags.PISTOL, required=true},
    features = {type='integer', min=0, default=0, required=true},
}
```

@tparam string logPrefix a string to prefix on log messages, usually containing the item's name
@tparam table properties a table of validation rules and default values
@tparam table source
@tparam table destination

@treturn bool true if the validation passes, false on failure.

Note on failure not all properties maybe copied (early return)

]]
local copyPropertiesTable = function(logPrefix, properties, source, destination)
    for propName, options in pairs(properties) do
        local validType = options.type
        local value = destination[propName] or source[propName]
        destination[propName] = value
        if validType == 'integer' or validType == 'float' then validType = 'number' end
        local wasNil = value == nil
        if type(value) ~= validType then -- wrong type
            if wasNil and options.required then
                Logger.error(logPrefix .. " property " .. propName .. " is invalid type (value "..tostring(value).." should be type "..options.type.."). Setting to default "..tostring(options.default))
                if options.default == nil then return false end
            end

            value = options.default
        end

        if options.type == 'integer' and value ~= math.floor(value) then
            if wasNil and options.required then
                Logger.error(logPrefix .. " property " .. propName .. " is invalid type (value "..tostring(value).." should be integer not float). Setting to default "..tostring(math.floor(value)))
            end
            value = math.floor(value)
        end

        if validType == 'number' then
            if (options.min and value < options.min) or (options.max and value > options.max) then
                if wasNil and options.required then
                    Logger.error(logPrefix .. " property " .. propName .. " is invalid range (value "..tostring(value).." should be between min:"..(options.min or '')..", max:" ..(options.max or '').."). Setting to default "..tostring(options.default))
                end
                value = options.default
            end
        end
        destination[propName] = value
    end
    return true
end


--[[- Creates a new ItemType.

@tparam string itemName the name of the new Item
@tparam table itemData a table containing aditional information for this group.
@tparam[opt] table template a table containing key/values to be copied to the new
item should they not exist in itemData.

@treturn table a new ItemType object

]]

function ItemType:new(itemName, itemData, template)
    local o = { }
    template = template or {}
    for key, value in pairs(itemData) do o[key] = value end
    setmetatable(o, { __index = self })
    Logger.verbose("ItemType: Initializing ".. itemName)
    o.type = itemName -- WARNING: depreciated
    o.type_id = itemName
    
    -- setup specific properties and error checks
    if not copyPropertiesTable("ItemType: ".. itemName, o._PropertiesTable, template, o) then
        return nil
    end

    if not o:validate() then
        Logger.error("ItemType: Validation checks failed for " .. itemName .. " (Registration Failed)")
        return false
    end

    -- TODO: this should use some Interface callback function to properly register a item with the application (if needed)
    o._ItemTable[itemName] = o

    for gname, weight in pairs(o.Groups or template.Groups) do
        local group = o._GroupTable[gname]
        if group then
            group:add(itemName, weight)
        else
            Logger.warn("ItemType: " .. itemName .. " requested to join invalid group "..gname)
        end
    end
    for gname, weight in pairs(o.addGroups or {}) do
        group = o._GroupTable[gname]
        if group then
            group:add(itemName, weight)
        else
            Logger.warn("ItemType: " .. itemName .. " requested to join invalid group "..gname)
        end
    end

    Logger.debug("ItemType: Registered " .. itemName)
    return o
end


--[[- Dummy function to be overwritten by sub-classes.

@treturn bool

]]
function ItemType:validate()
    return true
end

--[[- Finds all Groups this item is a direct member of.

@treturn table a table of group names (keys) and Group objects (values)

]]
function ItemType:getGroups()
    local results = {}
    for name, obj in pairs(self._GroupTable) do
        if obj:contains(self.type) then
            results[name] = obj
        end
    end
    return results
end


--[[- Tests if this item is a member of the specified Group

@tparam string|table groupType the string name of the group, or a Group object

@treturn table a table of group names (keys) and Group objects (values)

]]
function ItemType:isGroupMember(groupType)
    groupType = type(groupType) == 'table' and groupType or self._GroupTable[groupType]
    if groupType then return groupType:contains(self.type) end
end



--[[- Creates a new collection of ItemTypes

This method provides a way of calling `ItemType.new` multiple times, while passing the
same tempate. Its primarly used to create multiple variants of the same item.

@tparam string namePrefix a string to be prefixed on the name of every variant
@tparam table template the template table to be passed to `ItemType.new`
@tparam table variants a table containing sub-tables of itemData to be passed to `ItemType.new`

@treturn table a table of group names (keys) and Group objects (values)

]]
function ItemType:newCollection(namePrefix, template, variants)
    Logger.verbose("ItemType: Starting Collection ".. namePrefix)
    for variant, variantData in pairs(variants) do
        self:new(namePrefix .. "_" .. variant, variantData, template)
    end
end

return ItemType
