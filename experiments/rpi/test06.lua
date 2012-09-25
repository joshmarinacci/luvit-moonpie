--[[

test loading a ttf font from disk and drawing on screen

]]

local ffi = require("ffi")
local pi = require("moonpiemac")
local util = require("util")
local string = require("string")

ffi.cdef[[
  typedef signed long  FT_Long;
  typedef unsigned int  FT_UInt;
  typedef unsigned long  FT_ULong;
  typedef signed int      FT_Int32;
  typedef unsigned int    FT_UInt32;
  typedef char  FT_String;
  typedef signed int  FT_Int;
  typedef signed short  FT_Short;
  typedef signed long  FT_Pos;
  typedef unsigned short  FT_UShort;
  typedef struct FT_SizeRec_*  FT_Size;
  typedef signed long  FT_Fixed;

  typedef struct FT_FaceRec_*  FT_Face;

  typedef struct  FT_BBox_
  {
    FT_Pos  xMin, yMin;
    FT_Pos  xMax, yMax;

  } FT_BBox;

  typedef struct FT_GlyphSlotRec_*  FT_GlyphSlot;
  typedef struct FT_SubGlyphRec_*  FT_SubGlyph;
  typedef void  (*FT_Generic_Finalizer)(void*  object);
  typedef struct FT_Slot_InternalRec_*  FT_Slot_Internal;


  typedef struct  FT_Vector_
  {
    FT_Pos  x;
    FT_Pos  y;

  } FT_Vector;

  typedef struct  FT_Generic_
  {
    void*                 data;
    FT_Generic_Finalizer  finalizer;

  } FT_Generic;

  typedef enum  FT_Encoding_
  {
    FT_ENCODING_NONE= 0,

  } FT_Encoding;


  typedef enum  FT_Glyph_Format_
  {
    FT_GLYPH_FORMAT_NONE= 0
  } FT_Glyph_Format;
  
  typedef struct FT_CharMapRec_*  FT_CharMap;
  typedef struct  FT_CharMapRec_
  {
    FT_Face      face;
    FT_Encoding  encoding;
    FT_UShort    platform_id;
    FT_UShort    encoding_id;

  } FT_CharMapRec;


  typedef struct  FT_Bitmap_
  {
    int             rows;
    int             width;
    int             pitch;
    unsigned char*  buffer;
    short           num_grays;
    char            pixel_mode;
    char            palette_mode;
    void*           palette;

  } FT_Bitmap;

  typedef struct  FT_Outline_
  {
    short       n_contours;      /* number of contours in glyph        */
    short       n_points;        /* number of points in the glyph      */

    FT_Vector*  points;          /* the outline's points               */
    char*       tags;            /* the points flags                   */
    short*      contours;        /* the contour end points             */

    int         flags;           /* outline masks                      */

  } FT_Outline;

  typedef struct  FT_Bitmap_Size_
  {
    FT_Short  height;
    FT_Short  width;

    FT_Pos    size;

    FT_Pos    x_ppem;
    FT_Pos    y_ppem;

  } FT_Bitmap_Size;

  typedef struct  FT_FaceRec_
  {
    FT_Long           num_faces;
    FT_Long           face_index;

    FT_Long           face_flags;
    FT_Long           style_flags;

    FT_Long           num_glyphs;

    FT_String*        family_name;
    FT_String*        style_name;

    FT_Int            num_fixed_sizes;
    FT_Bitmap_Size*   available_sizes;

    FT_Int            num_charmaps;
    FT_CharMap*       charmaps;

    FT_Generic        generic;

    FT_BBox           bbox;

    FT_UShort         units_per_EM;
    FT_Short          ascender;
    FT_Short          descender;
    FT_Short          height;

    FT_Short          max_advance_width;
    FT_Short          max_advance_height;

    FT_Short          underline_position;
    FT_Short          underline_thickness;

    FT_GlyphSlot      glyph;
    FT_Size           size;
    FT_CharMap        charmap;


    FT_Generic        autohint; 
    void*             extensions;



  } FT_FaceRec;

  
  
  typedef int  FT_Error;
  typedef struct FT_LibraryRec_  *FT_Library;
  FT_Error FT_Init_FreeType( FT_Library  *alibrary );
  
  FT_Error 
  FT_New_Face( FT_Library   library,
               const char*  filepathname,
               FT_Long      face_index,
               FT_Face     *aface );
               
  FT_Error 
  FT_Set_Pixel_Sizes( FT_Face  face,
                      FT_UInt  pixel_width,
                      FT_UInt  pixel_height );

                      
  FT_Error
  FT_Load_Char( FT_Face   face,
                FT_ULong  char_code,
                FT_Int32  load_flags );

  typedef struct  FT_Glyph_Metrics_
  {
    FT_Pos  width;
    FT_Pos  height;

    FT_Pos  horiBearingX;
    FT_Pos  horiBearingY;
    FT_Pos  horiAdvance;

    FT_Pos  vertBearingX;
    FT_Pos  vertBearingY;
    FT_Pos  vertAdvance;

  } FT_Glyph_Metrics;

  typedef struct  FT_GlyphSlotRec_
  {
    FT_Library        library;
    FT_Face           face;
    FT_GlyphSlot      next;
    FT_UInt           reserved;       /* retained for binary compatibility */
    FT_Generic        generic;

    FT_Glyph_Metrics  metrics;
    FT_Fixed          linearHoriAdvance;
    FT_Fixed          linearVertAdvance;
    FT_Vector         advance;

    FT_Glyph_Format   format;

    FT_Bitmap         bitmap;
    FT_Int            bitmap_left;
    FT_Int            bitmap_top;

    FT_Outline        outline;

    FT_UInt           num_subglyphs;
    FT_SubGlyph       subglyphs;

    void*             control_data;
    long              control_len;

    FT_Pos            lsb_delta;
    FT_Pos            rsb_delta;

    void*             other;

    FT_Slot_Internal  internal;

  } FT_GlyphSlotRec;
]]

