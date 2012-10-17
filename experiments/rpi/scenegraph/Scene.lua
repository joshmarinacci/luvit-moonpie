--[[

Scene holds global state. Currently

* the global window
* the projection of the window, exposed for shaders to use\
* utility func to generate a standard orthographic matrix

--]]



local ffi = require("ffi");
local pi = require("moonpie")
local util = require("util")
require("RectNode")
require("ImageNode")
require("TextNode")
require("GroupNode")
local EB = require('eventbus').getShared()

Scene = {}
Scene.nodes = {}
Scene.anims = {}
Scene.window = nil

local function loadOrthoMatrix (left, right, top, bottom, near, far)
    local matrix = ffi.new("GLfloat[16]");
    
    local r_l = right - left;
    local t_b = top - bottom;
    local f_n = far - near;
    local tx = - (right + left) / (right - left);
    local ty = - (top + bottom) / (top - bottom);
    local tz = - (far + near) / (far - near);

    matrix[0] = 2.0 / r_l;
    matrix[1] = 0.0;
    matrix[2] = 0.0;
    matrix[3] = tx;

    matrix[4] = 0.0;
    matrix[5] = 2.0 / t_b;
    matrix[6] = 0.0;
    matrix[7] = ty;

    matrix[8] = 0.0;
    matrix[9] = 0.0;
    matrix[10] = 2.0 / f_n;
    matrix[11] = tz;

    matrix[12] = 0.0;
    matrix[13] = 0.0;
    matrix[14] = 0.0;
    matrix[15] = 1.0;
    return matrix
end
Scene.loadOrthoMatrix = loadOrthoMatrix


function Scene.loadIdentityMatrix() 
    local matrix = ffi.new("GLfloat[16]");
    for i=0,15,1 do
        matrix[i] = 0.0;
    end
    matrix[0] = 1.0;
    matrix[5] = 1.0;
    matrix[10] = 1.0;
    matrix[15] = 1.0;
    return matrix;
end

function Scene.clear()
   pi.gles.glViewport(0,0,Scene.window.width, Scene.window.height)
   pi.gles.glClearColor(0.5,0.5,0.5,1)
   pi.gles.glClear( pi.GL_COLOR_BUFFER_BIT )
end

function Scene.init()
    Scene.matrix = {}
    Scene.modelview = Scene.loadIdentityMatrix()
    table.insert(Scene.matrix,Scene.modelview)
    Scene.projection = Scene.loadOrthoMatrix(0,Scene.window.width,0,Scene.window.height,-1,1)
    Scene.cursor = ImageNode:new{x=0,y=0,width=16,height=16,color={1,1,1},src="cursor.png"}
    
    Scene.debugfps =       TextNode:new{x=5,y=0,width=200,height=100,color={1,1,1},textstring="0.00"}
    Scene.debugframetime = TextNode:new{x=5,y=30,width=200,height=100,color={1,1,1},textstring="0.00"}
    Scene.debuggroup = GroupNode:new{y=Scene.window.height-70}        
    Scene.debuggroup:add(Scene.debugfps)
    Scene.debuggroup:add(Scene.debugframetime)
end

