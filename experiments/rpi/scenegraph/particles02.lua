--[[

simple particle demo.

particles have 



xv is random
yv is random
start time is incremental

--]]


local ffi = require("ffi");
package.path = package.path .. ";../?.lua"
local pi = require("moonpiemac")
local util = require("util")
local string = require("string")
local EB = require("eventbus")
local img = require("freeimage")
local gl = pi.gles

window = pi.createFullscreenWindow()

--generate the particle points
local pointCount = 1000
local elementCount = 3
points = ffi.new("GLfloat["..(pointCount*elementCount).."]")
for i=0,pointCount,1 do
    points[i*2+0]=math.random()-0.5 -- xv
    points[i*2+1]=math.random()-0.5 -- yv
    points[i*2+2]=i -- start time
end

--create an array buffer / vbo from the points array
local vbo = util.floatsToArrayBuffer(points,pointCount,elementCount)

-- setup the shader
vshader = [[
#version 120
attribute vec3  part;    //the particle: x,y,t
varying   vec4  f_color;
uniform   float time;
varying   float age;

void main(void) {
    f_color = vec4(part.xy / 2.0 + 0.5, 1,1);
    gl_PointSize = 8.0;
    
    float t = part.z;
    float x = 0;
    float y = 0;
    
    if(time > t) {
        float dt = mod(time-t,1);
        x = dt*part.x/2.0;
        y = dt*part.y/2.0;
        age = dt;
    } else {
        age = 0.0;
    }
    gl_Position = vec4(x, y, 0, 1);
}
]]

-- color the particle using the texture * passed in color
fshader = [[
#version 120
uniform sampler2D tex;
varying vec4 f_color;
uniform float sprite;
varying float age;

void main(void) {
    vec4 color2 = texture2D(tex, gl_PointCoord);
    gl_FragColor = vec4(color2.r, color2.g, color2.b, color2.a*(1-age)) * f_color;
}
]]


--compile the shader
local shader = util.buildShaderProgram(vshader, fshader)
--grab the slots
local part_slot     = gl.glGetAttribLocation(shader,"part")
local time_slot   = gl.glGetUniformLocation(shader,"time")
local tex_slot      = pi.gles.glGetUniformLocation(shader,"tex");


-- enable point spriting (required on mac)
util.enablePointSprites()

--turn on blending for the texture
gl.glEnable(pi.GL_BLEND)
--gl.glBlendFunc(pi.GL_SRC_ALPHA, pi.GL_ONE_MINUS_SRC_ALPHA)
gl.glBlendFunc(pi.GL_SRC_ALPHA, pi.GL_ONE)

--load the sprite image, then turn it into a texture
local image = img.loadImage("sprite.png")
local texId = util.uploadImageAsTexture(image)


-- the main drawing loop

for i=0, 60*10, 1 do
    pi.gles.glUseProgram( shader )
    pi.gles.glActiveTexture(pi.GL_TEXTURE0)
    pi.gles.glBindTexture(pi.GL_TEXTURE_2D, texId)
    pi.gles.glEnable(pi.GL_TEXTURE_2D);

    --clear the screen
    pi.gles.glViewport(0,0,window.width, window.height)
    pi.gles.glClearColor(0,0,0,1)
    pi.gles.glClear( pi.GL_COLOR_BUFFER_BIT )
   
    --set our uniforms
    gl.glUniform1i(tex_slot, 0)
    gl.glUniform1f(time_slot, pi.getTime())
    
    --draw the vertices using our buffer
    gl.glBindBuffer(pi.GL_ARRAY_BUFFER, vbo) --turn on the buffer
    gl.glEnableVertexAttribArray(part_slot) --enable the attribute
    gl.glVertexAttribPointer(
        part_slot, --attribute
        3, --number of elements per vertex (x & y & t)
        pi.GL_FLOAT, --type of each element
        pi.GL_FALSE, -- take our values as is ???
        0, --no space between the values
        nil --use the vbo
    )
    gl.glDrawArrays(pi.GL_POINTS, 0, pointCount) --draw it
    gl.glDisableVertexAttribArray(part_slot) -- turn off the attribute
    gl.glBindBuffer(pi.GL_ARRAY_BUFFER, 0) --turn off the buffer
    window.swap()
end
