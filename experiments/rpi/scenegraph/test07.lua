--[[

a simple scenegraph.  loops over list of objects to display
three object types:  text, rect filled with color, and image

--]]

local ffi = require("ffi");

package.path = package.path .. ";../?.lua"

local pi = require("moonpiemac")
local util = require("util")


--[[
TextNode = {}
TextNode.x = 100
TextNode.y = 200
TextNode.color = {1.0,1.0,0.0}
TextNode.draw = function()
    print("drawing a text node")
end
--]]




--create a window
scene = require("Scene")
scene.window = pi.createFullscreenWindow()
scene:init()

require ("RectNode")
RectNode.loadShader()

-- set up a scene
local nodes = {}
for i=0,1000,1 do
    local r = RectNode:new{
        x=math.random(100,700),
        y=math.random(50,300),
        width=math.random(25,250),
        height=math.random(25,250),
        color={math.random(),math.random(),math.random()}
    }
    nodes[i] = r
end

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
       nodes[n].x = math.random(100,700)
       nodes[n].y = math.random(100,500)
   end
    
   scene:swap()
end