local freetype = ffi.load("freetype")

-- initialize freetype library
local R_ft = ffi.new("FT_Library[1]");
local ret = freetype.FT_Init_FreeType(R_ft)
print("ret = ", ret)
if(ret > 0) then
  print("Could not init freetype library");
  return 1;
end
local ft = R_ft[0];

--load FreeSans.ttf from disk


local R_face = ffi.new("FT_Face[1]")
print("created a new font face reference")
ret = freetype.FT_New_Face(ft, "foo.ttf", 0, R_face)
if not ret == 0 then
    printf("Could not open the font")
    return 1
end

local face = R_face[0]
print("the face = ",face)

-- set to 48 pt
freetype.FT_Set_Pixel_Sizes(face,0,30)
print("set the size to 14 pixels")

print("num faces = ",face.num_faces)
print("num glyphs = ",face.num_glyphs)
print("family name = ",face.family_name)
print("style name = ",face.style_name)
print("height = ",face.height)
print("max_advance_width = ",face.max_advance_width)
print("max_advance_height = ",face.max_advance_height)
print("size = ",face.size)



-- load the glyph for the letter X
--[[
if(FT_Load_Char(face, 'X', FT_LOAD_RENDER)) {
  fprintf(stderr, "Could not load character 'X'\n");
  return 1;
}
]]

local bit = require("bit")

local FT_LOAD_RENDER              =  bit.lshift( 1 , 2 )
local FT_LOAD_DEFAULT                   =  0x0
local FT_LOAD_NO_SCALE                    =bit.lshift(1, 0 )
FT_LOAD_NO_HINTING                  =bit.lshift(1, 1 )
FT_LOAD_RENDER                      =bit.lshift(1, 2 )
FT_LOAD_NO_BITMAP                  =bit.lshift(1, 3 )
FT_LOAD_VERTICAL_LAYOUT             =bit.lshift(1, 4 )
FT_LOAD_FORCE_AUTOHINT              =bit.lshift(1, 5 )
FT_LOAD_CROP_BITMAP                 =bit.lshift(1, 6 )
FT_LOAD_PEDANTIC                     =bit.lshift(1, 7 )
FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH  =bit.lshift(1, 9 )
FT_LOAD_NO_RECURSE                   =bit.lshift(1, 10 )
FT_LOAD_IGNORE_TRANSFORM             =bit.lshift(1, 11 )
FT_LOAD_MONOCHROME                   =bit.lshift(1, 12 )
FT_LOAD_LINEAR_DESIGN                =bit.lshift(1, 13 )
FT_LOAD_NO_AUTOHINT                  =bit.lshift(1, 15 )
print("render flag = ",FT_LOAD_RENDER)

