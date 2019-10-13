--[[- Class for magazine groups.

@classmod MagazineGroup
@author Fenris_Wolf
@release 1.0-alpha
@copyright 2018

]]
local ItemGroup = require(ENV_RFF_PATH .. "item_group")
local MagazineGroup = {}

setmetatable(MagazineGroup, { __index = ItemGroup })

return MagazineGroup

--[[


function MagazineGroup:spawn(typeModifiers, filter, container, loaded)
    local magazine = self:random(typeModifiers, filter)
    return magazine:spawn(container, loaded)
end

--[[- Finds the best matching magazine in a container.

Search is based on the given magazine name and preferred load
(can be specific round name, nil/any, or mixed), and the currentCapacity.

This is called when reloading some guns and all magazines.

Note magType and ammoType should NOT have the "ORGM." prefix.

@tparam string magType name of a magazine
@tparam nil|string ammoType 'any', 'mixed' or a specific ammo name
@tparam ItemContainer containerItem

@treturn nil|InventoryItem

function MagazineGroup:find(ammoType, containerItem)

    if containerItem == nil then return nil end
    if ammoType == nil then ammoType = 'any' end
    local bestMagazine = nil
    local mostAmmo = -1

    for magazineType, weight in pairs(self.members) do
        local items = containerItem:getItemsFromType(magazineType)
        for i = 0, items:size()-1 do repeat
            local currentItem = items:get(i)
            local modData = currentItem:getModData()
            local magData = Magazine.getData(currentItem:getType())
            if modData.currentCapacity == nil then -- magazine needs to be setup
                Magazine.setup(magData, currentItem)
            end
            if modData.currentCapacity <= mostAmmo then
                break
            end

            if ammoType ~= 'any' and ammoType ~= modData.loadedAmmoType then
                break
            end
            bestMagazine = currentItem
            mostAmmo = modData.currentCapacity
        until true end
    end
    return bestMagazine
end

]]
