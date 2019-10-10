--[[
    Checking malfunctions depends on a variety of factors:
    over all condition of the firearm
    how many rounds have been shot since the last time the firearm was cleaned. For some action types this is less important
        then others (ie: revolvers vs gas powered automatics)
    was WD-40 used and not been properly cleaned after? The use of WD-40 as a 'repair kit' is really quite incorrect. That
        stuff is NASTY for firearms. It creates extra dirt and gunk, strips away proper gun lubricants, and being a penetrating
        oil, can leak into ammo primers creating dud rounds.  It has its uses unseizing stuck parts, but without a proper
        cleaning after it creates additional problems

]]

local Firearm = require(ENV_RFF_PATH .. "firearm/init")
local Ammo = require(ENV_RFF_PATH .. "ammo/init")
local Bit = require(ENV_RFF_PATH .. "interface/bit32")

local Malfunctions = {}

local Ammunition = { } 
local Mechanical = {}
local Failure = {}

local ipairs = ipairs
local select = select

local band = Bit.band

--[[ ammo status flags.

    For InventoryItem loose ammo, use modData.status (if not 0).
    Boxes and Canisters should use a table: keys being flag sums, values being number of rounds in the box with those flags.
    Magazines (internal/external) should use a table: position in magazine, flags for that ammo (similar to magazineData table)
    Guns need a extra variable for the flags of the round in chamber.

Status.DUD = 1 -- obvious dud. primer has already been struck
Status.POWDERNONE = 2 -- no powder. if the primer is active this may squib (probably)
Status.POWDERLOW = 4 -- low powder. weak shot, hangfire or squib.
Status.POWDERHIGH = 8 -- high powder. excessive pressure.
Status.BRASSWEAK = 16 -- neck or rim might rip on extraction.
Status.BRASSDEFORMED = 32 -- brass is slightly deformed or bad measurements. possible feeding issues.
Status.PRIMERDEAD = 64 -- the primer is dead. dud round.
Status.PRIMERSEATPOS = 128 -- primer not seated far enough. causes slamfires
Status.PRIMERSEATNEG = 256 -- primer seated to far. causes duds, hangfires (pin does not strike hard enough)
Status.BULLETSEATPOS = 512 -- bullet not seated far enough. feeding and pressure issues.
Status.BULLETSEATNEG = 1024  -- bullet seated to far. excessive pressure.
Status.BULLETDEFORMED = 2048 -- bullet is slightly deformed. possible feeding/performance issues.
]]

local check = function(firearm_data, game_item, game_player, is_firing, ...)
    --if not Settings.JammingEnabled then return false end
    local gunData = Firearm.get(firearm_data.type)
    local ammoData = Ammo.getDesign(ammoType)
    for i, failure in ipairs({select(1, ...)}) do repeat
        if failure:onEvent(firearm_data, game_item, game_player, is_firing) then
            return true
        end
    until true end
    return false
end
Malfunctions.checkFeed = function(firearm_data, game_item, game_player, is_firing)
    return check(firearm_data, game_item, game_player, is_firing,
        Ammunition.FailToFeed1, -- poorly shaped bullet or neck not properly clearing the ramp.
        Mechanical.FailToFeed1, -- dirt
        Mechanical.FailToFeed2, -- worn recoil spring
        Mechanical.FailToFeed3, -- worn ramp
        Mechanical.FailToFeed4, -- bad magazine
        Mechanical.FailToFeed5, -- Chamber not empty
        Mechanical.FailToFeed6, -- slam fire. faulty firing pin (too long)
        Ammunition.FailToFeed2 -- slamfire. poorly seated primer
    )
end
Malfunctions.checkExtract = function(firearm_data, game_item, game_player, is_firing)
    return check(firearm_data, game_item, game_player, is_firing,
        Ammunition.FailToExtract1, -- brass rim failure
        Ammunition.FailToExtract2, -- case-head seperation. the head of the case is stuck in the chamber and needs to be extracted with tools.
        Ammunition.FailToExtract3, -- lack of pressure - autos only.
        Mechanical.FailToExtract1, -- dirt
        Mechanical.FailToExtract2, -- worn extractor hook
        Mechanical.FailToExtract3 -- recoil spring too strong
    )
