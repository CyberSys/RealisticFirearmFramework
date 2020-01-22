-- Converters
local Convert = { }

Convert.CELSIUS = 1
Convert.FAHRENHEIT = 2

-- +10 for metric distances
Convert.MILIMETER = 11
Convert.CENTIMETER = 12
Convert.METER = 13

-- +20 for imp distances
Convert.INCH = 21
Convert.FOOT = 22
Convert.YARD = 23

-- +30 metric weight
Convert.GRAM = 31
Convert.CENTIGRAM = 32
Convert.KILOGRAM = 33

Convert.GRAIN = 41
Convert.OUNCE = 42
Convert.POUND = 43


local MetricDistanceScale = {
    [Convert.MILIMETER] = 1, -- mm
    [Convert.CENTIMETER] = 10, -- cm
    [Convert.METER] = 1000, -- m
}
local ImperialDistanceScale = {
    [Convert.INCH] = 1, -- in
    [Convert.FOOT] = 12, -- ft
    [Convert.YARD] = 36, -- yard
}

local MetricWeightScale = {
    [Convert.GRAM] = 1, -- g
    [Convert.CENTIGRAM] = 10, -- cg
    [Convert.KILOGRAM] = 1000, -- kg
}
local ImperialWeightScale = {
    [Convert.GRAIN] = 1, -- gr
    [Convert.OUNCE] = 437.5, -- oz
    [Convert.POUND] = 7000, -- lb
}

local isTemp = function(type_const)
    if type_const == Convert.CELSIUS then return true end 
    if type_const == Convert.FAHRENHEIT then return true end
    return false 
end
local isDistance = function(type_const)
    if MetricDistanceScale[type_const] then return true end
    if ImperialDistanceScale[type_const] then return true end
    return false
end
local isMass = function(type_const)
    if MetricWeightScale[type_const] then return true end
    if ImperialWeightScale[type_const] then return true end
    return false 
end

local convert = function(value, input_type, output_type, table_a, table_b)
    local input_table = table_a
    if table_b[input_type] then input_table = table_b end

    local output_table = table_b
    if table_a[output_type] then output_table = table_a end
    
    -- reduce value to a base unit.
    value = value * input_table[input_type]
    --for k,v in pairs(input_table) do print(k, v) end
    if input_table == output_table then 
        value = value / output_table[output_type] 
    elseif input_table == MetricWeightScale then
        -- value is in grams, convert to grains, then scale
        value = (value * 15.43236) / output_table[output_type] 
    elseif input_table == ImperialWeightScale then
        -- value is in grains, convert to grams, then scale
        value = (value / 15.43236) / output_table[output_type] 
    elseif input_table == MetricDistanceScale then
        -- value is in mm, convert to inches, then scale
        value = (value * 0.03937007874) / output_table[output_type] 
    else
        -- value is in inches, convert to mm, then scale
        value = (value * 25.4) / output_table[output_type] 
    end
    -- todo, round value?
    return value
end

Convert.temp = function(value, input_type, output_type)
    if input_type == output_type or not (isTemp(input_type) and isTemp(output_type)) then return value end
    if input_type == Convert.CELSIUS and output_type == Convert.FAHRENHEIT then
        return value * 1.8 + 32 
    elseif input_type == Convert.FAHRENHEIT and output_type == Convert.CELSIUS then
        return (value - 32) / 1.8 
    end
    return nil -- what? impossible state? lol
end

Convert.distance = function(value, input_type, output_type)
    return convert(value, input_type, output_type, MetricDistanceScale, ImperialDistanceScale)
end


Convert.mass = function(value, input_type, output_type)
    return convert(value, input_type, output_type, MetricWeightScale, ImperialWeightScale)
end

return Convert
