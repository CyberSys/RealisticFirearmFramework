local Actions = {}

local Ammo = require(ENV_RFF_PATH .. "ammo/init")
local Firearm = require(ENV_RFF_PATH .. "firearm/init") 
local Instance = require(ENV_RFF_PATH .. "firearm/instance")


local EventSystem = require(ENV_RFF_PATH .. "events")
local Malfunctions = require(ENV_RFF_PATH .. "malfunctions")


local updateSetAmmo = function(firearm_data, game_item, game_player, is_firing)
    if Instance.updateSetAmmo(firearm_data, Instance.getAmmoChambered(firearm_data)) then
        -- TODO: stats recalculation
    end    
end

--- Firing Functions
-- @section Fire

--[[- Called as just as the trigger is pulled.

]]
Actions.pullTrigger = function(firearm_data, game_item, game_player, is_firing)
    -- Trigger event
    if EventSystem.triggerHalt("TriggerPulled", firearm_data, game_item, game_player, is_firing) then return false end

    if Instance.isSafe(firearm_data) then return false end
    
    if Instance.isOpen(firearm_data) then
        if Firearm.isOpenBolt(firearm_data) then
            Actions.closeBolt(firearm_data, game_item, game_player, is_firing)
            -- TODO: Check malfunction status here for fail to feed, and return false
        end
        return false
    elseif Firearm.isOpenBolt(firearm_data) then -- open bolt design, already closed?
        return false
    end
    
    -- single action with hammer at rest cant fire
    if Firearm.isSingleActionOnly(firearm_data) and not Instance.isCocked(firearm_data) then
        return false
    end        
    
    -- SA already has hammer cocked by this point, but we dont need to check here.
    Actions.cockHammer(firearm_data, game_item, game_player, is_firing) -- chamber rotates here for revolvers
    Actions.releaseHammer(firearm_data, game_item, game_player, is_firing)

    if not Instance.isAmmoChambered(firearm_data) then
        return false
    end 
    
    if Malfunctions.checkFire(firearm_data, game_player, game_item, is_firing) then
        return false
    end
    
    return true
end


--[[- Called after the trigger is pulled.

]]
Actions.shotFired = function(firearm_data, game_item, game_player, is_firing)
    -- Trigger event
    if EventSystem.triggerHalt("ShotFired", firearm_data, game_item, game_player, is_firing) then return false end
    
    Instance.incRoundsFired(firearm_data, 1)
    Instance.fireAmmoChambered(firearm_data)
    if Instance.isRotary(firearm_data) or Instance.isBreak(firearm_data) then
        Instance.setAmmoCountRelative(firearm_data, -1)
    end
    
    if Instance.isAutomatic(firearm_data) then
        Actions.openBolt(firearm_data, game_item, game_player, is_firing)
        
        -- dont close open-bolt designs or ones with slide lock on the last shot
        if (not Instance.isMagazineEmpty(firearm_data) or not Firearm.hasSlideLock(firearm_data)) and not Firearm.isOpenBolt(firearm_data) then
            Actions.closeBolt(firearm_data, game_item, game_player, is_firing)
        end
    elseif Instance.isBreak(firearm_data) then
        Instance.incPosition(firearm_data)
        
        -- TODO: if there are barrels left, auto recock the hammer (dual hammer double barrels)
        updateSetAmmo(firearm_data, game_item, game_player, is_firing)
    end
    return true
end

--[[- Called when the trigger is pulled on a empty chamber.

]]
Actions.dryFired = function(firearm_data, game_item, game_player, is_firing)
    -- click!
    return true
end


--- Hammer Functions
-- @section Hammer


--[[- Cocks the hammer and rotates the cylinder for Rotary actionType.

]]
Actions.cockHammer = function(firearm_data, game_item, game_player, is_firing)
    -- rotary cylinders rotate the chamber when the hammer is cocked
    if Instance.isCocked(firearm_data) then return false end
    if Instance.isRotary(firearm_data) and not Instance.isOpen(firearm_data) then
        Actions.rotateCylinder(firearm_data, 1, game_item, game_player, is_firing)
    end
    Instance.setCocked(firearm_data, true)
    return true
end

