--[[- Functions for manipulating framework data for a specific firearm instance.

expected instance keys:

* type_id

* state

* features

* feed_system

* ammo_group

* magazine_group

* max_capacity

* current_capacity

* magazine_id

* magazine_contents

* chambered_id

* set_ammo_id

* loaded_ammo_id

* cylinder_position

* rounds_fired

* rounds_since_cleaned

* barrel_length

* _rff_version

@module RFF.Firearm.Instance
@author Fenris_Wolf
@release 1.00-alpha
@copyright 2018

]]

local Instance = {}
local State = require(ENV_RFF_PATH .. "firearm/state")
local Flags = require(ENV_RFF_PATH .. "firearm/flags")
local Ammo = require(ENV_RFF_PATH .. "ammo/init")
local Magazine = require(ENV_RFF_PATH .. "magazine/init")
local Bit = require(ENV_RFF_PATH .. "interface/bit32")

local MagI = Magazine.Instance 

--[[

Instance.new(self)
    local o = { }
    setmetatable(o, self)
    self.__index = self
    return o
end
]]


Instance.setSelectFireMode = function(firearm_data, fire_mode)
    firearm_data.state = firearm_data.state - Bit.band(firearm_data.state, FIREMODESTATES) + fire_mode
end


Instance.isLoaded = function(firearm_data)
    if firearm_data.chambered_id and not Ammo.isCase(firearm_data.chambered_id) then
        return true
    end
    return MagI.isLoaded(firearm_data.magazine_data)
end

Instance.isEmpty = function(firearm_data)
    return (firearm_data.chambered_id == nil or Ammo.isCase(firearm_data.chambered_id)) and MagI.isEmpty(firearm_data.magazine_data)
end

Instance.setEmpty = function(firearm_data)
    MagI.setEmpty(firearm_data.magazine_data)
    firearm_data.chambered_id = nil
end

Instance.isFull = function(firearm_data)
    return MagI.isFull(firearm_data.magazine_data)
end


Instance.getMaxAmmoCount = function(firearm_data)
    return MagI.getMaxAmmoCount(firearm_data.magazine_data)
end

Instance.getAmmoCount = function(firearm_data)
    return MagI.getAmmoCount(firearm_data.magazine_data)
end

Instance.setAmmoCount = function(firearm_data, value)
    return MagI.setAmmoCount(firearm_data.magazine_data, value)
end

Instance.setAmmoCountRelative = function(firearm_data, count)
    MagI.setAmmoCountRelative(firearm_data.magazine_data, count)
end


Instance.updateLoadedAmmo = function(firearm_data, ammo_id)
    MagI.updateLoadedAmmo(firearm_data.magazine_data, ammo_id)
end

Instance.updateSetAmmo = function(firearm_data, ammo_id)
    if ammo_id == nil or Ammo.isCase(ammo_id) then return end
    if not Ammo.isAmmo(ammo_id) then
        firearm_data.set_ammo_id = nil
        return nil
    end
    if ammo_id ~= firearm_data.set_ammo_id then
        firearm_data.set_ammo_id = ammo_id
        return true
    end
    return false
end

Instance.getSetAmmo = function(firearm_data)
    return firearm_data.set_ammo_id
end


Instance.getMagazine = function(firearm_data) 
    return firearm_data.magazine_data
end




Instance.refillAmmo = function(firearm_data, ammo_id, count)
    MagI.refillAmmo(firearm_data.magazine_data, ammo_id, count)
    --firearm_data.current_capacity = count
    --firearm_data.loaded_ammo_id = ammo_id
end

-- Chamber, or current cylinder position
Instance.setAmmoChambered = function(firearm_data, ammo_id)
    if firearm_data.cylinder_position then
        MagI.setAmmoAtPosition(firearm_data.magazine_data, firearm_data.cylinder_position, ammo_id)
        --firearm_data.magazine_contents[firearm_data.cylinder_position] = ammo_id
        return
    end
    firearm_data.chambered_id = ammo_id
end

Instance.getAmmoChambered = function(firearm_data)
    if firearm_data.cylinder_position then
        return MagI.getAmmoAtPosition(firearm_data.magazine_data, firearm_data.cylinder_position)
        --return firearm_data.magazine_contents[firearm_data.cylinder_position]
    end
    return firearm_data.chambered_id
end

Instance.isAmmoChambered = function(firearm_data)
    local ammo_id = Instance.getAmmoChambered(firearm_data)
    return ammo_id and Ammo.isAmmo(ammo_id) or false
