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
local EB = require('eventbus').getShared()

Scene = {}
Scene.nodes = {}
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


function Scene.clear()
   pi.gles.glViewport(0,0,Scene.window.width, Scene.window.height)
   pi.gles.glClearColor(0.5,0.5,0.5,1)
   pi.gles.glClear( pi.GL_COLOR_BUFFER_BIT )
end

function Scene.init()
    Scene.projection = Scene.loadOrthoMatrix(0,Scene.window.width,0,Scene.window.height,-1,1)
    Scene.cursor = RectNode:new{x=0,y=0,width=16,height=16,color={1,1,1}}
end

function Scene.add(node)
    table.insert(Scene.nodes,node)
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
keymap[16]=113 -- P
keymap[19]=114 -- P
keymap[31]=115 -- P
keymap[20]=116 -- P
keymap[22]=117 -- P
keymap[47]=118 -- P
keymap[17]=119 -- P
keymap[45]=120 -- P
keymap[21]=121 -- P
keymap[44]=122 -- P

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

shiftmap[45] = 95 -- - _
shiftmap[61] = 43 -- = +
shiftmap[92] = 124-- = |

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
    print("key = ", state.key, " state = ",state.state, " shift = ", shiftPressed)
    if (keymap[state.key] ~= nil) then
        local code = keymap[state.key];
        EB:fire("keytyped", {
            keycode = keymap[state.key],
            shift = shiftPressed,
            asChar = function()
                local ch = keymap[state.key]
                print("shiftmap = ", shiftmap[keymap[state.key]], " shift = ", shiftPressed)
                if(shiftPressed and shiftmap[ch] ~= nil) then
                    return string.char(shiftmap[ch])
                end
                return string.char(keymap[state.key])
            end
        })
    end
end

function keyboardCallback(event) 
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
    end
end



function Scene.loop()
    Scene.window.keyboardCallback = keyboardCallback
    local oldMouse = pi.getMouseState()
    local lastkey = nil

    for i,n in ipairs(Scene.nodes) do 
        n:init()
    end
    
    Scene.cursor:init()
    
    while true do
        EB:tick(pi.getTime())
        local mouse = pi.getMouseState();
        if(mouse.x ~= oldMouse.x or mouse.y ~= oldMouse.y or mouse.left ~= oldMouse.left) then
           Scene.mouseCallback(mouse)
        end
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
        Scene.cursor:draw(Scene)
        oldMouse = mouse
        
        
        Scene.window.swap()
    end
    
end

return Scene
