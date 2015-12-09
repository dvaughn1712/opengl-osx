//
//  Chapter_7_Asteroids.m
//  Obj-C OpenGL
//

//////////////ASTEROIDS DOES NOT WORK AND I DO NOT HAVE ENOUGH KNOWLEDGE YET TO MAKE IT WORK//////////

#import "Chapter_7_Asteroids.h"

enum {
	NUM_DRAWS = 50000
};

struct DrawArraysIndirectCommand {
	GLuint count;
	GLuint primCount;
	GLuint first;
	GLuint baseInstance;
};

struct {
	GLint time;
	GLint view_matrix;
	GLint proj_matrix;
	GLint viewproj_matrix;
} uniforms;

enum MODE {
	MODE_FIRST,
	MODE_MULTI_DRAW = 0,
	MODE_SEPARATE_DRAWS,
	MODE_MAX = MODE_SEPARATE_DRAWS
};

@interface Chapter_7_Asteroids()
{
	sb6::object object;
	GLuint indirect_draw_buffer;
	GLuint draw_index_buffer;
	MODE mode;
	bool paused;
	bool vsync;
}

- (void)loadShaders;
- (void)onKey:(int)key withAction:(int)action;
@end

@implementation Chapter_7_Asteroids

- (void)startUp
{
	[self loadShaders];
	object = loadObjectFromSourceFile(@"asteroids");
	
	glGenBuffers(1, &indirect_draw_buffer);
	glBindBuffer(GL_DRAW_INDIRECT_BUFFER, indirect_draw_buffer);
	glBufferData(GL_DRAW_INDIRECT_BUFFER, NUM_DRAWS * sizeof(DrawArraysIndirectCommand), NULL, GL_STATIC_DRAW);
	DrawArraysIndirectCommand *cmd = (DrawArraysIndirectCommand *)glMapBufferRange(GL_DRAW_INDIRECT_BUFFER, 0, NUM_DRAWS * sizeof(DrawArraysIndirectCommand), GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
	
	int i = 0;
	for (i = 0; i < NUM_DRAWS; i++) {
		object.get_sub_object_info(i % object.get_sub_object_count(), cmd[i].first, cmd[i].count);
		cmd[i].primCount = 1;
		cmd[i].baseInstance = i;
	}
	
	glUnmapBuffer(GL_DRAW_INDIRECT_BUFFER);
	
	glBindVertexArray(object.get_vao());
	glGenBuffers(1, &draw_index_buffer);
	glBindBuffer(GL_ARRAY_BUFFER, draw_index_buffer);
	glBufferData(GL_ARRAY_BUFFER, NUM_DRAWS * sizeof(GLuint), NULL, GL_STATIC_DRAW);
	
	GLuint *draw_index = (GLuint *)glMapBufferRange(GL_ARRAY_BUFFER, 0, NUM_DRAWS * sizeof(GLuint), GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
	
	for (i = 0; i < NUM_DRAWS; i++) {
		draw_index[i] = i;
	}
	
	glUnmapBuffer(GL_ARRAY_BUFFER);
	
	glVertexAttribIPointer(10, 1, GL_UNSIGNED_INT, 0, NULL);
	glVertexAttribDivisor(10, 1);
	glEnableVertexAttribArray(10);
	
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	
	glEnable(GL_CULL_FACE);
}

- (void)render:(double)currentTime
{
	static const float one = 1.0f;
	static const float black[] = { 0.0f, 0.0f, 0.0f, 0.0f };
	
	static double last_time = 0.0;
	static double total_time = 0.0;
	
	if (!paused) {
		total_time += (currentTime - last_time);
	}
	last_time = currentTime;
	float t = float(currentTime);
	
	glViewport(0, 0, info.windowWidth, info.windowHeight);
	glClearBufferfv(GL_COLOR, 0, black);
	glClearBufferfv(GL_DEPTH, 0, &one);
	
	const vmath::mat4 view_matrix = vmath::lookat(vmath::vec3(100.0f * cosf(t * 0.023f), 100.0f * cosf(t * 0.023f), 300.0f * sinf(t * 0.037f) - 600.0f), vmath::vec3(0.0f, 0.0f, 260.0f), vmath::normalize(vmath::vec3(0.1f - cosf(t *0.1f) * 0.3f, 1.0f, 0.0f)));
	
	const vmath::mat4 proj_matrix = vmath::perspective(50.0f, (float)info.windowWidth / (float)info.windowHeight, 1.0f, 2000.0f);
	
	glUseProgram(renderProgram);
	glUniform1f(uniforms.time, t);
	glUniformMatrix4fv(uniforms.view_matrix, 1, GL_FALSE, view_matrix);
	glUniformMatrix4fv(uniforms.proj_matrix, 1, GL_FALSE, proj_matrix);
	glUniformMatrix4fv(uniforms.viewproj_matrix, 1, GL_FALSE, proj_matrix * view_matrix);
	
	glBindVertexArray(object.get_vao());
	
	if (mode == MODE_MULTI_DRAW) {
		int drawCount = 0;
		for (drawCount = 0; drawCount < NUM_DRAWS; drawCount++) {
			glDrawArraysIndirect(GL_TRIANGLES, NULL);
		}
	}
	else if (mode == MODE_SEPARATE_DRAWS) {
		int j = 0;
		
		for (j = 0; j < NUM_DRAWS; j++) {
			GLuint first, count;
			object.get_sub_object_info(j % object.get_sub_object_count(), first, count);
			glDrawArraysInstanced(GL_TRIANGLES, first, count, 1);
		}
	}
}

- (void)shutDown
{
	
}

- (void)loadShaders
{	
	static const GLchar *vs_source[] = { loadShaderFromSourcefile(@"media/shaders/multidrawindirect/render.vs.glsl") };
	static const GLchar *fs_source[] = { loadShaderFromSourcefile(@"media/shaders/multidrawindirect/render.fs.glsl") };

	GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vertexShader, 1, vs_source, NULL);
	glCompileShader(vertexShader);
	glAttachShader(renderProgram, vertexShader);
	logShader(vertexShader);
	
	GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(fragmentShader, 1, fs_source, NULL);
	glCompileShader(fragmentShader);
	glAttachShader(renderProgram, fragmentShader);
	logShader(fragmentShader);
	
	glLinkProgram(renderProgram);
	glDeleteShader(vertexShader);
	glDeleteShader(fragmentShader);
	
	if (renderProgram)
		glDeleteProgram(renderProgram);
	
//	renderProgram = sb6::program::link_from_shaders(shaders, 2, true);
	
	uniforms.time            = glGetUniformLocation(renderProgram, "time");
	uniforms.view_matrix     = glGetUniformLocation(renderProgram, "view_matrix");
	uniforms.proj_matrix     = glGetUniformLocation(renderProgram, "proj_matrix");
	uniforms.viewproj_matrix = glGetUniformLocation(renderProgram, "viewproj_matrix");
}

- (void)onKey:(int)key withAction:(int)action
{
	if (action)
	{
		switch (key)
		{
			case 'P':
				paused = !paused;
				break;
			case 'V':
				vsync = !vsync;
//				setVsync(vsync);
				break;
			case 'D':
				mode = MODE(mode + 1);
				if (mode > MODE_MAX)
					mode = MODE_FIRST;
				break;
			case 'R':
				[self loadShaders];
				break;
		}
	}
}

@end















