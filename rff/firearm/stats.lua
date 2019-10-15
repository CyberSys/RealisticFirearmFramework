local Stats = {}

Stats.calculate = function(firearm_data)
    -- get current ammo design specs and status flags
    -- get firearm design specs
    -- calculate overall weight
    -- calculate bonus from components and attachments (this should be cached. only recalc when the gun is modified) 
    
    -- first calculate ballisitc values.
    Stats.calculateProjectileVelocity(firearm_data)
    Stats.calculateProjectileEnergy(firearm_data)
    Stats.calculateProjectileDamage(firearm_data)
    Stats.calculateProjectilePenetration(firearm_data)
    Stats.calculateEffectiveRange(firearm_data)
    Stats.calculateMaximumRange(firearm_data)

    -- second calculate recoil values
    Stats.calculateMechanicalRecoil(firearm_data)
    Stats.calculatePercivedRecoil(firearm_data)
    Stats.calculateMuzzleRise(firearm_data)
    
    -- third calculate 'speed' values
    Stats.calculateAimingSpeed(firearm_data)
    Stats.calculateReactionSpeed(firearm_data)
    Stats.calculateManuverability(firearm_data)
    
    -- now accuracy values
    Stats.calculateMechanicalAccuracy(firearm_data)
    Stats.calculatePrecivedAccuracy(firearm_data)
    Stats.calculateRateOfFire(firearm_data)
     
    -- finally misc values
    Stats.calculateSoundDB(firearm_data)
end

-- ballistic values
Stats.calculateProjectileVelocity = function(firearm_data)
    -- Barrel and ammo qualities, as well as firearm feed system effect velocity. Combined with bullet mass 
    -- and design features to calculate range, damage and mechanical recoil.
    -- Should have a 'range' argument, to calculate velocity at specified range.
    -- returns a real number (fps/mps)  
end
Stats.calculateProjectileEnergy = function(firearm_data)
    -- Combonation of projectile velocity and mass
    -- returns a real number (ft/lbs)
end
Stats.calculateProjectileDamage = function(firearm_data)
    -- Factors bullet energy and design features (hollowpoint vs ball etc). 
    -- returns a abstract number
end
Stats.calculateProjectilePenetration = function(firearm_data)
    -- Factors bullet energy, mass and design features (hollowpoint vs ball vs AP etc). 
    -- returns a abstract number
end
Stats.calculateMaximumRange = function(firearm_data)
    -- For non-physics based engines, bullet should not travel past this point
    -- Returns a real number (feet/meters)
end
Stats.calculateEffectiveRange = function(firearm_data)
    -- For non-physics based engines, bullet accuracy and damage severely reduced past this point.
    -- Returns a real number (feet/meters)
end

-- recoil values
Stats.calculateMechanicalRecoil = function(firearm_data)
    -- chamber pressure and firearm feed system (auto with gas tubes vs bolt action), and weight of the weapon
    -- note: recoil is the "push back" motion only, not the rise.
    -- returns a abstract number
end
Stats.calculatePercivedRecoil = function(firearm_data)
    -- The 'felt' recoil. Combonation of Mechanical Recoil, components such as recoil pads and grips, and firearm
    -- feed system movement. Backwards motion only.
    -- returns a abstract number
end
Stats.calculateMuzzleRise = function(firearm_data)
    -- Factors such as barrel porting, firearm design (barrel above piviot point etc)
    -- Retturns a abstract number
end

-- speed values
Stats.calculateAimingSpeed = function(firearm_data)
    -- Assuming the gun is pointed in the general direction, how fast can the gun be sighted directly onto target?
    -- Effected by optics and range to target. Iron sights longer to aim at farther targets, while scopes have 
    -- a reverse effect. During followup shots, Muzzle Rise and Recoil effect Aiming Speed (rise has more of a effect)
    -- Returns a abstract number 
end
Stats.calculateReactionSpeed = function(firearm_data)
    -- A measure of how fast this weapon can be trained on target from a neutral position.
    -- Factors weight and weapon length. Generally combined with Aiming Speed
    -- Returns a abstract number.
end
Stats.calculateManuverability = function(firearm_data)
    -- How easy the weapon is to operate while moving or in CQB. Primarly based on Reaction Speed and Aiming Speed
    -- Returns a abstract number.
end
Stats.calculateRateOfFire = function(firearm_data)
    -- Primarly for fullauto weapons.
    -- With singleshot/semi-auto this is more subjective: a combo of recoil, muzzle rise,
    -- aiming speed and player stats like strength. Its also quite possible to bypass RoF in semi-auto by firing before
    -- the muzzle or sights has reset causing a loss of accuracy.
    -- Returns a real number. (rpm)
end

-- accuracy values
Stats.calculateMechanicalAccuracy = function(firearm_data)
    -- Barrel and Bullet qualities. Some firearm feed system qualities. Assumes firing from a Ransom Rest.
    -- Could effectively be group sizes...MoA rating for rifles, but since that doesn't apply to pistol calibers or 
    -- buckshot it needs to be standardized. 
    -- Returns a abstract number 
end
Stats.calculatePrecivedAccuracy = function(firearm_data)
    -- Includes Sight radius, sighting system features and firearm feed system qualities (mechanical movement)
    -- Combined with Mechanical Accuracy.
    -- For followup shots firing too soon (aka full auto) would include recoil and rise factors.
    -- Returns a abstract number
end

-- misc values
Stats.calculateSoundDB = function(firearm_data)
    -- Sound decibel levels. Barrel length, feed system, ammo features, and barrel attachments (suppressors, porting).
    -- Returns a real number.
end

return Stats
