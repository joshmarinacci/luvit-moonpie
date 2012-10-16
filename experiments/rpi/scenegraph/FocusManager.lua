FocusManager = {}
FocusManager.focusedNode = nil

local shared = nil

function FocusManager:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

function FocusManager:getShared()
    return shared
end

function FocusManager:setFocusedNode(node)
    self.focusedNode = node
end

function FocusManager:isFocused(node)
    return (self.focusedNode == node)
end

shared = FocusManager:new()

return FocusManager
