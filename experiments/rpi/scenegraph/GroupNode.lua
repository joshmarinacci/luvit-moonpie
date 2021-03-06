-- a group of nodes.  x/y translation doesn't work yet

GroupNode = {}
GroupNode.x = 0
GroupNode.y = 0
GroupNode.visible = true
GroupNode.children = {}

function GroupNode:init()
    for i,v in ipairs(self.children) do
        v:init(scene)        
    end
end

function GroupNode:add(node)
    table.insert(self.children,node)
    node.parent = self
end

function GroupNode:draw(scene)
    if(not self.visible) then return end
    scene.pushMatrix();
    scene.translate(self.x,self.y);
    for i,v in ipairs(self.children) do
        v:draw(scene)        
    end
    scene.popMatrix();
end


function GroupNode:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    o.children = {}
    return o
end

