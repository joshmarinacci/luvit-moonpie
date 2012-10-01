--[[

a simple scenegraph.  loops over list of objects to display
three object types:  text, rect filled with color, and image

--]]

local ffi = require("ffi");

package.path = package.path .. ";../?.lua"

local pi = require("moonpie")
local util = require("util")




--create a window
scene = require("Scene")
scene.window = pi.createFullscreenWindow()
scene:init()

require ("RectNode")
RectNode.loadShader()
require ("TextNode")
TextNode.loadShader()

-- set up a scene
local nodes = {}

--[[
for i=0,100,1 do
    local r = RectNode:new{
        x=math.random(100,700),
        y=math.random(50,300),
        width=math.random(25,250),
        height=math.random(25,250),
        color={math.random(),math.random(),math.random()}
    }
    nodes[i] = r
end
]]--

--[[
for i=0,200,1 do
    local r = TextNode:new{
        x=math.random(100,700),
        y=math.random(50,300),
        color={math.random(),math.random(),math.random()}
    }
    nodes[i] = r
end
]]

nodes[1] = RectNode:new{x=0,y=95,width=220,height=40,color={1,0,0}}
nodes[2] = TextNode:new{x=5,y=100}

-- do initial setup
for n in ipairs(nodes) do 
    nodes[n]:init()
end

print("going into the loop")
for count=1,60*3,1 do
    --clear the screen
    scene:clear()

   --for each node in the list
   for n in ipairs(nodes) do 
       nodes[n]:draw(scene)
       -- move them around randomly
       --nodes[n].x = math.random(100,700)
       --nodes[n].y = math.random(100,500)
   end
    
   scene:swap()
end
