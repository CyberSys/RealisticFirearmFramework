--[[- Magazine Functions

@module RFF.Magazine
@author Fenris_Wolf
@release 1.0-alpha
@copyright 2018

]]
local MagazineGroup = require(ENV_RFF_PATH .. "magazine/group")
local MagazineType = require(ENV_RFF_PATH .. "magazine/type")

--local Ammo = require(ENV_RFF_PATH .. "ammo/init")

local Flags = require(ENV_RFF_PATH .. "magazine/flags")
local State = require(ENV_RFF_PATH .. "magazine/state")
local Bit = require(ENV_RFF_PATH .. "interface/bit32")

local Magazine = {}
local MagazineTable = { }
local MagazineGroupTable = { }

Magazine.MagazineGroup = MagazineGroup
Magazine.MagazineType = MagazineType
Magazine.State = State
Magazine.Flags = Flags
Magazine.Instance = require(ENV_RFF_PATH .. "firearm/instance")

MagazineGroup._GroupTable = MagazineGroupTable
MagazineGroup._ItemTable = MagazineTable


MagazineType._GroupTable = MagazineGroupTable
MagazineType._ItemTable = MagazineTable


Magazine.isGroup = function(group_id)
    return MagazineGroupTable[group_id] ~= nil
end

Magazine.getGroup = function(group_id)
    return MagazineGroupTable[group_id]
end

Magazine.getGroupTable = function()
    return MagazineGroupTable
end


--[[- Gets the table of registered magazines.

]]
Magazine.getTable = function()
    return MagazineTable
end


--[[- Gets the data of a registered magazine, supports module checking.

]]
Magazine.get = function(magazine_id)
    return MagazineTable[magazine_id]
end


--[[- Checks if a item is a ORGM magazine.

]]
Magazine.isMagazine = function(magazine_id)
    return MagazineTable[magazine_id] ~= nil
end


--[[- Sets up a magazine, applying key/values into the item's data table.

]]
Magazine.setup = function(magazine_id, data_table)
    local design = Firearm.get(magazine_id)
    return design and design:setup(data_table) or nil  
end

return Magazine

--[[- Finds the best matching magazine in a container.

Search is based on the given magazine name and preferred load
(can be specific round name, nil/any, or mixed), and the currentCapacity.

This is called when reloading some guns and all magazines.

Note magType and ammoType should NOT have the "ORGM." prefix.

@tparam string magType name of a magazine
@tparam nil|string ammoType 'any', 'mixed' or a specific ammo name
@tparam ItemContainer containerItem

@treturn nil|InventoryItem

Magazine.findIn = function(magType, ammoType, containerItem)
    local group = MagazineGroupTable[magType]
    if not group then return end
    return group:find(ammoType, container, mode)
end





]]
