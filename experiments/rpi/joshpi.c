#include <stdio.h>
#include <assert.h>
#include "bcm_host.h"
#include "GLES2/gl2.h"
#include "EGL/egl.h"


#include "joshpi.h"




static PWindow _state, *state=&_state;

static void init_ogl(PWindow *state)
{
   int32_t success = 0;
   EGLBoolean result;
   EGLint num_config;

   static EGL_DISPMANX_WINDOW_T nativewindow;

   DISPMANX_ELEMENT_HANDLE_T dispman_element;
   DISPMANX_DISPLAY_HANDLE_T dispman_display;
   DISPMANX_UPDATE_HANDLE_T dispman_update;
   VC_RECT_T dst_rect;
   VC_RECT_T src_rect;

   static const EGLint attribute_list[] =
   {
      EGL_RED_SIZE, 8,
      EGL_GREEN_SIZE, 8,
      EGL_BLUE_SIZE, 8,
      EGL_ALPHA_SIZE, 8,
      EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
      EGL_NONE
   };
   
   static const EGLint context_attributes[] = 
   {
      EGL_CONTEXT_CLIENT_VERSION, 2,
      EGL_NONE
   };

   EGLConfig config;

   // get an EGL display connection
   state->display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
   assert(state->display!=EGL_NO_DISPLAY);

   // initialize the EGL display connection
   result = eglInitialize(state->display, NULL, NULL);
   assert(EGL_FALSE != result);

   // get an appropriate EGL frame buffer configuration
   result = eglChooseConfig(state->display, attribute_list, &config, 1, &num_config);
   assert(EGL_FALSE != result);

   // choose opengl 2
   result = eglBindAPI(EGL_OPENGL_ES_API);
   assert(EGL_FALSE != result);
   
   // create an EGL rendering context
   state->context = eglCreateContext(state->display, config, EGL_NO_CONTEXT, context_attributes);
   assert(state->context!=EGL_NO_CONTEXT);

   // create an EGL window surface
   success = graphics_get_display_size(0 /* LCD */, &state->screen_width, &state->screen_height);
   assert( success >= 0 );
   printf("display size = %d x %d\n",state->screen_width, state->screen_height);

   dst_rect.x = 0;
   dst_rect.y = 0;
   dst_rect.width = state->screen_width;
   dst_rect.height = state->screen_height;
      
   src_rect.x = 0;
   src_rect.y = 0;
   src_rect.width = state->screen_width << 16;
   src_rect.height = state->screen_height << 16;        

   dispman_display = vc_dispmanx_display_open( 0 /* LCD */);
   dispman_update = vc_dispmanx_update_start( 0 );
         
   dispman_element = vc_dispmanx_element_add ( dispman_update, dispman_display,
      0/*layer*/, &dst_rect, 0/*src*/,
      &src_rect, DISPMANX_PROTECTION_NONE, 0 /*alpha*/, 0/*clamp*/, 0/*transform*/);
      
   nativewindow.element = dispman_element;
   nativewindow.width = state->screen_width;
   nativewindow.height = state->screen_height;
   vc_dispmanx_update_submit_sync( dispman_update );
      
   state->surface = eglCreateWindowSurface( state->display, config, &nativewindow, NULL );
   assert(state->surface != EGL_NO_SURFACE);

   // connect the context to the surface
   result = eglMakeCurrent(state->display, state->surface, state->surface, state->context);
   assert(EGL_FALSE != result);

   
   
   //now we have a real opengl context so we can do stuff
   glClearColor(0.8,0.9,0.2,1);
   glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
   eglSwapBuffers(state->display, state->surface);
   
   printf("got to the real opengl context");
   

/*
   //init the shaders
   const GLchar *vshader_source;
   loadFile("SimpleVertex.glsl",&vshader_source);
   state->vshader = glCreateShader(GL_VERTEX_SHADER);
   glShaderSource(state->vshader, 1, &vshader_source, 0);
   glCompileShader(state->vshader);

   const GLchar *fshader_source;
   loadFile("SimpleFragment.glsl",&fshader_source);
   state->fshader = glCreateShader(GL_FRAGMENT_SHADER);
   glShaderSource(state->fshader, 1, &fshader_source, 0);
   glCompileShader(state->fshader);
   //printf("compiled the vertex shader %s",vshader_source);
   
   //link into a shader program
   state->program = glCreateProgram();
   glAttachShader(state->program, state->vshader);
   glAttachShader(state->program, state->fshader);
   glLinkProgram(state->program);
   
   
    
   //use the program
   glUseProgram(state->program);
    
   //save references to the parameters for the shaders
   state->positionSlot = glGetAttribLocation(state->program, "Position");
   state->colorSlot = glGetAttribLocation(state->program, "SourceColor");
   glEnableVertexAttribArray(state->positionSlot);
   glEnableVertexAttribArray(state->colorSlot);
   */
}

void foo(void)
{
    puts("Hello, I'm a shared library");
}

PWindow* createDefaultWindow() 
{    
   printf("creating a default window\n");
   bcm_host_init();
   // Clear application state
   memset( state, 0, sizeof( *state ) );
      
   // Start OGLES
   init_ogl(state);    
   return state;
}
