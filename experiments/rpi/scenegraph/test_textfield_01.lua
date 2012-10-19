jit.off()

package.path = package.path .. ";../?.lua"
local pi = require("moonpie")
local scene = require("Scene")

-- all of the inits
scene.window = pi.createFullscreenWindow()
print('window = ', scene.window)
scene.init()
require ("RectNode")
require ("TextNode")
require("TextField")

-- create a textfield
local tf1 = TextField:new{  x = 0,  y = 0,  text = "Engage!" }
-- add it to the scene
scene.add(tf1)


local g = GroupNode:new{x=100,y=100}
local tf2 = TextField:new {x=0,y=0,text="Activate!"}
g:add(tf2)
scene.add(g)


local tf3 = TextField:new{  x = 0,  y = 200,  text = "Engage!", enabled=false }
scene.add(tf3)

scene.loop()
