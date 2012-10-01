local ffi = require("ffi")
-- khrplatform.h
ffi.cdef[[
typedef int32_t                 khronos_int32_t;
typedef uint32_t                khronos_uint32_t;
typedef int64_t                 khronos_int64_t;
typedef uint64_t                khronos_uint64_t;
typedef signed   long  int      khronos_ssize_t;
typedef unsigned char           khronos_uint8_t;
typedef float                   khronos_float_t;
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
void   glDisableVertexAttribArray (GLuint index);
void   glGetProgramInfoLog (GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog);

void   glGenBuffers  (GLsizei n, GLuint* buffers );
void   glGenTextures (GLsizei n, GLuint* textures);

void   glBindBuffer  (GLenum target, GLuint buffer );
void   glBindTexture (GLenum target, GLuint texture);

void   glBufferData (GLenum target, GLsizeiptr size, const GLvoid* data, GLenum usage);
void   glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);
void   glClear (GLbitfield mask);
void   glEnable (GLenum cap);
void   glViewport (GLint x, GLint y, GLsizei width, GLsizei height);
void   glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr);

void   glVertexAttrib4f (GLuint indx, GLfloat x, GLfloat y, GLfloat z, GLfloat w);
void   glDrawElements (GLenum mode, GLsizei count, GLenum type, const GLvoid* indices);
void   glGetShaderiv (GLuint shader, GLenum pname, GLint* params);
int    glGetUniformLocation (GLuint program, const GLchar* name);

void   glUniform1f (GLint location, GLfloat x);
void   glUniform1i (GLint location, GLint   x);
void   glUniform2f (GLint location, GLfloat x, GLfloat y);
void   glUniform3f (GLint location, GLfloat x, GLfloat y, GLfloat z);
void   glUniform4f (GLint location, GLfloat x, GLfloat y, GLfloat z, GLfloat w);
void   glUniformMatrix4fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat* value);

void   glDrawArrays (GLenum mode, GLint first, GLsizei count);
void   glGetShaderInfoLog (GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* infolog);


void   glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* pixels);
void   glTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid* pixels);
void   glTexParameteri (GLenum target, GLenum pname, GLint param);
void   glActiveTexture (GLenum texture);

void   glBlendFunc (GLenum sfactor, GLenum dfactor);
void   glPixelStorei (GLenum pname, GLint param);

GLenum glGetError (void);
void   glGetFloatv (GLenum pname, GLfloat* params);

]]


return {
    -- basics
    GL_FLOAT                = 0x1406,
    GL_FALSE                = 0,
    GL_TRUE                 = 1,


    -- blending modes
    GL_SRC_ALPHA    = 0x0302,
    GL_ZERO         = 0,
    GL_ONE          = 1,
    GL_SRC_ALPHA    = 0x0302,
    GL_ONE_MINUS_SRC_ALPHA      = 0x0303,
    -- ??
    GL_UNPACK_ALIGNMENT         = 0x0CF5,

    -- image formats
    GL_ALPHA                    = 0x1906,
    GL_RGB                      = 0x1907,
    GL_RGBA                     = 0x1908,
    GL_UNSIGNED_BYTE            = 0x1401,
    
    --shader stuff
    GL_VERTEX_SHADER            = 0x8B31,
    GL_FRAGMENT_SHADER          = 0x8B30,
    
    GL_COMPILE_STATUS           = 0x8B81,
    GL_INFO_LOG_LENGTH          = 0x8B84,
    GL_SHADER_SOURCE_LENGTH     = 0x8B88,
    GL_SHADER_COMPILER          = 0x8DFA,
    
    --buffer types
    GL_ARRAY_BUFFER             = 0x8892,
    --drawing types
    GL_STATIC_DRAW              = 0x88E4,
    
    --enums
    GL_TEXTURE_2D               =      0x0DE1,
    GL_TEXTURE0                 =      0x84C0,
    GL_COLOR_BUFFER_BIT         =  0x00004000,
    
    --geometry
    GL_POINTS                   =      0x0000,
    GL_LINES                    =      0x0001,
    GL_LINE_LOOP                =      0x0002,
    GL_LINE_STRIP               =      0x0003,
    GL_TRIANGLES                =      0x0004,
    GL_TRIANGLE_STRIP           =      0x0005,
    GL_TRIANGLE_FAN             =      0x0006,
    
    
    --enable states
    GL_BLEND                    =      0x0BE2,

    -- texture stuff
    GL_NEAREST                  =      0x2600,
    GL_LINEAR                   =      0x2601,
    GL_TEXTURE_MAG_FILTER       =      0x2800,
    GL_TEXTURE_MIN_FILTER       =      0x2801,
    GL_TEXTURE_WRAP_S           =      0x2802,
    GL_TEXTURE_WRAP_T           =      0x2803,
    GL_REPEAT                   =      0x2901,
    GL_CLAMP_TO_EDGE            =      0x812F,
    GL_MIRRORED_REPEAT          =      0x8370,
    
    --error codes
    GL_NO_ERROR          = 0,
    GL_INVALID_ENUM      = 0x0500,
    GL_INVALID_VALUE     = 0x0501,
    GL_INVALID_OPERATION = 0x0502,
    GL_OUT_OF_MEMORY     = 0x0505
    
}
