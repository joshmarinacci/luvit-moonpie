jit.off()

package.path = package.path .. ";../?.lua"
local pi = require("moonpie")
local scene = require("Scene")

-- all of the inits
scene.window = pi.createFullscreenWindow()
print('window = ', scene.window)
scene.init()
require ("RectNode")
RectNode.loadShader()
require ("TextNode")
TextNode.loadShader()
require("SliderNode")

-- create a button
local slider = SliderNode:new{
    x = 0,
    y = 0,
    width=300,
    text = "particle count"
}

-- add it to the scene
scene.add(slider)

-- add an event handler
local EB = require("eventbus").getShared()
EB:on("change",function()
    print("an change event happened = ", slider.value*100)
    slider.text.textstring = "value = "..(slider.value*100)
end)


scene.loop()