end

Instance.delAmmoChambered = function(firearm_data)
    if firearm_data.cylinder_position then
        delAmmoAtPosition(firearm_data.magazine_data, firearm_data.cylinder_position)
        -- firearm_data.magazine_contents[firearm_data.cylinder_position] = nil
    end
    firearm_data.chambered_id = nil
end

Instance.fireAmmoChambered = function(firearm_data)
    local ammo_id = Instance.getAmmoChambered(firearm_data)
    local ammo_design = Ammo.get(ammo_id)
    Instance.setAmmoChambered(firearm_data, ammo_design and ammo_design.Case or nil)
end

-- Specified magazine or cylinder position
Instance.setAmmoAtPosition = function(firearm_data, position, ammo_id)
    return MagI.setAmmoAtPosition(firearm_data.magazine_data, position, ammo_id)
    -- firearm_data.magazine_contents[position] = ammo_id
end

Instance.getAmmoAtPosition = function(firearm_data, position)
    return MagI.getAmmoAtPosition(firearm_data.magazine_data, position)
    --return firearm_data.magazine_contents[position] -- arrays start at 1
end

Instance.isAmmoAtPosition = function(firearm_data, position)
    return MagI.isAmmoAtPosition(firearm_data.magazine_data, position)
    --local ammo_id = firearm_data.magazine_contents[position]
    --return ammo_id and Ammo.isAmmo(ammo_id) or false
end

Instance.delAmmoAtPosition = function(firearm_data, position)
    return MagI.delAmmoAtPosition(firearm_data.magazine_data, position)
    --firearm_data.magazine_contents[position] = nil
end

-- convert this spot to a shell casing
Instance.fireAmmoAtPosition = function(firearm_data, position)
    MagI.fireAmmoAtPosition(firearm_data.magazine_data, position)
    --local ammo_id = firearm_data.magazine_contents[position]
    --local ammo_design = Ammo.get(mag_data[position])
    --firearm_data.magazine_contents[position] = ammo_design and ammo_design.Case or nil
end

-- return the true next clyinder position. This is required for the 'NextPostion' functions.
local cylinderPos = function(firearm_data)
    return (firearm_data.cylinder_position % Instance.getMaxAmmoCount(firearm_data)) +1
end

-- Top of the magazine or next cylinder postion
Instance.setAmmoAtNextPosition = function(firearm_data, ammo_id)
    if firearm_data.cylinder_position then
        MagI.setAmmoAtPosition(firearm_data.magazine.data, cylinderPos(firearm_data), ammo_id)
        --firearm_data.magazine_contents[(firearm_data.cylinder_position % firearm_data.max_capacity) +1] = ammo_id
        return 
    end
    MagI.setAmmoNextPosition(firearm_data.magazine.data, ammo_id)
    --firearm_data.magazine_contents[firearm_data.current_capacity] = ammo_id
end

Instance.getAmmoAtNextPosition = function(firearm_data)
    if firearm_data.cylinder_position then
        return MagI.getAmmoAtPosition(firearm_data.magazine.data, cylinderPos(position))
        --return firearm_data.magazine_contents[(firearm_data.cylinder_position % firearm_data.max_capacity) +1]
    end
    return MagI.getAmmoNextPosition(firearm_data.magazine.data)
    --return firearm_data.magazine_contents[firearm_data.current_capacity]
end

Instance.isAmmoAtNextPosition = function(firearm_data)
    if firearm_data.cylinder_position then
        return MagI.isAmmoAtPosition(firearm_data.magazine_data, cylinderPos(firearm_data))
    end
    return MagI.isAmmoNextPosition(firearm_data.magazine_data)
    --local ammo_id = Instance.getAmmoAtNextPosition(firearm_data)
    --return ammo_id and Ammo.isAmmo(ammo_id) or false
end

Instance.delAmmoAtNextPosition = function(firearm_data)
    if firearm_data.cylinder_position then
        MagI.delAmmoAtPosition(firearm_data.magazine_data, cylinderPos(firearm_data))
        return
    end
    MagI.delAmmoAtNextPosition(firearm_data.magazine_data)
    --Instance.setAmmoAtNextPosition(firearm_data, nil)
end

