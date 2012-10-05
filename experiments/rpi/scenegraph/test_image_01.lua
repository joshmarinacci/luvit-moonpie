jit.off()

package.path = package.path .. ";../?.lua"
local pi = require("moonpie")
local scene = require("Scene")

-- all of the inits
scene.window = pi.createFullscreenWindow()
scene:init()

require ("ImageNode")
require ("RectNode")


local imageNode = ImageNode:new{x=770,y=100,width=200,height=200}
scene.add(imageNode)

local i2 = ImageNode:new{x=100,y=100,width=20,height=20, src="cursor.png"}
scene.add(i2)

scene.loop()
