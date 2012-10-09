--[[

TextNode is a node that can draw a single line of text with
a given font and color. It uses a shared shader
but each instance has it's own geometry

--]]

local ffi = require("ffi");
local pi = require("moonpie")
local util = require("util")
local freetype = require("freetype")

TextNode = {}
TextNode.x = 100
TextNode.y = 200
TextNode.color = {1.0,0.5,0.5}
TextNode.textstring = "PENNY penny"
TextNode.shaderloaded = false
TextNode.font = freetype.getFont("default")

function TextNode.loadShader() 
    if(TextNode.shaderloaded) then return end
    TextNode.shaderloaded = true
    
    checkError()
    --now we can set up the shaders
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
        uv = TextureCoords;
    }
    ]]
    
    local fshader_source = [[
    uniform sampler2D tex;
    varying vec2 uv;
    uniform vec3 color;
    void main()
    {
        vec4 color2 = texture2D(tex, vec2(uv.x,uv.y));
        gl_FragColor = vec4(color.r,color.g,color.b, color2.a);
    }
    ]]
    print("compiling the shaders")
    checkError();
    TextNode.shader = util.buildShaderProgram(vshader_source, fshader_source)
    print("the shader id = ",TextNode.shader)
    TextNode.projectionSlot = pi.gles.glGetUniformLocation(TextNode.shader,"projection");
    TextNode.texSlot        = pi.gles.glGetUniformLocation(TextNode.shader,"tex");
    TextNode.positionSlot   = pi.gles.glGetAttribLocation(TextNode.shader,"Position");
    pi.gles.glEnableVertexAttribArray(TextNode.positionSlot)
    TextNode.coordSlot      = pi.gles.glGetAttribLocation(TextNode.shader,"TextureCoords");
    pi.gles.glEnableVertexAttribArray(TextNode.coordSlot)
    TextNode.xySlot         = pi.gles.glGetUniformLocation(TextNode.shader,"xy");
    TextNode.colorSlot      = pi.gles.glGetUniformLocation(TextNode.shader,"color");
end

function TextNode:init()
    TextNode.loadShader()
    self.font:init()
    self.coordArray = ffi.new("float[10]")
    self.vertexArray = ffi.new("float[15]")
end

function TextNode:getMetrics()
    return self.font.metrics
end

function TextNode:draw(scene)
   pi.gles.glUseProgram( TextNode.shader )
   pi.gles.glBindTexture(pi.GL_TEXTURE_2D, self.font.texId)
   local xoff = 0
   local arr = self.coordArray
   local vertexArray = self.vertexArray
   local metrics = self.font.metrics
   local w = self.font.w
   local h = self.font.h
   for i=1, #self.textstring, 1 do
       local n = string.byte(self.textstring,i)
       local fx = metrics[n].x/w
       local fo = metrics[n].w/w
       local fh = metrics[n].h/h
       local size_w = metrics[n].w
       local size_h = metrics[n].h
       local fy = 0
       
       
       arr[0] = fx;    arr[1] = fy;
       arr[2] = fx;    arr[3] = fh; 
       arr[4] = fx+fo; arr[5] = fh; 
       arr[6] = fx+fo; arr[7] = fy;
       arr[8] = fx;    arr[9] = fy;
       
       
       local yoff = self.font.h-metrics[n].by;
       vertexArray[0]=0;
       vertexArray[1]=0;
       
       vertexArray[3]=0;
       vertexArray[4]=size_h; 
       
       vertexArray[6]=size_w;       
       vertexArray[7]=size_h; 

       vertexArray[9]=size_w;
       vertexArray[10]=0;
       
       vertexArray[12]=0;
       vertexArray[13]=0;
       
       pi.gles.glUniform2f(TextNode.xySlot, xoff+self.x,self.y+yoff)
       pi.gles.glUniformMatrix4fv(TextNode.projectionSlot,  1, pi.GL_FALSE, scene.projection )
       pi.gles.glUniform3f(TextNode.colorSlot, self.color[1], self.color[2], self.color[3])
       pi.gles.glVertexAttribPointer(TextNode.positionSlot, 3, pi.GL_FLOAT, pi.GL_FALSE, 0, vertexArray )
       pi.gles.glVertexAttribPointer(TextNode.coordSlot,    2, pi.GL_FLOAT, pi.GL_FALSE, 0, arr )
       pi.gles.glUniform1i(TextNode.texSlot, 0)
       pi.gles.glDrawArrays( pi.GL_TRIANGLE_STRIP, 0, 5 )
       xoff = xoff + metrics[n].advance
   end
end



function TextNode:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end


