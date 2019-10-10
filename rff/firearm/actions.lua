local Actions = {}

local Ammo = require(ENV_RFF_PATH .. "ammo/init") 
local Firearm = require(ENV_RFF_PATH .. "firearm/init") 
local State = require(ENV_RFF_PATH .. "firearm/state")


--- Firing Functions
-- @section Fire

--[[- Called when checking if a shot will attempt to fire when the trigger is pulled.

]]
Actions.willFire = function(firearm_data, game_item, game_player)
    if State.isSafe(firearm_data) then return false end
    -- cant fire with a open slide
    if State.isOpen(firearm_data) then
        if Firearm.isOpenBolt(firearm_data) and firearm_data.current_capacity > 0 then
            return true
        end

        return false
    end
    
    -- single action with hammer at rest cant fire
    if Firearm.isSingleActionOnly(firearm_data) and not State.isCocked(firearm_data) then
        return false
    end

    if State.isRotary(firearm_data) then
        local ammo_id = nil
        if State.isCocked(firearm_data) then -- hammer is cocked, check firearm_data position
            ammo_id = Actions.getAmmoAtPosition(firearm_data, firearm_data.cylinder_position)
        else -- uncocked doubleaction, the chamber will rotate when the player pulls
            ammo_id = Actions.getAmmoAtNextPosition(firearm_data, true)
        end
        return ammo_id and Ammo.isAmmo(ammo_id) or false

    elseif State.isBreak(firearm_data) then
        local ammo_id = Actions.getAmmoAtPosition(firearm_data, firearm_data.cylinder_position)
        return ammo_id and Ammo.isAmmo(ammo_id) or false
    end

    -- anything else needs a live round chambered
    return firearm_data.chambered_id and Ammo.isAmmo(firearm_data.chambered_id) or false
end



--[[- Called as just as the trigger is pulled.

]]
Actions.preFireShot = function(firearm_data, game_item, game_player)
    if Firearm.isOpenBolt(firearm_data) then
        Actions.closeBolt(firearm_data, game_item, game_player)
        -- TODO: Check malfunction status here for fail to feed, and return false
    end
    -- SA already has hammer cocked by this point, but we dont need to check here.
    Actions.cockHammer(firearm_data, game_item, game_player) -- chamber rotates here for revolvers
    Actions.releaseHammer(firearm_data, game_item, game_player)
    
    if Malfunctions.checkFire(firearm_data, game_player, game_item) then
        return false
    end
    
    return true
end


--[[- Called after the trigger is pulled.

]]
Actions.postFireShot = function(firearm_data, game_item, game_player)
    firearm_data.rounds_since_cleaned = firearm_data.rounds_since_cleaned + 1
    firearm_data.rounds_fired = 1 + firearm_data.rounds_fired
    Actions.setEmptyCase(firearm_data)
    
    if State.isAutomatic(firearm_data) then
        Actions.openBolt(firearm_data, game_item, game_player)
        -- dont close open-bolt designs or ones with slide lock on the last shot
        if (firearm_data.current_capacity ~= 0 or not Firearm.hasSlideLock(firearm_data)) and not Firearm.isOpenBolt(firearm_data) then
            Actions.closeBolt(firearm_data, game_item, game_player)
        end
    elseif State.isBreak(firearm_data) then
        firearm_data.cylinder_position = firearm_data.cylinder_position + 1 -- this can bypass our maxCapacity limit
        -- TODO: if there are barrels left, auto recock the hammer (dual hammer double barrels)
        if firearm_data.magazine_data[firearm_data.cylinder_position] then -- set the next round
            Actions.setCurrentAmmo(firearm_data, firearm_data.magazine_data[firearm_data.cylinder_position], game_item, game_player)
        end
    end
end

--[[- Called when the trigger is pulled on a empty chamber.

]]
Actions.dryFire = function(firearm_data, game_item, game_player)
    if State.isCocked(firearm_data) then
        Actions.releaseHammer(firearm_data, game_item, game_player)
    elseif not Firearm.isSingleActionOnly(firearm_data) then
        Actions.cockHammer(firearm_data, game_item, game_player)
        Actions.releaseHammer(firearm_data, game_item, game_player)
    end
end


--- Hammer Functions
-- @section Hammer


--[[- Cocks the hammer and rotates the cylinder for Rotary actionType.

]]
Actions.cockHammer = function(firearm_data, game_item, game_player)
    -- rotary cylinders rotate the chamber when the hammer is cocked
    if State.isCocked(firearm_data) then return end
    if State.isRotary(firearm_data) and not State.isOpen(firearm_data) then
        Actions.rotateCylinder(firearm_data, 1, game_item, game_player)
    end
    State.setCocked(firearm_data, true)
