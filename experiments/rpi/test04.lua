--[[

test drawing an image by filling a quad with a texture

]]
local ffi = require("ffi");
local pi = require("moonpie")
local util = require("util")

window = pi.createFullscreenWindow()

print("my window = ", window.width, window.height)



print("about to gen a texture id");
checkError()

-- load image into memory from disk, or just synth it
-- a single pixel image
local image = ffi.new(
   "GLubyte[36]",
   0,  255,   0,   255,
   0,  255,   0,   255,
   0,  255,   0,   255,
   
   0,  255,   255,   255,
   0,  255,   0,   255,
   0,  255,   255,   255,
   
   255,  255,   255,   255,
   255,  255,   255,   255,
   255,  255,   255,   255
   
)
-- generate texture id
local R_texId = ffi.new("GLuint[1]");
pi.gles.glGenTextures(1,R_texId);
checkError()

local texId = R_texId[0]
print("texture id = ", texId)
-- bind the texture
pi.gles.glBindTexture(pi.GL_TEXTURE_2D, texId)
checkError()
-- set the min filter parameter
pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_MIN_FILTER, pi.GL_NEAREST)
pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_MAG_FILTER, pi.GL_NEAREST)
pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_WRAP_S, pi.GL_REPEAT);
pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_WRAP_T, pi.GL_REPEAT);
checkError()
-- upload the data to the GPU
pi.gles.glTexImage2D(pi.GL_TEXTURE_2D, 0, pi.GL_RGBA, 3,3, 0, pi.GL_RGBA, pi.GL_UNSIGNED_BYTE, image);
checkError()

-- load up standard plain color shaders
local vshader_source = [[
attribute vec4 Position;
attribute vec2 TextureCoords;
uniform mat4 projection;
uniform vec2 xy;
varying vec2 uv;

mat4 translate(float x, float y, float z)
{
    return mat4(
        vec4(1.0, 0.0, 0.0, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(0.0, 0.0, 1.0, 0.0),
        vec4(x,   y,   z,   1.0)
    );
}

void main()
{
    gl_Position = translate(xy.x,xy.y,0.0) * Position *  projection ; 
    uv = vec2(Position.x,Position.y);
//    uv = vec2(TextureCoords.x,TextureCoords.y);
    uv = TextureCoords;
}
]]

local fshader_source = [[
precision mediump float;
uniform sampler2D tex;
varying vec2 uv;
void main()
{
    vec3 color0 = vec3(0.0,0.0,0.0);
    vec3 color1 = vec3(1.0,1.0,1.0);
    //vec3 color2 = mix(color0, color1, uv.x/100.0);
    //vec4 color2 = texture2D(tex, vec2(uv.x/100.0,uv.y/100.0));
    vec4 color2 = texture2D(tex, vec2(uv.x,uv.y));
    gl_FragColor = vec4(color2.r, color2.g, color2.b, 1.0);
}
]]




local prog = util.buildShaderProgram(vshader_source, fshader_source)
   
-- grab slots for the shader parameters. must match types in the shader code
local positionSlot   = pi.gles.glGetAttribLocation(prog,"Position");
checkError()
pi.gles.glEnableVertexAttribArray(positionSlot)
checkError()

-- it appears that if this variable is unused it will be stripped out of the code
-- so then the enable call will fail with an 'invalid value' error.
local coordSlot      = pi.gles.glGetAttribLocation(prog,"TextureCoords");
checkError()
pi.gles.glEnableVertexAttribArray(coordSlot)
checkError()
showProgramLog(prog)

--local colorSlot      = pi.gles.glGetUniformLocation(prog,"color");
local projectionSlot = pi.gles.glGetUniformLocation(prog,"projection");
local xySlot         = pi.gles.glGetUniformLocation(prog,"xy");
local texSlot        = pi.gles.glGetUniformLocation(prog,"tex");
checkError()


local size = 100
local count = 0;
local projection = util.loadOrthoMatrix(0,window.width,0,window.height,-1,1)


local coordsArray = ffi.new(
   "float[10]",
    0, 0,
    0, 1,
    1, 1,
    1, 0,
    0, 0
    )

print("successfully upload texture to the gpu")

-- free the local memory

local vertexArray = ffi.new(
   "float[15]",
   0,0, 0,
   0, size, 0,
   size, size, 0,
   size,0, 0,
   0,0, 0
)



while true do

    --set viewport to the entire screen
   pi.gles.glViewport(0,0,window.width, window.height)
   pi.gles.glClearColor(1,0,1,1)
   pi.gles.glClear( pi.GL_COLOR_BUFFER_BIT )
   checkError()
   
   --set the parameters
   --color of shape
   --using 0.01 is fine but using 0.0 has strange behavior!
   --pi.gles.glUniform3f(colorSlot, 1.0, 1.0, 0.01)
   
   local mouse = pi.getMouseState();
   --set translation based on mouse coords
   pi.gles.glUniform2f(xySlot, mouse.x*1.0,window.height-mouse.y*1.0)
   --pi.gles.glUniform2f(xySlot, 0.0, 0.0);--mouse.x*1.0,window.height-mouse.y*1.0)
   checkError();
   --set the projection matrix
   pi.gles.glUniformMatrix4fv(projectionSlot, 1, pi.GL_FALSE, projection )
   checkError();
   
   --slot, num items per value, item type, false, ?, pointer to the data
   --print("setting array");
   --set the vertex data array
   pi.gles.glVertexAttribPointer(positionSlot, 3, pi.GL_FLOAT, pi.GL_FALSE, 0, vertexArray )
   checkError();
   --set the texture coords data array
   pi.gles.glVertexAttribPointer(coordSlot,    2, pi.GL_FLOAT, pi.GL_FALSE, 0, coordsArray )
   checkError();
   
   --set the texture
   --draw a triangle strip from ? to ?
   pi.gles.glUniform1i(texSlot, 0)
   checkError()
   pi.gles.glDrawArrays( pi.GL_TRIANGLE_STRIP, 0, 5 )
   checkError()
 
   window.swap()
   checkError()
   count = count + 1
   if(count == 60*10) then --wait for 10 seconds at 60fps
        break
   end
end


