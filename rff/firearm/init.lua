--[[- Firearm Functions.

This file handles functions dealing with firearms data, and manipulating
HandWeapon/InventoryItem methods. Dynamic stat settings, reloadable
setup and ORGM version updates are contained.


@module ORGM.Firearm
@author Fenris_Wolf
@release 4.0
@copyright 2018

]]

local Firearm = { }
local Stats = {}
local Barrel = {}
local Hammer = {}
local Trigger = {}

local FirearmGroup = require(ENV_RFF_PATH .. "firearm/group")
local FirearmType = require(ENV_RFF_PATH .. "firearm/type")

--local Ammo = require(ENV_RFF_PATH .. "ammo/init")
--local Magazine = ORGM.Magazine
--local Component = ORGM.Component
--local Reloadable = ORGM.ReloadableWeapon

local Flags = require(ENV_RFF_PATH .. "firearm/flags")
local Status = require(ENV_RFF_PATH .. "firearm/status")

local FirearmTable = { }
local FirearmGroupTable = { }

FirearmGroup._GroupTable = FirearmGroupTable
FirearmGroup._ItemTable = FirearmTable


FirearmType._GroupTable = FirearmGroupTable
FirearmType._ItemTable = FirearmTable


--- Data Functions
-- @section FirearmData

--[[- Gets the table of registered FirearmType objects

@treturn table all registered FirearmType objects

]]
Firearm.getTable = function()
    return FirearmTable
end
--[[- Returns the firearm group table for the specified groupName.

The table contains all the firearm types that can be used for this group.

@tparam string groupName name of a firearm group

@treturn nil|table list of names

]]
Firearm.getGroup = function(groupName)
    return FirearmGroupTable[groupName]
end

Firearm.getGroupTable = function()
    return FirearmGroupTable
end


--[[-  Gets the data of a registered firearm, supports module checking.

@usage local design = ORGM.Firearm.getDesign('Ber92')
@tparam string|HandWeapon itemType
@tparam[opt] string moduleName module to compare

@treturn nil|table data of a registered firearm setup by `ORGM.Firearm.register`

]]
Firearm.getDesign = function(itemType, moduleName)
    return FirearmTable[itemType]
end


--[[- Checks if itemType is a ORGM Firearm.

@usage local result = ORGM.Firearm.isFirearm('Ber92')
@tparam string|HandWeapon itemType
@tparam[opt] string moduleName module to compare

@treturn bool true if it is a ORGM registered firearm

]]
Firearm.isFirearm = function(itemType, moduleName)
    return FirearmTable[itemType] ~= nil
end



--[[- Sets up a gun, applying key/values into the items modData.
This should be called whenever a firearm is spawned.
Basically the same as ReloadUtil:setupGun and ISORGMWeapon:setupReloadable but
called without needing a player or reloadable object.

@usage ORGM.Firearm.setup(Firearm.getDesign(weaponItem), weaponItem)
@tparam table design return value of `ORGM.Firearm.getDesign`
@tparam HandWeapon weaponItem

]]
Firearm.setup = function(design_id, data_table)
    local design = Firearm.getDesign(design_id)
    if design then return design:setup(data_table) end
    return nil
end

Firearm.create = function(design_id)
    local design = Firearm.getDesign(design_id)
    if design then return design:create() end
    return nil
end

return Firearm