function Scene.pushMatrix()
    table.insert(Scene.matrix,Scene.loadIdentityMatrix())
    --last element
    Scene.modelview = Scene.matrix[#Scene.matrix]
end
function Scene.translate(x,y)
    Scene.modelview[3]=x;
    Scene.modelview[7]=y;
end
function Scene.popMatrix()
    --pop off the last element
    table.remove(Scene.matrix,#Scene.matrix)
    Scene.modelview = Scene.matrix[#Scene.matrix]
end

function Scene.add(node)
    table.insert(Scene.nodes,node)
end

function Scene.addAnim(anim)
    table.insert(Scene.anims,anim)
end

local keymap = {}
keymap[30]=97 -- A
keymap[48]=98 -- B
keymap[46]=99 -- C
keymap[32]=100 -- D
keymap[18]=101 -- E
keymap[33]=102 -- F
keymap[34]=103 -- G
keymap[35]=104 -- H
keymap[23]=105 -- I
keymap[36]=106 -- J
keymap[37]=107 -- K
keymap[38]=108 -- L
keymap[50]=109 -- M
keymap[49]=110 -- N
keymap[24]=111 -- O
keymap[25]=112 -- P
keymap[16]=113 -- Q
keymap[19]=114 -- R
keymap[31]=115 -- S
keymap[20]=116 -- T
keymap[22]=117 -- U
keymap[47]=118 -- V
keymap[17]=119 -- W
keymap[45]=120 -- X
keymap[21]=121 -- Y
keymap[44]=122 -- Z

keymap[51]=44 --,
keymap[52]=46 --.
keymap[53]=47 --/

for i=2,10,1 do -- the numbers
    keymap[i]=i+47
end
keymap[11] = 48 -- 0

keymap[12] = 45 -- -
keymap[13] = 61 -- =
keymap[43] = 92 -- =


local shiftmap = {}
for i=97,122,1 do
    shiftmap[i]=i-(97-65)
end

shiftmap[44]=60 -- , <
shiftmap[46]=62 -- , <
shiftmap[47]=63 -- , <


-- the number row
shiftmap[48] = 41 -- 0 )
shiftmap[49] = 33 -- 1 !
shiftmap[50] = 64 -- 2 @
shiftmap[51] = 35 -- 3 #
shiftmap[52] = 36 -- 4 $
shiftmap[53] = 37 -- 5 %
shiftmap[54] = 94 -- 6 ^
shiftmap[55] = 38 -- 7 &
shiftmap[56] = 42 -- 8 *
shiftmap[57] = 40 -- 9 (

shiftmap[45] = 95 -- - _
shiftmap[61] = 43 -- = +
shiftmap[92] = 124-- = |

local BACKSPACE = 14

--shiftmap[97]=65
--shiftmap[98]=66
--shift = 54

local shiftPressed = false
function keyboardCallback_LINUX(state) 
    if(state.key == 0) then return end
    if(state.key == 42 and state.state == 1) then 
        shiftPressed = true
    end
    if(state.key == 42 and state.state == 0) then 
        shiftPressed = false
    end
    if(state.key == 54 and state.state == 1) then 
        shiftPressed = true
    end
    if(state.key == 54 and state.state == 0) then 
        shiftPressed = false
    end
    --print("key = ", state.key, " state = ",state.state, " shift = ", shiftPressed)
    
    if(state.key == BACKSPACE) then
        local evt = {
            keycode = -1,
            shift = shiftPressed,
            backspace = true,
            asChar = function()
                return nil
            end
        }
        if (state.state == 1) then
            EB:fire("keypress", evt)
        end
        if (state.state == 0) then
            EB:fire("keyrelease", evt)
        end
    end
    
    if (keymap[state.key] ~= nil) then
        local code = keymap[state.key];
        local evt = {
            keycode = keymap[state.key],
            shift = shiftPressed,
            asChar = function()
                local ch = keymap[state.key]
                --print("shiftmap = ", shiftmap[keymap[state.key]], " shift = ", shiftPressed)
                if(shiftPressed and shiftmap[ch] ~= nil) then
                    return string.char(shiftmap[ch])
                end
                return string.char(keymap[state.key])
            end
        }
            
        if (state.state == 1) then
            EB:fire("keypress", evt)
        end
        if (state.state == 0) then
            EB:fire("keyrelease", evt)
        end
    end
end

local k = require("keyboard_constants")
local km2 = {}
for i=65,90,1 do --cap letters
    km2[i] = i+(97-65)
end
for i=32,64,1 do --space, symbols, numbers
    km2[i] = i
end
km2[285] = k.RAW_LEFT_ARROW
km2[286] = k.RAW_RIGHT_ARROW
km2[284] = k.RAW_DOWN_ARROW
km2[283] = k.RAW_UP_ARROW

km2[287] = k.RAW_LEFT_SHIFT
km2[288] = k.RAW_RIGHT_SHIFT
km2[295] = k.RAW_BACKSPACE
km2[294] = k.RAW_ENTER
km2[323] = k.RAW_LEFT_COMMAND
km2[324] = k.RAW_RIGHT_COMMAND

local freeimage = require("freeimage")

function keyboardCallback(event) 
    local key = km2[event.key]
    print("I am the keyboard ", event.key, event.state, "key = ",key)
    if key == k.RAW_LEFT_SHIFT or key == k.RAW_RIGHT_SHIFT then
        shiftPressed = (event.state == 1)
        return
    end
    if key == k.RAW_LEFT_COMMAND or key == k.RAW_RIGHT_COMMAND then
        commandPressed = (event.state == 1)
        return
    end
    
    if key == k.RAW_BACKSPACE and shiftPressed and event.state == 0 then
        print("taking a screenshot")
        local w = Scene.window.width
        local h = Scene.window.height
        local pixels = ffi.new("GLubyte["..(3*w*h).."]")
        pi.gles.glReadPixels(0,0,w,h, pi.GL_RGB, pi.GL_UNSIGNED_BYTE, pixels)
        local image = freeimage.FT.FreeImage_ConvertFromRawBits(pixels, w, h, 3 * w, 24, 0x0000FF, 0xFF0000, 0x00FF00, false)
        freeimage.FT.FreeImage_Save(freeimage.FIF_PNG, image, "screenshot.png", 0);
        return
    end
    
    local evt = {
        keycode = key,
        shift = shiftPressed,
        command = commandPressed,
        printable = false,
        asChar = function()
            return nil
        end
    }
    
    
    if(key == k.RAW_ENTER) then
        evt.enter = true
    end
    if key == k.RAW_LEFT_ARROW then
        evt.arrowLeft = true
    end
   
    if(key == k.RAW_BACKSPACE) then
        evt.backspace = true
    end
    
    if key ~= nil and key >= 32 and key <= 122 then
        evt.printable = true
        evt.asChar = function()
            if(shiftPressed and shiftmap[key] ~= nil) then
                return string.char(shiftmap[key])
            end
            return string.char(key)
        end
    end
    
    
    if (event.state == 1) then
        EB:fire("keypress", evt)
    end
    if (event.state == 0) then
        EB:fire("keyrelease", evt)
    end
    
end


local leftDown = false
function Scene.mouseCallback(event)
    -- update the cursor first
    Scene.cursor.x = event.x
    Scene.cursor.y = event.y

    -- send out mouse events
    if(event.left and not leftDown) then
        leftDown = true
        EB:fire("mousepress", {
            kind="mousepress",
            x=event.x,
            y=event.y,
            left=event.left
        })
    end
    if(not event.left and leftDown) then
        leftDown = false
        EB:fire("mouserelease", {
            kind="mouserelease",
            x=event.x,
            y=event.y,
            left=event.left
        })
    end
    EB:fire("mousemove", {
        kind="mousemove",
        x=event.x,
        y=event.y,
        left=event.left
    })
end



CircularBuffer = {}
CircularBuffer.len = 10
CircularBuffer.__index = CircularBuffer

function CircularBuffer:new(len)
    return setmetatable({nums={},len=len},CircularBuffer)
end

function CircularBuffer:add(num)
    table.insert(self.nums,num)
    if(#self.nums > self.len) then
        table.remove(self.nums,1)
    end
end

function CircularBuffer:avg()
    local total = 0
    for n,v in ipairs(self.nums) do
        total = total + v
    end
    return total / #self.nums
end

Scene.frames = CircularBuffer:new(60)
Scene.frames2 = CircularBuffer:new(60)

function Scene.updateStats()
    Scene.debugfps.textstring =
        string.format("drawing time / frame %.2f msec",
        (Scene.frames:avg()*1000))
    Scene.debugframetime.textstring = 
        string.format("time between frames: %.2f msec",
        (Scene.frames2:avg()*1000))
end

function Scene.loop()
    --used only on mac
    Scene.window.keyboardCallback = keyboardCallback
    
    local oldMouse = pi.getMouseState()
    local lastkey = nil

    for i,n in ipairs(Scene.nodes) do 
        n:init()
    end

    Scene.debuggroup:init()    
    Scene.cursor:init()
    
    while true do
    
        local startTime = pi.getTime();
        EB:tick(pi.getTime())
        
        for i,a in ipairs(Scene.anims) do
            a:update(pi.getTime())
        end
        
        local mouse = pi.getMouseState();
        if(mouse.x ~= oldMouse.x or mouse.y ~= oldMouse.y or mouse.left ~= oldMouse.left) then
           Scene.mouseCallback(mouse)
        end
        --used only on linux
        if(pi.LINUX) then
            local keyboard = pi.getKeyboardState();
            if(keyboard.key ~= lastkey) then
                keyboardCallback_LINUX(keyboard)
            end
            lastkey = keyboard.key
        end
    
        Scene.clear()
        for i,n in ipairs(Scene.nodes) do 
            n:draw(Scene)
        end
        Scene.debuggroup:draw(Scene)
        Scene.cursor:draw(Scene)
        oldMouse = mouse
        
        
        Scene.frames:add(pi.getTime()-startTime)
        Scene.window.swap()
        Scene.frames2:add(pi.getTime()-startTime)
        Scene.updateStats()
    end
    
end

return Scene
