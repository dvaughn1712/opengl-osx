//
//  Chapter_7_Springmass.m
//  Obj-C OpenGL
//
//////// THIS EXAMPLE DOES NOT WORK BUT THE .CPP FILE THAT IS IN sb6/src DOES NOT WORK EITHER.
//////// HOWEVER, IT IS THE MOST ACCURATE THAT I CAN MAKE IT IN COMPARISON TO THE .CPP FILE GIVEN.

#import "Chapter_7_Springmass.h"
@interface Chapter_7_Springmass()
{
	GLuint vao[2];
	GLuint vbo[5];
	GLuint index_buffer;
	GLuint pos_tbo[2];
	GLuint update_program;
	GLuint c_loc;
	GLuint iteration_index;
	
	bool draw_points;
	bool draw_lines;
	int iterations_per_frame;
}
@end

enum BUFFER_TYPE_t
{
	POSITION_A,
	POSITION_B,
	VELOCITY_A,
	VELOCITY_B,
	CONNECTION
};

enum
{
	POINTS_X	= 50,
	POINTS_Y	= 50,
	POINTS_TOTAL = (POINTS_X * POINTS_Y),
	CONNECTIONS_TOTAL = (POINTS_X - 1) * POINTS_Y + (POINTS_Y - 1) * POINTS_X
};

@implementation Chapter_7_Springmass

- (void)startUp
{
	iteration_index = 0;
	update_program = 0;
	renderProgram = 0;
	draw_lines = true;
	draw_points = true;
	iterations_per_frame = 16;
	
	int i, j, n = 0;
	[self loadShaders];
	
	vmath::vec4 *initial_positions = new vmath::vec4 [POINTS_TOTAL];
	vmath::vec3 *initial_velocities = new vmath::vec3 [POINTS_TOTAL];
	vmath::ivec4 *connection_vectors = new vmath::ivec4 [POINTS_TOTAL];
	
	for (j = 0; j < POINTS_Y; j++) {
		float fj = (float)j / (float)POINTS_Y;
		for (i = 0; i < POINTS_X; i++) {
			float fi = (float)i / (float)POINTS_X;
			
			initial_positions[n] = vmath::vec4((fi - 0.5f) * (float)POINTS_X, (fj - 0.5f) * (float)POINTS_Y,
											   0.6f * sinf(fi) * cosf(fj), 1.0f);
			initial_velocities[n] = vmath::vec3(0.0f);
			connection_vectors[n] = vmath::ivec4(-1);
			
			if (j != (POINTS_Y - 1)) {
				if (i != 0) {
					connection_vectors[n][0] = n - 1;
				}
				if (j != 0) {
					connection_vectors[n][1] = n - POINTS_X;
				}
				if (i != (POINTS_X - 1)) {
					connection_vectors[n][2] = n + 1;
				}
				if (j != (POINTS_Y - 1)) {
					connection_vectors[n][3] = n + POINTS_X;
				}
			}
			n++;
		}
	}
	
	glGenVertexArrays(2, vao);
	glGenBuffers(5, vbo);
	
	for (i = 0; i < 2; i++) {
		glBindVertexArray(vao[i]);
		
		glBindBuffer(GL_ARRAY_BUFFER, vbo[POSITION_A + i]);
		glBufferData(GL_ARRAY_BUFFER, POINTS_TOTAL * sizeof(vmath::vec4), initial_positions, GL_DYNAMIC_COPY);
		glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, NULL);
		glEnableVertexAttribArray(0);
		
		glBindBuffer(GL_ARRAY_BUFFER, vbo[VELOCITY_A + i]);
		glBufferData(GL_ARRAY_BUFFER, POINTS_TOTAL * sizeof(vmath::vec3), initial_velocities, GL_DYNAMIC_COPY);
		glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
		glEnableVertexAttribArray(1);
		
		glBindBuffer(GL_ARRAY_BUFFER, vbo[CONNECTION]);
		glBufferData(GL_ARRAY_BUFFER, POINTS_TOTAL * sizeof(vmath::ivec4), connection_vectors, GL_STATIC_DRAW);
		glVertexAttribIPointer(2, 4, GL_INT, 0, NULL);
		glEnableVertexAttribArray(2);
	}
	
	delete [] initial_positions;
	delete [] initial_velocities;
	delete [] connection_vectors;
	
	glGenTextures(2, pos_tbo);
	glBindTexture(GL_TEXTURE_BUFFER, pos_tbo[0]);
	glTexBuffer(GL_TEXTURE_BUFFER, GL_RGBA32F, vbo[POSITION_A]);
	glBindTexture(GL_TEXTURE_BUFFER, pos_tbo[1]);
	glTexBuffer(GL_TEXTURE_BUFFER, GL_RGBA32F, vbo[POSITION_B]);
	
	int lines = (POINTS_X - 1) * POINTS_Y + (POINTS_Y - 1) * POINTS_X;
	
	glGenBuffers(1, &index_buffer);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index_buffer);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, lines * 2 * sizeof(int), NULL, GL_STATIC_DRAW);
	
	int *e = (int *)glMapBufferRange(GL_ELEMENT_ARRAY_BUFFER, 0, lines * 2 * sizeof(int), GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
	
	for (j = 0; j < POINTS_Y; j++) {
		for (i = 0; i < POINTS_X - 1; i++) {
			*e++ = i + j * POINTS_X;
			*e++ = 1 + i + j * POINTS_X;
		}
	}
	for (i = 0; i < POINTS_X; i++) {
		for (j = 0; j < POINTS_Y - 1; j++) {
			*e++ = i + j * POINTS_X;
			*e++ = POINTS_X + i + j * POINTS_X;
		}
	}
	glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);
}

