--[[

a simple scenegraph.  loops over list of objects to display
three object types:  text, rect filled with color, and image
--]]

jit.off(true,true)
package.path = package.path .. ";../?.lua"
local pi = require("moonpie")
local scene = require("Scene")
local EB = require('eventbus').getShared()
scene.window = pi.createFullscreenWindow()
scene:init()

require ("RectNode")
RectNode.loadShader()
require ("TextNode")
TextNode.loadShader()
require ("ImageNode")
ImageNode.loadShader()
require ("ParticleSplashNode")

--- set up some colors
local white = {1,1,1}
local black = {0,0,0}
local lightGray = {0.7,0.7,0.7}
local darkGray = {0.4,0.4,0.4}
local red = {1.0,0,0}

-- set up a scene
scene.add(RectNode:new{x=0,   y=0, width=250, height=600, color=lightGray})
scene.add(RectNode:new{x=250, y=0, width=500, height=600, color=darkGray})
scene.add(RectNode:new{x=750, y=0, width=250, height=600, color=lightGray})


-- left sidebar
local clock = TextNode:new{x=5,y=10,text="12:20"}
scene.add(clock)

local weather = TextNode:new{x=5,y=40, text="EUG: 70o, cloudy"}
scene.add(weather)

local bars = {}
for i=1, 10, 1 do
    bars[i] = RectNode:new{x=i*10, y=440, width=8, height=10, color=red}
    scene.add(bars[i])
end

local animRect = RectNode:new{x=0,y=0,width=20,height=20, color={1,1,0}}
scene.add(animRect)

-- right sidebar

local imageNode = ImageNode:new{x=770,y=100,width=200,height=200}
scene.add(imageNode)


-- particles
local partNode = ParticleSplashNode:new{}
scene.add(partNode)


-- animation
local onstart = function()
--    print("anim is starting")
end
local onend = function()
--    print("anim is ending")
end
require("TranslateAnim")
local anim = TranslateAnim:new{
    target=animRect,
    startX=0,endX=400,
    startY=0,endY=400,
    duration=800,
--    delay=1000,
    onStart=onstart,
    onEnd=onend,
    loop=true,
    reverse=true,
    }

anim:start()
scene.addAnim(anim)


-- text field 
require("TextField")
local tf = TextField:new{x=0,y=0,text="foo"}
scene.add(tf)


-- event handling

EB:on("action",function(e)
    if(e.source == tf) then
        tf.text.text = ""
    end
end)


EB:onTimer(1, function()
    local time = os.date("*t",os.time())
    clock.text = time.hour..":"..time.min..":"..time.sec
end)

EB:onTimer(6, function()
    print("status = ", jit.status())
    local w = {
        "cloudy",
        "sunny",
        "rainy",
        "snowy"
    }
    print("setting the weather")
    weather.text = "EUG " .. (math.random(40,90)).."o "..w[math.random(1,4)]
end)

EB:onTimer(0.1, function()
    for i=1,#bars,1 do
        local v = math.random(10,50)
        bars[i].y = 440-v
        bars[i].height = v
        bars[i]:update()
    end
    
end)
scene.loop()