Instance.fireAmmoAtNextPosition = function(firearm_data)
    if firearm_data.cylinder_position then
        MagI.fireAmmoAtNextPosition(firearm_data.magazine_data, cylinderPos(firearm_data))
        return
    end
    MagI.fireAmmoAtNextPosition(firearm_data.magazine_data)
    --local ammo_id = Instance.getAmmoAtNextPosition(firearm_data)
    --local ammo_design = Ammo.get(ammo_id)
    --Instance.setAmmoAtNextPosition(firearm_data, ammo_design and ammo_design.Case or nil)
end


--[[- Gets the number of empty cases in the magazine/cylinder.

]]

Instance.hasCases = function(firearm_data)
    return MagI.hasCases(firearm_data.magazine_data)
end

Instance.incRoundsFired = function(firearm_data, count)
    if not count then count = 1 end
    firearm_data.rounds_since_cleaned = firearm_data.rounds_since_cleaned + count
    firearm_data.rounds_fired = firearm_data.rounds_fired + count
end

Instance.incPosition = function(firearm_data, count, wrap)
    count = count or 1
    if not wrap then 
        firearm_data.cylinder_position = firearm_data.cylinder_position + count -- this can bypass our maxCapacity limit
    else
         local max = Instance.getMaxAmmoCount(firearm_data)
        firearm_data.cylinder_position = ((firearm_data.cylinder_position - 1 + count) % max) +1
        --firearm_data.cylinder_position = ((firearm_data.cylinder_position - 1 + count) % firearm_data.max_capacity) +1
    end
end

Instance.setPosition = function(firearm_data, position)
    -- TODO: insure upper limits
    firearm_data.cylinder_position = position
end

Instance.setRandomPosition = function(firearm_data)
    firearm_data.cylinder_position = math.random(firearm_data.max_capacity)
end


Instance.isFeedMode = function(firearm_data, feed_mode)
    local value = firearm_data.feed_mode or firearm_data.feed_system
    if not value then return end
    return Bit.band(value, feed_mode) ~= 0
end
Instance.isAutomatic = function(firearm_data)
    return Instance.isFeedMode(firearm_data, Flags.AUTO)
end
Instance.isPump = function(firearm_data)
    return Instance.isFeedMode(firearm_data, Flags.PUMP)
end
Instance.isLever = function(firearm_data)
    return Instance.isFeedMode(firearm_data, Flags.LEVER)
end
Instance.isRotary = function(firearm_data)
    return Instance.isFeedMode(firearm_data, Flags.ROTARY)
end
Instance.isBreak = function(firearm_data)
    return Instance.isFeedMode(firearm_data, Flags.BREAK)
end

Instance.isState = function(firearm_data, state)
    if not firearm_data.state then return end
    return Bit.band(firearm_data.state, state) ~= 0
end
Instance.isForceOpen = function(firearm_data)
    return Instance.isState(firearm_data, State.FORCEOPEN)
end

Instance.isFullAuto = function(firearm_data)
    return Instance.isState(firearm_data, State.FULLAUTO)
end

Instance.isSingle = function(firearm_data)
    return Instance.isState(firearm_data, State.SINGLESHOT)
end

Instance.is2ShotBurst = function(firearm_data)
    return Instance.isState(firearm_data, State.BURST2)
end

Instance.is3ShotBurst = function(firearm_data)
    return Instance.isState(firearm_data, State.BURST3)
end

Instance.isSafe = function(firearm_data)
    return Instance.isState(firearm_data, State.SAFETY)
end

Instance.isCocked = function(firearm_data)
    return Instance.isState(firearm_data, State.COCKED)
end

Instance.isOpen = function(firearm_data)
    return Instance.isState(firearm_data, State.OPEN)
end

Instance.setState = function(firearm_data, state, enabled)
    if enabled then
        -- should xor this
        firearm_data.state = not Instance.isState(firearm_data, state) and firearm_data.state + state or firearm_data.state
    else
        firearm_data.state = Instance.isState(firearm_data, state) and firearm_data.state - state or firearm_data.state
    end
end

Instance.setOpen = function(firearm_data, enabled)
    Instance.setState(firearm_data, State.OPEN, enabled)
end

Instance.setCocked = function(firearm_data, enabled)
    Instance.setState(firearm_data, State.COCKED, enabled)
end

Instance.setForceOpen = function(firearm_data, enabled)
    Instance.setState(firearm_data, State.FORCEOPEN, enabled)
end

Instance.setSafe = function(firearm_data, enabled)
    return Instance.setState(firearm_data, State.SAFETY, enabled)
end

--------------------------------------------------

Instance.getBarrelLength = function(firearm_data)
    return firearm_data.barrel_length
end

return Instance
