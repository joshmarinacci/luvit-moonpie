local EB = require("eventbus")

TranslateAnim = {
    startX=0,
    endX=0,
    startY=0,
    endY=0,
    duration=1000,
    delay=0,
    onStart=nil,
    onEnd=nil,
    running=false,
    stime=0,
    ctime=0,
    loop=false,
    reverse=false,
    forward=true,
}
--[[
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
            txt = txt .. string.char(e.keycode)
        end
        if(e.keycode == 295) then
            txt = string.sub(txt,1,#txt-1)
        end
        sf.cursor.x = 270+(#txt)*16
        sf.text.textstring = txt
    end)
    
end
function TextField:draw(scene)
    self.bg:draw(scene)
    self.text:draw(scene)
    self.cursor:draw(scene)
end
]]

function TranslateAnim:start()
    self.running = true
    self.delayed = true;
end

function TranslateAnim:ease(t,b,c,d)
    --linear
    --return c*t/d+b
    
    --quad in
    --t = t/d
    --return c*t*t + b
    
    
    --quad out
    --t = t/d
    --return -c * t * (t-2) + b
    
    
    --quad in/out
    --[[
    t = t/(d/2)
    if(t<1) then
        return c/2*t*t+b
    end
    t = t-1
    return -c/2 * (t *(t-2)-1)+ b
    ]]
    
    --cubic in/out
    t = t/(d/2)
    if t<1 then
        return c/2*t*t*t+b
    end
    t = t-2
    return c/2 * (t*t*t+2) + b
    
    
    
    --return 1-math.pow(1-t,3)
    
    --quad  in
    --return t*t
    
    --quad out
    --return 1-(1-t)*(1-t)
    
    --quad in then out
    --[[
    if (t < 0.5) then
        return t*t*2
    else
        return 1-(1-t)*(1-t)
    end
    ]]
    
end

function TranslateAnim:update(time)
    if(not self.running) then
        return
    end
    
    if(self.stime == 0) then
        self.stime = time + (self.delay/1000)
    end
    
    self.ctime = time
    
    local t = (self.ctime-self.stime)/(self.duration/1000)
    
    
    if t>=0 and self.delayed then
        self.delayed = false
        if self.onStart ~= nil then
            self.onStart()
        end
    end
    
    if t>=0 and t < 1.0 then
        local tt = t
        if (not self.forward) then
            tt = 1-tt
        end
        self.target.x = self:ease(tt,self.startX, (self.endX-self.startX), 1)
        --self.target.x = self.startX + (self.endX-self.startX)*t
    end
    
    if t > 1.0 and self.running then
        if self.onEnd ~= nil then
            self.onEnd()
        end
    end
    
    if t > 1.0 then
        self.running = false
        if(self.loop) then
            self.stime = 0
            self.running = true
            self.delayed = false
            if(self.reverse) then
                self.forward = not self.forward
            end
        end
    end
end


function TranslateAnim:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

