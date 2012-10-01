local ffi = require("ffi");
local pi = require("moonpie");


function printStack()
    print("2 = ",debug.getinfo(2).currentline, " ", debug.getinfo(2).source, " ", debug.getinfo(2).short_src)
    print("3 = ",debug.getinfo(3).currentline, " ", debug.getinfo(3).source, " ", debug.getinfo(3).short_src)
    print("4 = ",debug.getinfo(4).currentline, " ", debug.getinfo(4).source, " ", debug.getinfo(4).short_src)
    print("4 = ",debug.getinfo(5).currentline, " ", debug.getinfo(5).source, " ", debug.getinfo(5).short_src)
end

function checkError()
    local err = pi.gles.glGetError();
    if(err == pi.GL_NO_ERROR) then
        --print("no error")
    end
    if(err == pi.GL_INVALID_ENUM) then
        print("Error: invalid enum")
        printStack()
    end
    if(err == pi.GL_INVALID_VALUE) then
        print("Error: invalid value")
        printStack()
    end
    if(err == pi.GL_INVALID_OPERATION) then
        print("Error: invalid operation")
        printStack()
    end
    if(err == pi.GL_OUT_OF_MEMORY) then
        print("Error: out of memory")
        printStack()
    end
end




function showProgramLog(prog)
   local log = ffi.new("char[1024]")
   checkError();
   pi.gles.glGetProgramInfoLog(prog,1024,NULL,log);
   checkError();
   print("shader compiler log: ",ffi.string(log))
end

function buildShaderProgram(vshader_source, fshader_source)
    checkError();
    local prog = pi.gles.glCreateProgram()
    showProgramLog(prog);
    checkError();
    local fshader = pi.loadShader(fshader_source, pi.GL_FRAGMENT_SHADER)
    checkError();
    showProgramLog(prog);
    local vshader = pi.loadShader(vshader_source, pi.GL_VERTEX_SHADER)
    checkError();
    showProgramLog(prog);
    pi.gles.glAttachShader( prog, vshader )
    checkError();
    pi.gles.glAttachShader( prog, fshader )
    checkError();
    pi.gles.glLinkProgram( prog )
    checkError();
    showProgramLog(prog);
    pi.gles.glUseProgram( prog )
    checkError()
    print("built the shader program")
    return prog
end


local function loadOrthoMatrix (left, right, top, bottom, near, far)
    local matrix = ffi.new("GLfloat[16]");
    
    local r_l = right - left;
    local t_b = top - bottom;
    local f_n = far - near;
    local tx = - (right + left) / (right - left);
    local ty = - (top + bottom) / (top - bottom);
    local tz = - (far + near) / (far - near);

    matrix[0] = 2.0 / r_l;
    matrix[1] = 0.0;
    matrix[2] = 0.0;
    matrix[3] = tx;

    matrix[4] = 0.0;
    matrix[5] = 2.0 / t_b;
    matrix[6] = 0.0;
    matrix[7] = ty;

    matrix[8] = 0.0;
    matrix[9] = 0.0;
    matrix[10] = 2.0 / f_n;
    matrix[11] = tz;

    matrix[12] = 0.0;
    matrix[13] = 0.0;
    matrix[14] = 0.0;
    matrix[15] = 1.0;
    return matrix
end

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end


local function floatsToArrayBuffer(points, pointCount, elementSize) 
print("inside floats to array buffer")
    local floatSize = 4 --size of a GLfloat in bytes
    local R_vbo = ffi.new("GLuint[1]")
    pi.gles.glGenBuffers(1,R_vbo)
    local vbo = R_vbo[0]
    pi.gles.glBindBuffer(pi.GL_ARRAY_BUFFER, vbo)
    checkError()
    --tell opengl to copy our arry into the buffer
    --size = glfloat is 4 bytes, x 2 of them, x number of points
    pi.gles.glBufferData(
        pi.GL_ARRAY_BUFFER,
        pointCount*elementSize*floatSize,
        points,
        pi.GL_STATIC_DRAW)
    checkError()
    pi.gles.glBindBuffer(pi.GL_ARRAY_BUFFER, 0) --turn off the buffer
    return vbo
end


local function uploadTexture(image) 
    local ct = "GLubyte["..(image.width*image.height*4).."]";
    print("count = " , ct);
    local buf = ffi.new(ct);
    for j=0, image.width*image.height, 1 do
        buf[j*4+0] = image.pixels[j*4+2]
        buf[j*4+1] = image.pixels[j*4+1]
        buf[j*4+2] = image.pixels[j*4+0]
        buf[j*4+3] = image.pixels[j*4+3]
    end
    
    local R_texId = ffi.new("GLuint[1]");
    pi.gles.glGenTextures(1,R_texId);
    checkError()
    local texId = R_texId[0]
    
    print("texture id = ", texId)
    pi.gles.glActiveTexture(pi.GL_TEXTURE0)
    pi.gles.glBindTexture(pi.GL_TEXTURE_2D, texId)
    pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_MIN_FILTER, pi.GL_LINEAR)
    pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_MAG_FILTER, pi.GL_LINEAR)
    pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_WRAP_S, pi.GL_REPEAT);
    pi.gles.glTexParameteri(pi.GL_TEXTURE_2D, pi.GL_TEXTURE_WRAP_T, pi.GL_REPEAT);
    checkError()
    pi.gles.glTexImage2D(pi.GL_TEXTURE_2D, 
        0, 
        pi.GL_RGBA, 
        image.width,
        image.height,
        0, pi.GL_RGBA, pi.GL_UNSIGNED_BYTE, 
        buf);
    checkError()
    return texId
end

return {
    loadOrthoMatrix = loadOrthoMatrix,
    buildShaderProgram = buildShaderProgram,
    sleep = sleep,
    floatsToArrayBuffer= floatsToArrayBuffer,
    uploadImageAsTexture = uploadTexture,
    
    enablePointSprites = function()
        if(pi.MAC) then
        pi.gles.glEnable(pi.GL_POINT_SPRITE)  -- why do I need this?
        pi.gles.glEnable(pi.GL_VERTEX_PROGRAM_POINT_SIZE) -- why do I need this?
        end
    end

}
