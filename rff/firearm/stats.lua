--[[ Module for calculating firearm stats values.

Takes physical properties of the firearm such as weight, barrel length, feed system, current ammo etc and creates stats
such as range, damage, recoil, sound levels based on these properties. 

This system is intented to reflect real world properites and values, but is not a exact copy. Algorithms and concepts
have been simplified.  

]]
local Stats = {}
local Ammo = require(ENV_RFF_PATH .. "ammo/init")
local Instance = require(ENV_RFF_PATH .. "firearm/instance")
local Util = require(ENV_RFF_PATH .. "util")
-- local functions

--[[ Gets the balistics curve value for the specified barrel length. 

The ballistics curve is a cheap hack to increase/decrease values like projectile velocity
based on barrel length with diminishing returns. 

Curve point length is a completely abritrary  value, 30 for pistol calibers, 80 rifles, 60 shotguns 
seems to be a close match to most caliber velocity and energy curves.
The returned float can be used as a multiplier for stats based on barrel length. The closer the 2 inputs the higher 
the returned value is. The shorter the barrel length becomes, the more extreme the effect becomes (lower return value)  

@tparam float curve_length the 'ideal' length to produce maximum results (100% powder burn)
@tparam float barrel_length the length of the barrel
@tretun float a number between 0 to 1 

]]
local calculateBallisticsCurve = function(curve_length, barrel_length)
    return ((((curve_length - barrel_length) / curve_length)^3)^2)
end

--[[ Reverse of `calculateBallisticsCurve()`.

reverse calculation, get the curve point length from the curve value

@tparam float curve_value the value returned by `calculateBallisticsCurve()`
@tparam float barrel_length the length of the barrel
@treturn float the `curve_length` value passed into `calculateBallisticsCurve()`

]]
local calculateBallisticsCurvePoint = function(curve_value, barrel_length)
    -- reverse function.
    return barrel_length / (1 - ((curve_value ^ 0.5) ^ 0.333333333333) )
end

--[[ Normalizes a value between min and max.

@tparam float value
@tparam float min the minimum that value could be
@tparam float max the maximum that value could be
@treturn float the normalized result between 0.0 to 1.0

]]
local normalize = function(value, min, max)
    return (value - min) / (max - min)
end

--[[ Returns a denormalized value between min and max

@tparam float value between 0 to 1.0
@tparam float min the minimum that value could be
@tparam float max the maximum that value could be
@treturn float the result between min and max

]]
local denormalize = function(value, min, max)
    return (max-min) * value + min
end


--[[- Recalculate the firearm's stats.

@tparam table firearm_data 

]]
Stats.calculate = function(firearm_data)
    -- get current ammo design specs and status flags
    local ammo_id = Instance.getSetAmmo(firearm_data)
    local ammo_design = Ammo.get(ammo_id)
    local curve_length = ammo_design.curve_length -- 30 pistols, 80 rifles, 60 shotguns etc
    
    -- note: this really needs to add a few extra inches to both or subnoses go screwy. 
    local curve_point = calculateBallisticsCurve(curve_length, Instance.getBarrelLength(firearm_data))
    -- get firearm design specs
    -- calculate overall weight
    -- calculate bonus from components and attachments (this should be cached. only recalc when the gun is modified) 
    
    -- first calculate ballisitc values.
    local stats = firearm_data.stats
    
    stats.projectile_velocity = Stats.calculateProjectileVelocity(firearm_data, ammo_design)
    stats.projectile_energy = Stats.calculateProjectileEnergy(firearm_data, ammo_design)
    stats.projectile_damage = Stats.calculateProjectileDamage(firearm_data, ammo_design)
    stats.projectile_penetration = Stats.calculateProjectilePenetration(firearm_data, ammo_design)
    stats.range_effective = Stats.calculateEffectiveRange(firearm_data, ammo_design)
    stats.range_maximum = Stats.calculateMaximumRange(firearm_data, ammo_design)

    -- second calculate recoil values
    stats.recoil_mechanical = Stats.calculateMechanicalRecoil(firearm_data)
    stats.recoil_percived = Stats.calculatePerceivedRecoil(firearm_data)
    stats.recoil_muzzle_rise = Stats.calculateMuzzleRise(firearm_data)
    
    -- third calculate 'speed' values
    stats.speed_sight = Stats.calculateSightSpeed(firearm_data)
    stats.speed_reaction = Stats.calculateReactionSpeed(firearm_data)
    stats.speed_transition = Stats.calculateTranistionSpeed(firearm_data)
    --Stats.calculateRateOfFire(firearm_data)
    
    -- now accuracy values
    stats.accuracy_mechanical = Stats.calculateMechanicalAccuracy(firearm_data)
    stats.accuracy_percived = Stats.calculatePerceivedAccuracy(firearm_data)
     
    -- finally misc values
    stats.sound_db_level = Stats.calculateSoundDB(firearm_data)
