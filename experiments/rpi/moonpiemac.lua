local ffi = require("ffi")


require("gl2headers")

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

pi = {}

glfw = ffi.load("/Users/josh/projects/lua/glfw-2.7.6/lib/cocoa/libglfw.dylib");
gl = ffi.load("/System/Library/Frameworks/OpenGL.framework/Libraries/libGL.dylib")

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


pi.GL_VERTEX_SHADER        = 0x8B31
pi.GL_FRAGMENT_SHADER      = 0x8B30
pi.GL_COMPILE_STATUS       = 0x8B81
pi.GL_INFO_LOG_LENGTH      = 0x8B84
pi.GL_SHADER_SOURCE_LENGTH = 0x8B88
pi.GL_SHADER_COMPILER      = 0x8DFA
pi.GL_COLOR_BUFFER_BIT     = 0x00004000
pi.GL_FLOAT                = 0x1406
pi.GL_FALSE                = 0
pi.GL_TRIANGLE_STRIP       = 0x0005
pi.GL_POINTS               = 0x0000
pi.GL_LINES                = 0x0001
pi.GL_LINE_LOOP            = 0x0002
pi.GL_LINE_STRIP           = 0x0003
pi.GL_TRIANGLES            = 0x0004
pi.GL_TRIANGLE_STRIP       = 0x0005
pi.GL_TRIANGLE_FAN         = 0x0006

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
pi.GL_ALPHA                    =      0x1906
pi.GL_RGB                      =      0x1907
pi.GL_RGBA                     =      0x1908
pi.GL_UNSIGNED_BYTE        = 0x1401


pi.GL_ZERO                     =      0
pi.GL_ONE                      =      1
pi.GL_SRC_ALPHA                =      0x0302
pi.GL_ONE_MINUS_SRC_ALPHA      =      0x0303
pi.GL_UNPACK_ALIGNMENT         =      0x0CF5
pi.GL_ARRAY_BUFFER             =      0x8892


pi.GL_STREAM_DRAW              =      0x88E0
pi.GL_STATIC_DRAW              =      0x88E4
pi.GL_DYNAMIC_DRAW             =      0x88E8

pi.GL_ALIASED_POINT_SIZE_RANGE =      0x846D


--only needed on mac / non-pure es2.0 systems
pi.GL_POINT_SPRITE             =      0x8861
pi.GL_VERTEX_PROGRAM_POINT_SIZE =     0x8642

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
        gles.glGetShaderInfoLog( shader, length, int, buffer )
        print("result = ",ffi.string(buffer))
    end
end
pi.glfw = glfw;

local function createFullscreenWindow()
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


local function getMouseState()
    local R_x = ffi.new("unsigned int[1]", 0)
    local R_y = ffi.new("unsigned int[1]", 0)
    glfw.glfwGetMousePos(R_x, R_y)
    
    local left = glfw.glfwGetMouseButton(GLFW_MOUSE_BUTTON_LEFT)
--    print("x,y = ", R_x[0], " - ", R_y[0])


--    local bwidth =  ffi.new("unsigned int[1]",0)
--    local bheight = ffi.new("unsigned int[1]",0)
--    glfw.glfwGetWindowSize(bwidth, bheight)
--    print("width height ",bwidth[0]," x  ",bheight[0])
    return {
        x=R_x[0],
        y=R_y[0],
        leftdown=(left==1),
        buttonstate= 0
    }
end

pi.gles = gl;

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

pi.createFullscreenWindow = createFullscreenWindow
pi.getMouseState = getMouseState
pi.loadShader = load_shader

return pi;




