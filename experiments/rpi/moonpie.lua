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



print("os = " , jit.os )

local LINUX = false
local MAC = false

if jit.os == "Linux" then
    LINUX = true
end


if LINUX then
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
    extern int get_keyboard(int *key, int *state);
    ]]
end


pi = {}

-- copy the header #defines into 'pi'
for i,v in pairs(headers) do
    --print("header = ",i,v)
    pi[i] = v
end

if LINUX then
    app = ffi.load("/home/josh/luvit-moonpie/experiments/rpi/libjoshpi.so")
    gles = ffi.load("/opt/vc/lib/libGLESv2.so")
    egl = ffi.load("/opt/vc/lib/libEGL.so")
    openmaxil = ffi.load("/opt/vc/lib/libopenmaxil.so")
    bcm_host = ffi.load("/opt/vc/lib/libbcm_host.so")
    vcos = ffi.load("/opt/vc/lib/libvcos.so")
end


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
    
    --setup window swap function
    if(MAC) then
        window.swap = function()
            pi.glfw.glfwSwapBuffers();
        end
    end
    if(LINUX) then
        window.swap = function()
            egl.eglSwapBuffers(w.display, w.surface)
        end
    end
    
    --setup keyboard
    if(MAC) then
        pi.key_callback = function(key,state)
            if window.keyboardCallback ~= nil then
                local event = { key=key, state=state}
                window.keyboardCallback(event)
            end
        end
        --disable JIT for this callback to prevent segaults
        jit.off(pi.glfw.glfwSetKeyCallback(ffi.cast("GLFWkeyfun",pi.key_callback)))
    end

    
    -- a few quick debugging tests
    print("vendor = ",     ffi.string(pi.gles.glGetString(pi.GL_VENDOR)))
    print("renderer = ",   ffi.string(pi.gles.glGetString(pi.GL_RENDERER)))
    print("version = ",    ffi.string(pi.gles.glGetString(pi.GL_VERSION)))
    print("shading language version = ",    ffi.string(pi.gles.glGetString(pi.GL_SHADING_LANGUAGE_VERSION)))
    print("extensions = ", ffi.string(pi.gles.glGetString(pi.GL_EXTENSIONS)))
    
    return window
end


local function getKeyboardState()
    local state = {}
    local R_key   = ffi.new("int[1]")
    local R_state = ffi.new("int[1]")
    local k = app.get_keyboard(R_key,R_state);
    state.key = R_key[0]
    state.state = R_state[0]
    return state
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


if(MAC) then
    pi.getTime = function()
        return glfw.glfwGetTime()
    end
end

if(LINUX) then
    ffi.cdef[[
        struct timeval {
           uint32_t sec;
           uint32_t usec;
        };
    
        int gettimeofday(struct timeval *restrict tp, void *restrict tzp);
    ]]
        
    local tp = ffi.new("struct timeval")
    ffi.C.gettimeofday(tp, nil)
    local starttime = tp.sec+(tp.usec/1000000)
    pi.getTime = function()
        ffi.C.gettimeofday(tp, nil)
        local usec = tp.usec/1000000;
        --print("***", tp.sec, tp.usec, " ",usec)
        return tp.sec+usec - starttime
    end
end


pi.gles = gles
pi.createFullscreenWindow = createFullscreenWindow
pi.getMouseState = getMouseState
pi.getKeyboardState = getKeyboardState
pi.loadShader = load_shader
pi.egl = egl
pi.LINUX = LINUX
pi.MAC   = MAC

return pi