-- 'X' == 88
-- 'A' == 
ret = freetype.FT_Load_Char(face, 88, FT_LOAD_RENDER)
print("ret = ",ret)
if not ret == 0 then
    print("could not load character 'x'")
end

--[[
-- define a shortcut
FT_GlyphSlot g = face->glyph;
]]

local g = face.glyph
print("glyph = ",g.bitmap)
print("bitmap width = ",g.bitmap.width)
print("bitmap pitch = ",g.bitmap.pitch)
print("bitmap rows = ",g.bitmap.rows)
print("left = ",g.bitmap_left)
print("top = ",g.bitmap_top)
print("metrics = ",g.metrics)
print("metrics width = ",g.metrics.width)
print("metrics height = ",g.metrics.height)
print("metrics linear hori advance = ",g.linearHoriAdvance)
print("metrics linear vert advance = ",g.linearVertAdvance)


local w = 0
local h = 0
for i=32,128,1 do
    ret = freetype.FT_Load_Char(face, i, FT_LOAD_RENDER)
    if not ret == 0 then
        print("could not load character",i)
    end
    w = w + g.bitmap.width
    if(g.bitmap.rows > h) then
        h = g.bitmap.rows
    end
end

print("final width, height = ", w, ",", h)




--[[
for row=0,g.bitmap.rows,1 do
    for col=0,g.bitmap.width,1 do
        local val = g.bitmap.buffer[col+row*g.bitmap.pitch]
        if val > 0 then
--            io.write("*")
        else
--            io.write(".")
        end
            
    end
--    print("")
end
]]

--print("")


window = pi.createFullscreenWindow()


--enable blending
pi.gles.glEnable(pi.GL_BLEND);
pi.gles.glBlendFunc(pi.GL_SRC_ALPHA, pi.GL_ONE_MINUS_SRC_ALPHA);

local R_texId = ffi.new("GLuint[1]")
--pi.gles.glActiveTexture(pi.GL_TEXTURE0)
pi.gles.glGenTextures(1,R_texId)
checkError()
local texId = R_texId[0]
pi.gles.glBindTexture(pi.GL_TEXTURE_2D, texId)
checkError()
--pi.gles.glUniform1i(uniform_tex, 0)
--pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_MIN_FILTER, pi.GL_NEAREST)
--pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_MAG_FILTER, pi.GL_NEAREST)
pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_WRAP_S, pi.GL_CLAMP_TO_EDGE)
pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_WRAP_T, pi.GL_CLAMP_TO_EDGE)
pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_MIN_FILTER, pi.GL_LINEAR)
pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_MAG_FILTER, pi.GL_LINEAR)
checkError()




-- special settings because we are using a 1 byte image
--glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
pi.gles.glPixelStorei(pi.GL_UNPACK_ALIGNMENT, 1)
-- create an empty texture of the right size
pi.gles.glTexImage2D(
    pi.GL_TEXTURE_2D, 
    0, 
    pi.GL_RGBA, 
    w,
    h,
    0, 
    pi.GL_ALPHA,
    pi.GL_UNSIGNED_BYTE,
    nil);

-- copy the glyphs into the texture

local metrics = {}

local x = 0
for i=32,128,1 do
    --load each char
    ret = freetype.FT_Load_Char(face, i, FT_LOAD_RENDER)
    if not ret == 0 then
        print("could not load character",i)
    end
    pi.gles.glTexSubImage2D(
        pi.GL_TEXTURE_2D, 
        0,
        x,
        0,
        g.bitmap.width,
        g.bitmap.rows,
        pi.GL_ALPHA,
        pi.GL_UNSIGNED_BYTE,
        g.bitmap.buffer
    )
    metrics[i] = {
        x=x,
        w=g.bitmap.width,
        h=g.bitmap.rows,
    }
    x = x + g.bitmap.width
