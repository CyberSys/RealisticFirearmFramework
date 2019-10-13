--[[- placeholder container handling functions, to be overwritten by the application or bridge

]]
local Container = {}


Container.find = function(container, item_id)
    -- PZ version: 
    -- return container:FindAndReturn(item_id)
    return nil
end
Container.count = function(container, item_id)
    return nil 
end
Container.add = function(container, item, count) 
    return nil
end
Container.remove = function(container, item, count)
    return nil
end

return Container
