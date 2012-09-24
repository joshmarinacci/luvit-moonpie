--[[

Test getting the current state of the mouse

]]
local pi = require("moonpiemac")

window = pi.createFullscreenWindow()

print("my window = ", window.width, window.height)

local mouse = pi.getMouseState()
while true do
    local mouse2 = pi.getMouseState();
    if(
        not (mouse2.x == mouse.x)
        or not(mouse2.y == mouse.y)
        or not(mouse2.leftdown == mouse.leftdown)
        ) then
        print("mouse = ", mouse2.x, mouse2.y, " button = ", mouse2.leftdown)
    end
    window.swap()
    mouse = mouse2
end

