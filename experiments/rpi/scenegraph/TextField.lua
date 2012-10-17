local EB = require("eventbus")

local k = require("keyboard_constants")
local clip = require("Clipboard").getShared()

TextField = {
    col=0,
    selection=nil,
    x=0,
    y=0,
}
function TextField:init()
    self.bg = RectNode:new{x=self.x, y=self.y, width=200, height=30, color={1,1,1}}
    self.bg:init()
    self.text = TextNode:new{x=self.x+5, y=self.y+5, textstring="list", color={0,0,0}}
    self.text:init()
    self.cursor = RectNode:new{x=0,y=0, width=2, height=30, color={1,0,0}}
    self.cursor:init()
    self.selectionNode = RectNode:new{x=0,y=0, width=2, height=30, color={0,1,0}}
    self.selectionNode:init()
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
            if e.shift then
                sf:selectionLeft(1)
            else
                sf.selection = nil
            end
            return
        end
        if e.keycode == k.RAW_RIGHT_ARROW then
            sf:moveColumn(1)
            if e.shift then
                sf:selectionRight(1)
            else
                sf.selection = nil
            end
            return
        end
        
        if e.command and e.keycode == k.RAW_C then
            if sf.selection ~= nil then
                clip:setString(sf:getSelection())
            end
            return
        end
        if e.command and e.keycode == k.RAW_V then
            self:insertText(clip:getString())
            sf.selection = nil
            return
        end
        
        --don't let command keys get beyond here
        if e.command then
            return
        end
        
        if e.printable then
            local t1 = string.sub(txt,1,self.col)
            local t2 = string.sub(txt,self.col+1,#txt)
            sf.text.textstring = t1 .. e.asChar() .. t2
            sf:moveColumn(1)
            return
        end
        
    end)
    self:setColumn(#self.text.textstring)
end

function TextField:insertText(str)
    local txt = self.text.textstring;
    local t1 = string.sub(txt,1,self.col)
    local t2 = string.sub(txt,self.col+1,#txt)
    if self.selection ~= nil then
        t1 = string.sub(txt,1,self.selection.s)
        t2 = string.sub(txt,self.selection.e,#txt)
    end
    txt = t1 .. str .. t2
    self.text.textstring = txt
end

function TextField:getSelection() 
    return string.sub(
        self.text.textstring
        ,self.selection.s
        ,self.selection.e)
end

function TextField:selectionLeft(off)
    if self.selection == nil then
        self.selection = {s=self.col,e=self.col}
    else
        self.selection.s = self.selection.s - 1
    end
    if self.selection.s < 0 then
        self.selection.s = 0
    end
    self:updateSelection()
end

function TextField:selectionRight(off)
    if self.selection == nil then
        self.selection = {s=self.col,e=self.col}
    else
        self.selection.e = self.selection.e + 1
    end
    if self.selection.e > #self.text.textstring then
        self.selection.e = #self.text.textstring
    end
    self:updateSelection()
end

function TextField:updateSelection()
    local x = self:calcWidth(string.sub(self.text.textstring,1,self.selection.s))
    self.selectionNode.x = 270 + x    
    local w = self:calcWidth(string.sub(self.text.textstring,self.selection.s,self.selection.e))
    self.selectionNode.width = w
    self.selectionNode:update()
end

function TextField:calcWidth(str)
    local metrics = self.text.getMetrics()
    local xoff = 0
    for i=1, #str, 1 do
        local n = string.byte(str,i)
        xoff = xoff + metrics[n].advance
    end
    return xoff
end

function TextField:moveColumn(offset) 
    self.col = self.col + offset
    if self.col > #self.text.textstring then
        self.col = #self.text.textstring
    end
    if self.col < 0 then
        self.col = 0
    end
    self:recalcCursor() 
end

function TextField:setColumn(col)
    self.col = col
    self:recalcCursor()
end

function TextField:recalcCursor()
    local metrics = self.text:getMetrics()
    local xoff = 0
    for i=1, self.col, 1 do
        local n = string.byte(self.text.textstring,i)
        xoff = xoff + metrics[n].advance
    end
    self.cursor.x = 270 + xoff
end

function TextField:draw(scene)
    self.bg:draw(scene)
    if self.selection ~= nil then
        self.selectionNode:draw(scene)
    end
    self.text:draw(scene)
    self.cursor:draw(scene)
end

function TextField:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

