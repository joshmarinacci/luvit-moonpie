attribute vec4 Position;
uniform mat4 projection;
uniform vec2 xy;

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
/*    gl_Position = projection * translate(0.5,0.0,0.0) * Position ; */
    gl_Position = translate(xy.x,xy.y,0.0) * Position *  projection; 
}

