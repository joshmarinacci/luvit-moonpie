jit.off()

package.path = package.path .. ";../?.lua"
local pi = require("moonpie")
local scene = require("Scene")

-- all of the inits
scene.window = pi.createFullscreenWindow()
print('window = ', scene.window)
scene:init()
require ("RectNode")
require ("TextNode")
FT = require("freetype")

--[[
implement the render algorithm before the layout algorithm, then do the editing algorithm.

lines is array of line objects
line is array of segment objects, plus max height the line, plus width of the line
segment has text and view
view is stateless renderer of text
segments are rendered left to right, end to end
lines are rendered top to bottom, end to end
style is simply a string which has meaning to views

demo
--]]

local maxwidth = 300

local plain_font = FT.getFont("default")
local bold_font = FT.getFont("bold")
local text = TextNode:new{x=270, y=550, textstring="list", color={0,0,0}, font=plain_font}
local bold = TextNode:new{x=270, y=550, textstring="list", color={0,1,0}, font=bold_font}

--scene.add(text)


local view1 = {
    render=function(str,style,x,y)
        text.x = x
        text.y = y
        text.textstring = str
        text:draw(scene)
    end,
    measure = function(ch)
        return text.font.metrics[ch].w
    end
}

local view2 = {
    render=function(str,style,x,y)
        bold.x = x
        bold.y = y
        bold.textstring = str
        bold:draw(scene)
    end,
    measure = function(str)
        return text.font.metrics[ch].w
    end
}



function render(lines,scene)
    local y = 0
    for i,line in ipairs(lines) do
        local x = 0
        y = y + line.height
        for j,seg in ipairs(line.segs) do
            seg.view.render(seg.text,seg.style,x,y-seg.height)
            x = x + seg.width
        end
    end
end


function layout(str)
    local lines = {}
    
    local maxlen = 200
    local view = view1
    local s = ""
    local len = 0
    for i=1, #str, 1 do
        local ch = string.sub(str,i,i)
        len = len + view.measure(string.byte(ch,1))
        if len < maxlen then
            s = s .. ch
        else
            local seg = { style="plain", text=s, view=view, width=35, height=30}
            local line = {segs={seg}, height=30}
            table.insert(lines,line)
            s = ch
            len = 0
            print("adding line")
        end
    end
    local seg = { style="plain", text=s, view=view, width=35, height=30}
    local line = {segs={seg}, height=30}
    table.insert(lines,line)
    return lines
end


local rt = {
    lines = nil,
    str = "",
    init = function(self)
        text:init()
        bold:init()
        self.lines = layout(self.str)
    end,
    draw = function(self,scene)
        render(self.lines,scene)
    end,
}

rt.str = "This is a long run of text that we have to wrap into multiple lines each with a segment."

scene.add(rt)

scene.loop()
