--[[

init the usual stuff

]]

local ffi = require("ffi");
package.path = package.path .. ";../?.lua"
local pi = require("moonpiemac")
local util = require("util")
local string = require("string")
local EB = require("eventbus")
window = pi.createFullscreenWindow()


local gl = pi.gles


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
    gl_Position = vec4((coord2d.x + offset_x*time) * scale_x, coord2d.y, 0, 1);
    f_color = vec4(coord2d.xy / 2.0 + 0.5, 1,1);
    gl_PointSize = 8.0;
}
]]

fshader = [[
#version 120
uniform sampler2D tex;
varying vec4 f_color;
uniform float sprite;

void main(void) {
    vec4 color2 = texture2D(tex, gl_PointCoord);
    gl_FragColor = vec4(color2.r, color2.g, color2.b, color2.a) * f_color;
}
]]

local shader = util.buildShaderProgram(vshader, fshader)

-- mac only?
gl.glEnable(pi.GL_POINT_SPRITE)  -- why do I need this?
gl.glEnable(pi.GL_VERTEX_PROGRAM_POINT_SIZE) -- why do I need this?
--

local coord2d_slot  = gl.glGetAttribLocation(shader,"coord2d")
local offset_x_slot = gl.glGetUniformLocation(shader,"offset_x")
local scale_x_slot  = gl.glGetUniformLocation(shader,"scale_x")
local sprite_slot   = gl.glGetUniformLocation(shader,"sprite")
local time_slot   = gl.glGetUniformLocation(shader,"time")
local tex_slot      = pi.gles.glGetUniformLocation(shader,"tex");


--turn on blending for the texture
gl.glEnable(pi.GL_BLEND)
gl.glBlendFunc(pi.GL_SRC_ALPHA, pi.GL_ONE_MINUS_SRC_ALPHA)


fsizes = ffi.new("GLfloat[2]")
gl.glGetFloatv(pi.GL_ALIASED_POINT_SIZE_RANGE, fsizes)
print("size = ", fsizes[0]," , ",fsizes[1])

--gl.glEnable(pi.GL_POINT_SPRITE);


--upload the sprite texture
-- freom the freeimage .h file

ffi.cdef[[

typedef int FREE_IMAGE_FORMAT; enum FREE_IMAGE_FORMAT {
	FIF_UNKNOWN = -1,
	FIF_BMP		= 0,
	FIF_ICO		= 1,
	FIF_JPEG	= 2,
	FIF_JNG		= 3,
	FIF_KOALA	= 4,
	FIF_LBM		= 5,
	FIF_IFF = FIF_LBM,
	FIF_MNG		= 6,
	FIF_PBM		= 7,
	FIF_PBMRAW	= 8,
	FIF_PCD		= 9,
	FIF_PCX		= 10,
	FIF_PGM		= 11,
	FIF_PGMRAW	= 12,
	FIF_PNG		= 13,
	FIF_PPM		= 14,
	FIF_PPMRAW	= 15,
	FIF_RAS		= 16,
	FIF_TARGA	= 17,
	FIF_TIFF	= 18,
	FIF_WBMP	= 19,
	FIF_PSD		= 20,
	FIF_CUT		= 21,
	FIF_XBM		= 22,
	FIF_XPM		= 23,
	FIF_DDS		= 24,
	FIF_GIF     = 25,
	FIF_HDR		= 26,
	FIF_FAXG3	= 27,
	FIF_SGI		= 28,
	FIF_EXR		= 29,
	FIF_J2K		= 30,
	FIF_JP2		= 31,
	FIF_PFM		= 32,
	FIF_PICT	= 33,
	FIF_RAW		= 34
};

typedef struct FIBITMAP FIBITMAP; struct FIBITMAP { void *data; };

typedef uint8_t BYTE;

FREE_IMAGE_FORMAT FreeImage_GetFileType(const char *filename, int size);
FIBITMAP *FreeImage_Load(FREE_IMAGE_FORMAT fif, const char *filename, int flags);
FIBITMAP *FreeImage_ConvertTo32Bits(FIBITMAP *dib);
void FreeImage_Unload(FIBITMAP *dib);
unsigned FreeImage_GetWidth(FIBITMAP *dib);
unsigned FreeImage_GetHeight(FIBITMAP *dib);
BYTE *   FreeImage_GetBits(FIBITMAP *dib);

]]

