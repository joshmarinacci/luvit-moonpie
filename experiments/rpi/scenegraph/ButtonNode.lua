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
ButtonNode.selectable = true
ButtonNode.enabled = true

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
    self._bg = RectNode:new{x=self.x,y=self.y,width=200,height=40,color={0,1,0}}
    self._bg:init()
    self._text = TextNode:new{x=10+self.x,y=self.y,color={0,0,0}, text=self.text}
    self._text:init()
    
    EB:on("mousepress",function(e)
        if not self.enabled then return end
        local p = {x=e.x,y=e.y}
        if(self.parent ~= nil) then
            p.x = p.x - self.parent.x
            p.y = p.y - self.parent.y
        end
        
        if(self:contains(p)) then
            self.pressed = true
            self.selected = not self.selected
            EB:fire("action",{kind="action",target=self})
        end
    end)
    
    local w,h = self._text.font:measure(self.text)
    
    self._bg.width = w+10*2
    self._bg.height = h+5*2
    self._text.y = self.y -5/2
    self._bg:update()
end
function ButtonNode:update()
    local w,h = self._text.font:measure(self.text)
    
    self._bg.width = w+10*2
    self._bg.height = h+5*2
    self._text.y = self.y -5/2
    
    self._bg.x = self.x
    self._bg.y = self.y
    self._bg:update()
    self._text.x = 10+self.x
    self._text.text = self.text
end

function ButtonNode:draw(scene)
    if(self.selected and self.selectable) then
        self._bg.color = {1,0,1}
    else 
        self._bg.color = {0,1,0}
    end
    if not self.enabled then
        self._bg.color = {0.6,0.9,0.6}
    end
    self._bg:draw(scene)
    self._text:draw(scene)
end
