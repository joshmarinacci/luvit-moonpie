jit.off()

package.path = package.path .. ";../?.lua"
local pi = require("moonpie")
local EB = require("eventbus").getShared()
EB:on("action",function()
    print("an action happened. engaged?")
end)

local scene = require("Scene")
scene.window = pi.createFullscreenWindow()
print('window = ', scene.window)
scene:init()

require ("RectNode")
RectNode.loadShader()
require ("TextNode")
TextNode.loadShader()
require("ButtonNode")

local button = ButtonNode:new{
    x = 0,
    y = 0,
    text = "Engage!"
}

scene:add(button)
scene.loop()
