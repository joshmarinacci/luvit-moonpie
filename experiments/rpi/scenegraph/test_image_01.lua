jit.off()

package.path = package.path .. ";../?.lua"
local pi = require("moonpie")
local scene = require("Scene")

-- all of the inits
scene.window = pi.createFullscreenWindow()
print('window = ', scene.window)
scene:init()
require ("ImageNode")
ImageNode.loadShader()
require ("RectNode")
RectNode.loadShader()


local imageNode = ImageNode:new{x=770,y=100,width=200,height=200}
scene.add(imageNode)


scene.loop()
