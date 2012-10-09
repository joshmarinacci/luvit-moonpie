package.path = package.path .. ";../?.lua"
local ffi = require("ffi")
local pi = require("moonpie")

-- freom the freeimage .h file

ffi.cdef[[

typedef int32_t BOOL;


typedef int FREE_IMAGE_FORMAT; enum FREE_IMAGE_FORMAT {
	FIF_UNKNOWN = -1,
	FIF_BMP		= 0,
	FIF_ICO		= 1,
	FIF_JPEG	= 2,
	FIF_JNG		= 3,
	FIF_KOALA	= 4,
	FIF_LBM		= 5,
	FIF_IFF = FIF_LBM,
	FIF_MNG		= 6,
	FIF_PBM		= 7,
	FIF_PBMRAW	= 8,
	FIF_PCD		= 9,
	FIF_PCX		= 10,
	FIF_PGM		= 11,
	FIF_PGMRAW	= 12,
	FIF_PNG		= 13,
	FIF_PPM		= 14,
	FIF_PPMRAW	= 15,
	FIF_RAS		= 16,
	FIF_TARGA	= 17,
	FIF_TIFF	= 18,
	FIF_WBMP	= 19,
	FIF_PSD		= 20,
	FIF_CUT		= 21,
	FIF_XBM		= 22,
	FIF_XPM		= 23,
	FIF_DDS		= 24,
	FIF_GIF     = 25,
	FIF_HDR		= 26,
	FIF_FAXG3	= 27,
	FIF_SGI		= 28,
	FIF_EXR		= 29,
	FIF_J2K		= 30,
	FIF_JP2		= 31,
	FIF_PFM		= 32,
	FIF_PICT	= 33,
	FIF_RAW		= 34
};

typedef struct FIBITMAP FIBITMAP; struct FIBITMAP { void *data; };

typedef uint8_t BYTE;

FREE_IMAGE_FORMAT FreeImage_GetFileType(const char *filename, int size);
FIBITMAP *FreeImage_Load(FREE_IMAGE_FORMAT fif, const char *filename, int flags);
FIBITMAP *FreeImage_ConvertTo32Bits(FIBITMAP *dib);
void FreeImage_Unload(FIBITMAP *dib);
unsigned FreeImage_GetWidth(FIBITMAP *dib);
unsigned FreeImage_GetHeight(FIBITMAP *dib);
BYTE *   FreeImage_GetBits(FIBITMAP *dib);


FIBITMAP *FreeImage_ConvertFromRawBits(BYTE *bits, int width, int height, int pitch, unsigned bpp, unsigned red_mask, unsigned green_mask, unsigned blue_mask, BOOL topdown);
BOOL FreeImage_Save(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, const char *filename, int flags);

]]

local img
if (pi.MAC) then
    img = ffi.load("/usr/local/Cellar/freeimage/3.15.1/lib/libfreeimage.dylib")
end
if (pi.LINUX) then
    img = ffi.load("/usr/lib/libfreeimage.so.3")
end

function loadImage(filename)
    local textureFile = ffi.string(filename);
    local formato = img.FreeImage_GetFileType(textureFile,0);
    
    local imagen  = img.FreeImage_Load(formato, textureFile, 0);
    local temp = imagen;
    imagen = img.FreeImage_ConvertTo32Bits(imagen);
    img.FreeImage_Unload(temp);
    local w = img.FreeImage_GetWidth(imagen);
    local h = img.FreeImage_GetHeight(imagen);
    
    print("width = ", w, " height = ",h);
    local pixels = img.FreeImage_GetBits(imagen);
    return {
        width=w,
        height=h,
        pixels=pixels
    };
end

return {
    FT=img,
    loadImage=loadImage,
    FIF_BMP= 0,
}
