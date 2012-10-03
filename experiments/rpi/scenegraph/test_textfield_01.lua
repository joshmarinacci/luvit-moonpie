jit.off()

package.path = package.path .. ";../?.lua"
local pi = require("moonpie")
local scene = require("Scene")

-- all of the inits
scene.window = pi.createFullscreenWindow()
print('window = ', scene.window)
scene:init()
require ("RectNode")
RectNode.loadShader()
require ("TextNode")
TextNode.loadShader()
require("TextField")

-- create a button
local button = TextField:new{
    x = 0,
    y = 0,
    text = "Engage!"
}

-- add it to the scene
scene:add(button)


scene.loop()
