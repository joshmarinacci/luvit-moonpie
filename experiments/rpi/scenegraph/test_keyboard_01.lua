jit.off()
package.path = package.path .. ";../?.lua"

local pi = require("moonpie")
local util = require("util")
local string = require("string")
local EB = require("eventbus").getShared()
local k = require("keyboard_constants")

scene = require("Scene")
scene.window = pi.createFullscreenWindow()
scene:init()
require ("RectNode")
RectNode.loadShader()
require ("TextNode")
TextNode.loadShader()
require("TextField")
local tf = TextField:new()
scene.add(tf)

EB:on("keytyped",function(e)
    print("typed: ",e.keycode,e.asChar())
end)
EB:on("action",function(e)
    print("action: ")
end)


scene.loop()