end

--[[- Releases a cocked hammer.

]]
Actions.release = function(firearm_data, game_item, game_player)
    if not State.isCocked(firearm_data) then return end
    State.setCocked(firearm_data, false)
end


--- Bolt Functions
-- @section Bolt

--[[- Opens the bolt, ejecting whatever is currently in the chamber onto the ground.

]]
Actions.openBolt = function(firearm_data, game_item, game_player)
    if State.isOpen(firearm_data) then return end -- already opened!
    -- first open the slide...
    State.setOpen(firearm_data, true)

    if Malfunctions.checkExtract(firearm_data, game_item, game_player) then
        return
    end

    if Malfunctions.checkEject(firearm_data, game_item, game_player) then
        firearm_data.chambered_id = nil
        return
    end
    firearm_data.chambered_id = nil
    -- TODO: case ejection
end

--[[- Closes the bolt and chambers the next round.

Single and Double actions this also cocks the hammer.

]]
Actions.closeBolt = function(firearm_data, game_item, game_player)
    if not State.isOpen(firearm_data) then return end -- already closed!
    if not Firearm.isDoubleActionOnly(firearm_data) then
        Actions.cockHammer(firearm_data, game_item, game_player)
    end
    State.setForceOpen(firearm_data, false)
    State.setOpen(firearm_data, false)

    -- TODO: load next shot, this isn't always true though:
    -- a pump action shotgun reloaded with slide open wont chamber a round, THIS NEEDS TO BE HANDLED
    -- open bolt designs dont chamber at all until firing.

    Actions.chamberNextRound(firearm_data, game_item, game_player)
end


--- Cylinder Functions
-- @section Cylinder


--[[- Rotates the cylinder by the specified amount.

]]
Actions.rotateCylinder = function(firearm_data, count, game_item, game_player)
    local position = firearm_data.cylinder_position
    if (count == nil or count == 0) then -- random count
        count = math.random(firearm_data.max_capacity)
    end
    firearm_data.cylinder_position = ((firearm_data.cylinder_position - 1 + count) % firearm_data.max_capacity) +1
    Actions.setCurrentAmmo(firearm_data, firearm_data.magazine_data[firearm_data.cylinder_position], game_item, game_player)
end


--[[- Opens the cylinder.

]]
Actions.openCylinder = function(firearm_data, game_item, game_player)
    if State.isOpen(firearm_data) then return end
    State.setOpen(firearm_data, true)
end

--[[- Closes the cylinder and sets the current round.

]]
Actions.closeCylinder = function(firearm_data, game_item, game_player)
    if not State.isOpen(firearm_data) then return end
    State.setForceOpen(firearm_data, false)
    State.setOpen(firearm_data, false)
    Actions.setCurrentAmmo(firearm_data, firearm_data.magazine_data[firearm_data.cylinder_position], game_item, game_player)
end


--- Break Barrel Functions
-- @section Break

--[[- Opens the breech and ejects any shells.

]]
Actions.openBreech = function(firearm_data, game_item, game_player)
    if State.isOpen(firearm_data) then return end
    State.setOpen(firearm_data, true)
    firearm_data.cylinder_position = 1 -- use cylinder position variable for which barrel to fire, set to 1 for reloading
    Actions.ejectAll(firearm_data, game_item, game_player)
end


--[[- Closes the breech and sets the current round.

]]
Actions.closeBreech = function(firearm_data, game_item, game_player)
    if not State.isOpen(firearm_data) then return end
    State.setForceOpen(firearm_data, false)
    State.setOpen(firearm_data, false)
    firearm_data.cylinder_position = 1 -- use cylinder position variable for which barrel to fire
    Actions.setCurrentAmmo(firearm_data, firearm_data.magazine_data[1], game_item, game_player)
end



--- Ammo Functions
-- @section Ammo

Actions.setEmptyCase = function(firearm_data)
    if State.isRotary(firearm_data) or State.isBreak(firearm_data) then
        local mag_data = firearm_data.magazine_data
        local position = firearm_data.cylinder_position
        local ammo_design = Ammo.getDesign(mag_data[position])
        mag_data[position] = ammo_design and ammo_design.Case or nil
        firearm_data.current_capacity = firearm_data.current_capacity - 1
    else
        local ammo_design = Ammo.getDesign(firearm_data.chambered_id)
        firearm_data.chambered_id = ammo_design and ammo_design.Case or nil
    end
end

