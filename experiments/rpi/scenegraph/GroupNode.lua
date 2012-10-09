-- a group of nodes.  x/y translation doesn't work yet

GroupNode = {}
GroupNode.x = 0
GroupNode.y = 0
GroupNode.children = {}

function GroupNode:init()
    for i,v in ipairs(self.children) do
        v:init(scene)        
    end
end

function GroupNode:add(node)
    table.insert(self.children,node)
end

function GroupNode:draw(scene)
    for i,v in ipairs(self.children) do
        v:draw(scene)        
    end
end


function GroupNode:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