end
Malfunctions.checkEject = function(firearm_data, game_item, game_player, is_firing)
    return check(firearm_data, game_item, game_player, is_firing,
        -- stovepipes!
        Ammunition.FailToEject, -- not enough pressure to cycle the action in automatics.
        Mechanical.FailToEject1, -- dirt
        Mechanical.FailToEject2 -- recoil to strong
    )
end
Malfunctions.checkFire = function(firearm_data, game_item, game_player, is_firing)
    return check(firearm_data, game_item, game_player, is_firing,
        Mechanical.FailToFire1, -- dirt
        Mechanical.FailToFire2, -- worn firing pin spring
        Mechanical.FailToFire3, -- worn firing pin
        Ammunition.FailToFire1, -- dud round. refuses to fire.
        Ammunition.FailToFire2, -- squib load. bullet will lodged in the barrel and needs to be cleared. Will not cycle automatics. (FailToEject)
        Ammunition.FailToFire3 -- delay firing for a few seconds.
    )
end

Ammunition.FailToFire1 = {
    name = "Failure-To-Fire, Dud Round",
    description = "For whatever reason, the round is a dud and will not fire.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        -- check the status flags of the current ammo:
        -- PRIMERDEAD = true
        -- PRIMERSEATNEG probably returns true
        -- POWDERNONE might return true...if the player is lucky...
        -- any true result here needs to set DUD flag
        return false
    end,
}
Ammunition.FailToFire2 = {
    name = "Failure-To-Fire, Squib Load",
    description = "Bullet becomes lodged in the barrel due to bad ammo. Next shot is disastrous. Squib loads can be detected by the shot sound, less of a bang and more of a pop. <LINE> Automatics will not properly cycle with a squib, causing a failure to extract or eject.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        -- check the status flags of the current ammo:
        -- POWDERNONE = true (if not a dud in FailToFire1)
        -- POWDERLOW might return true, or result in a hangfire
        return false
    end,
}
Ammunition.FailToFire3 = {
    name = "Failure-To-Fire, Hang-Fire",
    description = "Firing of the shot is delayed due to bad ammo. When a firearm refuses to fire, it should be pointed in a safe direction for 2 minutes to rule out a hangfire. <LINE> This can cause severe damage to the shooter if the weapon has been holstered, and will be disastrous if a revolver and the cylinder was rotated.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        -- check the status flags of the current ammo:
        -- POWDERLOW =  true (if not a squib in FailToFire2)
        -- PRIMERSEATNEG = high random chance of true (if not a dud in FailToFire1)
        return false
    end,
}
Ammunition.FailToFeed1 = {
    name = "Failure-To-Feed, Bad Ammo",
    description = "Poorly shaped bullet or neck not properly clearing the ramp.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        -- check the status flags of the current ammo:
        -- BRASSDEFORMED random chance of true
        -- BULLETSEATPOS random chance of true
        -- BULLETDEFORMED random chance of true
        return false
    end,
}
Ammunition.FailToFeed2 = {
    name = "Slam-Fire, Primer Seating",
    description = "The ammo has a poorly seated primer, sticking out slightly too far causing the gun to fire when the bolt is closed",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        -- check the status flags of the current ammo:
        -- PRIMERSEATPOS random chance of true
        return false
    end,
}
Ammunition.FailToExtract1 = {
    name = "Failure-To-Extract, Brass Failure",
    description = "The brass rim on the case has ripped, causing it not to extract from the chamber.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        -- check the status flags of the current ammo:
        -- BRASSWEAK random chance of true
        return false
    end,
}
Ammunition.FailToExtract2 = {
    name = "Case-Head Separation, Brass Failure",
    description = "The neck of the case has ripped, and the head is stuck in the chamber and needs to be extracted with tools.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        -- check the status flags of the current ammo:
        -- BRASSWEAK random chance of true
        return false
    end,
}
Ammunition.FailToExtract3 = {
    name = "Failure-To-Extract, Low Pressure",
    description = "Casing failed to extract due not enough pressure to cycle the bolt.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        -- these should slightly adjust our recoil factor (guns preference vs ammo recoil)
        -- POWDERLOW
        -- PRIMERSEATNEG
        -- BULLETSEATPOS

    end,
}
Ammunition.FailToEject = {
    name = "Failure-To-Eject, Low Pressure",
    description = "Casing failed to eject due not enough pressure to cycle the bolt.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        -- these should slightly adjust our recoil factor (guns preference vs ammo recoil)
        -- POWDERLOW
        -- PRIMERSEATNEG
        -- BULLETSEATPOS
        return false
    end,
}

