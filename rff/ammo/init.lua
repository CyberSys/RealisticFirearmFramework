--[[- Functions for dealing with ammo.


    @module RFF.Ammo
    @copyright 2018
    @author Fenris_Wolf
    @release 4.0
]]


local Flags = require(ENV_RFF_PATH .. "ammo/flags")

local AmmoGroup = require(ENV_RFF_PATH .. "ammo/group")
local AmmoType =  require(ENV_RFF_PATH .. "ammo/type")

local Ammo = { }
local AmmoTable = { }
local AmmoGroupTable = { }

Ammo.AmmoGroup = AmmoGroup
Ammo.AmmoType = AmmoType
Ammo.Flags = Flags

AmmoGroup._GroupTable = AmmoGroupTable
AmmoGroup._ItemTable = AmmoTable
AmmoType._GroupTable = AmmoGroupTable
AmmoType._ItemTable = AmmoTable

-- TODO: move this to the file?
AmmoType._PropertiesTable = {
    case = {type='string', required=true },
    case_mass = {type='float', min=0, required=true }, -- total weight of the round, in grains    
    bullet_mass = {type='float', min=0, default=55, required=true}, -- bullet mass, in grains
    powder_mass = {type='float', min=0, default=55, required=true}, -- powder charge, in grains
    powder_type = {type='string', required=true},
    category = {type='integer', min=Flags.PISTOL, max=Flags.SHOTGUN, default=Flags.PISTOL, required=true},
    features = {type='integer', min=0, default=0, required=true},
}



Ammo.randomFromGroup = function(group_id)
    local group = AmmoGroupTable[group_id]
    if not group then return end
    return group:random()
end

Ammo.newGroup = function(group_id, group_data)
    AmmoGroup:new(group_id, group_data)
end

Ammo.isGroup = function(group_id)
    return AmmoGroupTable[group_id] ~= nil
end

--[[- Gets the table of ammo groups.

@treturn table keys are group names, values are table arrays of ammo names.

]]
Ammo.getGroupTable = function()
    return AmmoGroupTable
end


--[[- Returns the ammo group table for the specified groupName.

The table contains all the ammo types that can be used for this group.

@tparam string groupName name of a ammo group

@treturn nil|table list of real ammo names

]]
Ammo.getGroup = function(group_id)
    return AmmoGroupTable[group_id]
end


--[[- Gets the table of registered ammo.

@treturn table all registered ammo setup by `ORGM.Ammo.register`

]]
Ammo.getTable = function()
    return AmmoTable
end


--[[- Gets a value from the AmmoTable

@tparam string|InventoryItem itemType

@treturn table data of a registered ammo setup by `Ammo.register`

]]
Ammo.get = function(design_id)
    return AmmoTable[design_id]
end


--[[- Checks if a item is ammo.

@tparam string|InventoryItem itemType
@tparam[opt] string moduleName module to compare

@treturn bool true if registered ammo setup by `Ammo.register`

]]
Ammo.isAmmo = function(design_id)
    return AmmoTable[design_id] ~= nil
end

--[[- Checks if a item is ORGM spent casing.

@tparam string|InventoryItem itemType

@treturn bool

]]
Ammo.isCase = function(design_id)
    -- TODO: this needs a far more robust system....
    if design_id:sub(1, 5) == "Case_" then return true end
    return false
end

-- TODO: mostly below here should be redundant, convert these to new OO format

--[[- Finds the best matching ammo (bullets only) in a container.

Finds loose bullets, boxes and canisters of ammo.
Search is based on the given ammoGroup name and preferred type.
(can be specific round name, nil/any, or mixed)

This is called when reloading some guns and all magazines.

@tparam string ammoGroup name of a AmmoGroup.
@tparam nil|string ammoType 'any', 'mixed' or a specific ammo name
@tparam ItemContainer container
@tparam[opt] nil|int mode 0 = rounds, 1 = box, 2 = can

@treturn nil|InventoryItem

]]
Ammo.findIn = function(ammo_group, ammo_type, container, mode)
    local group = AmmoGroupTable[ammo_group]
    if group == nil then return nil end
    return group:find(ammo_type, container, mode)
end

return Ammo
