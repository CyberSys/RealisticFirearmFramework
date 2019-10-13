--[[- Class for specific magazine data templates.

@classmod MagazineType
@author Fenris_Wolf
@release 1.0-alpha
@copyright 2018

]]
local MagazineType = {}
local ItemType = require(ENV_RFF_PATH .. "item_type")
local Flags = require(ENV_RFF_PATH .. "firearm/flags")
local State = require(ENV_RFF_PATH .. "firearm/state")

local Bit = require(ENV_RFF_PATH .. "interface/bit32")
local Logger = require(ENV_RFF_PATH .. "interface/logger")
setmetatable(MagazineType, { __index = ItemType })

MagazineType._PropertiesTable = {
    features = {type='integer', min=0, default=0, required=true},
    image = {type='string', default=""},
    ammo_group = {type='string', default="", required=true},
    max_capacity = {type='integer', min=1, default=10, required=true},
    weight = {type='float', min=0, max=100, default=0.2},
}



function MagazineType:setup(data_table)
    data_table.ammo_group = self.ammo_group
    data_table.max_mapacity = self.max_capacity
    data_table.current_capacity = 0
    data_table.magazineData = { }
    --modData.strictAmmoType = nil
    data_table.loaded_ammo_id = nil
    data_table.features = self.features
    data_table.weight = self.weight
    return data_table
end

--[[

function MagazineType:spawn(container, loaded)
    local item = InventoryItemFactory.CreateItem("ORGM.".. self.type)
    self:setup(item)
    if loaded then
        local count = self.maxCapacity
        if ZombRand(100) < 50 then count = ZombRand(self.maxCapacity)+1 end
    end
    Magazine.refill(item, count)
    container:AddItem(item)
    return item
end

]]

return MagazineType
