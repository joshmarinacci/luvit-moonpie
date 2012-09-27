--[[

a simple scenegraph.  loops over list of objects to display
three object types:  text, rect filled with color, and image

--]]

local ffi = require("ffi");

package.path = package.path .. ";../?.lua"

local pi = require("moonpiemac")
local util = require("util")
local string = require("string")
local EB = require("eventbus")

EB = EB:new()
EB:on("foo",function()
    print("foo happens")
end)

EB:fire("foo", {x=0,y=1})

--create a window
scene = require("Scene")
scene.window = pi.createFullscreenWindow()
scene:init()
require ("RectNode")
RectNode.loadShader()
require ("TextNode")
TextNode.loadShader()


--- set up some colors
local white = {1,1,1}
local black = {0,0,0}
local lightGray = {0.7,0.7,0.7}
local darkGray = {0.4,0.4,0.4}
local red = {1.0,0,0}

-- set up a scene
local nodes = {}



local leftbar  = RectNode:new{x=0,   y=0, width=250, height=600, color=lightGray}
local center   = RectNode:new{x=250, y=0, width=500, height=600, color=darkGray}
local rightbar = RectNode:new{x=750, y=0, width=250, height=600, color=lightGray}
table.insert(nodes, leftbar)
table.insert(nodes, rightbar)
table.insert(nodes, center)

--table.insert(nodes, RectNode:new{x=0,y=95,width=220,height=40,color={1,0,0}})
--table.insert(nodes, TextNode:new{x=5,y=100})

local clock = TextNode:new{x=5,y=10,textstring="12:20"}
table.insert(nodes,clock)

local weather = TextNode:new{x=5,y=40, textstring="EUG: 70o, cloudy"}
table.insert(nodes,weather)


table.insert(nodes, RectNode:new{x=10, y=410, width=8, height=30, color=red})
table.insert(nodes, RectNode:new{x=20, y=420, width=8, height=20, color=red})
table.insert(nodes, RectNode:new{x=30, y=400, width=8, height=40, color=red})



require("TextField")


local tf = TextField:new()
table.insert(nodes,tf)

EB:on("action",function(e)
    if(e.source == tf) then
        tf.text.textstring = ""
    end
end)



mouseCallback = function(event)
    --print("I am the mouse ", event.x, " ", event.y)
end

local shiftDown = false

scene.window.keyboardCallback = function(event) 
    --print("I am the keyboard ", event.key, event.state)
    --local txt = commandbarText.textstring
    --printable chars
    if(event.key >= 32 and event.key<=100) then
        if(event.state == 1) then
            
            --A-Z
            if(event.key >= 65 and event.key <= 90) then
                --handle caps vs lowercase
                if(shiftDown) then
                    EB:fire("keytyped",{keycode=event.key+0})
                    --txt = txt .. string.char(event.key+0)
                else
                    EB:fire("keytyped",{keycode=event.key+(97-65)})
                    --txt = txt .. string.char(event.key+(97-65))
                end
            else
                EB:fire("keytyped",{keycode=event.key})
                --txt = txt .. string.char(event.key)
            end
        end
    end
    -- return/enter
    if(event.key == 294 and event.state == 0) then
        EB:fire("keytyped",{keycode=294})
    end
    --backspace
    if(event.key == 295 and event.state == 0) then
        --txt = string.sub(txt,1,#txt-1)
        EB:fire("keytyped",{keycode=295})
    end
    if(event.key == 287 or event.key == 288)then
        if(event.state == 1) then 
            shiftDown=true
        else
            shiftDown = false
        end
    end
end



-- do initial setup
for i,n in ipairs(nodes) do 
    n:init()
end

print("going into the loop")
local oldMouse = pi.getMouseState()

for count=1,60*10,1 do
    scene:clear()
    -- draw all nodes
    for i,n in ipairs(nodes) do 
        n:draw(scene)
    end
    
    scene:swap()
   
    local mouse = pi.getMouseState();
    if(mouse.x ~= oldMouse.x or mouse.y ~= oldMouse.y) then
       mouseCallback(mouse)
    end

    oldMouse = mouse
end
