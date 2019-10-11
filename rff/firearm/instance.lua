local Instance = {}
local Ammo = require(ENV_RFF_PATH .. "ammo/init")


-- Chamber, or current cylinder position
Instance.setAmmoChambered = function(firearm_data, ammo_id)
    if firearm_data.cylinder_position then
        firearm_data.magazine_data[firearm_data.cylinder_position] = ammo_id
        return
    end
    firearm_data.chambered_id = ammo_id
end

Instance.getAmmoChambered = function(firearm_data)
    if firearm_data.cylinder_position then
        return firearm_data.magazine_data[firearm_data.cylinder_position]
    end
    return firearm_data.chambered_id
end

Instance.isAmmoChambered = function(firearm_data)
    local ammo_id = Instance.getAmmoChambered(firearm_data)
    return ammo_id and Ammo.isAmmo(ammo_id) or false
end

Instance.delAmmoChambered = function(firearm_data)
    if firearm_data.cylinder_position then
        firearm_data.magazine_data[firearm_data.cylinder_position] = nil
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
    firearm_data.magazine_data[position] = ammo_id
end

Instance.getAmmoAtPosition = function(firearm_data, position)
    return firearm_data.magazine_data[position] -- arrays start at 1
end

Instance.isAmmoAtPosition = function(firearm_data, position)
    local ammo_id = firearm_data.magazine_data[position]
    return ammo_id and Ammo.isAmmo(ammo_id) or false
end

Instance.delAmmoAtPosition = function(firearm_data, position)
    firearm_data.magazine_data[position] = nil
end

-- convert this spot to a shell casing
Instance.fireAmmoAtPosition = function(firearm_data, position)
    local ammo_id = firearm_data.magazine_data[position]
    local ammo_design = Ammo.getDesign(mag_data[position])
    firearm_data.magazine_data[position] = ammo_design and ammo_design.Case or nil
end


-- Top of the magazine or next cylinder postion
Instance.setAmmoAtNextPosition = function(firearm_data, ammo_id)
    if firearm_data.cylinder_position then
        firearm_data.magazine_data[(firearm_data.cylinder_position % firearm_data.max_capacity) +1] = ammo_id
        return 
    end
    firearm_data.magazine_data[firearm_data.current_capacity] = ammo_id
end

Instance.getAmmoAtNextPosition = function(firearm_data)
    if firearm_data.cylinder_position then
        return firearm_data.magazine_data[(firearm_data.cylinder_position % firearm_data.max_capacity) +1]
    end
    return firearm_data.magazine_data[firearm_data.current_capacity]
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
    for index, ammo_id in pairs(firearm_data.magazine_data) do
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
        firearm_data.magazine_data[index] = nil
    end
    firearm_data.loaded_ammo_id = nil
    firearm_data.current_capacity = 0    
end

Instance.getMagazineData = function(firearm_data)
    return firearm_data.magazine_data
end



return Instance