end

print("finished loading the glyphs")


local vshader_source = [[
attribute vec4 Position;
attribute vec2 TextureCoords;
uniform mat4 projection;
uniform vec2 xy;
varying vec2 uv;

mat4 translate(float x, float y, float z)
{
    return mat4(
        vec4(1.0, 0.0, 0.0, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(0.0, 0.0, 1.0, 0.0),
        vec4(x,   y,   z,   1.0)
    );
}

void main()
{
    gl_Position = translate(xy.x,xy.y,0.0) * Position *  projection ; 
    uv = vec2(Position.x,Position.y);
//    uv = vec2(TextureCoords.x,TextureCoords.y);
    uv = TextureCoords;
}
]]

local fshader_source = [[
uniform sampler2D tex;
varying vec2 uv;
void main()
{
    vec3 color0 = vec3(0.0,0.0,0.0);
    vec3 color1 = vec3(1.0,1.0,1.0);
    vec4 color2 = texture2D(tex, vec2(uv.x,uv.y));
    gl_FragColor = vec4(0.0,0.0,0.0, color2.a);
}
]]

local prog = util.buildShaderProgram(vshader_source, fshader_source)

local positionSlot   = pi.gles.glGetAttribLocation(prog,"Position");
checkError()
pi.gles.glEnableVertexAttribArray(positionSlot)
checkError()

-- it appears that if this variable is unused it will be stripped out of the code
-- so then the enable call will fail with an 'invalid value' error.
local coordSlot      = pi.gles.glGetAttribLocation(prog,"TextureCoords");
checkError()
pi.gles.glEnableVertexAttribArray(coordSlot)
checkError()
showProgramLog(prog)

--local colorSlot      = pi.gles.glGetUniformLocation(prog,"color");
local projectionSlot = pi.gles.glGetUniformLocation(prog,"projection");
local xySlot         = pi.gles.glGetUniformLocation(prog,"xy");
local texSlot        = pi.gles.glGetUniformLocation(prog,"tex");
checkError()


local count = 0;
local projection = util.loadOrthoMatrix(0,window.width,0,window.height,-1,1)



local textstring = "PENNY penny"

       local fx = 0
       local fo = 0.02
       local fh = 1
       local size_w = 30
       local size_h = 30
while true do
   pi.gles.glViewport(0,0,window.width, window.height)
   pi.gles.glClearColor(1,1,1,1)
   pi.gles.glClear( pi.GL_COLOR_BUFFER_BIT )
   checkError()

   local xoff = 0
   for i=1, #textstring, 1 do
       local n = string.byte(textstring,i)
       --local n = 65
       
       
       local fx = metrics[n].x/w
       local fo = metrics[n].w/w
       local fh = metrics[n].h/h
       local size_w = metrics[n].w
       local size_h = metrics[n].h
       local arr = ffi.new("float[10]",  fx,0,  fx,fh,  fx+fo,fh,  fx+fo,0,  fx,0)
       local vertexArray = ffi.new("float[15]", 0,0,0, 0,size_h,0, size_w,size_h,0, size_w,0,0, 0,0,0 )
       
       pi.gles.glUniform2f(xySlot, xoff,100.0)
       pi.gles.glUniformMatrix4fv(projectionSlot,  1, pi.GL_FALSE, projection )
       pi.gles.glVertexAttribPointer(positionSlot, 3, pi.GL_FLOAT, pi.GL_FALSE, 0, vertexArray )
       pi.gles.glVertexAttribPointer(coordSlot,    2, pi.GL_FLOAT, pi.GL_FALSE, 0, arr )
       pi.gles.glUniform1i(texSlot, 0)
       pi.gles.glDrawArrays( pi.GL_TRIANGLE_STRIP, 0, 5 )
       checkError()
       xoff = xoff + metrics[n].w
       --xoff = xoff + 30
   end
   
   
   window.swap()
   checkError()
   count = count + 1
   if(count == 60*20) then --wait for 10 seconds at 60fps
        break
   end
end


print("done with everything")