--[[- Releases a cocked hammer.

]]
Actions.releaseHammer = function(firearm_data, game_item, game_player, is_firing)
    if not Instance.isCocked(firearm_data) then return false end
    Instance.setCocked(firearm_data, false)
    return true
end


--- Bolt Functions
-- @section Bolt

--[[- Opens the bolt, ejecting whatever is currently in the chamber onto the ground.

]]
Actions.openBolt = function(firearm_data, game_item, game_player, is_firing)
    if Instance.isOpen(firearm_data) then return end -- already opened!
    -- first open the slide...
    Instance.setOpen(firearm_data, true)

    if Malfunctions.checkExtract(firearm_data, game_item, game_player, is_firing) then
        return false
    end

    if Malfunctions.checkEject(firearm_data, game_item, game_player, is_firing) then
        Instance.delAmmoChambered(firearm_data)
        return false
    end
    Instance.delAmmoChambered(firearm_data)
    -- TODO: case ejection
    return true
end

--[[- Closes the bolt and chambers the next round.

Single and Double actions this also cocks the hammer.

]]
Actions.closeBolt = function(firearm_data, game_item, game_player, is_firing)
    if not Instance.isOpen(firearm_data) then return false end -- already closed!
    if not Firearm.isDoubleActionOnly(firearm_data) then
        Actions.cockHammer(firearm_data, game_item, game_player, is_firing)
    end
    Instance.setForceOpen(firearm_data, false)
    Instance.setOpen(firearm_data, false)

    -- TODO: load next shot, this isn't always true though:
    -- a pump action shotgun reloaded with slide open wont chamber a round, THIS NEEDS TO BE HANDLED
    -- open bolt designs dont chamber at all until firing.

    Actions.chamberNextRound(firearm_data, game_item, game_player, is_firing)
    return true
end


--- Cylinder Functions
-- @section Cylinder


--[[- Rotates the cylinder by the specified amount.

]]
Actions.rotateCylinder = function(firearm_data, count, game_item, game_player, is_firing)
    if not count or count == 0 then -- random count
        Instance.setRandomPosition(firearm_data)
        return false
    end
    Instance.incPosition(firearm_data, 1, true)
    --firearm_data.cylinder_position = ((firearm_data.cylinder_position - 1 + count) % firearm_data.max_capacity) +1
    updateSetAmmo(firearm_data, game_item, game_player, is_firing)
    return true
end


--[[- Opens the cylinder.

]]
Actions.openCylinder = function(firearm_data, game_item, game_player, is_firing)
    if Instance.isOpen(firearm_data) then return false end
    Instance.setOpen(firearm_data, true)
    return true
end

--[[- Closes the cylinder and sets the current round.

]]
Actions.closeCylinder = function(firearm_data, game_item, game_player, is_firing)
    if not Instance.isOpen(firearm_data) then return false end
    Instance.setForceOpen(firearm_data, false)
    Instance.setOpen(firearm_data, false)
    updateSetAmmo(firearm_data, game_item, game_player, is_firing)
    return true
end


--- Break Barrel Functions
-- @section Break

--[[- Opens the breech and ejects any shells.

]]
Actions.openBreech = function(firearm_data, game_item, game_player, is_firing)
    if Instance.isOpen(firearm_data) then return false end
    Instance.setOpen(firearm_data, true)
    Instance.setPosition(firearm_data, 1) -- set to 1 for reloading
    Actions.ejectAll(firearm_data, game_item, game_player, is_firing)
    return true
end


--[[- Closes the breech and sets the current round.

]]
Actions.closeBreech = function(firearm_data, game_item, game_player, is_firing)
    if not Instance.isOpen(firearm_data) then return false end
    Instance.setForceOpen(firearm_data, false)
    Instance.setOpen(firearm_data, false)
    Instance.setPosition(firearm_data, 1) 
    --firearm_data.cylinder_position = 1 -- use cylinder position variable for which barrel to fire
    updateSetAmmo(firearm_data, game_item, game_player, is_firing)
    return true
end



--- Ammo Functions
-- @section Ammo

