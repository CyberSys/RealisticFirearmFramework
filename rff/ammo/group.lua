local AmmoGroup = {}
local ItemGroup = require(ENV_RFF_PATH .. "item_group")
local Container = require(ENV_RFF_PATH .. "interface/container")

local pairs = pairs
local table = table

setmetatable(AmmoGroup, { __index = ItemGroup })


--[[- Finds the best matching ammo (bullets only) in a container.

Finds loose bullets, boxes and canisters of ammo.
Search is based on the given ammoGroup name and preferred type.
(can be specific round name, nil/any, or mixed)

This is called when reloading some guns and all magazines.

Note ammoGroup and ammoType should NOT have the "ORGM." prefix.

@tparam string ammoGroup name of a AmmoGroup.
@tparam nil|string ammoType 'any', 'mixed' or a specific ammo name
@tparam ItemContainer container
@tparam[opt] nil|int mode 0 = rounds, 1 = box, 2 = can

@treturn nil|InventoryItem

]]
function AmmoGroup:find(ammoType, container, mode)

    if container == nil then return nil end
    if ammoType == nil then ammoType = 'any' end

    local suffex = ""
    --[[ there should be a better way...
    if mode == 1 then
        suffex = "_Box"
    elseif mode == 2 then
        suffex = "_Can"
    end
    ]]
    -- check for a prefererd type.
    if ammoType ~= "any" and ammoType ~= 'mixed' then
        -- a preferred ammo is set, we only look for these bullets
        return Container.find(container, ammoType)
    end

    if self.members == nil then
        return nil
    end

    if ammoType == 'mixed' then
        local options = {}
        for name, weight in pairs(self.members) do
            -- check what rounds the player has
            if Container.find(container, name) then table.insert(options, name) end
        end
        -- randomly pick one
        return Container.find(container, options[math.random(#options)])

    else -- not a random picking, go through the list in order
        for name, weight in pairs(self.members) do
            round = Container.find(name)
            if round then
                 return round
            end
        end
    end
    return nil
end


return AmmoGroup
