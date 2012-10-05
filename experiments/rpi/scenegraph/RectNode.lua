--[[

RectNode is a node in the scenegraph which draws a colored
rectangle on screen. It uses a shared RectNode shader
but each instance of RectNode has it's own geometry.

--]]

package.path = package.path .. ";../?.lua"
local ffi = require("ffi");
local pi = require("moonpie")
local util = require("util")

RectNode = {}
RectNode.x = 300
RectNode.y = 100
RectNode.width = 50
RectNode.height = 50
RectNode.color = {0.0,0.0,1.0}
RectNode.shaderloaded = false

function RectNode.loadShader()
    if(RectNode.shaderloaded) then return end
    RectNode.shaderloaded = true
    local vshader_source = [[
    attribute vec4 Position;
    uniform mat4 projection;
    uniform vec2 xy;
    
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
        gl_Position = translate(xy.x,xy.y,0.0) * Position *  projection;
    }
    ]]
    local fshader_source = [[
    //precision mediump float;
    uniform vec3 color;
    
    void main()
    {
      gl_FragColor = vec4(color.r,color.g,color.b,1.0);
    }

    ]];
    
    RectNode.shader = util.buildShaderProgram(vshader_source, fshader_source)
    RectNode.projectionSlot = pi.gles.glGetUniformLocation(RectNode.shader,"projection");
    RectNode.positionSlot   = pi.gles.glGetAttribLocation(RectNode.shader,"Position");
    RectNode.colorSlot      = pi.gles.glGetUniformLocation(RectNode.shader,"color");
    RectNode.xySlot         = pi.gles.glGetUniformLocation(RectNode.shader,"xy");
    pi.gles.glEnableVertexAttribArray(RectNode.positionSlot)
end

function RectNode:init()
    RectNode.loadShader()
    local w = self.width
    local h = self.height
    self.vertexArray = ffi.new(
       "float[15]",
       0,0,0, --0,1,2
       0,h,0, --3,4,5
       w,h,0, --6,7,8
       w,0,0, --9,
       0,0,0
    )
end

function RectNode:update()
    self.vertexArray[4]=self.height
    self.vertexArray[7]=self.height
    self.vertexArray[6]=self.width
    self.vertexArray[9]=self.width
end

function RectNode:draw(scene)
    pi.gles.glUseProgram( RectNode.shader )
    pi.gles.glUniformMatrix4fv(RectNode.projectionSlot, 1, pi.GL_FALSE, scene.projection )   
    pi.gles.glUniform3f(RectNode.colorSlot, self.color[1], self.color[2], self.color[3])
    pi.gles.glUniform2f(RectNode.xySlot, self.x, self.y)
    pi.gles.glVertexAttribPointer(RectNode.positionSlot, 3, pi.GL_FLOAT, pi.GL_FALSE, 0, self.vertexArray )
    pi.gles.glDrawArrays( pi.GL_TRIANGLE_STRIP, 0, 5 )
end

function RectNode:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end


