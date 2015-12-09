#version 410 core

void main(void) {
	const vec4 verticies[] = vec4(vec4( 0.4, -0.4, 0.5, 1.0),
								  vec4(-0.4, -0.4, 0.5, 1.0),
								  vec4( 0.4,  0.4, 0.5, 1.0),
								  vec4(-0.4,  0.4, 0.5, 1.0));
	gl_Position = verticies[gl_VertexID];
}