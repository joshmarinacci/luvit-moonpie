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
void   glTexParameteri (GLenum target, GLenum pname, GLint param);
void   glActiveTexture (GLenum texture);

void   glBlendFunc (GLenum sfactor, GLenum dfactor);
void   glPixelStorei (GLenum pname, GLint param);

GLenum glGetError (void);

]]

