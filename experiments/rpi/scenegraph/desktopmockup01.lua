--[[

a simple scenegraph.  loops over list of objects to display
three object types:  text, rect filled with color, and image
--]]

local ffi = require("ffi");

package.path = package.path .. ";../?.lua"

local pi = require("moonpiemac")
local util = require("util")
local string = require("string")
local EB = require("eventbus")

EB = EB:new()
EB:on("foo",function()
    print("foo happens")
end)

EB:fire("foo", {x=0,y=1})

--create a window
scene = require("Scene")
scene.window = pi.createFullscreenWindow()
scene:init()
require ("RectNode")
RectNode.loadShader()
require ("TextNode")
TextNode.loadShader()
require ("ImageNode")
ImageNode.loadShader()
require ("ParticleSplashNode")

local nodes = {}
--- set up some colors
local white = {1,1,1}
local black = {0,0,0}
local lightGray = {0.7,0.7,0.7}
local darkGray = {0.4,0.4,0.4}
local red = {1.0,0,0}

-- set up a scene



local leftbar  = RectNode:new{x=0,   y=0, width=250, height=600, color=lightGray}
local center   = RectNode:new{x=250, y=0, width=500, height=600, color=darkGray}
local rightbar = RectNode:new{x=750, y=0, width=250, height=600, color=lightGray}
table.insert(nodes, leftbar)
table.insert(nodes, rightbar)
table.insert(nodes, center)

local clock = TextNode:new{x=5,y=10,textstring="12:20"}
table.insert(nodes,clock)

local weather = TextNode:new{x=5,y=40, textstring="EUG: 70o, cloudy"}
table.insert(nodes,weather)


table.insert(nodes, RectNode:new{x=10, y=410, width=8, height=30, color=red})
table.insert(nodes, RectNode:new{x=20, y=420, width=8, height=20, color=red})
table.insert(nodes, RectNode:new{x=30, y=400, width=8, height=40, color=red})


local animRect = RectNode:new{x=0,y=0,width=20,height=20, color={1,1,0}}
table.insert(nodes, animRect)

local imageNode = ImageNode:new{x=770,y=100,width=200,height=200}
table.insert(nodes, imageNode)

local partNode = ParticleSplashNode:new{}
table.insert(nodes, partNode)

--[[
anim. create anim obj, processed by the rect shader. 
    always has start pos, end pos, and time. if time <= 0 then just start pos.
anim = TranslateAnim:new{target=rect1, startx=300,endx=500,
    starty=100,endy=100,duration=1000,delay=500,onStart=func,onEnd=func})
anim.start()
     changes the translate (x,y) of the shader, modulated by T and an easing.
     doesn't update the rectnode's x,y until the transition is complete. 
     ensures faster speed.
     onstart and onend functions can be called when the 
     transition itself starts (after the delay), and when it ends
--]]

local onstart = function()
    print("anim is starting")
end
local onend = function()
    print("anim is ending")
end

require("TranslateAnim")
local anim = TranslateAnim:new{
    target=animRect,
    startX=0,endX=400,
    startY=0,endY=400,
    duration=800,
--    delay=1000,
--    onStart=onstart,
--    onEnd=onend,
    loop=true,
    reverse=true,
    }

anim:start()

require("TextField")
local tf = TextField:new()
table.insert(nodes,tf)

EB:on("action",function(e)
    if(e.source == tf) then
        tf.text.textstring = ""
    end
end)


EB:onTimer(1, function()
    print("timer happened")
    local time = os.date("*t",os.time())
    print("os.time = ", time.hour, " ",time.min, " ",time.sec)
    clock.textstring = time.hour..":"..time.min..":"..time.sec
end)


mouseCallback = function(event)
    --print("I am the mouse ", event.x, " ", event.y)
end

local shiftDown = false

scene.window.keyboardCallback = function(event) 
    --print("I am the keyboard ", event.key, event.state)
    --local txt = commandbarText.textstring
    --printable chars
    if(event.key >= 32 and event.key<=100) then
        if(event.state == 1) then
            
            --A-Z
            if(event.key >= 65 and event.key <= 90) then
                --handle caps vs lowercase
                if(shiftDown) then
                    EB:fire("keytyped",{keycode=event.key+0})
                    --txt = txt .. string.char(event.key+0)
                else
                    EB:fire("keytyped",{keycode=event.key+(97-65)})
                    --txt = txt .. string.char(event.key+(97-65))
                end
            else
                EB:fire("keytyped",{keycode=event.key})
                --txt = txt .. string.char(event.key)
            end
        end
    end
    -- return/enter
    if(event.key == 294 and event.state == 0) then
        EB:fire("keytyped",{keycode=294})
    end
    --backspace
    if(event.key == 295 and event.state == 0) then
        --txt = string.sub(txt,1,#txt-1)
        EB:fire("keytyped",{keycode=295})
    end
    if(event.key == 287 or event.key == 288)then
        if(event.state == 1) then 
            shiftDown=true
        else
            shiftDown = false
        end
    end
end



-- do initial setup
for i,n in ipairs(nodes) do 
    n:init()
end

print("going into the loop")
local oldMouse = pi.getMouseState()


while true do
    EB:tick(pi.getTime())
    -- update the animations
    anim:update(pi.getTime())

    -- clear the screen
    scene:clear()
    -- draw all nodes
    for i,n in ipairs(nodes) do 
        n:draw(scene)
    end

    scene:swap()
   
    local mouse = pi.getMouseState();
    if(mouse.x ~= oldMouse.x or mouse.y ~= oldMouse.y) then
       mouseCallback(mouse)
    end

    oldMouse = mouse
end
