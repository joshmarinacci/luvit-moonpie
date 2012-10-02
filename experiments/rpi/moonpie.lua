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


pi = {}

print("os = " , jit.os )

local LINUX = false
local MAC = false

if jit.os == "Linux" then
    LINUX = true
end

if jit.os == "OSX" then
    MAC = true
-- These are copied from glfw.h, but without the #defines
ffi.cdef[[
 
int  glfwInit( void );
int  glfwOpenWindow( int width, int height, int redbits, int greenbits, int bluebits, int alphabits, int depthbits, int stencilbits, int mode );
void glfwSetWindowTitle( const char *title );
void glfwEnable( int token );
void glfwDisable( int token);
void glfwSwapBuffers( void );
void glfwSwapInterval( int interval );
void glfwTerminate( void );
int  glfwGetWindowParam( int param );

int  glfwGetKey( int key );
void glfwGetMousePos( int *xpos, int *ypos );
int  glfwGetMouseButton( int button );

typedef void (* GLFWkeyfun)(int,int);
void glfwSetKeyCallback( GLFWkeyfun cbfun );
void glfwPollEvents( void );

double glfwGetTime( void );
void glfwGetWindowSize( int *width, int *height );



/* opengl stuff */
typedef unsigned int GLenum;
typedef unsigned char GLboolean;
typedef unsigned int GLbitfield;
typedef signed char GLbyte;
typedef short GLshort;
typedef int GLint;
typedef int GLsizei;
typedef unsigned char GLubyte;
typedef unsigned short GLushort;
typedef unsigned int GLuint;
typedef float GLfloat;
typedef float GLclampf;
typedef double GLdouble;
typedef double GLclampd;
typedef void GLvoid;

typedef long GLintptr;
typedef long GLsizeiptr;

extern void glViewport (GLint x, GLint y, GLsizei width, GLsizei height);
extern void glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);
extern void glClear (GLbitfield mask);
extern void glMatrixMode (GLenum mode);
extern void glLoadIdentity (void);
extern void glTranslatef (GLfloat x, GLfloat y, GLfloat z);
extern void glRotatef (GLfloat angle, GLfloat x, GLfloat y, GLfloat z);
extern void glBegin (GLenum mode);
extern void glEnd (void);
extern void glColor3f (GLfloat red, GLfloat green, GLfloat blue);
extern void glVertex3f (GLfloat x, GLfloat y, GLfloat z);

/* GLU.h */
extern void gluPerspective (GLdouble fovy, GLdouble aspect, GLdouble zNear, GLdouble zFar);
extern void gluLookAt (GLdouble eyeX, GLdouble eyeY, GLdouble eyeZ, GLdouble centerX, GLdouble centerY, GLdouble centerZ, GLdouble upX, GLdouble upY, GLdouble upZ);

int printf(const char *fmt, ...);
]]


pi.glfw = ffi.load("/Users/josh/projects/lua/glfw-2.7.6/lib/cocoa/libglfw.dylib");
pi.gles = ffi.load("/System/Library/Frameworks/OpenGL.framework/Libraries/libGL.dylib")

print("gles set", pi.gles);

GLFW_WINDOW      = 0x00010001;
pi.GLFW_STICKY_KEYS = 0x00030002
GLFW_MOUSE_BUTTON_1     = 0
GLFW_MOUSE_BUTTON_2     = 1
GLFW_MOUSE_BUTTON_3     = 2
GLFW_MOUSE_BUTTON_4     = 3
GLFW_MOUSE_BUTTON_5     = 4
GLFW_MOUSE_BUTTON_6     = 5
GLFW_MOUSE_BUTTON_7     = 6
GLFW_MOUSE_BUTTON_8     = 7
GLFW_MOUSE_BUTTON_LAST  = GLFW_MOUSE_BUTTON_8

GLFW_MOUSE_BUTTON_LEFT  = GLFW_MOUSE_BUTTON_1
GLFW_MOUSE_BUTTON_RIGHT = GLFW_MOUSE_BUTTON_2
GLFW_MOUSE_BUTTON_MIDDLE = GLFW_MOUSE_BUTTON_3
pi.GLFW_RELEASE     = 0
pi.GLFW_PRESS       = 1
pi.GLFW_KEY_SPECIAL = 256
pi.GLFW_KEY_ESC     = (pi.GLFW_KEY_SPECIAL+1)
pi.GLFW_AUTO_POLL_EVENTS   =  0x00030006
    
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