end


-- --------------------------------------------------------------
--- Ballistic Values
-- @section ballistics


-- --------------
-- Projectile Velocity

--[[- Calculates the projectile velocity at muzzle.

Factors such barrel and ammo qualities, as well as firearm feed system effect velocity. 
Combined with bullet mass and design features to calculate range, damage and mechanical recoil.

@tparam table firearm_data
@treturn float feet-per-second (meters-per-second?)

]]
Stats.calculateProjectileVelocity = function(firearm_data, ammo_design)
    -- get ammo powder type and charge levels.
    -- check bullet powder consistancy levels
    -- get barrel leade, and check bullet seating (too much leade, low pressure & velocity, too little = extreme pressure and higher velocity) 
        -- (might have to skip this one, it will constantly trigger full stat changes)
    -- calc velocity at max curve length 
    -- get barrel length and adjust by feed system, barrel features (chrome lined, dirt levels, condition) 
    -- calc curve point
    -- calc new velocity
    return 0
end

Stats.getProjectileVelocity = function(firearm_data)
    return firearm_data.stats.projectile_velocity
end
Stats.setProjectileVelocity = function(firearm_data, value)
    firearm_data.stats.projectile_velocity = value
end


-- --------------
-- Projectile Energy

--[[- Calculates the projectile energy at muzzle in ft/lbs.

Calculates energy based on velocity and mass.

@tparam table firearm_data
@treturn float energy in ft/lbs.

]]
Stats.calculateProjectileEnergy = function(firearm_data, ammo_design)
    -- energy (ft/lbs) = bullet mass (grains) * (velocity^2) / 450437
    return ammo_design.bullet_mass * (firearm_data.stats.projectile_velocity ^ 2) / 450437
end

Stats.getProjectileEnergy = function(firearm_data)
    return firearm_data.stats.projectile_energy
end

Stats.setProjectileEnergy = function(firearm_data, value)
    firearm_data.stats.projectile_energy = value
end


-- --------------
-- Projectile Damage (HITS) 

--[[- Calculates the raw damage (or HITS value), at muzzle.

Uses the HITS (Hornady Index of Terminal Standards) as base damage, modified by 
additional bullet design features.

@tparam table firearm_data
@treturn float damage in HITS rating.

]]
Stats.calculateProjectileDamage = function(firearm_data, ammo_design)
    -- hits = (weight in grains ^ 2) * velocity / (diameter in inches ^ 2) / 700000
    local damage = (ammo_design.bullet_mass ^ 2) * firearm_data.stats.projectile_velocity / (ammo_design.diameter ^ 2) / 700000
    -- adjust here by design features.
    return damage
end

Stats.getProjectileDamage = function(firearm_data)
    return firearm_data.stats.projectile_damage
end
Stats.setProjectileDamage = function(firearm_data, value)
    firearm_data.stats.projectile_damage = value
end


-- --------------
-- Projectile Penetration

--[[- Calculates penetration values, as a function of bullet Sectional Density.

Uses SI (sectional density) as base value, adjusted by projectile velocity and design features.

@tparam table firearm_data
@treturn float result in abstracted SI value.

]]
Stats.calculateProjectilePenetration = function(firearm_data, ammo_design)
    -- SI = (grains / 7000) / (diameter ^ 2)
    local si = (ammo_design.bullet_mass / 7000) / (ammo_design.diameter ^ 2)
    -- adjust here for velocity and features
    return si
end
Stats.getProjectilePenetration = function(firearm_data)
    return firearm_data.stats.projectile_penetration
end
Stats.setProjectilePenetration = function(firearm_data, value)
    firearm_data.stats.projectile_penetration = value
end


-- --------------
-- Maximum Range

--[[- Calculates maximum range.

Primarily for non-physics engines. Bullet should not travel past this point

@tparam table firearm_data
@treturn float result in feet (meters?).

]]
Stats.calculateMaximumRange = function(firearm_data)
    return 0
end
Stats.getMaximumRange = function(firearm_data)
    return firearm_data.stats.range_maximum
end
Stats.setMaximumRange = function(firearm_data, value)
    firearm_data.stats.range_maximum = value
end


-- --------------
-- Effective Maximum Range

