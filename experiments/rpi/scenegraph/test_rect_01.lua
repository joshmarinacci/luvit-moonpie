jit.off()

package.path = package.path .. ";../?.lua"
local pi = require("moonpie")
local scene = require("Scene")

-- all of the inits
scene.window = pi.createFullscreenWindow()
scene:init()

require ("RectNode")
RectNode.loadShader()


-----------
local r = RectNode:new{ x = 0, y = 0, width=100,height=100,color={1,0,1,}}

-- add it to the scene
scene.add(r)


scene.loop()
