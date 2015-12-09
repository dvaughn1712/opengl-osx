//
//  Chapter_7_Rectangles.m
//  Obj-C OpenGL
//

#import "Chapter_7_Rectangles.h"
@interface Chapter_7_Rectangles()
{
	GLuint square_buffer;
	GLuint square_vao;
}
@end
@implementation Chapter_7_Rectangles

- (void)startUp
{
	
	static const GLfloat square_vertices[] = {
		-1.0f, -1.0f, 0.0f, 1.0f,
		 1.0f, -1.0f, 0.0f, 1.0f,
		 1.0f,	1.0f, 0.0f, 1.0f,
		-1.0f,  1.0f, 0.0f, 1.0f
	};
	
	static const GLfloat instance_colors[] =  {
		1.0f, 0.0f, 0.0f, 1.0f,
		0.0f, 1.0f, 0.0f, 1.0f,
		0.0f, 0.0f, 1.0f, 1.0f,
		1.0f, 1.0f, 0.0f, 0.0f
	};
	
	static const GLfloat instance_positions[] = {
		-2.0f, -2.0f, 0.0f, 0.0f,
		 2.0f, -2.0f, 0.0f, 0.0f,
		 2.0f,  2.0f, 0.0f, 0.0f,
		-2.0f,  2.0f, 0.0f, 0.0f
	};
	
	GLuint offset = 0;
	
	glGenVertexArrays(1, &square_vao);
	glGenBuffers(1, &square_buffer);
	glBindVertexArray(square_vao);
	glBindBuffer(GL_ARRAY_BUFFER, square_buffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(square_vertices) + sizeof(instance_colors) + sizeof(instance_positions), NULL, GL_STATIC_DRAW);
	glBufferSubData(GL_ARRAY_BUFFER, offset, sizeof(square_vertices), square_vertices);
	offset += sizeof(square_vertices);
	glBufferSubData(GL_ARRAY_BUFFER, offset, sizeof(instance_colors), instance_colors);
	offset += sizeof(instance_colors);
	glBufferSubData(GL_ARRAY_BUFFER, offset, sizeof(instance_positions), instance_positions);
	offset += sizeof(instance_positions);
	
	glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, 0);
	glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, 0, (GLvoid *)sizeof(square_vertices));
	glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, 0, (GLvoid *)(sizeof(square_vertices) + sizeof(instance_colors)));
	
	glEnableVertexAttribArray(0);
	glEnableVertexAttribArray(1);
	glEnableVertexAttribArray(2);
	
	glVertexAttribDivisor(1, 1);
	glVertexAttribDivisor(2, 1);
	
	renderProgram = glCreateProgram();
	
	static const GLchar *vs_source[] = { loadShaderFromSourcefile(@"rectangle_vertex") };
	static const GLchar *fs_source[] = { loadShaderFromSourcefile(@"rectangle_fragment") };
	
	GLuint square_vs = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(square_vs, 1, vs_source, NULL);
	glCompileShader(square_vs);
	glAttachShader(renderProgram, square_vs);
	logShader(square_vs);
	
	GLuint square_fs = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(square_fs, 1, fs_source, NULL);
	glCompileShader(square_fs);
	glAttachShader(renderProgram, square_fs);
	logShader(square_fs);
	
	glLinkProgram(renderProgram);
	glDeleteShader(square_vs);
	glDeleteShader(square_fs);
}

- (void)render:(double)currentTime
{
	static const GLfloat black[] = { 0.0f, 0.0f, 0.0f, 0.0f };
	glClearBufferfv(GL_COLOR, 0, black);
	
	glUseProgram(renderProgram);
	glBindVertexArray(square_vao);
	glDrawArraysInstanced(GL_TRIANGLE_FAN, 0, 4, 4);
}

- (void)shutDown
{
	glDeleteProgram(renderProgram);
	glDeleteBuffers(1, &square_buffer);
	glDeleteVertexArrays(1, &vao);
}

@end
