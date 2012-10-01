package.path = package.path .. ";../?.lua"
local ffi = require("ffi");
local pi = require("moonpie")
local util = require("util")
local freeimage = require("freeimage")

ImageNode = {}
ImageNode.x = 100
ImageNode.y = 10
ImageNode.width = 50
ImageNode.height = 50
ImageNode.color = {1,1,1}

function ImageNode:loadShader()
    local vshader_source = [[
    #version 120
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
        gl_Position = translate(xy.x,xy.y,0.0) * Position *  projection;
        uv = TextureCoords;
    }
    ]]
    local fshader_source = [[
    #version 120
    uniform vec3 color;
    uniform sampler2D tex;
    varying vec2 uv;
    
    void main()
    {
        vec4 color = texture2D(tex, uv);
        gl_FragColor = vec4(color.r,color.g,color.b,1.0);
    }
    ]];
    
    ImageNode.shader = util.buildShaderProgram(vshader_source, fshader_source)
    
    ImageNode.projectionSlot = pi.gles.glGetUniformLocation(ImageNode.shader,"projection");
    ImageNode.texSlot        = pi.gles.glGetUniformLocation(ImageNode.shader,"tex");
    ImageNode.positionSlot   = pi.gles.glGetAttribLocation( ImageNode.shader,"Position");
    pi.gles.glEnableVertexAttribArray(ImageNode.positionSlot)
    ImageNode.coordSlot      = pi.gles.glGetAttribLocation(ImageNode.shader,"TextureCoords");
    pi.gles.glEnableVertexAttribArray(ImageNode.coordSlot)    
    ImageNode.xySlot         = pi.gles.glGetUniformLocation(ImageNode.shader,"xy");
    ImageNode.colorSlot      = pi.gles.glGetUniformLocation(ImageNode.shader,"color");
end

function ImageNode:init()
    local w = self.width
    local h = self.height
    self.vertexArray = ffi.new("float[15]",
       0,0,0,
       0,h,0,
       w,h,0,
       w,0,0,
       0,0,0
    )
    self.coordArray = ffi.new("float[10]",
        0,0,
        0,1,
        1,1,
        1,0,
        0,0
    )
    self.image = freeimage.loadImage("earth.jpeg")
    self.texId = util.uploadImageAsTexture(self.image)
end

function ImageNode:draw(scene)
   
    pi.gles.glUseProgram( ImageNode.shader )
    pi.gles.glActiveTexture(pi.GL_TEXTURE0)
    pi.gles.glBindTexture(pi.GL_TEXTURE_2D, self.texId)
    pi.gles.glEnable(pi.GL_TEXTURE_2D);
    pi.gles.glEnableVertexAttribArray(ImageNode.positionSlot)
    
    pi.gles.glUniform2f(ImageNode.xySlot, self.x, self.y)
    pi.gles.glUniformMatrix4fv(ImageNode.projectionSlot, 1,   pi.GL_FALSE, scene.projection )
    pi.gles.glUniform3f(ImageNode.colorSlot, self.color[1],   self.color[2], self.color[3])
    pi.gles.glVertexAttribPointer(ImageNode.positionSlot, 3,  pi.GL_FLOAT, pi.GL_FALSE, 0, self.vertexArray )
    pi.gles.glVertexAttribPointer(ImageNode.coordSlot,     2, pi.GL_FLOAT, pi.GL_FALSE, 0, self.coordArray )
    pi.gles.glUniform1i(ImageNode.texSlot, 0)
    pi.gles.glDrawArrays( pi.GL_TRIANGLE_STRIP, 0, 5 )
    
    --pi.gles.glDisableVertexAttribArray(ImageNode.positionSlot)
end

function ImageNode:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

