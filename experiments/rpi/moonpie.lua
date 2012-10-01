local ffi = require("ffi")

--[[

Note that the constants EGLAPI and EGLAPIENTRY get #defined to empty. It's
really just here for Win32 support. Ick.
ex
EGLAPI EGLDisplay EGLAPIENTRY eglGetDisplay(EGLNativeDisplayType display_id);
goes to
EGLDisplay eglGetDisplay(EGLNativeDisplayType display_id);
]]


headers = require("gl2headers")

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

-- copy the header #defines into 'pi'
for i,v in pairs(headers) do
    --print("header = ",i,v)
    pi[i] = v
end
app = ffi.load("/home/josh/luvit-moonpie/experiments/rpi/libjoshpi.so")
gles = ffi.load("/opt/vc/lib/libGLESv2.so")
egl = ffi.load("/opt/vc/lib/libEGL.so")
openmaxil = ffi.load("/opt/vc/lib/libopenmaxil.so")
bcm_host = ffi.load("/opt/vc/lib/libbcm_host.so")
vcos = ffi.load("/opt/vc/lib/libvcos.so")


-- code stolen from  https://github.com/malkia/ufo/blob/master/samples/OpenGLES2/test.lua
-- this code doesn't work right on the RaspberryPi. It returns 'Compiled' in the log
-- whether or not it actually compiled correctly
local function validate_shader(shader) 


    local int = ffi.new("GLint[1]")
    gles.glGetShaderiv( shader, pi.GL_COMPILE_STATUS, int )
    if(int[0] == 0) then
        print("everything is fine")
        return
    end
    print("there is an error")
    gles.glGetShaderiv(shader, pi.GL_INFO_LOG_LENGTH, int)
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
