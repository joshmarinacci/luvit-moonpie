local EB = require("eventbus")
FT = require("freetype")
local k = require("keyboard_constants")


local plain_font = FT.loadFont("ssp-reg.ttf","default",20)
local bold_font = FT.loadFont("ssp-bold.ttf","default",20)
local text = TextNode:new{x=270, y=550, textstring="list", color={0,0,0}, font=plain_font}
local bold = TextNode:new{x=270, y=550, textstring="list", color={0,0,0}, font=bold_font}
local view1 = {
    render=function(str,style,x,y,scene)
        text.x = x
        text.y = y
        text.textstring = str
        text:draw(scene)
    end,
    measure = function(ch)
        local m = text.font.metrics[ch]
        return m.advance,m.h
    end
}

local view2 = {
    render=function(str,style,x,y,scene)
        bold.x = x
        bold.y = y
        bold.textstring = str
        bold:draw(scene)
    end,
    measure = function(ch)
        local m = bold.font.metrics[ch]
        return m.advance,m.h
    end
}

RichTextNode = {
    x=0,
    y=0,
    width=300,
    lines=nil,
    cursorIndex=0,
    str="",
    styles={},
}

function calcStyle(rt,i) 
    for j,st in ipairs(rt.styles) do
        if i >= st.start and i < st.start+st.length then
            return st.view
        end
    end
    return view1
end

function layout(rt,str, maxlen)
    local lines = {}
    local view = view1
    local s = ""
    local len = 0
    local width = 0
    local height = 0
    
    local line = {segs={}, height=0, startIndex=1}
     
    for i=1, #str, 1 do
        local ch = string.sub(str,i,i)
        local v = calcStyle(rt,i)
                
        if (v ~= view) then
            local seg = { style="plain", text=s, view=view, width=width, height=height}
            table.insert(line.segs,seg)
            width = 0
            view = v
            s = ""
        end
        
        local w,h = v.measure(string.byte(ch,1))
        if h > height then
            height = h
        end
        len = len + w
        width = width + w
        if len < maxlen then
            s = s .. ch
        else
            local seg = { style="plain", text=s, view=v, width=width, height=height}
            table.insert(line.segs,seg)
            width = w
            if height > line.height then
                line.height = height
            end
            height = 0
            line.endIndex = i
            table.insert(lines,line)
            line = {segs={},height=0,startIndex=i}
            s = ch
            len = 0
        end
    end
    local seg = { style="plain", text=s, view=view, width=width, height=height}
    table.insert(line.segs,seg)
    width = 0
    if height > line.height then
        line.height = height
    end
    height = 0
    line.endIndex = #str
    table.insert(lines,line)
    return lines
end


function RichTextNode:render(lines,scene)
    local leading = 10
    local y = 0
    for i,line in ipairs(lines) do
        local x = 0
        y = y + line.height + leading
        for j,seg in ipairs(line.segs) do
            seg.view.render(seg.text,seg.style,x+self.x,y-seg.height+self.y,scene)
            x = x + seg.width
        end
    end
end


function RichTextNode:init()
    self.bg = RectNode:new{x=self.x, y=self.y, width=self.width, height=self.height, color={1,1,1}}
    self.cursor = RectNode:new{x=0, y=4, width=2, height=30, color={1,0,0}}
    text:init()
    bold:init()
    self.bg:init()
    self.cursor:init()
    self.lines = layout(self,self.str, self.width)
    self.bg.width=self.width
    local leading = 10
    local y = 0
    for i,line in ipairs(self.lines) do
        y = y + line.height + leading
    end
--    self.bg.height=y+leading
    self.bg.height = self.height
    self.bg:update()
    

    EB:on("keypress",function(e) 
        self:keypressHandler(e)
    end)
end


function RichTextNode:draw(scene)
    self.bg:draw(scene)
    self:render(self.lines,scene)
    self.cursor:draw(scene)
end

function RichTextNode:update()
    self.lines = layout(self,self.str,self.width)
    print("cursor index = ",self.cursorIndex)
    local line,col = self.indexToLineColumn(self,self.cursorIndex)
    print("line,col = ",line,col)
    local x,y = self.lineColumnToXY(self,line,col)
    print("x,y = ",x,y)
    self.cursor.x = x+self.x
    self.cursor.y = y+self.y
end
    
function RichTextNode:indexToLineColumn(n)
    for i,line in ipairs(self.lines) do
        if n >= line.startIndex and n < line.endIndex then
            return i,n-line.startIndex
        end
    end
    return 1,1
end
    
function RichTextNode:lineColumnToIndex(li,col)
    local n = 1
    for i,line in ipairs(self.lines) do
        if i == li then
            return n + col
        end
        n = n + line.endIndex
    end
    return 0
end
    
function RichTextNode:lineColumnToXY(l,c)
    -- for each line
    local y = 0
    -- TODO: do a first loop to get to the right line and calc height
    -- then just loop through the right line
    for n1,line in ipairs(self.lines) do
        y = y + line.height
        if n1 == l then 
            local i = 1
            local x = 0
            -- for each seg
            for n2,seg in ipairs(line.segs) do
                -- for each char in the seg
                for n3=1,#seg.text,1 do
                    local ch = string.sub(seg.text,n3,n3)
                    local w,h = seg.view.measure(string.byte(ch,1))
                    x = x + w
                    if i == c then
                        return x,y
                    end
                    i = i + 1
                end
            end
        end
    end
    return 0,0
end

function RichTextNode:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end


function RichTextNode:keypressHandler(e)
    if(e.enter) then
--        EB:fire("action",{source=sf})
--        return
    end
    
    local txt = self.str;
    local n = #txt-1
    
    if(e.backspace) then
        n = self.cursorIndex
        if n < 1 then 
            return 
        end
        local t1 = string.sub(txt,1,n-1)
        local t2 = string.sub(txt,n+1,#txt)
        txt = t1 .. t2
        self.str = txt
        self.cursorIndex = self.cursorIndex - 1
        self:update()
        return
    end
    
    if e.keycode == k.RAW_LEFT_ARROW then
        self.cursorIndex = self.cursorIndex - 1
        self:update()
        --        if e.shift then
        --            sf:selectionLeft(1)
        --        else
        --            sf.selection = nil
        --        end
        return
    end
    
    
    if e.keycode == k.RAW_RIGHT_ARROW then
        self.cursorIndex = self.cursorIndex + 1
        self:update()
        --        if e.shift then
        --            sf:selectionRight(1)
        --        else
        --            sf.selection = nil
        --        end
        return
    end
    
    if e.keycode == k.RAW_DOWN_ARROW then
        local line,col = self:indexToLineColumn(self.cursorIndex)
        line = line + 1
        if line > #rt.lines then
            line = #rt.lines
        end
        local index = self:lineColumnToIndex(line,col)
        rt.cursorIndex = index
        rt:update()
        return
    end
    
    if e.keycode == k.RAW_UP_ARROW then
        local line,col = rt:indexToLineColumn(rt.cursorIndex)
        line = line - 1
        if line < 1 then
            line = 1
        end
        local index = rt:lineColumnToIndex(line,col)
        rt.cursorIndex = index
        rt:update()
        return
    end
    
    --[[
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
    
    --]]
    
    --don't let command keys get beyond here
    if e.command then
        return
    end
    
    if e.printable then
        local n = self.cursorIndex
        local t1 = string.sub(txt,1,n)
        local t2 = string.sub(txt,n+1,#txt)
        txt = t1 .. e.asChar() .. t2
        self.cursorIndex = self.cursorIndex + 1
        self.str = txt
        self:update()
        return
    end
    
end


