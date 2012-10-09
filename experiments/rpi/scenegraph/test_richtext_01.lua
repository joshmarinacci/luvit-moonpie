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

local text = TextNode:new{x=270, y=550, textstring="list", color={0,0,0}}

--scene.add(text)

local view1 = {
    render=function(str,style,x,y)
        --print("plain: rendering = '",text, "' with style = ",style, " at ",x,",",y)
        text.x = x
        text.y = y
        text.textstring = str
        text:draw(scene)
    end
}
local view2 = {
    render=function(str,style,x,y)
        --print("bold:  rendering = '",text, "' with style = ",style, " at ",x,",",y)
        text.x = x
        text.y = y
        text.textstring = str
        text:draw(scene)
    end
}

local seg1 = { style="plain",   text="foo",   view=view1, width=50}
local seg2 = { style="bold",    text="bar",   view=view2, width=50}
local seg3 = { style="plain",   text="baz",   view=view1, width=50}
local seg4 = { style="bold",    text="quxx",  view=view2, width=50}

local line1 = {segs={seg1,seg2,seg3}, height=30}
local line2 = {segs={seg4}, height=30}
local lines = {line1,line2}


function render(lines,scene)
    local y = 0
    for i,line in ipairs(lines) do
        local x = 0
        y = y + line.height
        for j,seg in ipairs(line.segs) do
            seg.view.render(seg.text,seg.style,x,y)
            x = x + seg.width
        end
    end
end


local rt = {
    init = function()
        text:init()
    end,
    draw = function(self,scene)
        render(lines,scene)
        text:draw(scene)
    end,
}

--render(lines)

scene.add(rt)

scene.loop()
