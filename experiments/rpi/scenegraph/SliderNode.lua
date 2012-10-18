package.path = package.path .. ";../?.lua"
local pi = require("moonpie")
require("RectNode")
require("TextNode")
local EB = require("eventbus").getShared()

SliderNode = {}
SliderNode.x = 0
SliderNode.y = 0
SliderNode.width = 200
SliderNode.height = 40
SliderNode.text = "--no text--"
SliderNode.pressed = false
SliderNode.value = 0

function SliderNode:new(o) 
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

function SliderNode:contains(p)
    if(p.x >= self.x and p.x <= self.x + self.width) then
        if(p.y >= self.y and p.y <= self.y + self.height) then
            return true
        end
    end
    return false
end

function SliderNode:init()
    self.bg = RectNode:new{x=0,y=0,width=self.width,height=self.height,color={0.6,0.6,0.6}}
    self.bg:init()
    self.thumb = RectNode:new{x=0,y=0,width=10,height=self.height,color={0.1,0.1,0.1}}
    self.thumb:init()
    self.text = TextNode:new{x=10,y=0,color={0,0,0}, text=self.text}
    self.text:init()
    
    EB:on("mousepress",function(e)
        if(self:contains(e)) then
            --self.pressed = true
            --EB:fire("action",{kind="action",target=self})
            self.value = (e.x-self.x) / self.width
            self.thumb.x = self.value * self.width
            --print("value = ", self.value, " x = ", self.thumb.x)
            EB:fire("change",{kind='change', target=self, value=self.value})
        else
        end
    end)
    EB:on("mousemove",function(e)
        if(self:contains(e) and e.left) then
            self.value = (e.x-self.x) / self.width
            self.thumb.x = self.value * self.width
            EB:fire("change",{kind='change', target=self, value=self.value})
        else
        end
    end)
end

function SliderNode:draw(scene)
    self.bg:draw(scene)
    self.thumb:draw(scene)
    self.text:draw(scene)
end


