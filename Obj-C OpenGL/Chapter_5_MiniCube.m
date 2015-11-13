//
//  Chapter_5_Cube.m
//  Obj-C OpenGL
//

#import "Chapter_5_MiniCube.h"
#import "vmath.h"

@interface Chapter_5_MiniCube()
{
	vmath::mat4 proj_matrix;
	GLint mv_location;
	GLint proj_location;
	GLuint global_buffer;
}
@end


@implementation Chapter_5_MiniCube

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
	
	//		GLuint buffer;
	
	static const GLfloat vertex_positions[] = {
		-0.25f,  0.25f, -0.25f,
		-0.25f, -0.25f, -0.25f,
		0.25f, -0.25f, -0.25f,
		
		0.25f, -0.25f, -0.25f,
		0.25f,  0.25f, -0.25f,
		-0.25f,  0.25f, -0.25f,
		
		0.25f, -0.25f, -0.25f,
		0.25f, -0.25f,  0.25f,
		0.25f,  0.25f, -0.25f,
		
		0.25f, -0.25f,  0.25f,
		0.25f,  0.25f,  0.25f,
		0.25f,  0.25f, -0.25f,
		
		0.25f, -0.25f,  0.25f,
		-0.25f, -0.25f,  0.25f,
		0.25f,  0.25f,  0.25f,
		
		-0.25f, -0.25f,  0.25f,
		-0.25f,  0.25f,  0.25f,
		0.25f,  0.25f,  0.25f,
		
		-0.25f, -0.25f,  0.25f,
		-0.25f, -0.25f, -0.25f,
		-0.25f,  0.25f,  0.25f,
		
		-0.25f, -0.25f, -0.25f,
		-0.25f,  0.25f, -0.25f,
		-0.25f,  0.25f,  0.25f,
		
		-0.25f, -0.25f,  0.25f,
		0.25f, -0.25f,  0.25f,
		0.25f, -0.25f, -0.25f,
		
		0.25f, -0.25f, -0.25f,
		-0.25f, -0.25f, -0.25f,
		-0.25f, -0.25f,  0.25f,
		
		-0.25f,  0.25f, -0.25f,
		0.25f,  0.25f, -0.25f,
		0.25f,  0.25f,  0.25f,
		
		0.25f,  0.25f,  0.25f,
		-0.25f,  0.25f,  0.25f,
		-0.25f,  0.25f, -0.25f
	};
	
	glGenBuffers(1, &global_buffer);
	glBindBuffer(GL_ARRAY_BUFFER, global_buffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertex_positions), vertex_positions, GL_STATIC_DRAW);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
	glEnableVertexAttribArray(0);
	
	glEnable(GL_CULL_FACE);
	glFrontFace(GL_CW);
	
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
}

- (void)render:(double)currentTime
{
	static const GLfloat green[] = { 0.0f, 0.25f, 0.0f, 1.0f };
	glClearBufferfv(GL_COLOR, 0, green);
	static const GLfloat one = 1.0f;
	glClearBufferfv(GL_DEPTH, 0, &one);
	
//	glViewport(0, 0, info.windowWidth, info.windowHeight);
	
	glUseProgram(renderProgram);
	glUniformMatrix4fv(proj_location, 1, GL_FALSE, proj_matrix);
	
	
	int i = 0;
	for (i = 0; i < 24; i++ ) {
		float f = (float)i + (float)currentTime * 0.3f;
		
		vmath::mat4 mv_matrix = vmath::translate(0.0f, 0.0f, -6.0f) *
		vmath::rotate((float)currentTime * 45.0f, 0.0f, 1.0f, 0.0f) *
		vmath::rotate((float)currentTime * 21.0f, 1.0f, 0.0f, 0.0f) *
		vmath::translate(sinf(2.1f * f) * 2.0f,
						 cosf(1.7f * f) * 2.0f,
						 sinf(1.3f * f) * cosf(1.5f * f) * 2.0f
						 );
		glUniformMatrix4fv(mv_location, 1, GL_FALSE, mv_matrix);
		glDrawArrays(GL_TRIANGLES, 0, 36);
	}
}

- (void)shutDown
{
	
}

- (void)onResize:(int)width :(int)height
{
	float aspect = width / height;
	proj_matrix = vmath::perspective(50.0f, aspect, 0.1f, 1000.0f);
}

@end