--[[- Calculates effective maximum range.

Primarily for non-physics engines. Bullet accuracy and damage severely reduced past this point.

@tparam table firearm_data
@treturn float result in feet (meters?).

]]
Stats.calculateEffectiveRange = function(firearm_data)
    return 0
end
Stats.getEffectiveRange = function(firearm_data)
    return firearm_data.stats.range_effective
end
Stats.setEffectiveRange = function(firearm_data, value)
    firearm_data.stats.range_effective = value
end



-- --------------------------------------------------------------
--- Recoil Values
-- @section Recoil

-- --------------
-- Mechanical Recoil

--[[- Calculates the mechanical recoil energy of a firearm in ft/lbs.

Factors in chamber pressure, feed system (auto with gas tubes vs bolt action) and weight of the weapon
to produce the mechanical recoil "push back" motion (not muzzle rise)  

@tparam table firearm_data
@treturn float recoil energy in ft/lbs.

]]
Stats.calculateMechanicalRecoil = function(firearm_data)
    --[[
        might be useful:
        free recoil calcuation.
        https://en.wikipedia.org/wiki/Free_recoil

        mgu is the weight of the small arm expressed in kilograms (kg).
        mp is the weight of the projectile expressed in grams (g).
        mc is the weight of the powder charge expressed in grams (g).
        vp is the velocity of the projectile expressed in meters per second (m/s).
        vc is the velocity of the powder charge expressed in meters per second (m/s).

        function freerecoil(mgu, mp, mc, vp, vc)
            return 0.5 * ((((mp*vp)+(mc*vc)) / 1000 )^2) /mgu
        end

        Free recoil has its drawbacks for our use. It doesn't factor recoil from escaping gas 
        (shorter barrel = lower velocity = lower recoil)
        
    ]]
    return 0
end
Stats.getMechanicalRecoil = function(firearm_data)
    return firearm_data.stats.recoil_mechanical
end
Stats.setMechanicalRecoil = function(firearm_data, value)
    firearm_data.stats.recoil_mechanical = value
end


-- --------------
-- Perceived Recoil

--[[- Calculates the 'felt' recoil in ft/lbs.

Includes mechanical recoil, and components such as recoil pads and grips, as well as additional firearm features.

@tparam table firearm_data
@treturn float recoil energy in ft/lbs.

]]
Stats.calculatePerceivedRecoil = function(firearm_data)
    return 0
end
Stats.getPercivedRecoil = function(firearm_data)
    return firearm_data.stats.recoil_percived
end
Stats.setPercivedRecoil = function(firearm_data, value)
    firearm_data.stats.recoil_percived = value
end


-- --------------
-- Muzzle Rise

--[[- Calculates the muzzle rise in degrees centered on the grip (pivot point). 

Includes components and features such as barrel porting, barrels (force centers) higher then the pivot point,
and high centered pistons

@tparam table firearm_data
@treturn float recoil energy in degrees.

]]
Stats.calculateMuzzleRise = function(firearm_data)
    return 0
end
Stats.getMuzzleRise = function(firearm_data)
    return firearm_data.stats.recoil_muzzle_rise
end
Stats.getMuzzleRise = function(firearm_data, value)
    firearm_data.stats.recoil_muzzle_rise = value
end


-- --------------------------------------------------------------
--- Speed Values
-- @section Speed


-- --------------
-- Sight Speed

--[[- Calculates the sighting speed of the weapon.

Highly dependent on optics, character skill (or in FPS games, player skill), and range to target.  
Iron sights longer to aim at farther targets, while scopes have a reverse effect (to a point).
for example with iron sights vs a high power scope:

* 20m = iron (extremely fast), scope (extremely slow, way too close)

* 100m = iron (normal), scope (slow, still too close)

* 500m = iron (very slow), scope (fast)

* 1000m = iron (next year), scope (slow)

During followup shots, Muzzle Rise and Recoil have a large effect on time. 

]]
Stats.calculateSightSpeed = function(firearm_data)
end


-- --------------
-- Reaction Speed

--[[- Calculates the reaction speed of a weapon in seconds.

A measure of how fast this weapon can be trained on target from a neutral position.
Factors weight and weapon length. Generally combined with Sight Speed

calc reaction time 0.2 to 0.3s "Unit of Human Reaction” (UHR). This should be a function of the player obj.
calc motion time = 0.4 to 1.1s average for a lightweight pistol depending on training and reflex, assume gun is in hand already
motion time needs to be modified by weight and length, and firing stance (hip shots vs proper stances) 

]]
Stats.calculateReactionSpeed = function(firearm_data)
    return 0
