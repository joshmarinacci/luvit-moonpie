--[[

a simple scenegraph.  loops over list of objects to display
three object types:  text, rect filled with color, and image

--]]

local ffi = require("ffi");

package.path = package.path .. ";../?.lua"

local pi = require("moonpiemac")
local util = require("util")
local string = require("string")
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



local leftbar  = RectNode:new{x=0,   y=0, width=200, height=600, color=lightGray}
local center   = RectNode:new{x=200, y=0, width=600, height=600, color=darkGray}
local rightbar = RectNode:new{x=800, y=0, width=200, height=600, color=lightGray}
table.insert(nodes, leftbar)
table.insert(nodes, rightbar)
table.insert(nodes, center)

--table.insert(nodes, RectNode:new{x=0,y=95,width=220,height=40,color={1,0,0}})
--table.insert(nodes, TextNode:new{x=5,y=100})

local clock = TextNode:new{x=5,y=30,textstring="12:20"}
table.insert(nodes,clock)

local weather = TextNode:new{x=5,y=60, textstring="EUG: 70o, cloudy"}
table.insert(nodes,weather)


table.insert(nodes, RectNode:new{x=10, y=410, width=8, height=30, color=red})
table.insert(nodes, RectNode:new{x=20, y=420, width=8, height=20, color=red})
table.insert(nodes, RectNode:new{x=30, y=400, width=8, height=40, color=red})



local commandbarBG = RectNode:new{x=210, y=530, width=600-20, height=40, color=white}
local commandbarText = TextNode:new{x=220, y=540, textstring="list programs"}
table.insert(nodes,commandbarBG)
table.insert(nodes,commandbarText)

mouseCallback = function(event)
    print("I am the mouse ", event.x, " ", event.y)
end

scene.window.keyboardCallback = function(event) 
    print("I am the keyboard ", event.key, event.state)
    local txt = commandbarText.textstring
    --letters
    if(event.key >= 32 and event.key<=100) then
        if(event.state == 0) then
            txt = txt .. string.char(event.key)
        end
    end
    --backspaces
    if(event.key == 295 and event.state == 0) then
        txt = string.sub(txt,1,#txt-1)
    end
    commandbarText.textstring = txt
end



-- do initial setup
for i,n in ipairs(nodes) do 
    n:init()
end

print("going into the loop")
local oldMouse = pi.getMouseState()

for count=1,60*10,1 do
    --clear the screen
    scene:clear()

   --for each node in the list
   for i,n in ipairs(nodes) do 
       n:draw(scene)
       -- move them around randomly
       --n.x = math.random(100,700)
       --n.y = math.random(100,500)
   end
    
   scene:swap()
   
   local mouse = pi.getMouseState();
   if(mouse.x ~= oldMouse.x or mouse.y ~= oldMouse.y) then
       mouseCallback(mouse)
   end

   oldMouse = mouse
end
