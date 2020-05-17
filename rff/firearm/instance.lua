--[[- Functions for manipulating framework data for a specific firearm instance.

Instance data is stored in a table. Key/value pairs in these instance table should not be directly accessed, 
instead using the functions (or methods, depending) in this module. 

This module is written in 'functional code' style, allowing for both OO style (metatables), or functional style 
depending on your requirements. It never uses `self:` internally for flexibility in sterilization of instances.

```lua
local Firearm = RFF.Firearm
local Instance = Firearm.Instance
local design = Firearm.get("M16")

-- OO
local gun1 = Instance:new(design)
gun1:setSelectFireMode(Firearm.Flags.FULLAUTO)

-- functional
local gun2 = Instance.initialize({ }, design)
Instance.setSelectFireMode(gun2, Firearm.Flags.FULLAUTO)
```

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
local logger = require(ENV_RFF_PATH .. "interface/logger")

local MagI = Magazine.Instance 


--[[- Creates a new Firearm instance with metamethods.

@tparam table self
@tparam table design
@tparam[opt] table attrib
 
]]
Instance.new = function(self, design, attrib)
    local o = setmetatable({ }, { __index=self })
    attrib = attrib or {}
    attrib._meta = true
    return Instance.initialize(o, design, attrib)
end

--[[-

]]
Instance.initialize = function(firearm_data, design, attrib)
    firearm_data = firearm_data or {}

    firearm_data.type_id = design.type_id
    firearm_data.features = design.features
    firearm_data.ammo_group = design.ammo_group

    if design.magazine_group then
        local mag = Magazine.getGroup(self.magazine_group):random()
        firearm_data.magazine_type = MagI.initialize(nil, mag, attrib)
    else
        firearm_data.magazine_data = MagI.initialize(nil,{
            ammo_group = design.ammo_group,
            max_capacity = design.max_capacity,
            type_id = nil,
            features = Magazine.Flags.INTERNAL
        })
    end


    --firearm_data.speedLoader = self.speedLoader -- speedloader/stripperclip name
    
    -- normally isAutomatic checks firearm_data.feed_system, but thats not set yet so self.feed_system is used.
    -- direct copying of self.feed_system to firearm_data.feed_system is not desirable for dual type systems like
    -- the spas-12. firearm_data.feed_system should only contain the current firemode.
    if design:isAutomatic() then
        firearm_data.feed_system = Flags.AUTO + Bit.band(design.feed_system, AUTOFEEDTYPES)
    --elseif Firearm.isRotary(weaponItem, self) then
    --elseif Firearm.isBolt(weaponItem, self) then
    --elseif Firearm.isPump(weaponItem, self) then
    --elseif Firearm.isLever(weaponItem, self) then
    --elseif Firearm.isBreak(weaponItem, self) then
    else
        firearm_data.feed_system = design.feed_system
    end

    if design:isFeedType(Flags.ROTARY + Flags.BREAK) then
        firearm_data.cylinder_position = 1 -- position is 1 to maxCapacity (required for % oper to work properly)
        --firearm_data.roundChambered = nil
        --firearm_data.emptyShellChambered = nil
    else
        firearm_data.chambered_id = nil
        --firearm_data.roundChambered = 0 -- 0 or 1, a round is currently chambered
        --firearm_data.emptyShellChambered = 0 -- 0 or 1, a empty shell is currently chambered
    end

    local state = 0
    -- set the current firemode to first available position.

    --if Firearm.isSelectFire(weaponItem, self) then
    if design:isSemiAuto() then
        state = state + Status.SINGLESHOT
    elseif design:isFullAuto() then
        state = state + State.FULLAUTO
    elseif design:is2ShotBurst() then
        state = state + State.BURST2
    elseif design:is3ShotBurst() then
        state = state + State.BURST3
    else
        state = state + State.SINGLESHOT
    end
    --end
    firearm_data.state = state

    
    
    -- firearm_data.strictAmmoType = nil -- preferred ammo type, this is set by the UI context menu
    -- last round the stats were set to, used for knowing what to eject, and if we should change weapon stats when chambering next round
    firearm_data.set_ammo_id = nil
    -- what type of rounds are loaded, either ammo name, or 'mixed'. This is only really used when ejecting a magazine, so the mag's data_table
    -- has this flagged (used when loading new mags to match self.preferredAmmoType). Also used in tooltips
    firearm_data.loaded_ammo_id = nil
    firearm_data.rounds_fired = 0
    firearm_data.rounds_since_cleaned = 0
    firearm_data.barrel_length = design.barrel_length
    return firearm_data
end


Instance.dump = function(firearm_data)
    local info = logger.info
    
    local text = {
        '----------------',
        'Firearm Data:',
        '  type_id: ' .. tostring(firearm_data.type_id),
        '  ammo_group: ' .. tostring(firearm_data.ammo_group),
        '  state: ' .. tostring(firearm_data.state),
    }
    for _,t in ipairs(text) do logger.info(t) end
    if firearm_data.magazine_data then
        MagI.dump(firearm_data.magazine_data)
    end 
end

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
end

-- Chamber, or current cylinder position
Instance.setAmmoChambered = function(firearm_data, ammo_id)
    if firearm_data.cylinder_position then
        MagI.setAmmoAtPosition(firearm_data.magazine_data, firearm_data.cylinder_position, ammo_id)
        return
    end
    firearm_data.chambered_id = ammo_id
end

Instance.getAmmoChambered = function(firearm_data)
    if firearm_data.cylinder_position then
        return MagI.getAmmoAtPosition(firearm_data.magazine_data, firearm_data.cylinder_position)
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
    end
    firearm_data.chambered_id = nil
end

Instance.fireAmmoChambered = function(firearm_data)
    local ammo_id = Instance.getAmmoChambered(firearm_data)
    local ammo_design = Ammo.get(ammo_id)
    Instance.setAmmoChambered(firearm_data, ammo_design and ammo_design.case or nil)
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
