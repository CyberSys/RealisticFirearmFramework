--[[- Firearm Functions

@module RFF.Firearm
@author Fenris_Wolf
@release 1.0
@copyright 2018

]]


local FirearmGroup = require(ENV_RFF_PATH .. "firearm/group")
local FirearmType = require(ENV_RFF_PATH .. "firearm/type")

--local Ammo = require(ENV_RFF_PATH .. "ammo/init")

local Flags = require(ENV_RFF_PATH .. "firearm/flags")
local State = require(ENV_RFF_PATH .. "firearm/state")
local Bit = require(ENV_RFF_PATH .. "interface/bit32")

local Firearm = {}
local FirearmTable = { }
local FirearmGroupTable = { }

Firearm.FirearmGroup = FirearmGroup
Firearm.FirearmType = FirearmType
Firearm.State = State
Firearm.Flags = Flags
Firearm.Instance = require(ENV_RFF_PATH .. "firearm/instance")

FirearmGroup._GroupTable = FirearmGroupTable
FirearmGroup._ItemTable = FirearmTable


FirearmType._GroupTable = FirearmGroupTable
FirearmType._ItemTable = FirearmTable



--- Group Functions
-- @section FirearmGroups

--[[- Returns the FirearmGroup for the specified group_id.

@tparam string group_id

@treturn FirearmGroup 

]]
Firearm.getGroup = function(group_id)
    return FirearmGroupTable[group_id]
end

Firearm.getGroupTable = function()
    return FirearmGroupTable
end

--- Design Functions
-- @section FirearmData

--[[- Gets the table of registered FirearmType objects.

@treturn table all registered FirearmType objects

]]
Firearm.getTable = function()
    return FirearmTable
end

--[[- Filters a the FirearmTable based on a callback.

@treturn callback filter_function
@treturn[opt] table filter_table defaults to the local FirearmTable
@treturn table a table of registered FirearmType objects

]]
Firearm.filterTable = function(filter_function, filter_table)
    local resuts = { }
    filter_table = filter_table or FirearmTable
    for design_id, design in pairs(filter_table) do
        if filter_function(design_id, design) then
            results[design_id] = design
        end
    end
    return results
end

--[[-  Gets the a FirearmType design.

@tparam string design_id

@treturn nil|FirearmType

]]
Firearm.get = function(design_id)
    return FirearmTable[design_id]
end


--[[- Checks if a design_id is a firearm.

@tparam string design_id

@treturn bool

]]
Firearm.isFirearm = function(design_id)
    return FirearmTable[design_id] ~= nil
end



--[[- Creates data for a firearm game object.

This should be called whenever a firearm is spawned.
It is the application's interface job to keep track of
the returned table past here
 
@tparam string design_id
@tparam table data_table Supplied by the interface
@treturn table

]]
Firearm.create = function(design_id)
    local design = Firearm.get(design_id)
    return design and design:create() or nil  
end

--[[- Sets up a data for a firearm game object.

Identical to `Firearm.create()` but allows for a custom table to be used.

@tparam string design_id
@tparam table data_table Supplied by the interface

]]
Firearm.setup = function(design_id, data_table)
    local design = Firearm.get(design_id)
    return design and design:setup(data_table) or nil  
end


--------------------------------------------------------------------
--- Convience Functions
-- these can operate on a firearm data instance, a FirearmType design, or by design_id string.
-- @section Convience

--[[- Returns the features for this instance or design.

@tparam string|table this

@treturn integer

]]
Firearm.getFeatures = function(this)
    if type(this) == 'string' then
        this = Firearm.get(this)
    end
    if not this then return nil end
    return this.features
end


Firearm.isFeature = function(this, flags)
    return Bit.band(Firearm.getFeatures(this), flags) ~= 0
end


Firearm.isSelectFire = function(this)
    return Firearm.isFeature(this, Flags.SELECTFIRE)
end

Firearm.isFullAuto = function(this)
    return Firearm.isFeature(this, Flags.FULLAUTO)
end

Firearm.isSemiAuto = function(this)
    return Firearm.isFeature(this, Flags.SEMIAUTO)
end

Firearm.is2ShotBurst = function(this)
    return Firearm.isFeature(this, Flags.BURST2)
end

Firearm.is3ShotBurst = function(this)
    return Firearm.isFeature(this, Flags.BURST3)
end

Firearm.isOpenBolt = function(this)
    return Firearm.isFeature(this, Flags.OPENBOLT)
end

Firearm.isBullpup = function(this)
    return Firearm.isFeature(this, Flags.BULLPUP)
end

Firearm.isFreeFloat = function(this)
    return Firearm.isFeature(this, Flags.FREEFLOAT)
end

Firearm.isSightless = function(this)
    return Firearm.isFeature(this, Flags.NOSIGHTS)
end

Firearm.hasSafety = function(this)
    return Firearm.isFeature(this, Flags.SAFETY)
end

Firearm.hasSlideLock = function(this)
    return Firearm.isFeature(this, Flags.SLIDELOCK)
end

Firearm.hasChamberIndicator = function(this)
    return Firearm.isFeature(this, Flags.CHAMBERINDICATOR)
end

-- trigger check
Firearm.isSingleActionOnly = function(this)
    return Bit.band(Firearm.getFeatures(this), Flags.TRIGGER_TYPES) == Flags.SINGLEACTION
end

Firearm.isSingleAction = function(this)
    return Bit.band(Firearm.getFeatures(this), Flags.SINGLEACTION) ~= 0
end

Firearm.isDoubleActiton = function(this)
    return Bit.band(Firearm.getFeatures(this), Flags.DOUBLEACTION) ~= 0
end

Firearm.isDoubleActionOnly = function(this)
    return Bit.band(Firearm.getFeatures(this), Flags.TRIGGER_TYPES) == Flags.DOUBLEACTION
end

-- feed system checks
Firearm.isFeedType = function(this, feed_system)
    if type(this) == 'string' then
        this = Firearm.get(this)
    end
    if not this then return nil end
    return Bit.band(this.feed_system, feed_system) ~= 0
end

Firearm.isRotary = function(this)
    return Firearm.isFeedType(this, Flags.ROTARY)
end
Firearm.isAutomatic = function(this)
    return Firearm.isFeedType(this, Flags.AUTO)
end
Firearm.isBolt = function(this)
    return Firearm.isFeedType(this, Flags.BOLT)
end
Firearm.isPump = function(this)
    return Firearm.isFeedType(this, Flags.PUMP)
end
Firearm.isLever = function(this)
    return Firearm.isFeedType(this, Flags.LEVER)
end
Firearm.isBreak = function(this)
    return Firearm.isFeedType(this, Flags.BREAK)
end

Firearm.getBarrelLength = function(this)
    if type(this) == 'string' then
        this = Firearm.get(this)
    end
    if not this then return nil end
    return this.barrel_length
end


return Firearm
