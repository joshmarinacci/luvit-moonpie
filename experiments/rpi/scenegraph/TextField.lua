local EB = require("eventbus")



TextField = {}
function TextField:init()
    self.bg = RectNode:new{x=260, y=550, width=500-20, height=40, color={1,1,1}}
    self.bg:init()
    self.text = TextNode:new{x=270, y=550, textstring="list"}
    self.text:init()
    self.cursor = RectNode:new{x=400,y=554, width=2, height=30, color={1,0,0}}
    self.cursor:init()
    local sf = self;
    EB:on("keytyped",function(e)
        if(e.keycode == 294) then
            EB:fire("action",{source=sf})
            return
        end
    
        local txt = sf.text.textstring;
        if(e.keycode >= 32 and e.keycode <= 126) then
            print("typed a ", string.char(e.keycode))
            txt = txt .. string.char(e.keycode)
        end
        if(e.keycode == 295) then
            txt = string.sub(txt,1,#txt-1)
        end
        --count the advances for the string
        local metrics = self.text.getMetrics()
        local xoff = 0
        for i=1, #txt, 1 do
            local n = string.byte(txt,i)
            xoff = xoff + metrics[n].advance
        end
        sf.cursor.x = 270 + xoff
        sf.text.textstring = txt
    end)
    
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