local img = ffi.load("/usr/local/Cellar/freeimage/3.15.1/lib/libfreeimage.dylib")


print("done");

local textureFile = ffi.string("sprite.png");
local formato = img.FreeImage_GetFileType(textureFile,0);

local imagen  = img.FreeImage_Load(formato, textureFile, 0);
local temp = imagen;
imagen = img.FreeImage_ConvertTo32Bits(imagen);
img.FreeImage_Unload(temp);
local w = img.FreeImage_GetWidth(imagen);
local h = img.FreeImage_GetHeight(imagen);

print("width = ", w, " height = ",h);
local pixels = img.FreeImage_GetBits(imagen);

local ct = "GLubyte["..(w*h*4).."]";
print("count = " , ct);
local image = ffi.new(ct);
for j=0, w*h, 1 do
    image[j*4+0] = pixels[j*4+2]
    image[j*4+1] = pixels[j*4+1]
    image[j*4+2] = pixels[j*4+0]
    image[j*4+3] = pixels[j*4+3]
    --
    --3 is the alpha
end
local R_texId = ffi.new("GLuint[1]");
pi.gles.glGenTextures(1,R_texId);
local texId = R_texId[0]
print("texture id = ", texId)
pi.gles.glActiveTexture(pi.GL_TEXTURE0)
pi.gles.glBindTexture(pi.GL_TEXTURE_2D, texId)
pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_MIN_FILTER, pi.GL_NEAREST)
pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_MAG_FILTER, pi.GL_NEAREST)
pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_WRAP_S, pi.GL_REPEAT);
pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_WRAP_T, pi.GL_REPEAT);
checkError()
pi.gles.glTexImage2D(pi.GL_TEXTURE_2D, 0, pi.GL_RGBA, w,h, 0, pi.GL_RGBA, pi.GL_UNSIGNED_BYTE, image);
checkError()


--create a vbo

--generate the points for the equation
local pointCount = 2000
points = ffi.new("GLfloat["..(pointCount*2).."]")
for i=0,pointCount,1 do
    local x = (i-1000.0)/100.0
    points[i*2+0]=x
    points[i*2+1]=math.sin(x*10.0)/(1.0+x*x)
    --print("point = ", points[i*2+0], " , ",points[i*2+1])
end


local R_vbo = ffi.new("GLuint[1]")
pi.gles.glGenBuffers(1,R_vbo)
local vbo = R_vbo[0]
pi.gles.glBindBuffer(pi.GL_ARRAY_BUFFER, vbo)
checkError()
--tell opengl to copy our arry into the buffer
--size = glfloat is 4 bytes, x 2 of them, x number of points
pi.gles.glBufferData(pi.GL_ARRAY_BUFFER, pointCount*2*4, points, pi.GL_STATIC_DRAW)
checkError()


-- the main drawing loop

for i=0, 60*10, 1 do
    pi.gles.glUseProgram( shader )
    pi.gles.glActiveTexture(pi.GL_TEXTURE0)
    pi.gles.glBindTexture(pi.GL_TEXTURE_2D, texId)
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
    gl.glUniform1f(time_slot, pi.glfw.glfwGetTime())
    
    

    --draw the vertices using our buffer
    gl.glBindBuffer(pi.GL_ARRAY_BUFFER, vbo) --turn on the buffer
    checkError()
    gl.glEnableVertexAttribArray(coord2d_slot) --enable the attribute
    checkError()
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
    checkError()
    gl.glDisableVertexAttribArray(coord2d_slot) -- turn off the attribute
    checkError()
    gl.glBindBuffer(pi.GL_ARRAY_BUFFER, 0) --turn off the buffer
    window.swap()
    checkError()
end
