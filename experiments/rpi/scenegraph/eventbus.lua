EventBus = {}
EventBus.callbacks = {}

function EventBus:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
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



return EventBus
