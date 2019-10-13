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

local Bit = require(ENV_RFF_PATH .. "interface/bit32")

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
    return firearm_data.current_capacity > 0
end

Instance.refillAmmo = function(firearm_data, ammo_id, count)
    --local ammo_group = Ammo.itemGroup(item, true)
    local ammo_group = Ammo.getGroup(firearm_data.ammo_group)
    if ammo_id then
        local ammo_design = Ammo.getDesign(ammo_id)
        if not ammo_design:isGroupMember(firearm_data.ammo_group) then return false end
    else
        ammo_id = ammo_group:random().type_id
    end
    if not count then 
        count = firearm_data.max_capacity 
    end
    for i=1, count do
        firearm_data.magazine_contents[i] = ammo_id
    end
    -- TODO: validate remaining mag position are empty.
    firearm_data.current_capacity = count
    firearm_data.loaded_ammo_id = ammo_id
end


-- Chamber, or current cylinder position
Instance.setAmmoChambered = function(firearm_data, ammo_id)
    if firearm_data.cylinder_position then
        firearm_data.magazine_contents[firearm_data.cylinder_position] = ammo_id
        return
    end
    firearm_data.chambered_id = ammo_id
end

Instance.getAmmoChambered = function(firearm_data)
    if firearm_data.cylinder_position then
        return firearm_data.magazine_contents[firearm_data.cylinder_position]
    end
    return firearm_data.chambered_id
end

Instance.isAmmoChambered = function(firearm_data)
    local ammo_id = Instance.getAmmoChambered(firearm_data)
    return ammo_id and Ammo.isAmmo(ammo_id) or false
end

Instance.delAmmoChambered = function(firearm_data)
    if firearm_data.cylinder_position then
        firearm_data.magazine_contents[firearm_data.cylinder_position] = nil
    end
    firearm_data.chambered_id = nil
end

Instance.fireAmmoChambered = function(firearm_data)
    local ammo_id = Instance.getAmmoChambered(firearm_data)
    local ammo_design = Ammo.getDesign(ammo_id)
    Instance.setAmmoChambered(firearm_data, ammo_design and ammo_design.Case or nil)
end

-- Specified magazine or cylinder position
Instance.setAmmoAtPosition = function(firearm_data, position, ammo_id)
    firearm_data.magazine_contents[position] = ammo_id
end

Instance.getAmmoAtPosition = function(firearm_data, position)
    return firearm_data.magazine_contents[position] -- arrays start at 1
end

Instance.isAmmoAtPosition = function(firearm_data, position)
    local ammo_id = firearm_data.magazine_contents[position]
    return ammo_id and Ammo.isAmmo(ammo_id) or false
end

Instance.delAmmoAtPosition = function(firearm_data, position)
    firearm_data.magazine_contents[position] = nil
end

-- convert this spot to a shell casing
Instance.fireAmmoAtPosition = function(firearm_data, position)
    local ammo_id = firearm_data.magazine_contents[position]
    local ammo_design = Ammo.getDesign(mag_data[position])
    firearm_data.magazine_contents[position] = ammo_design and ammo_design.Case or nil
end


-- Top of the magazine or next cylinder postion
Instance.setAmmoAtNextPosition = function(firearm_data, ammo_id)
    if firearm_data.cylinder_position then
        firearm_data.magazine_contents[(firearm_data.cylinder_position % firearm_data.max_capacity) +1] = ammo_id
        return 
    end
    firearm_data.magazine_contents[firearm_data.current_capacity] = ammo_id
end

Instance.getAmmoAtNextPosition = function(firearm_data)
    if firearm_data.cylinder_position then
        return firearm_data.magazine_contents[(firearm_data.cylinder_position % firearm_data.max_capacity) +1]
    end
    return firearm_data.magazine_contents[firearm_data.current_capacity]
end

Instance.isAmmoAtNextPosition = function(firearm_data)
    local ammo_id = Instance.getAmmoAtNextPosition(firearm_data)
    return ammo_id and Ammo.isAmmo(ammo_id) or false
end

Instance.delAmmoAtNextPosition = function(firearm_data)
    Instance.setAmmoAtNextPosition(firearm_data, nil)
end

Instance.fireAmmoAtNextPosition = function(firearm_data)
    local ammo_id = Instance.getAmmoAtNextPosition(firearm_data)
    local ammo_design = Ammo.getDesign(ammo_id)
    Instance.setAmmoAtNextPosition(firearm_data, ammo_design and ammo_design.Case or nil)
end


--[[- Gets the number of empty cases in the magazine/cylinder.

]]

Instance.hasCases = function(firearm_data)
    local count = 0
    for index, ammo_id in pairs(firearm_data.magazine_contents) do
        if ammo_id and Ammo.isCase(ammo_id) then
            count = 1 + count
        end
    end
    return count
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
        firearm_data.cylinder_position = ((firearm_data.cylinder_position - 1 + count) % firearm_data.max_capacity) +1
    end
end

Instance.setPosition = function(firearm_data, position)
    -- TODO: insure upper limits
    firearm_data.cylinder_position = position
end

Instance.setRandomPosition = function(firearm_data)
    firearm_data.cylinder_position = math.random(firearm_data.max_capacity)
end


Instance.setAmmoCountRelative = function(firearm_data, count)
    firearm_data.current_capacity = firearm_data.current_capacity + count
    -- TODO: validate limits
end

Instance.getAmmoCount = function(firearm_data)
    return firearm_data.current_capacity
end

Instance.isAmmoCountMaxed = function(firearm_data)
    return firearm_data.current_capacity == firearm_data.max_capacity
end

Instance.updateLoadedAmmo = function(firearm, ammo_id)
    if ammo_id == nil then
        firearm_data.loaded_ammo_id = nil
    elseif firearm_data.loaded_ammo_id == nil then
        firearm_data.loaded_ammo_id = ammo_id
    elseif firearm_data.loaded_ammo_id ~= ammo_id then
        firearm_data.loaded_ammo_id = 'mixed'
    end    
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


Instance.isMagazineEmpty = function(firearm_data)
    return firearm_data.current_capacity == 0
end

Instance.setMagazineEmpty = function(firearm_data)
    for index = 1, firearm_data.max_capacity do
        firearm_data.magazine_contents[index] = nil
    end
    firearm_data.loaded_ammo_id = nil
    firearm_data.current_capacity = 0    
end

Instance.getMagazineData = function(firearm_data) 
    -- TODO: should return full data not just contents
    return firearm_data.magazine_contents
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


return Instance
