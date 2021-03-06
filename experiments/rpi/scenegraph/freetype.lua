local ffi = require("ffi")
local Font = require("Font")
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
  
  
  typedef signed long  FT_F26Dot6;
  FT_Error FT_Set_Char_Size(FT_Face face,
    FT_F26Dot6 char_width,
    FT_F26Dot6 char_height,
    FT_UInt horiz_resolution,
    FT_UInt vert_resolution
    );
]]

local freetype = ffi.load("freetype")

local FT = {}

-- initialize freetype library
local R_ft = ffi.new("FT_Library[1]");
local ret = freetype.FT_Init_FreeType(R_ft)
print("ret = ", ret)
if(ret > 0) then
  print("Could not init freetype library");
  return 1;
end
local ft = R_ft[0];
FT.ft = ft

local bit = require("bit")


FT.FT_LOAD_RENDER              =  bit.lshift( 1 , 2 )
FT.FT_LOAD_DEFAULT                   =  0x0
FT.FT_LOAD_NO_SCALE                    =bit.lshift(1, 0 )
FT.FT_LOAD_NO_HINTING                  =bit.lshift(1, 1 )
FT.FT_LOAD_RENDER                      =bit.lshift(1, 2 )

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


--calculate the width and height of the font

FT.freetype=freetype

FT.fonts = {}
FT.fonts['default'] = Font:new("ssp-reg.ttf","default",14)
FT.fonts['default'].FT = FT
FT.fonts['bold'] = Font:new("ssp-reg.ttf","bold",14)
FT.fonts['bold'].FT = FT


FT.getFont = function(name,size)
    return FT.fonts[name]
end
FT.loadFont = function(file,name,size)
    local fnt = Font:new(file,name,size)
    fnt.FT = FT
    return fnt
end
return FT


