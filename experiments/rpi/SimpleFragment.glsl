precision mediump float;
uniform vec3 color;

void main()
{
  gl_FragColor = vec4(0.0, 1.0, 0.5, 1.0);
  //gl_FragColor = SourceColor;
  //gl_FragColor = vec4(color.r,color.g,color.b,1.0);
}
