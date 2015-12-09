//
//  Chapter_8_Tessmodes.m
//  Obj-C OpenGL
//

////// THIS IS ANOTHER EXAMPLE THAT DOES NOT WORK ON OS X BUT THE CODE APPEARS TO BE CORRECT. THE SAMPLE .CPP
////// ONLY DISPLAYS A BLACK SCREEN AND SO DOES THE COMPILED PROJECT THAT YOU CAN RUN IN sb6

#import "Chapter_8_Tessmodes.h"

@interface Chapter_8_Tessmodes()
{
	GLuint		program[4];
	int			program_index;
}
@end

@implementation Chapter_8_Tessmodes

- (void)startUp
{
	program_index = 0;
	
	static const char *vs_source[] = { loadShaderFromSourcefile(@"tessmodes_vs") };
	static const char *tcs_source_triangles[] = { loadShaderFromSourcefile(@"tessmodes_tcs_triangles") };
	static const char *tes_source_triangles[] = { loadShaderFromSourcefile(@"tessmodes_tes_triangles") };
	static const char *tes_source_triangles_as_points[] = { loadShaderFromSourcefile(@"tessmodes_tes_triangles_points") } ;
	static const char *tcs_source_quads[] = { loadShaderFromSourcefile(@"tessmodes_tcs_quads") };
	static const char *tes_source_quads[] = { loadShaderFromSourcefile(@"tessmodes_tes_quads") };
	static const char *tcs_source_isolines[] = { loadShaderFromSourcefile(@"tessmodes_tcs_isolines") };
	static const char *tes_source_isolines[] = { loadShaderFromSourcefile(@"tessmodes_tes_isolines") };
	static const char *fs_source[] = { loadShaderFromSourcefile(@"tessmodes_fs") };
	
	int i;
	
	static const char * const *vs_sources[] = {
		vs_source, vs_source, vs_source, vs_source
	};
	
	static const char * const *tcs_sources[] = {
		tcs_source_quads, tcs_source_triangles, tcs_source_triangles, tcs_source_isolines
	};
	
	static const char * const *tes_sources[] = {
		tes_source_quads, tes_source_triangles, tes_source_triangles_as_points, tes_source_isolines
	};
	
	static const char * const *fs_sources[] = {
		fs_source, fs_source, fs_source, fs_source
	};
	
	for (i = 0; i < 4; i++) {
		program[i] = glCreateProgram();
		GLuint vs = glCreateShader(GL_VERTEX_SHADER);
		glShaderSource(vs, 1, vs_sources[i], NULL);
		glCompileShader(vs);
		
		GLuint tcs = glCreateShader(GL_TESS_CONTROL_SHADER);
		glShaderSource(tcs, 1, tcs_sources[i], NULL);
		glCompileShader(tcs);
		
		GLuint tes = glCreateShader(GL_TESS_EVALUATION_SHADER);
		glShaderSource(tes, 1, tes_sources[i], NULL);
		glCompileShader(tes);
		
		GLuint fs = glCreateShader(GL_FRAGMENT_SHADER);
		glShaderSource(fs, 1, fs_sources[i], NULL);
		glCompileShader(fs);
		
		glAttachShader(program[i], vs);
		glAttachShader(program[i], tcs);
		glAttachShader(program[i], tes);
		glAttachShader(program[i], fs);
		glLinkProgram(program[i]);
	}
	
	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);
	
	glPatchParameteri(GL_PATCH_VERTICES, 4);
	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
}

- (void)render:(double)currentTime
{
	static const GLfloat black[] = { 0.0f, 0.0f, 0.0f, 1.0f };
	glClearBufferfv(GL_COLOR, 0, black);
	
	glUseProgram(program[program_index]);
	glDrawArrays(GL_PATCHES, 0, 4);
}

- (void)shutDown
{
	int i;
	glDeleteVertexArrays(1, &vao);
	for (i = 0; i < 4; i++) {
		glDeleteProgram(program[i]);
	}
}

- (void)onKey:(int)key action:(int)action
{
	if (!action)
		return;
	
	switch (key)
	{
		case 'M':
			program_index = (program_index + 1) % 4;
			break;
	}
}

@end
