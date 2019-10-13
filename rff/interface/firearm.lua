local Firearm = {}

Firearm.getInstance = function(game_item)
    -- this needs to translate a game object to a RFF representation (a lua table).
    -- for testing purproses it returns itself. For PZ this would be game_item:getModData()
    return game_item
end
-- TODO: this needs to handle engines with proper physics. need velocity, bullet mass, energy calculations.
Firearm.setDamage = function(game_item, value)
end

Firearm.setRange = function(game_item, value)
end

Firearm.setAccuracy = function(game_item, value)
end

Firearm.setRecoil = function(game_item, value)
end

Firearm.setWeight = function(game_item, value)
end

Firearm.setReactionTime = function(game_item, value)
end

Firearm.setRateOfFire = function(game_item, value)
end

return Firearm
