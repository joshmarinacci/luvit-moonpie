--[[

Test getting the current state of the mouse

]]
local pi = require("moonpie")

window = pi.createFullscreenWindow()

print("my window = ", window.width, window.height)

local mouse = pi.getMouseState()
while true do
    local mouse2 = pi.getMouseState();
    if(
        not (mouse2.x == mouse.x)
        or not(mouse2.y == mouse.y)
        or not(mouse2.buttonCode == mouse.buttonCode)
        ) then
        print("mouse = ", mouse2.x, mouse2.y, " button = ", mouse2.buttonCode)
    end
    mouse = mouse2
end

