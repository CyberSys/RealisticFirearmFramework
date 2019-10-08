--[[- placeholder player handling functions, to be overwritten by the application or bridge

]]
local Player = {}
Player.getInventory = function(player)
    return nil
end
Player.getPosition = function(player)
    return nil
end
Player.getFirearm = function(player)
    return nil
end

return Player
