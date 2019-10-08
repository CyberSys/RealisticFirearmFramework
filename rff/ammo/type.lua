local AmmoType = {}
local ItemType = require(ENV_RFF_PATH .. "item_type")
local Flags = require(ENV_RFF_PATH .. "ammo/flags")
local Bit = require(ENV_RFF_PATH .. "interface/bit32")

setmetatable(AmmoType, { __index = ItemType })

function AmmoType:isRimfire()
    return Bit.band(self.category, Flags.RIMFIRE) ~= 0
end
function AmmoType:isPistol()
    return Bit.band(self.category, Flags.PISTOL) ~= 0
end
function AmmoType:isRifle()
    return Bit.band(self.category, Flags.RIFLE) ~= 0
end
function AmmoType:isPistol()
    return Bit.band(self.category, Flags.SHOTGUN) ~= 0
end
function AmmoType:isHollowPoint()
    return Bit.band(self.features, Flags.HOLLOWPOINT) ~= 0
end
function AmmoType:isJacketed()
    return Bit.band(self.features, Flags.JACKETED) ~= 0
end
function AmmoType:isSoftPoint()
    return Bit.band(self.features, Flags.SOFTPOINT) ~= 0
end
function AmmoType:isFlatPoint()
    return Bit.band(self.features, Flags.FLATPOINT) ~= 0
end
function AmmoType:isMatchGrade()
    return Bit.band(self.features, Flags.MATCHGRADE) ~= 0
end
function AmmoType:isBulk()
    return Bit.band(self.features, Flags.BULK) ~= 0
end
function AmmoType:isSurplus()
    return Bit.band(self.features, Flags.SURPLUS) ~= 0
end
function AmmoType:isSubsonic()
    return Bit.band(self.features, Flags.SUBSONIC) ~= 0
end
function AmmoType:isSteelCore()
    return Bit.band(self.features, Flags.STEELCORE) ~= 0
end


return AmmoType
