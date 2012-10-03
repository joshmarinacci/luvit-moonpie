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
require("ButtonNode")

-- create a button
local button = ButtonNode:new{
    x = 0,
    y = 0,
    text = "Engage!"
}

-- add it to the scene
scene.add(button)

-- add an event handler
local EB = require("eventbus").getShared()
EB:on("action",function()
    print("an action happened. engaged = ", button.selected)
end)


scene.loop()
