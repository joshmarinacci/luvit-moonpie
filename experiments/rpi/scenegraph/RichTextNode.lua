local EB = require("eventbus")
FT = require("freetype")
local k = require("keyboard_constants")


local plain_font = FT.loadFont("ssp-reg.ttf","default",18)
local bold_font = FT.loadFont("ssp-bold.ttf","default",18)
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
    leading = 10,
    stylemap = {
        text=view1,
        bold=view2
    },
}

function calcStyle(rt,i) 
    for j,st in ipairs(rt.styles) do
        if i >= st.start and i < st.start+st.length then
            return rt.stylemap[st.name]
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
     
    local word = ""
    local i = 1
    while true do
        local ch = string.sub(str,i,i)
        local v = calcStyle(rt,i)
                
        if (v ~= view) then
            local seg = { style="plain", text=s, view=view, width=width, height=height}
            table.insert(line.segs,seg)
            width = 0
            view = v
            s = ""
        end
        
        if(ch == '\n') then
            chopLine(width, height, s, line, i-1, lines, v)
            s = ""
            width = 0
            height = 0
            line = {segs={},height=0,startIndex=i+1}
            len = 0
        else 
            if ch == ' ' then
                word = ""
            else
                word = word .. ch
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
                --back up to end of previous word plus the sapce
                ch = string.sub(s,#s-#word+1,#s-#word+1)
                s = string.sub(s,1,#s-#word)
                i = i - #word -1
                word = ""
                chopLine(width, height, s, line, i, lines, v)
                width = w
                height = 0
                line = {segs={},height=0,startIndex=i+2} -- add extra +1 to skip the space
                s = ""
                i = i + 1
                len = 0
            end
        end
        i = i + 1
        if i > #str then break end
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

function chopLine(width, height, s, line, i, lines, v)
    local seg = { style="plain", text=s, view=v, width=width, height=height}
    table.insert(line.segs,seg)
    if height > line.height then
        line.height = height
    end
    line.endIndex = i
    table.insert(lines,line)
end

function RichTextNode:render(lines,scene)
    local y = 0
    for i,line in ipairs(lines) do
        local x = 0
        y = y + line.height + self.leading
        for j,seg in ipairs(line.segs) do
            seg.view.render(seg.text,seg.style,x+self.x,y-seg.height+self.y,scene)
            x = x + seg.width
        end
    end
end


function RichTextNode:init()
    self.cursorIndex = 1
    self.bg = RectNode:new{x=self.x, y=self.y, width=self.width, height=self.height, color={1.0,1.0,1.0}}
    self.cursor = RectNode:new{x=0, y=4, width=1, height=20, color={1,0,0}}
    text:init()
    bold:init()
    self.bg:init()
    self.cursor:init()
    self.lines = layout(self,self.str, self.width)
    self.bg.width=self.width
    local y = 0
    for i,line in ipairs(self.lines) do
        y = y + line.height + self.leading
    end
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
    if(self.cursorIndex < 1) then
        self.cursorIndex = 1
    end
    if(self.cursorIndex > #self.str) then
        self.cursorIndex = #self.str
    end

    self.lines = layout(self,self.str,self.width)
    local n = self.cursorIndex;
    local txt = self.str
    local line,col = self.indexToLineColumn(self,self.cursorIndex)
    local x,y = self.lineColumnToXY(self,line,col)
    self.cursor.x = x+self.x
    self.cursor.y = y+self.y
    --self:dumpLayout()
end

function RichTextNode:dumpLayout()
    print("--- layout")
    for i,l in ipairs(self.lines) do
        print("   line ",i,l.startIndex,l.endIndex, "-"..string.sub(self.str,l.startIndex,l.endIndex).."-")
        for j,s in ipairs(l.segs) do
            print("      seg ",j,"-"..s.text.."-")
        end
    end
    print("   index = ",self.cursorIndex)
end
    
function RichTextNode:indexToLineColumn(n)
    for i,line in ipairs(self.lines) do
        if n >= line.startIndex and n <= line.endIndex then
            return i,n-line.startIndex
        end
        if n < line.startIndex then
            return i,1
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
        n = line.endIndex
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
                    if i > c then
                        return x,y
                    end
                    i = i + 1
                end
            end
        end
        y = y + self.leading
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
        --adjust style positions
        for i,style in ipairs(self.styles) do
            if(style.start >= n) then
                style.start = style.start - 1
            end
        end
        self:update()
        return
    end
    
    if e.keycode == k.RAW_LEFT_ARROW then
        self.cursorIndex = self.cursorIndex - 1
        if(self.cursorIndex < 1) then
            self.cursorIndex = 1
        end
        local l,c = self:indexToLineColumn(self.cursorIndex)
        -- if we are stuck between lines, move up to end of previous line
        if(self.cursorIndex < self.lines[l].startIndex) then
            l = l -1
            self.cursorIndex = self.lines[l].endIndex
        end
        self:update()
        return
    end
    
    if e.keycode == k.RAW_RIGHT_ARROW then
        self.cursorIndex = self.cursorIndex + 1
        local l,c = self:indexToLineColumn(self.cursorIndex)
        -- if we are stuck between lines, move to the start of current line
        if(self.cursorIndex < self.lines[l].startIndex) then
            self.cursorIndex = self.lines[l].startIndex
        end
        self:update()
        return
    end
    
    if e.keycode == k.RAW_DOWN_ARROW then
        local line,col = self:indexToLineColumn(self.cursorIndex)
        line = line + 1
        if line > #self.lines then
            line = #self.lines
        end
        local index = self:lineColumnToIndex(line,col)
        self.cursorIndex = index
        self:update()
        return
    end
    
    if e.keycode == k.RAW_UP_ARROW then
        local line,col = self:indexToLineColumn(self.cursorIndex)
        line = line - 1
        if line < 1 then
            line = 1
        end
        local index = self:lineColumnToIndex(line,col)
        self.cursorIndex = index
        self:update()
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
        -- adjust style positions
        for i,style in ipairs(self.styles) do
            if(style.start >= n) then
                style.start = style.start + 1
            end
        end
        self.cursorIndex = self.cursorIndex + 1
        self.str = txt
        self:update()
        return
    end
    
end


