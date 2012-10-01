--[[

simple particle demo

--]]
jit.off()

local ffi = require("ffi");
package.path = package.path .. ";../?.lua"
local pi = require("moonpie")
local util = require("util")
local string = require("string")
local EB = require("eventbus")
local img = require("freeimage")
local gl = pi.gles

window = pi.createFullscreenWindow()

-- setup the shader
vshader = [[
#version 120
attribute vec2  coord2d;
varying   vec4  f_color;
uniform   float offset_x;
uniform   float scale_x;
uniform   float sprite;
uniform   float time;

void main(void) {
    f_color = vec4(coord2d.xy / 2.0 + 0.5, 1,1);
    gl_PointSize = 8.0;

    //just plot the values directly
    gl_Position = vec4((coord2d.x + offset_x) * scale_x, coord2d.y, 0, 1);
    
    //plot as a sinewave over time
    //gl_Position = vec4(coord2d.x+offset_x,sin(coord2d.x*8-time)/2,0,1);
    
    //funky spinny wave
    /*
    gl_Position = vec4(
        sin(coord2d.x*3.0)/5.0*sin(time*time),
        sin(coord2d.x-time*10.0)+coord2d.x/100.0,
        0,1
    );
    */
}
]]
--#version 120

fshader = [[
#version 120
uniform sampler2D tex;
varying vec4 f_color;
uniform float sprite;


void main(void) {
    vec4 color2 = texture2D(tex, gl_PointCoord);
    gl_FragColor = vec4(color2.r, color2.g, color2.b, color2.a) * f_color;
    //gl_FragColor = vec4(0,1,0,1);
}

]]


--compile the shader
local shader = util.buildShaderProgram(vshader, fshader)

--grab the slots
local coord2d_slot  = gl.glGetAttribLocation(shader,"coord2d")
local offset_x_slot = gl.glGetUniformLocation(shader,"offset_x")
local scale_x_slot  = gl.glGetUniformLocation(shader,"scale_x")
local sprite_slot   = gl.glGetUniformLocation(shader,"sprite")
local time_slot     = gl.glGetUniformLocation(shader,"time")
local tex_slot      = pi.gles.glGetUniformLocation(shader,"tex");


-- enable point spriting (required on mac)
util.enablePointSprites()

--turn on blending for the texture
gl.glEnable(pi.GL_BLEND)
gl.glBlendFunc(pi.GL_SRC_ALPHA, pi.GL_ONE_MINUS_SRC_ALPHA)

--load the sprite image, then turn it into a texture
local image = img.loadImage("sprite.png")
local texId = util.uploadImageAsTexture(image)

--generate the points for the equation
local pointCount = 2000
local points = ffi.new("GLfloat["..(pointCount*2).."]")
for i=0,pointCount,1 do
    local x = (i-1000.0)/100.0
    points[i*2+0]=x
    points[i*2+1]=math.sin(x*10.0)/(1.0+x*x)
end

--create an array buffer / vbo from the points array
local vbo = util.floatsToArrayBuffer(points,pointCount,2)

-- the main drawing loop
for i=0, 60*10, 1 do
    checkError()
  --  print("shader = ", shader)
    pi.gles.glUseProgram( shader )
    checkError()
    pi.gles.glActiveTexture(pi.GL_TEXTURE0)
    checkError()
    pi.gles.glBindTexture(pi.GL_TEXTURE_2D, texId)
    checkError()
    pi.gles.glEnable(pi.GL_TEXTURE_2D);
    checkError()

    --clear the screen
    pi.gles.glViewport(0,0,window.width, window.height)
    pi.gles.glClearColor(0,0,0,1)
    pi.gles.glClear( pi.GL_COLOR_BUFFER_BIT )
    checkError()
   
    --set our uniforms
    gl.glUniform1i(tex_slot, 0)
    gl.glUniform1f(offset_x_slot, 0.0)
    gl.glUniform1f(scale_x_slot, 0.2)
    --gl.glUniform1f(time_slot, pi.getTime())
    gl.glUniform1f(time_slot, 0)
    checkError()
    
    --draw the vertices using our buffer
    gl.glBindBuffer(pi.GL_ARRAY_BUFFER, vbo) --turn on the buffer
    gl.glEnableVertexAttribArray(coord2d_slot) --enable the attribute
    gl.glVertexAttribPointer(
        coord2d_slot, --attribute
        2, --number of elements per vertex (x & y)
        pi.GL_FLOAT, --type of each element
        pi.GL_FALSE, -- take our values as is ???
        0, --no space between the values
        nil --use the vbo
    )
    --gl.glDrawArrays(pi.GL_LINE_STRIP, 0, pointCount) --draw it
    gl.glUniform1f(sprite_slot, 4.0)
    gl.glDrawArrays(pi.GL_POINTS, 0, pointCount) --draw it
    gl.glDisableVertexAttribArray(coord2d_slot) -- turn off the attribute
    gl.glBindBuffer(pi.GL_ARRAY_BUFFER, 0) --turn off the buffer
    window.swap()
end