--[[- Loads a round into the firearm (internal magazine or cylinder).

]]
Actions.loadAmmo = function(firearm_data, ammo_id, position)
    if firearm_data.current_capacity == firearm_data.max_capacity then return end
    firearm_data.current_capacity = firearm_data.current_capacity + 1
    if position == nil then position = firearm_data.current_capacity end
    firearm_data.magazineData[position] = ammo_id

    if firearm_data.loaded_ammo_id == nil then
        firearm_data.loaded_ammo_id = ammo_id
    elseif firearm_data.loaded_ammo_id ~= ammo_id then
        firearm_data.loaded_ammo_id = 'mixed'
    end
end


--[[- Gets the ammo at specified position.

]]
Actions.getAmmoAtPosition = function(firearm_data, position)
    return firearm_data.magazineData[position] -- arrays start at 1
end


--[[- Gets the ammo at the next position.

]]
Actions.getAmmoAtNextPosition = function(firearm_data, wrap)
    if wrap then
        return firearm_data.magazine_data[(firearm_data.cylinder_position % firearm_data.max_capacity) +1]
    end
    return firearm_data.magazine_data[firearm_data.current_capacity]
end


--[[- Ejects all shells (live and spent) onto the ground.

Used primarly with revolvers and break barrels on opening.

]]
Actions.ejectAll = function(firearm_data, game_item, game_player)
    if not State.isOpen(firearm_data) then return end
    --local square = playerObj:getCurrentSquare()

    for index = 1, firearm_data.max_capacity do
        local ammo_id = firearm_data.magazine_data[index]
        --[[ TODO: fix this mess
        local ammoItem = nil
        if ammoType and _Ammo.isCase(ammoType) then -- eject shell
            if Settings.CasesEnabled then
                ammoItem = InventoryItemFactory.CreateItem('ORGM.' .. ammoType)
            end
        elseif ammoType then -- eject bullet
            ammoItem = Ammo.convert(firearm_data, ammoType)
            ammoItem = InventoryItemFactory.CreateItem(_Ammo.getDesign(ammoItem).moduleName..'.' .. ammoItem)
            -- TODO: check if type is faulty ammo and flag it
        end
        if (ammoItem and square) then
            square:AddWorldInventoryItem(ammoItem, 0, 0, 0)
        end
        ]]
        firearm_data.magazine_data[index] = nil
    end
    firearm_data.loaded_ammo_id = nil
    firearm_data.current_capacity = 0
end


--[[- Loads the next round into the chamber


]]
Actions.chamberNextRound = function(firearm_data, game_item, game_player)
    if firearm_data.current_capacity == 0 or firearm_data.current_capacity == nil then
        firearm_data.loaded_ammo_id = nil
        return
    end
    local ammo_id = firearm_data.magazine_data[firearm_data.current_capacity]
    if ammo_id == nil then -- problem, currentCapacity doesn't match our magazineData
        -- TODO: seems i missed filling out this part...
    end
    -- TODO: check failure to feed jams here
    if Malfunctions.checkFeed(firearm_data, playerObj, weaponItem, ammoType) then

    end

    -- remove last entry from data table (Note: using #table to find the length is slow)
    firearm_data.chambered_id = ammo_id
    firearm_data.magazine_data[firearm_data.current_capacity] = nil
    firearm_data.current_capacity = firearm_data.current_capacity - 1
    -- a different round has been chambered, change the stats
    Actions.setCurrentAmmo(firearm_data, ammo_id, game_item, game_player)

end


--[[- Triggers a recalcuation of firearm stats on ammo changes.


]]
Actions.setCurrentAmmo = function(firearm_data, ammo_id, game_item, game_player)
    if ammo_id == nil or Ammo.isCase(ammo_id) then return end
    if not Ammo.isAmmo(ammo_id) then
        firearm_data.set_ammo_id = nil
        return
    end
    if ammo_id ~= firearm_data.set_ammo_id then
        firearm_data.set_ammo_id = ammo_id -- this is also used if the slide is cycled again before firing, so we know what to eject
        -- _Stats.set(weaponItem) -- TODO: Fix stat calculation
    end
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

--[[- Gets the number of empty cases in the magazine/cylinder.

Ammo.hasCases = function(firearm_data)
    local count = 0
    for index = 1, firearm_data.maxCapacity do
        local ammoType = firearm_data.magazineData[index]

        if ammoType and _Ammo.isCase(ammoType) then
            count = count + 1
        end
    end
    return count
end


]]

--[[- Finds and returns the best ammo available in the players inventory.

Ammo.findBest = function(firearm_data, playerObj)
    return _Ammo.findIn(firearm_data.ammoType, firearm_data.strictAmmoType, playerObj:getInventory())
end

]]




return Actions
