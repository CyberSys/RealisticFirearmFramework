
local Ammo = require(ENV_RFF_PATH .. "ammo/init")
local State = require(ENV_RFF_PATH .. "magazine/state")
local Flags = require(ENV_RFF_PATH .. "magazine/flags")
local Bit = require(ENV_RFF_PATH .. "interface/bit32")

local Instance = {}

Instance.isLoaded = function(magazine_data)
    if magazine_data.chambered_id and not Ammo.isCase(magazine_data.chambered_id) then
        return true
    end
    return magazine_data.current_capacity > 0
end

Instance.refillAmmo = function(magazine_data, ammo_id, count)
    --local ammo_group = Ammo.itemGroup(item, true)
    local ammo_group = Ammo.getGroup(magazine_data.ammo_group)
    if ammo_id then
        local ammo_design = Ammo.getData(ammo_id)
        if not ammo_design:isGroupMember(magazine_data.ammo_group) then return false end
    else
        ammo_id = ammo_group:random().type_id
    end
    if not count then 
        count = magazine_data.max_capacity 
    end
    for i=1, count do
        magazine_data.magazine_contents[i] = ammo_id
    end
    -- TODO: validate remaining mag position are empty.
    magazine_data.current_capacity = count
    magazine_data.loaded_ammo_id = ammo_id
end

-- Specified magazine or cylinder position
Instance.setAmmoAtPosition = function(magazine_data, position, ammo_id)
    magazine_data.magazine_contents[position] = ammo_id
end

Instance.getAmmoAtPosition = function(magazine_data, position)
    return magazine_data.magazine_contents[position] -- arrays start at 1
end

Instance.isAmmoAtPosition = function(magazine_data, position)
    local ammo_id = magazine_data.magazine_contents[position]
    return ammo_id and Ammo.isAmmo(ammo_id) or false
end

Instance.delAmmoAtPosition = function(magazine_data, position)
    magazine_data.magazine_contents[position] = nil
end

-- convert this spot to a shell casing
Instance.fireAmmoAtPosition = function(magazine_data, position)
    local ammo_id = magazine_data.magazine_contents[position]
    local ammo_design = Ammo.getDesign(mag_data[position])
    magazine_data.magazine_contents[position] = ammo_design and ammo_design.Case or nil
end


-- Top of the magazine or next cylinder postion
Instance.setAmmoAtNextPosition = function(magazine_data, ammo_id)
    magazine_data.magazine_contents[magazine_data.current_capacity] = ammo_id
end

Instance.getAmmoAtNextPosition = function(magazine_data)
    return magazine_data.magazine_contents[magazine_data.current_capacity]
end

Instance.isAmmoAtNextPosition = function(magazine_data)
    local ammo_id = Instance.getAmmoAtNextPosition(magazine_data)
    return ammo_id and Ammo.isAmmo(ammo_id) or false
end

Instance.delAmmoAtNextPosition = function(magazine_data)
    Instance.setAmmoAtNextPosition(magazine_data, nil)
end

Instance.fireAmmoAtNextPosition = function(magazine_data)
    local ammo_id = Instance.getAmmoAtNextPosition(magazine_data)
    local ammo_design = Ammo.getDesign(ammo_id)
    Instance.setAmmoAtNextPosition(magazine_data, ammo_design and ammo_design.Case or nil)
end


return Instance
