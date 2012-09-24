local ffi = require("ffi");

function checkError()
    local err = pi.gles.glGetError();
    if(err == pi.GL_NO_ERROR) then
        --print("no error")
    end
    if(err == pi.GL_INVALID_ENUM) then
        print("Error: invalid enum")
        print("doing debug: ", debug.getinfo(2).currentline)
    end
    if(err == pi.GL_INVALID_VALUE) then
        print("Error: invalid value")
        print("doing debug: ", debug.getinfo(2).currentline)
    end
    if(err == pi.GL_INVALID_OPERATION) then
        print("Error: invalid operation")
        print("doing debug: ", debug.getinfo(2).currentline)
    end
    if(err == pi.GL_OUT_OF_MEMORY) then
        print("Error: out of memory")
        print("doing debug: ", debug.getinfo(2).currentline)
    end
end


function showProgramLog(prog)
   local log = ffi.new("char[1024]")
   pi.gles.glGetProgramInfoLog(prog,1024,NULL,log);
   print("got a log: ",ffi.string(log))
end

function buildShaderProgram(vshader_source, fshader_source)
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

return {
    loadOrthoMatrix = loadOrthoMatrix,
    buildShaderProgram = buildShaderProgram,
    sleep = sleep,
}
