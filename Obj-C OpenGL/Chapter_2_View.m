//
//  Chapter_2_View.m
//  Obj-C OpenGL
//


#import "Chapter_2_View.h"

@interface Chapter_2_View()
{
	GLuint renderProgram;
	GLuint vao;
}
@end

@implementation Chapter_2_View

- (void)startUp {
	
	static const GLchar *vs_source[] = {
		"#version 410 core														\n"
		"void main(void)														\n"
		"{																		\n"
		"	const vec4 vertices[3] = vec4[3](vec4( 0.25, -0.25, 0.5, 1.0),		\n"
		"									 vec4(-0.25, -0.25, 0.5, 1.0),		\n"
		"									 vec4( 0.25,  0.25, 0.5, 1.0));		\n"
		"																		\n"
		"	gl_Position = vertices[gl_VertexID];								\n"
		"}																		\n"
		"																		\n"
	};
	
	static const GLchar *fs_source[] =  {
		"#version 410 core														\n"
		"out vec4 color;														\n"
		"																		\n"
		"void main(void)														\n"
		"{																		\n"
		"	color = vec4(0.0, 0.8, 1.0, 1.0);									\n"
		"}																		\n"
		"																		\n"
	};
	
	GLuint vertexShader, fragmentShader;
	vertexShader = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vertexShader, 1, vs_source, NULL);
	glCompileShader(vertexShader);
	logShader(vertexShader);
	
	fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(fragmentShader, 1, fs_source, NULL);
	glCompileShader(fragmentShader);
	logShader(fragmentShader);
	
	renderProgram = glCreateProgram();
	glAttachShader(renderProgram, vertexShader);
	glAttachShader(renderProgram, fragmentShader);
	glLinkProgram(renderProgram);
	
	glDeleteShader(vertexShader);
	glDeleteShader(fragmentShader);
	
	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);
}

- (void)render:(double)currentTime {
	
	const GLfloat color[] = { (float)sin(currentTime) * 0.5f + 0.5f,
		(float)cos(currentTime) * 0.5f + 0.5f
	};
	glClearBufferfv(GL_COLOR, 0 , color);
	
//	static const GLfloat red[] = { 0.7f, 0.0f, 0.0f, 1.0f };
//	glClearBufferfv(GL_COLOR, 0, red);
	
	glUseProgram(renderProgram);
	glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)shutDown {
	glDeleteVertexArrays(1, &vao);
	glDeleteProgram(renderProgram);
}

@end













