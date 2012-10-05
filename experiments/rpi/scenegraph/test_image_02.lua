jit.off()

package.path = package.path .. ";../?.lua"
local ffi = require("ffi");
local pi = require("moonpie")
local scene = require("Scene")
local util = require("util")
local freeimage = require("freeimage")

-- all of the inits
scene.window = pi.createFullscreenWindow()
print('window = ', scene.window)
scene:init()

require ("RectNode")
RectNode.loadShader()

require ("TextNode")
TextNode.loadShader()
require("SliderNode")
local slider = SliderNode:new{
    x = 0,
    y = 0,
    width=300,
    text = "saturation"
}
scene.add(slider)

local ImageNode = {
    x=0,
    y=100,
    color={0,0,0},
    amount=1.0
}

function loadShader()
    print("Loading the shader")
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
    uniform float amount;
    
    void main()
    {
        vec4 color = texture2D(tex, uv);
        float value = (color.r + color.g + color.b)/3.0;
        gl_FragColor = vec4(
             mix(value,color.r,amount)
            ,mix(value,color.g,amount)
            ,mix(value,color.b,amount)
            ,1.0);
    }
    ]];
    
--    vshader_source = "#version 120\n"..vshader_source
--    fshader_source = "#version 120\n"..fshader_source
    ImageNode.shader = util.buildShaderProgram(vshader_source, fshader_source)
    
    ImageNode.projectionSlot = pi.gles.glGetUniformLocation(ImageNode.shader,"projection");
    ImageNode.texSlot        = pi.gles.glGetUniformLocation(ImageNode.shader,"tex");
    ImageNode.positionSlot   = pi.gles.glGetAttribLocation( ImageNode.shader,"Position");
    pi.gles.glEnableVertexAttribArray(ImageNode.positionSlot)
    ImageNode.coordSlot      = pi.gles.glGetAttribLocation(ImageNode.shader,"TextureCoords");
    pi.gles.glEnableVertexAttribArray(ImageNode.coordSlot)    
    ImageNode.xySlot         = pi.gles.glGetUniformLocation(ImageNode.shader,"xy");
    ImageNode.amountSlot         = pi.gles.glGetUniformLocation(ImageNode.shader,"amount");
    --ImageNode.colorSlot      = pi.gles.glGetUniformLocation(ImageNode.shader,"color");
    
    --[[
        a better api to shaders would be
        
        shader = buildShader{
            vectorSource = "",
            fragmentSource = "",
            uniforms= {"projection","tex","xy","amount"},
            attributes = {"Position","TextureCoords"}
        }
        
        when drawing call
        shader.use()
        shader.enableVertexAttribArray("Position") --checks that we are using the right name and it really is an attribute
        shader.uniform2f("xy",5,6) -- checks that it really is a uniform. checks for null values?
        shader.vertexAttribPointer("Position", etc...
    
    ]]
end

loadShader()


function imageInit()
    local w = 240;
    local h = 240;
    ImageNode.vertexArray = ffi.new("float[15]",
       0,0,0,
       0,h,0,
       w,h,0,
       w,0,0,
       0,0,0
    )
    ImageNode.coordArray = ffi.new("float[10]",
        0,0,
        0,1,
        1,1,
        1,0,
        0,0
    )
    ImageNode.image = freeimage.loadImage("earth.jpeg")
    ImageNode.texId = util.uploadImageAsTexture(ImageNode.image)
    print("image loaded: ", ImageNode.image.width, ImageNode.image.height)
end

--[[
local proxy = {}

local mt = {
    __index = function(t,k)
        return function(...)
            checkError()
            return pi.gles[k](unpack(arg))
        end
    end
}

setmetatable(proxy,mt)

--print("proxy = ", proxy.glUseProgram(ImageNode.shader))
--]]

function imageDraw(scene)
    pi.gles.glUseProgram( ImageNode.shader )
    pi.gles.glActiveTexture(pi.GL_TEXTURE0)
    pi.gles.glBindTexture(pi.GL_TEXTURE_2D, ImageNode.texId)
    pi.gles.glEnable(pi.GL_TEXTURE_2D);
    pi.gles.glEnableVertexAttribArray(ImageNode.positionSlot)

    pi.gles.glUniform2f(ImageNode.xySlot, ImageNode.x, ImageNode.y)
    pi.gles.glUniform1f(ImageNode.amountSlot, ImageNode.amount)
    pi.gles.glUniformMatrix4fv(ImageNode.projectionSlot, 1,   pi.GL_FALSE, Scene.projection )
    --pi.gles.glUniform3f(ImageNode.colorSlot, ImageNode.color[1],   ImageNode.color[2], ImageNode.color[3])
    pi.gles.glVertexAttribPointer(ImageNode.positionSlot, 3,  pi.GL_FLOAT, pi.GL_FALSE, 0, ImageNode.vertexArray )
    pi.gles.glVertexAttribPointer(ImageNode.coordSlot,    2, pi.GL_FLOAT, pi.GL_FALSE, 0, ImageNode.coordArray )
    pi.gles.glUniform1i(ImageNode.texSlot, 0)
    pi.gles.glDrawArrays( pi.GL_TRIANGLE_STRIP, 0, 5 )
end

obj = {
    init = imageInit,
    draw = imageDraw,
}
scene.add(obj)



local EB = require("eventbus").getShared()
EB:on("change",function()
    slider.text.textstring = "saturation = "..(slider.value*100).."%"
    ImageNode.amount = slider.value
end)

scene.loop()
