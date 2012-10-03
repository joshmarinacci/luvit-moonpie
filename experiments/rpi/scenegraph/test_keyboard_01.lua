jit.off()
package.path = package.path .. ";../?.lua"

local pi = require("moonpie")
local util = require("util")
local string = require("string")
local EB = require("eventbus").getShared()
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

local r = RectNode:new{x=0,y=0,width=10,height=10,color={0,1,0}}
scene.add(r)

EB:on("keytyped",function(e)
    print("typed: ",e.keycode,e.asChar())
end)

scene.loop()
