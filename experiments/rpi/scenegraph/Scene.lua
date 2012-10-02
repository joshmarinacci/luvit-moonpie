--[[

Scene holds global state. Currently

* the global window
* the projection of the window, exposed for shaders to use\
* utility func to generate a standard orthographic matrix

--]]



local ffi = require("ffi");
local pi = require("moonpie")
local util = require("util")
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
end

function Scene:add(node)
    table.insert(Scene.nodes,node)
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

    for i,n in ipairs(Scene.nodes) do 
        n:init()
    end
    
    while true do
        local mouse = pi.getMouseState();
        if(mouse.x ~= oldMouse.x or mouse.y ~= oldMouse.y) then
           Scene.mouseCallback(mouse)
        end
    
        Scene.clear()
        for i,n in ipairs(Scene.nodes) do 
            n:draw(Scene)
        end
        Scene.window.swap()
    end
    
end

return Scene
