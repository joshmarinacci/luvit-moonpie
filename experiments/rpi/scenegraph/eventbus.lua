EventBus = {}
EventBus.callbacks = {}
EventBus.timers = {}

local shared = nil

function EventBus:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

function EventBus:getShared()
    return shared
end

function EventBus:on(name,callback)
    if self.callbacks[name] == nil then
        self.callbacks[name] = {}
    end
    table.insert(self.callbacks[name],callback)
    --print("callbacks for ", name, " count = ", #(self.callbacks[name]))
end

function EventBus:fire(name,event)
    if(self.callbacks[name] == nil) then return end
    for i,v in pairs(self.callbacks[name]) do
        v(event)
    end
end

function EventBus:onTimer(period, callback)
    table.insert(self.timers, {
        period=period,
        callback=callback,
    })
end

function EventBus:tick(time)
    for i,v in pairs(self.timers) do
        if(v.lastTime == nil) then
            v.lastTime = time
        end
        jit.off()
        --print("v.lasttime = ", v.lastTime)
        if(time - v.lastTime > v.period) then
            v.lastTime = time
            v.callback()
        end
    end
end


shared = EventBus:new()

return EventBus
