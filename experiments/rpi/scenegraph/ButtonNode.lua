package.path = package.path .. ";../?.lua"
local pi = require("moonpie")
require("RectNode")
require("TextNode")
local EB = require("eventbus").getShared()

ButtonNode = {}
ButtonNode.x = 0
ButtonNode.y = 0
ButtonNode.text = "--no text--"
ButtonNode.pressed = false
ButtonNode.selected = false

function ButtonNode:new(o) 
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

function ButtonNode:contains(p)
    if(p.x >= self.x and p.x <= self.x + 200) then
        if(p.y >= self.y and p.y <= self.y + 40) then
            return true
        end
    end
    return false
end
function ButtonNode:init()
    self.bg = RectNode:new{x=0,y=0,width=200,height=40,color={0,1,0}}
    self.bg:init()
    self.text = TextNode:new{x=10,y=0,color={0,0,0}, textstring=self.text}
    self.text:init()
    
    EB:on("mousepress",function(e)
        if(self:contains(e)) then
            self.pressed = true
            self.selected = not self.selected
            EB:fire("action",{kind="action",target=self})
        else
        end
    end)
end

function ButtonNode:draw(scene)
    if(self.selected) then
        self.bg.color = {1,0,1}
    else 
        self.bg.color = {0,1,0}
    end
    self.bg:draw(scene)
    self.text:draw(scene)
end