- (void)render:(double)currentTime
{
	int i;
	glUseProgram(update_program);
	glEnable(GL_RASTERIZER_DISCARD);
	
	for (i = iterations_per_frame; i != 0; --i) {
		glBindVertexArray(vao[iteration_index & 1]);
		glBindTexture(GL_TEXTURE_BUFFER, pos_tbo[iteration_index & 1]);
		
		iteration_index++;
		glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, vbo[POSITION_A * (iteration_index & 1)]);
		glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 1, vbo[VELOCITY_A + (iteration_index & 1)]);
		glBeginTransformFeedback(GL_POINTS);
		glDrawArrays(GL_POINTS, 0,  POINTS_TOTAL);
		glEndTransformFeedback();
	}
	
	glDisable(GL_RASTERIZER_DISCARD);
	
	static const GLfloat black[] = { 0.0f, 0.0f, 0.0f, 0.0f };
	glViewport(0, 0, info.windowWidth, info.windowHeight);
	glClearBufferfv(GL_COLOR, 0, black);
	
	glUseProgram(renderProgram);
	
	if (draw_points) {
		glPointSize(4.0f);
		glDrawArrays(GL_POINTS, 0, POINTS_TOTAL);
	}
	if (draw_lines) {
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index_buffer);
		glDrawElements(GL_LINES, CONNECTIONS_TOTAL * 2, GL_UNSIGNED_INT, NULL);
	}
}

- (void)shutDown
{
	glDeleteProgram(update_program);
	glDeleteBuffers(5, vbo);
	glDeleteVertexArrays(2, vao);
}

- (void)loadShaders
{
	GLuint vs, vs2, fs;
	
	static const GLchar *vs_source[] = { loadShaderFromSourcefile(@"media/shaders/springmass/update.vs.glsl") };
	
	vs = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vs, 1, vs_source, NULL);
	glCompileShader(vs);
	
	if (update_program) {
		glDeleteProgram(update_program);
	}
	update_program = glCreateProgram();
	glAttachShader(update_program, vs);
	logShader(vs);
	
	static const char *tf_varyings[] = {
		"tf_position_mass",
		"tf_velocity"
	};
	
	glTransformFeedbackVaryings(update_program, 2, tf_varyings, GL_SEPARATE_ATTRIBS);
	glLinkProgram(update_program);
	glDeleteShader(vs);
	
	static const GLchar *vs_source2[] = { loadShaderFromSourcefile(@"media/shaders/springmass/render.vs.glsl") };
	static const GLchar *fs_source[] = { loadShaderFromSourcefile(@"media/shaders/springmass/render.fs.glsl") };
	vs2 = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vs2, 1, vs_source2, NULL);
	glCompileShader(vs2);
	fs = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(fs, 1, fs_source, NULL);
	
	logShader(vs2);
	logShader(fs);
	
	if (renderProgram) {
		glDeleteProgram(renderProgram);
	}
	renderProgram = glCreateProgram();
	glAttachShader(renderProgram, vs);
	glAttachShader(renderProgram, fs);
	
	glLinkProgram(renderProgram);
}

- (void)onKey:(int)key action:(int)action
{
	if (action)
	{
		switch (key)
		{
			case 'R': [self loadShaders];
				break;
			case 'L': draw_lines = !draw_lines;
				break;
			case 'P': draw_points = !draw_points;
				break;
		}
	}
}

@end
