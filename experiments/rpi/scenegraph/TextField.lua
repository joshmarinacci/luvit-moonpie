local EB = require("eventbus")

local k = require("keyboard_constants")

TextField = {
    col=0
}
function TextField:init()
    self.bg = RectNode:new{x=260, y=550, width=500-20, height=40, color={1,1,1}}
    self.bg:init()
    self.text = TextNode:new{x=270, y=550, textstring="list", color={0,0,0}}
    self.text:init()
    self.cursor = RectNode:new{x=270,y=554, width=2, height=30, color={1,0,0}}
    self.cursor:init()
    local sf = self;
    
    EB:on("keytyped",function(e)
    end)
    
    EB:on("keyrelease",function(e)
    end)
    
    EB:on("keypress",function(e)
        if(e.enter) then
            EB:fire("action",{source=sf})
            return
        end
        
        local txt = sf.text.textstring;
        
        if(e.backspace) then
            if self.col < 1 then 
                return 
            end
            local t1 = string.sub(txt,1,self.col-1)
            local t2 = string.sub(txt,self.col+1,#txt)
            sf.text.textstring = t1 .. t2
            sf:setColumn(#t1)
            return
        end
        
        if e.keycode == k.RAW_LEFT_ARROW then
            sf:moveColumn(-1)
            return
        end
        if e.keycode == k.RAW_RIGHT_ARROW then
            sf:moveColumn(1)
            return
        end
        
        if e.printable then
            local t1 = string.sub(txt,1,self.col)
            local t2 = string.sub(txt,self.col+1,#txt)
            --print("t1 = ",t1, "  ",t2)
            sf.text.textstring = t1 .. e.asChar() .. t2
            sf:moveColumn(1)
            return
        end
        
        --count the advances for the string
--        sf.cursor.x = 270 + xoff
--        sf.text.textstring = txt
--        sf.col = #txt
        
--        print("column = " , sf.col, ", text length = ",#txt)
    end)
    self:setColumn(#self.text.textstring)
end

function TextField:moveColumn(offset) 
    self.col = self.col + offset
    if self.col > #self.text.textstring then
        self.col = #self.text.textstring
    end
    if self.col < 0 then
        self.col = 1
    end
    self:recalcCursor() 
end

function TextField:setColumn(col)
    self.col = col
    self:recalcCursor()
end

function TextField:recalcCursor()
    local metrics = self.text.getMetrics()
    local xoff = 0
    for i=1, self.col, 1 do
        local n = string.byte(self.text.textstring,i)
        xoff = xoff + metrics[n].advance
    end
    self.cursor.x = 270 + xoff
end

function TextField:draw(scene)
    self.bg:draw(scene)
    self.text:draw(scene)
    self.cursor:draw(scene)
end
function TextField:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