end
Stats.getReactionSpeed = function(firearm_data)
    return firearm_data.stats.speed_reaction
end
Stats.setReactionSpeed = function(firearm_data, value)
    firearm_data.stats.speed_reaction = value
end


-- --------------
-- Transition Speed

--[[ Calculates the transition speed of a weapon in seconds.

Assuming the gun is in firing postiion, how fast can can it be transitioned to targets?
How easy the weapon is to operate while moving or in CQB. Primarly based on Reaction Speed.

]]
Stats.calculateTranistionSpeed = function(firearm_data)
    return 0
end
Stats.getTranistionSpeed = function(firearm_data)
    return firearm_data.stats.speed_transition
end
Stats.setTranistionSpeed = function(firearm_data, value)
    firearm_data.stats.speed_transition = value
end

-- --------------
--[[
Stats.calculateRateOfFire = function(firearm_data)
    -- Primarly for fullauto weapons.
    -- With singleshot/semi-auto this is more subjective: a combo of recoil, muzzle rise,
    -- aiming speed and player stats like strength. Its also quite possible to bypass RoF in semi-auto by firing before
    -- the muzzle or sights has reset causing a loss of accuracy.
    -- Returns a real number. (rpm)
end
Stats.getRateOfFire = function(firearm_data)
    return firearm_data.stats.speed_rate_of_fire
end
Stats.setRateOfFire = function(firearm_data, value)
    firearm_data.stats.speed_rate_of_fire = value
end
]]



-- --------------------------------------------------------------
--- Accuracy Values
-- @section Accuracy

-- --------------
-- Mechanical Accuracy

--[[- Calculates the mechanical accuracy of the firearm and returns a 'MoA' rating.

Barrel and bullet qualities as well as some firearm feed system qualities. 
Assumes firing from a Ransom Rest, removing the actual shooter from the equation.

Note different types of firearms use different test range standards for calculating mechanical accuracy
100 yards for rifles
25 yards for pistols

]]
Stats.calculateMechanicalAccuracy = function(firearm_data)
    return 0
end
Stats.getMechanicalAccuracy = function(firearm_data)
    return firearm_data.stats.accuracy_mechanical
end
Stats.setMechanicalAccuracy = function(firearm_data, value)
    firearm_data.stats.accuracy_mechanical = value
end


-- --------------
-- Perceived Accuracy

--[[- Calculates the perceived accuracy of a firearm, as a modifier to the mechanical accuracy

Includes Sight radius, sighting system features, firearm feed system qualities, additional mechanical movement such as 
trigger jerk.

For followup shots firing too soon (aka full auto) would include recoil and rise factors.

]]
Stats.calculatePerceivedAccuracy = function(firearm_data)
    return 0
end
Stats.getPerceivedAccuracy = function(firearm_data)
    return firearm_data.stats.accuracy_percived
end
Stats.setPerceivedAccuracy = function(firearm_data, value)
    firearm_data.stats.accuracy_percived = value
end



-- --------------------------------------------------------------
--- Misc Values

-- --------------
-- Sound dB levels

--[[- Calculates the sound levels as decibels.

Barrel length, feed system, ammo features, and barrel attachments (suppressors, porting) have a effect.
Since volume levels are highly subjective dependent on position of the listener relative to barrel. 

Assmume 1m to front and side.

Notes:

most sources favor:
130dB - 140db .22LR rifles, 150+ .22LR pistols
pistol and mid length rifles calibers mostly rate 155dB - 160dB
shotguns rate generally 150db - 160db (18" - 28"), .410s and 20gu dont drop as much with shorter barrels

This page https://www.ammunitiontogo.com/lodge/silencer-guide-with-decibel-level-testing/ seems to show much higher
results then most (testing differences?)

+3db is a noticeable difference, +10db is double volume

suppressors reduce noise from the blast 25db - 40db

sonic crack varies from 140db - 150db (even for .22LR)
sound barrier depends on temperature. (331.3+0.606 * temp in C) = meters per sec  

sound loses 6db per doubling of distance. assume returned value is 1m from barrel, so 2m = -6, 4 = -12, 8m =-18.
-- db = db + 20*math.log10(distance1, distance2)

-- https://en.wikipedia.org/wiki/Sound_pressure

]]
Stats.calculateSoundDB = function(firearm_data)
    return 0
end
Stats.getSoundDBLevel = function(firearm_data)
    return firearm_data.stats.sound_db_level
end
Stats.setSoundDBLevel = function(firearm_data, value)
    firearm_data.stats.sound_db_level = value
end



return Stats
