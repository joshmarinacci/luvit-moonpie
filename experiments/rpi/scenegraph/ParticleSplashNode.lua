package.path = package.path .. ";../?.lua"
local ffi = require("ffi");
local pi = require("moonpiemac")
local util = require("util")
local freeimage = require("freeimage")

ParticleSplashNode = {}
ParticleSplashNode.x = 0
ParticleSplashNode.y = 0


function ParticleSplashNode:init()
    --generate the particle points
    self.pointCount = 1000
    self.elementCount = 3
    self.points = ffi.new("GLfloat["..(self.pointCount*self.elementCount).."]")
    for i=0,self.pointCount,1 do
        self.points[i*2+0]=math.random()-0.5 -- xv
        self.points[i*2+1]=math.random()-0.5 -- yv
        self.points[i*2+2]=i -- start time
    end
    
    --create an array buffer / vbo from the points array
    self.vbo = util.floatsToArrayBuffer(self.points,self.pointCount,self.elementCount)

local vshader = [[
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
local fshader = [[
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
self.shader = util.buildShaderProgram(vshader, fshader)
--grab the slots
self.part_slot     = gl.glGetAttribLocation(self.shader,"part")
self.time_slot     = gl.glGetUniformLocation(self.shader,"time")
self.tex_slot      = pi.gles.glGetUniformLocation(self.shader,"tex");


-- enable point spriting (required on mac)
util.enablePointSprites()

--turn on blending for the texture
gl.glEnable(pi.GL_BLEND)

--load the sprite image, then turn it into a texture
self.image = freeimage.loadImage("sprite.png")
self.texId = util.uploadImageAsTexture(self.image)

end



function ParticleSplashNode:draw()
    gl.glBlendFunc(pi.GL_SRC_ALPHA, pi.GL_ONE)
    pi.gles.glUseProgram( self.shader )
    pi.gles.glActiveTexture(pi.GL_TEXTURE0)
    pi.gles.glBindTexture(pi.GL_TEXTURE_2D, self.texId)
    --pi.gles.glEnable(pi.GL_TEXTURE_2D);
    
    
    --set our uniforms
    gl.glUniform1i(self.tex_slot, 0)
    gl.glUniform1f(self.time_slot, pi.getTime())
    
    gl.glBindBuffer(pi.GL_ARRAY_BUFFER, self.vbo) --turn on the buffer
    gl.glEnableVertexAttribArray(self.part_slot) --enable the attribute
    --draw the vertices using our buffer
    gl.glVertexAttribPointer(
        self.part_slot, --attribute
        3, --number of elements per vertex (x & y & t)
        pi.GL_FLOAT, --type of each element
        pi.GL_FALSE, -- take our values as is ???
        0, --no space between the values
        nil --use the vbo
    )
    gl.glDrawArrays(pi.GL_POINTS, 0, self.pointCount) --draw it
--[[
    ]]
    --gl.glDisableVertexAttribArray(self.part_slot) -- turn off the attribute
    gl.glBindBuffer(pi.GL_ARRAY_BUFFER, 0) --turn off the buffer
    gl.glBlendFunc(pi.GL_SRC_ALPHA, pi.GL_ONE_MINUS_SRC_ALPHA)
end


function ParticleSplashNode:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

