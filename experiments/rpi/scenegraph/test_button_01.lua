jit.off()

package.path = package.path .. ";../?.lua"
local pi = require("moonpie")
local scene = require("Scene")

-- all of the inits
scene.window = pi.createFullscreenWindow()
print('window = ', scene.window)
scene:init()
require ("RectNode")
require ("TextNode")
require("ButtonNode")

-- create regular button
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



-- button translated inside of a group
local g = GroupNode:new{x=100,y=100}
g:add(ButtonNode:new{text="Activate"})
scene.add(g)
-- button that is disabled

scene.add(ButtonNode:new{text="disabled",x=10,y=200, enabled=false})
-- button that doesn't support selected state
scene.add(ButtonNode:new{text="no select",x=10,y=300, selectable=false})



scene.loop()
