--[[

Scene holds global state. Currently

* the global window
* the projection of the window, exposed for shaders to use\
* utility func to generate a standard orthographic matrix

--]]



local ffi = require("ffi");
local pi = require("moonpiemac")
local util = require("util")

Scene = {}
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


function Scene:clear()
   pi.gles.glViewport(0,0,self.window.width, self.window.height)
   pi.gles.glClearColor(0,0,1,1)
   pi.gles.glClear( pi.GL_COLOR_BUFFER_BIT )
end

function Scene:init()
    self.projection = self.loadOrthoMatrix(0,self.window.width,0,self.window.height,-1,1)
end


function Scene:swap()
    self.window.swap()
end

return Scene
