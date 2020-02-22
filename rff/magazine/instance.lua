
local Ammo = require(ENV_RFF_PATH .. "ammo/init")
local State = require(ENV_RFF_PATH .. "magazine/state")
local Flags = require(ENV_RFF_PATH .. "magazine/flags")
local Bit = require(ENV_RFF_PATH .. "interface/bit32")
local logger = require(ENV_RFF_PATH .. "interface/logger")

local Instance = {}

Instance.initialize = function(magazine_data, design, attrib)
    magazine_data = magazine_data or { }
    magazine_data.magazine_contents = { }
    magazine_data.state = 0
    magazine_data.current_capacity = 0
    magazine_data.loaded_ammo_id = nil

    magazine_data.type_id = design.type_id or nil 
    magazine_data.ammo_group = design.ammo_group
    magazine_data.features = design.features
    magazine_data.max_capacity = design.max_capacity
    return magazine_data
end

Instance.dump = function(magazine_data)
    local info = logger.info
    local text = {
        '----------------',
        '  Magazine Data:',
        '  type_id: ' .. tostring(magazine_data.type_id),
        '  ammo_group: ' .. tostring(magazine_data.ammo_group),
        '  loaded_ammo_id: ' .. tostring(magazine_data.loaded_ammo_id),
        '  features: ' .. tostring(magazine_data.features),
        '  state: ' .. tostring(magazine_data.state),
        '  max_capacity: ' .. tostring(magazine_data.max_capacity),
        '  current_capacity: ' .. tostring(magazine_data.current_capacity),
        '  state: ' .. tostring(magazine_data.state),
        '  contents: '
    }
    for _,t in ipairs(text) do logger.info(t) end
    local contents = magazine_data.magazine_contents
    for i=1, magazine_data.max_capacity do
        if contents[i] then logger.info('    '..tostring(i)..": "..tostring(contents[i])) end
    end
end

Instance.isLoaded = function(magazine_data)
    return magazine_data.current_capacity > 0
end

Instance.isEmpty = function(magazine_data)
    return magazine_data.current_capacity == 0
end

Instance.setEmpty = function(magazine_data)
    for index = 1, magazine_data.max_capacity do
        magazine_data.magazine_contents[index] = nil
    end
    magazine_data.loaded_ammo_id = nil
    magazine_data.current_capacity = 0    
end

Instance.isFull = function(magazine_data)
    return magazine_data.current_capacity >= magazine_data.max_capacity
end

Instance.getMaxAmmoCount = function(magazine_data)
    return magazine_data.max_capacity
end

Instance.setMaxAmmoCount = function(magazine_data, value)
    magazine_data.max_capacity = value
end

Instance.getAmmoCount = function(magazine_data)
    return magazine_data.current_capacity
end

Instance.setAmmoCount = function(magazine_data, value)
    magazine_data.current_capacity = value
end

Instance.setAmmoCountRelative = function(magazine_data, count)
    magazine_data.current_capacity = magazine_data.current_capacity + count
    -- TODO: validate limits
end


Instance.updateLoadedAmmo = function(magazine_data, ammo_id)
    if ammo_id == nil then
        magazine_data.loaded_ammo_id = nil
    elseif magazine_data.loaded_ammo_id == nil then
        magazine_data.loaded_ammo_id = ammo_id
    elseif magazine_data.loaded_ammo_id ~= ammo_id then
        magazine_data.loaded_ammo_id = 'mixed'
    end    
end


Instance.refillAmmo = function(magazine_data, ammo_id, count)
    --local ammo_group = Ammo.itemGroup(item, true)
    local ammo_group = Ammo.getGroup(magazine_data.ammo_group)
    if ammo_id then
        local ammo_design = Ammo.get(ammo_id)
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
    local ammo_design = Ammo.get(ammo_id)
    magazine_data.magazine_contents[position] = ammo_design and ammo_design.Case or nil
end

-- Top of the magazine. cylinders need to manually specify position using other functions 
Instance.setAmmoAtNextPosition = function(magazine_data, ammo_id)
    magazine_data.magazine_contents[magazine_data.current_capacity] = ammo_id
end

Instance.getAmmoAtNextPosition = function(magazine_data)
    return magazine_data.magazine_contents[magazine_data.current_capacity]
end

Instance.isAmmoAtNextPosition = function(magazine_data)
    local ammo_id = Instance.getAmmoAtNextPosition(magazine_data)
    return Ammo.isAmmo(ammo_id)
end

Instance.delAmmoAtNextPosition = function(magazine_data)
    Instance.setAmmoAtNextPosition(magazine_data, nil)
end

Instance.fireAmmoAtNextPosition = function(magazine_data)
    local ammo_id = Instance.getAmmoAtNextPosition(magazine_data)
    local ammo_design = Ammo.get(ammo_id)
    Instance.setAmmoAtNextPosition(magazine_data, ammo_design and ammo_design.Case or nil)
end

Instance.hasCases = function(magazine_data)
    local count = 0
    for index, ammo_id in pairs(magazine_data.magazine_contents) do
        if ammo_id and Ammo.isCase(ammo_id) then
            count = 1 + count
        end
    end
    return count
end





return Instance
