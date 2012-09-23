--[[

Test getting the current state of the mouse

]]
local ffi = require("ffi");
local pi = require("moonpie")

window = pi.createFullscreenWindow()

print("my window = ", window.width, window.height)
function checkError()
    local err = pi.gles.glGetError();
    if(err == pi.GL_NO_ERROR) then
        --print("no error")
    end
    if(err == pi.GL_INVALID_ENUM) then
        print("Error: invalid enum")
    end
    if(err == pi.GL_INVALID_VALUE) then
        print("Error: invalid value")
    end
    if(err == pi.GL_INVALID_OPERATION) then
        print("Error: invalid operation")
    end
    if(err == pi.GL_OUT_OF_MEMORY) then
        print("Error: out of memory")
    end
end

--[[

load up some plain color shaders

create vertex array for a quad of triangles

draw the data

]]


-- load up standard plain color shaders
local vshader_source = assert(io.open("SimpleVertex.glsl","r")):read("*all")
local vshader = pi.loadShader(vshader_source, GL_VERTEX_SHADER)
local fshader_source = assert(io.open("SimpleFragment.glsl","r")):read("*all")
local fshader = pi.loadShader(fshader_source, GL_FRAGMENT_SHADER)
checkError()

-- link into a program
local prog = pi.gles.glCreateProgram()
pi.gles.glAttachShader( prog, vshader )
pi.gles.glAttachShader( prog, fshader )
pi.gles.glLinkProgram( prog )
pi.gles.glUseProgram( prog )
checkError()

-- grab slots for the shader parameters. must match types in the shader code
local positionSlot   = pi.gles.glGetAttribLocation(prog,"Position");
local colorSlot      = pi.gles.glGetUniformLocation(prog,"color");
local projectionSlot = pi.gles.glGetUniformLocation(prog,"projection");
local xySlot         = pi.gles.glGetUniformLocation(prog,"xy");
--local modelviewSlot  = pi.gles.glGetUniformLocation(prog,"modelview");

-- only do this for the position and projection
-- because they are the only ones which will use pointers
pi.gles.glEnableVertexAttribArray(positionSlot)
--pi.gles.glEnableVertexAttribArray(projectionSlot)
checkError()
--pi.gles.glEnableVertexAttribArray(colorSlot)
checkError()

print("the shaders are set up now")


local size = 32
-- creat quad data to fill the whole screen
local vertexArray = ffi.new(
   "float[15]",
   0,0, 0,
   0, size, 0,
   size, size, 0,
   size,0, 0,
   0,0, 0
)


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

local count = 0;

local projection = loadOrthoMatrix(0,window.width,0,window.height,-1,1)

--print("the projection = ", projection)
--for i=0, 15, 1 do
--    print("foo", projection[i])
--end

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

local r = 1.0;

while true do
    --set viewport to the entire screen
   pi.gles.glViewport(0,0,window.width, window.height)
   --print("clearing");
   pi.gles.glClearColor(1,0,1,1)
   pi.gles.glClear( pi.GL_COLOR_BUFFER_BIT )
   checkError()
   
   --set the parameters
   --color of shape
   --using 0.01 is fine but using 0.0 has strange behavior!
   pi.gles.glUniform3f(colorSlot, 1.0, 1.0, 0.01)
   
   local mouse = pi.getMouseState();
   --set translation based on mouse coords
   pi.gles.glUniform2f(xySlot, mouse.x*1.0,window.height-mouse.y*1.0)
   checkError();
   
   --slot, num items per value, item type, false, ?, pointer to the data
   --print("setting array");
   --set the vertex data array
   pi.gles.glVertexAttribPointer(positionSlot, 3, pi.GL_FLOAT, pi.GL_FALSE, 0, vertexArray )
   --   pi.gles.glVertexAttribPointer(projectionSlot, 1, pi.GL_FLOAT, pi.GL_FALSE, 0, projection)
   --set the projection matrix
   pi.gles.glUniformMatrix4fv(projectionSlot, 1, pi.GL_FALSE, projection )
   checkError();
   --enable the parameter
   --pi.gles.glEnableVertexAttribArray( positionSlot )
   
   --draw a triangle strip from ? to ?
   pi.gles.glDrawArrays( pi.GL_TRIANGLE_STRIP, 0, 5 )
   checkError()
 
   window.swap()
   checkError()
   count = count + 1
   if(count == 60*10) then --wait for 10 seconds at 60fps
        break
   end
end