--[[

    This table lists malfunctions caused by firearms in poor condition.  These should not be confused with
    actual mechanical failure (ie: broken parts), as they may not happen consistently. The firearm might
    function normally, suffer a malfunction, then continue to function normally after without maintenance
    or repair.

]]
Mechanical.FailToFeed1 = {
    name = "Failure-To-Feed, Dirt",
    description = "Excessive dirt causing the gun to fail to chamber rounds.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        -- check dirt threshold
        return false
    end
}
Mechanical.FailToFeed2 = {
    name = "Failure-To-Feed, Worn Recoil Spring",
    description = "The recoil spring is not providing enough tension to properly chamber rounds.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        return false
    end
}
Mechanical.FailToFeed3 = {
    name = "Failure-To-Feed, Worn Chamber Ramp",
    description = "The chamber ramp is worn, causing the gun to fail to chamber rounds.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        return false
    end
}
Mechanical.FailToFeed4 = {
    name = "Failure-To-Feed, Magazine Failure",
    description = "Issues with the magazine preventing the gun from properly chambering rounds.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        return false
    end,
}
Mechanical.FailToFeed5 = {
    name = "Failure-To-Feed, Chamber Obstructed",
    description = "Something in the chamber is preventing ammo from feeding.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        return false
    end,
}
Mechanical.FailToFeed6 = {
    name = "Slam-Fire, Faulty Firing Pin",
    description = "The firing pin is slighty too long, causing the gun to slamfire (also known as Hammer Follow).",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        return false
    end,
}
Mechanical.FailToFire1 = {
    name = "Failure-To-Fire, Dirt",
    description = "Excessive dirt is jamming up the firing pin.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        return false
    end,
}
Mechanical.FailToFire2 = {
    name = "Failure-To-Fire, Faulty Firing Pin Spring",
    description = "The firing pin spring is worn, causing the firing pin to not have enough force.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        return false
    end,
}
Mechanical.FailToFire3 = {
    name = "Failure-To-Fire, Faulty Firing Pin",
    description = "The firing pin is worn, causing it to not fully engage the primer.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        return false
    end,
}
Mechanical.FailToExtract1 = {
    name = "Failure-To-Extract, Dirt",
    description = "Excessive chamber dirt causing casings to become stuck.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        return false
    end,
}
Mechanical.FailToExtract2 = {
    name = "Failure-To-Extract, Worn Extractor Hook",
    description = "The extractor hook is worn out, causing it to fail to extract casings from the chamber.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        return false
    end,
}
Mechanical.FailToExtract3 = {
    name = "Failure-To-Extract, Recoil Spring Issues",
    description = "The recoil spring is providing too much tension preventing the action from cycling properly, causing it to fail to extract.",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        return false
    end,
}
Mechanical.FailToEject1 = {
    name = "Failue-To-Eject, Dirt",
    description = "Excessive dirt is preventing the action from cycling properly, leading to a failure to eject. (also known as Stovepipe)",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        return false
    end,
}
Mechanical.FailToEject2 = {
    name = "Failue-To-Eject, Dirt",
    description = "The recoil spring is providing too much tension preventing the action from cycling properly, leading to a failure to eject. (also known as Stovepipe)",
    onEvent = function(self, firearm_data, game_item, game_player, is_firing)
        return false
    end,
}

--[[    ORGM.MechanicaFailureTable

    This table contains potential mechanical failures (broken or seized parts). These will consistently
    lead to the mechanical malfunctions listed above.

]]

--[[ The crude, old mechanics (see how far we've come?)

    local chance = (weaponItem:getConditionMax() / weaponItem:getCondition()) *2
    if playerObj:HasTrait("Lucky") then
        chance = chance * 0.8
    elseif playerObj:HasTrait("Unlucky") then
        chance = chance * 1.2
    end
    local result = ZombRand(300 - math.ceil(chance)*2)+1
    if result <= chance then
        this.isJammed = true
        weaponItem:getModData().isJammed = true
        return true
    end

]]


return Malfunctions
