--[[

test loading an image from disk with FreeImage

]]

local ffi = require("ffi")
--local pi = require("moonpie")
--local util = require("util")


-- freom the freeimage .h file

ffi.cdef[[

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

]]

local img = ffi.load("/usr/local/Cellar/freeimage/3.15.1/lib/libfreeimage.dylib")


print("done");

local textureFile = ffi.string("foo.png");
local formato = img.FreeImage_GetFileType(textureFile,0);

local imagen  = img.FreeImage_Load(formato, textureFile, 0);
local temp = imagen;
imagen = img.FreeImage_ConvertTo32Bits(imagen);
img.FreeImage_Unload(temp);
local w = img.FreeImage_GetWidth(imagen);
local h = img.FreeImage_GetHeight(imagen);

print("width = ", w, " height = ",h);
local pixels = img.FreeImage_GetBits(imagen);

print("got the pixels ",pixels);
for j=0, w*h, 1 do
print(pixels[j*4+0],pixels[j*4+1],pixels[j*4+2],pixels[j*4+3]);
--		textura[j*4+0]= pixeles[j*4+2];
--		textura[j*4+1]= pixeles[j*4+1];
--		textura[j*4+2]= pixeles[j*4+0];
--		textura[j*4+3]= pixeles[j*4+3];
--		//cout<<j<<": "<<textura[j*4+0]<<"**"<<textura[j*4+1]<<"**"<<textura[j*4+2]<<"**"<<textura[j*4+3]<<endl;
end

--[[

FREE_IMAGE_FORMAT formato = FreeImage_GetFileType(textureFile,0);//Automatocally detects the format(from over 20 formats!)
	FIBITMAP* imagen = FreeImage_Load(formato, textureFile);
	
	FIBITMAP* temp = imagen;
	imagen = FreeImage_ConvertTo32Bits(imagen);
	FreeImage_Unload(temp);
	
	int w = FreeImage_GetWidth(imagen);
	int h = FreeImage_GetHeight(imagen);
	cout<<"The size of the image is: "<<textureFile<<" es "<<w<<"*"<<h<<endl; //Some debugging code
	
	GLubyte* textura = new GLubyte[4*w*h];
	char* pixeles = (char*)FreeImage_GetBits(imagen);
	//FreeImage loads in BGR format, so you need to swap some bytes(Or use GL_BGR).
	
	for(int j= 0; j<w*h; j++){
		textura[j*4+0]= pixeles[j*4+2];
		textura[j*4+1]= pixeles[j*4+1];
		textura[j*4+2]= pixeles[j*4+0];
		textura[j*4+3]= pixeles[j*4+3];
		//cout<<j<<": "<<textura[j*4+0]<<"**"<<textura[j*4+1]<<"**"<<textura[j*4+2]<<"**"<<textura[j*4+3]<<endl;
	}
	
	//Now generate the OpenGL texture object 
	
	glGenTextures(1, &amp;texturaID);
	glBindTexture(GL_TEXTURE_2D, texturaID);
	glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA, w, h, 0, GL_RGBA,GL_UNSIGNED_BYTE,(GLvoid*)textura );
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	
	GLenum huboError = glGetError();
	if(huboError){
		
		cout<<"There was an error loading the texture"<<endl;
	}
	

]]
