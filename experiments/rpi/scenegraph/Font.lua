ffi = require("ffi")
pi = require("moonpie")

local Font = {
    inited = false,
    FT = nil
}
Font.__index = Font

function Font:init()
    if(self.inited) then return end
    self.inited = true
    print("initing a font with name = ", self.name, " size = ",self.size)
    local R_face = ffi.new("FT_Face[1]")
    --print("created a new font face reference")
    ret = self.FT.freetype.FT_New_Face(self.FT.ft, "ssp-reg.ttf", 0, R_face)
    if not ret == 0 then
        printf("Could not open the font")
        return 1
    end
    
    local face = R_face[0]
    self.face = face
--    print("the face = ",face)
    
    
--    print("num faces = ",face.num_faces)
--    print("num glyphs = ",face.num_glyphs)
--    print("family name = ",face.family_name)
--    print("style name = ",face.style_name)
--    print("height = ",face.height)
--    print("max_advance_width = ",face.max_advance_width)
--    print("max_advance_height = ",face.max_advance_height)
--    print("size = ",face.size)
    
    self.FT.freetype.FT_Set_Pixel_Sizes(face,0,self.size)
    ret = self.FT.freetype.FT_Load_Char(face, 97, self.FT.FT_LOAD_RENDER)
    if not ret == 0 then
        print("could not load character 'a'")
    end
    
    local g = face.glyph
    
    local w = 0
    local h = 0
    for i=32,128,1 do
        ret = self.FT.freetype.FT_Load_Char(face, i, self.FT.FT_LOAD_RENDER)
        if not ret == 0 then
            print("could not load character",i)
        end
        w = w + g.bitmap.width
        if(g.bitmap.rows > h) then
            h = g.bitmap.rows
        end
    end
    self.w = w
    self.h = h
    
    --print("final width, height = ", self.w, ",", self.h)
    
    
    --set up the opengl texture
    
    --setup the font text first
    --pi.gles.glEnable(pi.GL_BLEND);
    --pi.gles.glBlendFunc(pi.GL_SRC_ALPHA, pi.GL_ONE_MINUS_SRC_ALPHA);
    checkError()
    
    local R_texId = ffi.new("GLuint[1]")
    --pi.gles.glActiveTexture(pi.GL_TEXTURE0)
    pi.gles.glGenTextures(1,R_texId)
    checkError()
    self.texId = R_texId[0]
    pi.gles.glBindTexture(pi.GL_TEXTURE_2D, self.texId)
    checkError()
    --pi.gles.glUniform1i(uniform_tex, 0)
    --pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_MIN_FILTER, pi.GL_NEAREST)
    --pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_MAG_FILTER, pi.GL_NEAREST)
    pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_WRAP_S, pi.GL_CLAMP_TO_EDGE)
    pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_WRAP_T, pi.GL_CLAMP_TO_EDGE)
    pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_MIN_FILTER, pi.GL_LINEAR)
    pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_MAG_FILTER, pi.GL_LINEAR)
    
    pi.gles.glPixelStorei(pi.GL_UNPACK_ALIGNMENT, 1)
    checkError()
    -- create an empty texture of the right size
    pi.gles.glTexImage2D(
        pi.GL_TEXTURE_2D, 
        0, 
        pi.GL_ALPHA,  -- internal format
        self.w,   -- width of texture
        self.h,   -- height of texture
        0,            -- border?
        pi.GL_ALPHA,  -- kind of pixel data
        pi.GL_UNSIGNED_BYTE,  -- format of pixel data
        nil);
    checkError()
    
    -- copy the glyphs into the texture
    
    local metrics = {}
    
    local x = 0
    for i=32,128,1 do
        --load each char
        ret = self.FT.freetype.FT_Load_Char(self.face, i, self.FT.FT_LOAD_RENDER)
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
        checkError()
        metrics[i] = {
            x=x,
            w=g.bitmap.width,
            h=g.bitmap.rows,
            bx=g.metrics.horiBearingX/64,
            by=g.metrics.horiBearingY/64,
            advance=g.metrics.horiAdvance/64,
        }
        x = x + g.bitmap.width
    end
    
    checkError();
    self.metrics = metrics
    checkError();
    print("finished loading the glyphs")
    
end

function Font:new(name,size) 
    return setmetatable({name=name,size=size},Font)
end


return Font
