//
//  Chapter_7_Cube.m
//  Obj-C OpenGL
//

#import "Chapter_7_Cube.h"
#import "vmath.h"

@interface Chapter_7_Cube()
{
	vmath::mat4 proj_matrix;
	GLint mv_location;
	GLint proj_location;
	GLuint position_buffer;
	GLuint index_buffer;
}
@end

@implementation Chapter_7_Cube

- (void)startUp
{
	static const GLchar *vs_source[] = { loadShaderFromSourcefile(@"cube_vertex") };
	static const GLchar *fs_source[] = { loadShaderFromSourcefile(@"cube_fragment") };
	
	renderProgram = glCreateProgram();
	GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(fragmentShader, 1, fs_source, NULL);
	glCompileShader(fragmentShader);
	
	GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vertexShader, 1, vs_source, NULL);
	glCompileShader(vertexShader);
	
	glAttachShader(renderProgram, fragmentShader);
	glAttachShader(renderProgram, vertexShader);
	
	glLinkProgram(renderProgram);
	
	//GET THE UNIFORM LOCATIONS THAT ARE IN THE SHADER SOURCE FILES.
	mv_location = glGetUniformLocation(renderProgram, "mv_matrix");
	proj_location = glGetUniformLocation(renderProgram, "proj_matrix");
	
	
	//		GLuint vao;
	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);
	
	static const GLushort vertex_indices[] =
	{
		0, 1, 2,
		2, 1, 3,
		2, 3, 4,
		4, 3, 5,
		4, 5, 6,
		6, 5, 7,
		6, 7, 0,
		0, 7, 1,
		6, 0, 2,
		2, 4, 6,
		7, 5, 3,
		7, 3, 1
	};
	
	static const GLfloat vertex_positions[] =
	{
		-0.25f, -0.25f, -0.25f,
		-0.25f,  0.25f, -0.25f,
		0.25f, -0.25f, -0.25f,
		0.25f,  0.25f, -0.25f,
		0.25f, -0.25f,  0.25f,
		0.25f,  0.25f,  0.25f,
		-0.25f, -0.25f,  0.25f,
		-0.25f,  0.25f,  0.25f,
	};
	
	glGenBuffers(1, &position_buffer);
	glBindBuffer(GL_ARRAY_BUFFER, position_buffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertex_positions), vertex_positions, GL_STATIC_DRAW);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
	glEnableVertexAttribArray(0);
	
	glGenBuffers(1, &index_buffer);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index_buffer);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(vertex_indices), vertex_indices, GL_STATIC_DRAW);
	
	glEnable(GL_CULL_FACE);
	
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
}

- (void)render:(double)currentTime
{
	static const GLfloat green[] = { 0.0f, 0.25f, 0.0f, 1.0f };
	static const GLfloat one = 1.0f;
	
	glClearBufferfv(GL_COLOR, 0, green);
	glClearBufferfv(GL_DEPTH, 0, &one);
	
	glUseProgram(renderProgram);
	proj_matrix = vmath::perspective(50.0f,
									 (float)info.windowWidth / (float)info.windowHeight,
									 0.1f,
									 1000.0f);
	glUniformMatrix4fv(proj_location, 1, GL_FALSE, proj_matrix);
	
	float f = (float)currentTime * 0.3f;
	vmath::mat4 mv_matrix = vmath::translate(0.0f, 0.0f, -4.0f) *
	vmath::translate(sinf(2.1f * f) * 0.5f,
					 cosf(1.7f * f) * 0.5f,
					 sinf(1.3f * f) * cosf(1.5f * f) * 2.0f) *
	vmath::rotate((float)currentTime * 45.0f, 0.0f, 1.0f, 0.0f) *
	vmath::rotate((float)currentTime * 81.0f, 1.0f, 0.0f, 0.0f);
	glUniformMatrix4fv(mv_location, 1, GL_FALSE, mv_matrix);
	glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_SHORT, 0);
}

-(void)shutDown
{
	
}

@end
