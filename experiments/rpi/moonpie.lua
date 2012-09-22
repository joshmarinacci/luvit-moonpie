local ffi = require("ffi")

--[[

Note that the constants EGLAPI and EGLAPIENTRY get #defined to empty. It's
really just here for Win32 support. Ick.
ex
EGLAPI EGLDisplay EGLAPIENTRY eglGetDisplay(EGLNativeDisplayType display_id);
goes to
EGLDisplay eglGetDisplay(EGLNativeDisplayType display_id);
]]

-- khrplatform.h
ffi.cdef[[
typedef int32_t                 khronos_int32_t;
typedef uint32_t                khronos_uint32_t;
typedef int64_t                 khronos_int64_t;
typedef uint64_t                khronos_uint64_t;
typedef signed   long  int      khronos_ssize_t;
typedef unsigned char          khronos_uint8_t;
typedef          float         khronos_float_t;
]]

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

-- GLES2/gl2.h
ffi.cdef[[

typedef void             GLvoid;
typedef char             GLchar;
typedef unsigned int     GLenum;
typedef int              GLsizei;
typedef unsigned int     GLuint;
typedef int              GLint;
typedef khronos_uint8_t  GLubyte;
typedef khronos_ssize_t  GLsizeiptr;
typedef khronos_float_t  GLfloat;
typedef khronos_float_t  GLclampf;
typedef unsigned int     GLbitfield;
typedef unsigned char    GLboolean;


GLuint glCreateShader (GLenum type);
void   glShaderSource (GLuint shader, GLsizei count, const GLchar** string, const GLint* length);
void   glCompileShader (GLuint shader);
GLuint glCreateProgram (void);
void   glAttachShader (GLuint program, GLuint shader);
void   glLinkProgram (GLuint program);
void   glUseProgram (GLuint program);
int    glGetAttribLocation (GLuint program, const GLchar* name);
void   glEnableVertexAttribArray (GLuint index);
void   glGenBuffers (GLsizei n, GLuint* buffers);
void   glBindBuffer (GLenum target, GLuint buffer);
void   glBufferData (GLenum target, GLsizeiptr size, const GLvoid* data, GLenum usage);
void   glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);
void   glClear (GLbitfield mask);
void   glViewport (GLint x, GLint y, GLsizei width, GLsizei height);
void   glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr);
void   glDrawElements (GLenum mode, GLsizei count, GLenum type, const GLvoid* indices);
void   glGetShaderiv (GLuint shader, GLenum pname, GLint* params);
int    glGetUniformLocation (GLuint program, const GLchar* name);
void   glUniform1f (GLint location, GLfloat x);
void   glUniform4f (GLint location, GLfloat x, GLfloat y, GLfloat z, GLfloat w);
void   glDrawArrays (GLenum mode, GLint first, GLsizei count);

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


app = ffi.load("./libjoshpi.so")
GL_VERTEX_SHADER        = 0x8B31
GL_FRAGMENT_SHADER      = 0x8B30
GL_ARRAY_BUFFER         = 0x8892
GL_STATIC_DRAW          = 0x88E4
GL_COLOR_BUFFER_BIT     = 0x00004000
GL_FLOAT                = 0x1406
GL_FALSE                = 0
GL_TRUE                 = 1

GL_POINTS               =          0x0000
GL_LINES                =          0x0001
GL_LINE_LOOP            =          0x0002
GL_LINE_STRIP           =          0x0003
GL_TRIANGLES            =          0x0004
GL_TRIANGLE_STRIP       =          0x0005
GL_TRIANGLE_FAN         =          0x0006

GL_UNSIGNED_BYTE        = 0x1401

GL_COMPILE_STATUS       = 0x8B81
GL_INFO_LOG_LENGTH      = 0x8B84
GL_SHADER_SOURCE_LENGTH = 0x8B88
GL_SHADER_COMPILER      = 0x8DFA

gles = ffi.load("/opt/vc/lib/libGLESv2.so")
egl = ffi.load("/opt/vc/lib/libEGL.so")
openmaxil = ffi.load("/opt/vc/lib/libopenmaxil.so")
bcm_host = ffi.load("/opt/vc/lib/libbcm_host.so")
vcos = ffi.load("/opt/vc/lib/libvcos.so")

print("loaded ffi");




-- code stolen from  https://github.com/malkia/ufo/blob/master/samples/OpenGLES2/test.lua
local function validate_shader(shader) 
    local int = ffi.new("GLint[1]")
    gles.glGetShaderiv(shader, GL_INFO_LOG_LENGTH, int)
    local length = int[0]
    if length <= 0 then
        return
    end
   gles.glGetShaderiv( shader, GL_COMPILE_STATUS, int )
   local success = int[0]
   if success == GL_TRUE then
      return
   end
   local buffer = ffi.new( "char[?]", length )
   gles.glGetShaderInfoLog( shader, length, int, buffer )
   error( ffi.string(buffer) )
end
    

local function load_shader(src, type) 
    local shader = gles.glCreateShader(type);
    if shader == 0 then
        error( "glGetError: " .. tonumber( gles.glGetError()) )
    end
    
    local src = ffi.new("char[?]", #src, src)
    --local l = ffi.new("GLchar [?]",#vshader_source+1,vshader_source)
    local srcs = ffi.new("const char*[1]",src)
    --local length = ffi.new("GLint[1]",#vshader_source);
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
    return window
end

local function getMouseState()
    local state = {}
end

pi = {}

pi.gles = gles
pi.createFullscreenWindow = createFullscreenWindow
pi.getMouseState = getMouseState

return pi
