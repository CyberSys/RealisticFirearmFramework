--[[- placeholder player handling functions, to be overwritten by the application or bridge

]]
local Player = {}

Player.getInventory = function(game_player)
    return nil
end

Player.getPosition = function(game_player)
    return nil
end

Player.getFirearm = function(game_player)
    return nil
end

Player.playSound = function(game_player)
    return nil
end

return Player
