local Clipboard = {
    string = ""
}

local shared = nil

function Clipboard:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

function Clipboard:getShared()
    return shared
end

shared = Clipboard:new()


function Clipboard:setString(str)
    self.string = str
    print("copied the string ", self.string)
end
function Clipboard:getString(str)
    print("pasting the string", self.string)
    return self.string
end

return Clipboard
