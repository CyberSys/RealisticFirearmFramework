local FirearmType = {}
local ItemType = require(ENV_RFF_PATH .. "item_type")
local Flags = require(ENV_RFF_PATH .. "firearm/flags")
local State = require(ENV_RFF_PATH .. "firearm/state")

local Bit = require(ENV_RFF_PATH .. "interface/bit32")
local Logger = require(ENV_RFF_PATH .. "interface/logger")

local FEEDTYPES = Flags.AUTO + Flags.BOLT + Flags.LEVER + Flags.PUMP + Flags.BREAK + Flags.ROTARY
local AUTOFEEDTYPES = Flags.BLOWBACK + Flags.DELAYEDBLOWBACK + Flags.SHORTGAS + Flags.LONGGAS + Flags.DIRECTGAS + Flags.LONGRECOIL + Flags.SHORTRECOIL

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
    max_capacity = {type='integer', min=0, default=10},
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
    return self:isFeedType(Flags.Bolt)
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

--[[- Sets up a gun, applying key/values into the items modData.
This should be called whenever a firearm is spawned.
Basically the same as ReloadUtil:setupGun and ISORGMWeapon:setupReloadable but
called without needing a player or reloadable object.

@usage ORGM.Firearm.setup(Firearm.getDesign(weaponItem), weaponItem)
@tparam HandWeapon weaponItem

]]
function FirearmType:setup(data_table)
    data_table.type_id = self.type_id

    data_table.ammo_group = self.ammo_group

    data_table.max_capacity = self.max_capacity
    data_table.current_capacity = 0

    if self.magazine_group then
        -- TODO: fix magazine code
        -- local mag = Magazine.getGroup(self.magazine_group):random()
        -- data_table.magazine_type = mag.type_id
        -- data_table.max_capacity = mag.max_capacity
    else -- sanity check when resetting to default
        data_table.magazine_type = nil
    end

    --data_table.speedLoader = self.speedLoader -- speedloader/stripperclip name
    
    -- normally isAutomatic checks data_table.feed_system, but thats not set yet so self.feed_system is used.
    -- direct copying of self.feed_system to data_table.feed_system is not desirable for dual type systems like
    -- the spas-12. data_table.feed_system should only contain the current firemode.
    if self:isAutomatic() then
        data_table.feed_system = Flags.AUTO + Bit.band(self.feed_system, AUTOFEEDTYPES)
    --elseif Firearm.isRotary(weaponItem, self) then
    --elseif Firearm.isBolt(weaponItem, self) then
    --elseif Firearm.isPump(weaponItem, self) then
    --elseif Firearm.isLever(weaponItem, self) then
    --elseif Firearm.isBreak(weaponItem, self) then
    else
        data_table.feed_system = self.feed_system
    end

    if self:isFeedType(Flags.ROTARY + Flags.BREAK) then
        data_table.cylinder_position = 1 -- position is 1 to maxCapacity (required for % oper to work properly)
        --data_table.roundChambered = nil
        --data_table.emptyShellChambered = nil
    else
        data_table.chambered_id = nil
        --data_table.roundChambered = 0 -- 0 or 1, a round is currently chambered
        --data_table.emptyShellChambered = 0 -- 0 or 1, a empty shell is currently chambered
    end

    local state = 0
    -- set the current firemode to first available position.

    --if Firearm.isSelectFire(weaponItem, self) then
    if self:isSemiAuto() then
        state = state + Status.SINGLESHOT
    elseif self:isFullAuto() then
        state = state + State.FULLAUTO
    elseif self:is2ShotBurst() then
        state = state + State.BURST2
    elseif self:is3ShotBurst() then
        state = state + State.BURST3
    else
        state = state + State.SINGLESHOT
    end
    --end
    data_table.state = state

    data_table.magazine_data = {} -- current rounds, LIFO list
    -- data_table.strictAmmoType = nil -- preferred ammo type, this is set by the UI context menu
    -- last round the stats were set to, used for knowing what to eject, and if we should change weapon stats when chambering next round
    data_table.set_ammo = nil
    -- what type of rounds are loaded, either ammo name, or 'mixed'. This is only really used when ejecting a magazine, so the mag's data_table
    -- has this flagged (used when loading new mags to match self.preferredAmmoType). Also used in tooltips
    data_table.loaded_ammo = nil
    data_table.rounds_fired = 0
    data_table.rounds_since_cleaned = 0
    data_table.barrel_length = self.barrel_length
end


function FirearmType:randomMagazine()
    local group = Magazine.getGroup(self.magazine_group)
    if not group then return nil end
    return group:random()
end


function FirearmType:usesMagazines()
    return self.magazine_group
end


return FirearmType