-- copy the header #defines into 'pi'
for i,v in pairs(headers) do
    --print("header = ",i,v)
    pi[i] = v
end

if LINUX then
    app = ffi.load("/home/josh/luvit-moonpie/experiments/rpi/libjoshpi.so")
    gles = ffi.load("/opt/vc/lib/libGLESv2.so")
    pi.gles = gles
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
    pi.gles.glGetShaderiv( shader, pi.GL_COMPILE_STATUS, int )
    if(int[0] == 0) then
        print("everything is fine")
        return
    end
    print("there is an error")
    pi.gles.glGetShaderiv(shader, pi.GL_INFO_LOG_LENGTH, int)
    local length = int[0]
    if(length > 1) then
        local buffer = ffi.new( "char[?]", length )
        pi.gles.glGetShaderInfoLog( shader, length, int, buffer )
        print("result = ",ffi.string(buffer))
    end
end
    

local function load_shader(src, type) 
    local shader = pi.gles.glCreateShader(type);
    if shader == 0 then
        error( "glGetError: " .. tonumber( pi.gles.glGetError()) )
    end
    
    local src = ffi.new("char[?]", #src, src)
    local srcs = ffi.new("const char*[1]",src)
    pi.gles.glShaderSource(shader, 1, srcs, nil)
    pi.gles.glCompileShader(shader);
    
    validate_shader(shader)
    print("loaded a shader");
    return shader
end


local function createFullscreenWindow_LINUX()
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

local function createFullscreenWindow_MAC()
    local window = {}
    window.width = 1024;
    window.height = 600;
    
    local ret = pi.glfw.glfwInit();
    if(ret == 0) then
        error("error starting GLFW");
    end

    ret = pi.glfw.glfwOpenWindow(window.width,window.height, 8,8,8,8, 0,0, GLFW_WINDOW)
    if(ret == 0) then
        pi.glfw.glfwTerminate()
        error("error opening GLFW window")
    end
    print("initing early. pi = ", pi)
    
    pi.glfw.glfwSetWindowTitle("Spinning Triangle")
    --glfw.glfwEnable( pi.GLFW_STICKY_KEYS )
    --sync to vertical retrace (60fps usually)
    pi.glfw.glfwSwapInterval( 1 )
    
    pi.key_callback = function(key,state)
        if window.keyboardCallback ~= nil then
            local event = { key=key, state=state}
            window.keyboardCallback(event)
        end
    end
    --disable JIT for this callback to prevent segaults
    jit.off(pi.glfw.glfwSetKeyCallback(ffi.cast("GLFWkeyfun",pi.key_callback)))
    
    print("successfully created a valid open window ", window.width, " ", window.height)
    window.swap = function()
        pi.glfw.glfwSwapBuffers();
    end
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

local function getMouseState_LINUX()
    local state = {}
    
    local R_x = ffi.new("int[1]")
    local R_y = ffi.new("int[1]")
    local b = app.get_mouse(1360,768,R_x, R_y);
    state.buttonCode = b
    state.x = R_x[0]
    state.y = 768-R_y[0]
    return state;
end

local function getMouseState_MAC()
    local R_x = ffi.new("unsigned int[1]", 0)
    local R_y = ffi.new("unsigned int[1]", 0)
    pi.glfw.glfwGetMousePos(R_x, R_y)
    
    local left = pi.glfw.glfwGetMouseButton(GLFW_MOUSE_BUTTON_LEFT)
--    print("x,y = ", R_x[0], " - ", R_y[0])


--    local bwidth =  ffi.new("unsigned int[1]",0)
--    local bheight = ffi.new("unsigned int[1]",0)
--    glfw.glfwGetWindowSize(bwidth, bheight)
--    print("width height ",bwidth[0]," x  ",bheight[0])
    return {
        x=R_x[0],
        y=R_y[0],
        left=(left==1),
        button= 0
    }
end

if(MAC) then
    pi.getTime = function()
        return pi.glfw.glfwGetTime()
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


if LINUX then
    pi.createFullscreenWindow = createFullscreenWindow_LINUX
    pi.getMouseState = getMouseState_LINUX
    pi.getKeyboardState = getKeyboardState
end
if MAC then
    pi.createFullscreenWindow = createFullscreenWindow_MAC
    pi.getMouseState = getMouseState_MAC
    pi.getKeyboardState = function() end
end
pi.loadShader = load_shader
pi.egl = egl
pi.LINUX = LINUX
pi.MAC   = MAC

return pi
