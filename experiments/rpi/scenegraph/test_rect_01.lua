jit.off()

package.path = package.path .. ";../?.lua"
local pi = require("moonpie")
local scene = require("Scene")

-- all of the inits
scene.window = pi.createFullscreenWindow()
scene:init()
require ("RectNode")

-- regular rect
local r1 = RectNode:new{ x = 0, y = 0, width=50,height=50,color={1,0,1,}}
scene.add(r1)

-- moved rect in x direction
local r2 = RectNode:new{ x = 100, y = 0, width=50,height=50,color={0,1,1,}}
scene.add(r2)

-- moved rect in y direction
local r3 = RectNode:new{ x = 0, y = 100, width=50,height=50,color={1,1,0,}}
scene.add(r3)


-- rect translated by a group
local r4 = RectNode:new { x=0, y=0, width=50, height=50, color={0,0,1}}
local g1 = GroupNode:new{}
g1.x = 200
g1.y = 100
g1:add(r4);
scene.add(g1);


scene.loop()
