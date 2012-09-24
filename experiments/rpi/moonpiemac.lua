local ffi = require("ffi")

-- These are copied from glfw.h, but without the #defines
ffi.cdef[[
 
int  glfwInit( void );
int  glfwOpenWindow( int width, int height, int redbits, int greenbits, int bluebits, int alphabits, int depthbits, int stencilbits, int mode );
void glfwSetWindowTitle( const char *title );
void glfwEnable( int token );
void glfwSwapBuffers( void );
void glfwSwapInterval( int interval );
void glfwTerminate( void );
int  glfwGetWindowParam( int param );
int  glfwGetKey( int key );
void glfwGetMousePos( int *xpos, int *ypos );
int glfwGetMouseButton( int button );
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
GLFW_STICKY_KEYS = 0x00030002
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

local function createFullscreenWindow()
    local window = {}
    window.width = 640;
    window.height = 480;
    
    local ret = glfw.glfwInit();
    if(ret == 0) then
        error("error starting GLFW");
    end

    ret = glfw.glfwOpenWindow(window.width,window.height, 0,0,0,0, 0,0, GLFW_WINDOW)
    if(ret == 0) then
        glfw.glfwTerminate()
        error("error opening GLFW window")
    end

    glfw.glfwSetWindowTitle("Spinning Triangle")
    glfw.glfwEnable( GLFW_STICKY_KEYS )
    --sync to vertical retrace (60fps usually)
    glfw.glfwSwapInterval( 1 )
    
    print("successfully created a valid open window ", window.width, " ", window.height)
    window.swap = function()
        glfw.glfwSwapBuffers();
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
pi.createFullscreenWindow = createFullscreenWindow
pi.getMouseState = getMouseState

return pi;




