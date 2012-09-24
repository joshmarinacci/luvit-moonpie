local ffi = require("ffi")

--[[

Note that the constants EGLAPI and EGLAPIENTRY get #defined to empty. It's
really just here for Win32 support. Ick.
ex
EGLAPI EGLDisplay EGLAPIENTRY eglGetDisplay(EGLNativeDisplayType display_id);
goes to
EGLDisplay eglGetDisplay(EGLNativeDisplayType display_id);
]]


require("gl2headers")

-- eglplatform.h
ffi.cdef[[
typedef void *EGLNativeDisplayType;
typedef void *EGLNativePixmapType;
typedef void *EGLNativeWindowType;
typedef khronos_int32_t EGLint;
]]

-- egl.h
ffi.cdef[[
typedef unsigned int EGLBoolean;
typedef unsigned int EGLenum;
typedef void *EGLConfig;
typedef void *EGLContext;
typedef void *EGLDisplay;
typedef void *EGLSurface;
typedef void *EGLClientBuffer;

EGLDisplay eglGetDisplay(EGLNativeDisplayType display_id);
EGLBoolean eglInitialize(EGLDisplay dpy, EGLint *major, EGLint *minor);
EGLBoolean eglSwapBuffers(EGLDisplay dpy, EGLSurface surface);

]]





--joshpi.h
ffi.cdef[[
typedef struct
{
   uint32_t screen_width;
   uint32_t screen_height;
   
// OpenGL|ES objects
   EGLDisplay display;
   EGLSurface surface;
   EGLContext context;
} PWindow;

extern void foo(void);
extern PWindow *createDefaultWindow(void);
extern int get_mouse(int sw, int sh, int *outx, int *outy);





]]


-- extras for this demo
ffi.cdef[[
typedef struct {
    float Position[3];
    float Color[4];
} Vertex;


]]


function sleep(n)
  os.execute("sleep " .. tonumber(n))
end


pi = {}


app = ffi.load("./libjoshpi.so")
pi.GL_VERTEX_SHADER        = 0x8B31
pi.GL_FRAGMENT_SHADER      = 0x8B30
GL_ARRAY_BUFFER         = 0x8892
GL_STATIC_DRAW          = 0x88E4
pi.GL_COLOR_BUFFER_BIT     = 0x00004000
pi.GL_FLOAT                = 0x1406
pi.GL_FALSE                = 0
GL_TRUE                 = 1

GL_POINTS               =          0x0000
GL_LINES                =          0x0001
GL_LINE_LOOP            =          0x0002
GL_LINE_STRIP           =          0x0003
GL_TRIANGLES            =          0x0004
pi.GL_TRIANGLE_STRIP       =          0x0005
GL_TRIANGLE_FAN         =          0x0006

pi.GL_UNSIGNED_BYTE        = 0x1401

GL_COMPILE_STATUS       = 0x8B81
GL_INFO_LOG_LENGTH      = 0x8B84
GL_SHADER_SOURCE_LENGTH = 0x8B88
GL_SHADER_COMPILER      = 0x8DFA

pi.GL_NO_ERROR          = 0
pi.GL_INVALID_ENUM      = 0x0500
pi.GL_INVALID_VALUE     = 0x0501
pi.GL_INVALID_OPERATION = 0x0502
pi.GL_OUT_OF_MEMORY     = 0x0505

pi.GL_TEXTURE_2D               =      0x0DE1
pi.GL_CULL_FACE                =      0x0B44
pi.GL_BLEND                    =      0x0BE2
pi.GL_DITHER                   =      0x0BD0
pi.GL_STENCIL_TEST             =      0x0B90
pi.GL_DEPTH_TEST               =      0x0B71
pi.GL_SCISSOR_TEST             =      0x0C11
pi.GL_POLYGON_OFFSET_FILL      =      0x8037
pi.GL_SAMPLE_ALPHA_TO_COVERAGE =      0x809E
pi.GL_SAMPLE_COVERAGE          =      0x80A0


-- texture stuff
pi.GL_NEAREST                  =      0x2600
pi.GL_LINEAR                   =      0x2601
pi.GL_TEXTURE_MAG_FILTER       =      0x2800
pi.GL_TEXTURE_MIN_FILTER       =      0x2801
pi.GL_TEXTURE_WRAP_S           =      0x2802
pi.GL_TEXTURE_WRAP_T           =      0x2803
pi.GL_REPEAT                   =      0x2901
pi.GL_CLAMP_TO_EDGE            =      0x812F
pi.GL_MIRRORED_REPEAT          =      0x8370
-- texture units
pi.GL_TEXTURE0                 =      0x84C0

-- image formats
pi.GL_RGBA                     =      0x1908


gles = ffi.load("/opt/vc/lib/libGLESv2.so")
egl = ffi.load("/opt/vc/lib/libEGL.so")
openmaxil = ffi.load("/opt/vc/lib/libopenmaxil.so")
bcm_host = ffi.load("/opt/vc/lib/libbcm_host.so")
vcos = ffi.load("/opt/vc/lib/libvcos.so")

print("loaded ffi");




-- code stolen from  https://github.com/malkia/ufo/blob/master/samples/OpenGLES2/test.lua
-- this code doesn't work right on the RaspberryPi. It returns 'Compiled' in the log
-- whether or not it actually compiled correctly
local function validate_shader(shader) 


    local int = ffi.new("GLint[1]")
    gles.glGetShaderiv( shader, GL_COMPILE_STATUS, int )
    if(int[0] == 0) then
        print("everything is fine")
        return
    end
    print("there is an error")
    gles.glGetShaderiv(shader, GL_INFO_LOG_LENGTH, int)
    local length = int[0]
    if(length > 1) then
        local buffer = ffi.new( "char[?]", length )
        gles.glGetShaderInfoLog( shader, length, int, buffer )
        print("result = ",ffi.string(buffer))
    end
end
    

local function load_shader(src, type) 
    local shader = gles.glCreateShader(type);
    if shader == 0 then
        error( "glGetError: " .. tonumber( gles.glGetError()) )
    end
    
    local src = ffi.new("char[?]", #src, src)
    local srcs = ffi.new("const char*[1]",src)
    gles.glShaderSource(shader, 1, srcs, nil)
    gles.glCompileShader(shader);
    
    validate_shader(shader)
    print("loaded a shader");
    return shader
end


local function createFullscreenWindow()
    local window = {}
    local w = app.createDefaultWindow()
    print("successfully created a valid open window ", w.screen_width, " ", w.screen_height)
    
    window.window = w;
    window.width = w.screen_width
    window.height = w.screen_height
    window.display = w.display
    window.surface = w.surface
    window.swap = function()
        egl.eglSwapBuffers(w.display, w.surface)
    end
    return window
end

local function getMouseState()
    local state = {}
    
    local R_x = ffi.new("int[1]")
    local R_y = ffi.new("int[1]")
    local b = app.get_mouse(1360,768,R_x, R_y);
    state.buttonCode = b
    state.x = R_x[0]
    state.y = 768-R_y[0]
    return state;
end


pi.gles = gles
pi.createFullscreenWindow = createFullscreenWindow
pi.getMouseState = getMouseState
pi.loadShader = load_shader
pi.egl = egl

return pi
