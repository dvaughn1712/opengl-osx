#import "Chapter_5_View.h"
#import "vmath.h"
#include <cmath>
#include <string>

@interface Chapter_5_View()
{
	GLuint texture;
	GLuint rainBuffer;
	
	float dropletXOffset[256];
	float dropletRotSpeed[256];
	float dropletFallSpeed[256];
}
@end

static unsigned int seed = 0x13371337;

static inline float random_float() {
	float res;
	unsigned int tmp;
	
	seed *= 16807;
	
	tmp= seed ^ (seed >> 4) ^ (seed << 15);
	*((unsigned int *) &res) = (tmp >> 9) | 0x3F800000;
	
	return (res - 1.0f);
}


@implementation Chapter_5_View

- (void)startUp
{
	GLuint vertexShader, fragmentShader;
	static const GLchar *vsSource[] = { loadShaderFromSourcefile(@"alien_vertex.glsl") };
	static const GLchar *fsSource[] = { loadShaderFromSourcefile(@"alien_fragment") };
	
	vertexShader = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vertexShader, 1, vsSource, NULL);
	glCompileShader(vertexShader);
	logShader(vertexShader);
	
	fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(fragmentShader, 1, fsSource, NULL);
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
	
	texture = loadTextureFromSourcefile(@"aliens.ktx");
	glBindTexture(GL_TEXTURE_2D_ARRAY, texture);
	glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	
	glGenBuffers(1, &rainBuffer);
	glBindBuffer(GL_UNIFORM_BUFFER, rainBuffer);
	glBufferData(GL_UNIFORM_BUFFER, 256 * sizeof(vmath::vec4), NULL, GL_DYNAMIC_DRAW);
	
	for (int i = 0; i < 256; i++) {
		dropletXOffset[i] = random_float() * 2.0f - 1.0f;
		dropletRotSpeed[i] = (random_float() * 0.5f) * ((i & 1) ? -3.0f : 3.0f);
		dropletFallSpeed[i] = random_float() + 0.2f;
	}
	
	glBindVertexArray(vao);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

}

- (void)render:(double)currentTime
{
	static const GLfloat black[] = { 0.0f, 0.0f, 0.0f, 0.0f };
	float t = (float)currentTime;
	
	glClearBufferfv(GL_COLOR, 0, black);
	glUseProgram(renderProgram);
	
	glBindBufferBase(GL_UNIFORM_BUFFER, 0 , rainBuffer);
	vmath::vec4 *droplet = (vmath::vec4 *)glMapBufferRange(GL_UNIFORM_BUFFER, 0, 256 * sizeof(vmath::vec4), GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
	
	for (int i = 0; i < 256; i++) {
		droplet[i][0] = dropletXOffset[i];
		droplet[i][1] = 2.0f - fmodf((t + float(i)) * dropletFallSpeed[i], 4.31f);
		droplet[i][2] = t * dropletRotSpeed[i];
		droplet[i][3] = 0.0f;
	}
	glUnmapBuffer(GL_UNIFORM_BUFFER);
	
	int alienIndex;
	for (alienIndex = 0; alienIndex < 256; alienIndex++) {
		glVertexAttribI1i(0, alienIndex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}
}

- (void)shutDown
{
	
}

@end
