--[[- Class for organizing firearm group data.

@classmod FirearmGroup
@author Fenris_Wolf
@release 1.0-alpha
@copyright 2018

]]

local FirearmGroup = {}
local ItemGroup = require(ENV_RFF_PATH .. "item_group")

setmetatable(FirearmGroup, { __index = ItemGroup })

--- FirearmGroup Methods
-- @section FirearmGroup


--[[
function FirearmGroup:spawn(container, loaded, typeModifiers, flagModifiers, chance, mustFit)
    local firearm = self:random(typeModifiers, flagModifiers)
    return firearm:spawn(container, loaded, chance, mustFit)
end

-- bad test. cant import 'Firearm' from here.
function FirearmGroup:test()
    -- pick a random gun manufactured by colt
    local group = Firearm.getGroup('Group_Colt')
    local result = group:random({
        Group_Colt_Revolvers = 3, -- x3 more likely to choose a revolver
        Colt_Anaconda_MM4540 = 0, -- dont pick this ultra rare version
        Colt_M16_M603 = 2, -- if we do pick a rifle, and its a CAR15/M16 then twice a likely its a m16a1
        Colt_M16_M645 = 0.5 -- and only half as likey its a m16a2
    })
    print(result)
end
]]
return FirearmGroup
