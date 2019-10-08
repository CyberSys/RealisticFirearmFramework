--[[- placeholder container handling functions, to be overwritten by the application or bridge

]]
local Container = {}


Container.find = function(container, item) 
    return nil -- equiv to pz's container:FindAndReturn(itemType)
end
Container.count = function(container, item)
    return nil 
end
Container.add = function(container, item, count) 
    return nil
end
Container.remove = function(container, item, count)
    return nil
end

return Container
