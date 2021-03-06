#ifndef foo_h__
#define foo_h__

#include "EGL/egl.h"

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

#endif
