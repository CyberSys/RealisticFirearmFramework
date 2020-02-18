--[[- Class for specific firearm data templates.

@classmod FirearmType
@author Fenris_Wolf
@release 1.0-alpha
@copyright 2018

]]
local FirearmType = {}
local ItemType = require(ENV_RFF_PATH .. "item_type")
local Flags = require(ENV_RFF_PATH .. "firearm/flags")
local State = require(ENV_RFF_PATH .. "firearm/state")
local Instance = require(ENV_RFF_PATH .. "firearm/instance")

local Bit = require(ENV_RFF_PATH .. "interface/bit32")
local Logger = require(ENV_RFF_PATH .. "interface/logger")

local FEEDTYPES = Flags.AUTO + Flags.BOLT + Flags.LEVER + Flags.PUMP + Flags.BREAK + Flags.ROTARY
--local AUTOFEEDTYPES = Flags.BLOWBACK + Flags.DELAYEDBLOWBACK + Flags.SHORTGAS + Flags.LONGGAS + Flags.DIRECTGAS + Flags.LONGRECOIL + Flags.SHORTRECOIL

setmetatable(FirearmType, { __index = ItemType })

FirearmType._PropertiesTable = {
    weight = {type='float', min=0, max=100, default=1, required=true},
    ammo_group = {type='string', default="", required=true},
    magazine_group = {type='string'},

    classification = {type='string', default="Unknown"},
    country = {type='string', default="Unknown"},
    manufacturer = {type='string', default="Unknown"},
    description = {type='string', default="No description available"},
    category = {type='integer', min=0, max=100, default=1, required=true},

    features = {type='integer', min=0, default=0, required=true},

    barrel_length = {type='float', min=0, default=10, required=true},
    feed_system = {type='integer', min=0, default=Flags.AUTO+Flags.BLOWBACK, required=true},
    max_capacity = {type='integer', min=0, default=0},
}

--- FirearmType Methods
-- @section FirearmType
function FirearmType:isFeature(flags)
    return Bit.band(self.features, flags) ~= 0
end

function FirearmType:isSelectFire()
    return self:isFeature(Flags.SELECTFIRE)
end

function FirearmType:isFullAuto()
    return self:isFeature(Flags.FULLAUTO)
end

function FirearmType:isSemiAuto()
    return self:isFeature(Flags.SEMIAUTO)
end

function FirearmType:is2ShotBurst()
    return self:isFeature(Flags.BURST2)
end

function FirearmType:is3ShotBurst()
    return self:isFeature(Flags.BURST3)
end

function FirearmType:isOpenBolt()
    return self:isFeature(Flags.OPENBOLT)
end

function FirearmType:isBullpup()
    return self:isFeature(Flags.BULLPUP)
end

function FirearmType:isFreeFloat()
    return self:isFeature(Flags.FREEFLOAT)
end
function FirearmType:isPorted()
    return self:isFeature(Flags.PORTED)
end

function FirearmType:isSightless()
    return self:isFeature(Flags.NOSIGHTS)
end
function FirearmType:hasSafety()
    return self:isFeature(Flags.SAFETY)
end
function FirearmType:hasSlideLock()
    return self:isFeature(Flags.SLIDELOCK)
end
function FirearmType:hasChamberIndicator()
    return self:isFeature(Flags.CHAMBERINDICATOR)
end

function FirearmType:isFeedType(value)
    if not value then value = FEEDTYPES end
    return Bit.band(self.feed_system, value) ~= 0
end
function FirearmType:isRotary()
    return self:isFeedType(Flags.ROTARY)
end
function FirearmType:isAutomatic()
    return self:isFeedType(Flags.AUTO)
end
function FirearmType:isBolt()
    return self:isFeedType(Flags.BOLT)
end
function FirearmType:isPump()
    return self:isFeedType(Flags.PUMP)
end
function FirearmType:isLever()
    return self:isFeedType(Flags.LEVER)
end
function FirearmType:isBreak()
    return self:isFeedType(Flags.BREAK)
end


function FirearmType:validate()
    self.features = self.features + (self.additional_features or 0)
    self.additional_features = nil

    ---------------------------------------------------------------------------------------------------
    -- bitwise flag validation

    if Bit.band(self.features, Flags.SINGLEACTION + Flags.DOUBLEACTION) == 0 then
        Logger.error("FirearmType: Missing required feature for " .. self.type_id .. " (SINGLEACTION|DOUBLEACTION)")
        return
    end

    if Bit.band(self.feed_system, FEEDTYPES) == 0 then
        Logger.error("FirearmType: Missing required feature for " .. self.type_id .. " (AUTO|BOLT|LEVER|PUMP|BREAK|ROTARY)")
        return
    end
    if Bit.band(self.feed_system, Flags.AUTO) ~= 0 and Bit.band(self.feed_system, Flags.BLOWBACK + Flags.DELAYEDBLOWBACK + Flags.SHORTGAS + Flags.LONGGAS + Flags.DIRECTGAS + Flags.LONGRECOIL + Flags.SHORTRECOIL) == 0 then
        Logger.error("FirearmType: Missing required feature flag for " .. self.type_id .. " (BLOWBACK|DELAYEDBLOWBACK|SHORTGAS|LONGGAS|DIRECTGAS|LONGRECOIL|SHORTRECOIL)")
        return
    end


    ---------------------------------------------------------------------------------------------------
    -- TODO:
    -- validate self.category
    -- validate caliber/AmmoGroup
    -- validate MagazineGroup 
    return true
end

function FirearmType:create()
    return self:setup({})
end

function FirearmType:setup(firearm_data)
    return Instance.initialize(firearm_data, self)
end


function FirearmType:randomMagazine()
    local group = Magazine.getGroup(self.magazine_group)
    if not group then return nil end
    return group:random()
end


function FirearmType:usesMagazines()
    return self.magazine_group
end

--[[

function FirearmType:spawn(container, loaded, chance, mustFit)
    if chance and ZombRand(100)+1 <= chance * ZomboidGlobals.WeaponLootModifier * Settings.FirearmSpawnModifier then
        return nil
    end
    local item = InventoryItemFactory.CreateItem("ORGM.".. self.type)
    if mustFit and not container:hasRoomFor(nil, item:getActualWeight()) then
		return nil
	end

    self:setup(item)

    -- set the serial number
    local sn = {}
    for i=1, 6 do sn[i] = tostring(ZombRand(10)) end
    item:getModData().serialnumber = table.concat(sn, '')

    if loaded then
        local count = self.maxCapacity
        if ZombRand(100) < 50 then count = ZombRand(self.maxCapacity)+1 end
    end
    Firearm.refill(item, count)
    Firearm.Stats.set(item)
    if container then
        container:AddItem(item)
    end
    return item
end


]]
return FirearmType