--[[- Loads a round into the firearm (internal magazine or cylinder).

]]
Actions.loadAmmo = function(firearm_data, ammo_id, position)
    if Instance.isAmmoCountMaxed(firearm_data) then return false end
    Instance.setAmmoCountRelative(firearm_data, 1)
    if position then
        Instance.setAmmoAtPosition(firearm_data, position, ammo_id)
    else
        Instance.setAmmoAtNextPosition(firearm_data, ammo_id)
    end
    Instance.updateLoadedAmmo(firearm_data, ammo_id)
    return true
end


--[[- Ejects all shells (live and spent) onto the ground.

Used primarly with revolvers and break barrels on opening.

]]
Actions.ejectAll = function(firearm_data, game_item, game_player, is_firing)
    if not Instance.isOpen(firearm_data) then return false end
    local magazine_data = Instance.getMagazineData()
    for k, v in pairs(magazine_data) do
        -- TODO: call Interface functions for dropping ammo.
    end
    Instance.setMagazineEmpty(firearm_data)
    return true
end


--[[- Loads the next round into the chamber


]]
Actions.chamberNextRound = function(firearm_data, game_item, game_player, is_firing)
    if Instance.isMagazineEmpty(firearm_data) then
        Instance.updateLoadedAmmo() 
        return false
    end

    local ammo_id = Instance.getAmmoAtNextPosition(firearm_data)
    -- firearm_data.magazine_data[firearm_data.current_capacity]
    if ammo_id == nil then -- problem, currentCapacity doesn't match our magazineData
        -- TODO: seems i missed filling out this part...
    end
    
    -- TODO: check failure to feed jams here
    if Malfunctions.checkFeed(firearm_data, game_item, game_player, is_firing) then
        return false -- TODO: we need a proper error code here to seperate from empty mags returning false as well....
    end
    Instance.setAmmoChambered(firearm_data, ammo_id)
    Instance.delAmmoAtNextPosition(firearm_data)
    Instance.setAmmoCountRelative(firearm_data, -1)

    updateSetAmmo(firearm_data, game_item, game_player, is_firing)
    return true
end


--[[- Sets the position of the Select Fire switch.
local FIREMODESTATES = Status.SINGLESHOT+Status.FULLAUTO+Status.BURST2+Status.BURST3

Fire.set = function(this, mode)
    if not mode then
        -- find all firing modes allowed
        local thisData = Firearm.getDesign(this.type)
        local opt = {}
        if Firearm.isSemiAuto(this) then table.insert(opt, Status.SINGLESHOT) end
        if Firearm.isFullAuto(this) then table.insert(opt, Status.FULLAUTO) end
        if Firearm.is2ShotBurst(this) then table.insert(opt, Status.BURST2) end
        if Firearm.is3ShotBurst(this) then table.insert(opt, Status.BURST3) end
        if #opt == 0 then
            mode = Status.SINGLESHOT
        else
            mode = opt[ZombRand(#opt) +1]
        end
    end
    this.status = this.status - Bit.band(this.status, FIREMODESTATES) + mode
    return mode
end
]]

--[[- Finds and returns the best ammo available in the players inventory.

Ammo.findBest = function(firearm_data, playerObj)
    return _Ammo.findIn(firearm_data.ammoType, firearm_data.strictAmmoType, playerObj:getInventory())
end



Actions.willFire = function(firearm_data, game_item, game_player)
    if Instance.isSafe(firearm_data) then return false end
    if Instance.isOpen(firearm_data) then
        if Firearm.isOpenBolt(firearm_data) and firearm_data.current_capacity > 0 then
            return true
        end
        -- cant fire with a open slide
        return false
    end
    
    -- single action with hammer at rest cant fire
    if Firearm.isSingleActionOnly(firearm_data) and not Instance.isCocked(firearm_data) then
        return false
    end

    if Instance.isRotary(firearm_data) then
        if Instance.isCocked(firearm_data) then -- hammer is cocked, check firearm_data position
            return Instance.isAmmoChambered(firearm_data)
        end
        -- uncocked doubleaction, the chamber will rotate when the player pulls
        return Instance.isAmmoAtNextPosition(firearm_data, true)
    end

    -- anything else needs a live round chambered
    return Instance.isAmmoChambered(firearm_data)
end


]]




return Actions
