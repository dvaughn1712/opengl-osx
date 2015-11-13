//
//  MainOpenGLView.h
//  Obj-C OpenGL
//


#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>

struct BaseInfo {
	int windowWidth;
	int windowHeight;
};

@interface BaseOpenGLView : NSOpenGLView
{
	GLuint renderProgram;
	GLuint vao;
	BaseInfo info;
}

- (void)startUp;
- (void)shutDown;
- (void)render:(double)currentTime;
- (void)onResize:(int)width :(int)height;

void logShader(GLuint shader);
GLuint loadTextureFromSourcefile(NSString *fileName);
const GLchar *loadShaderFromSourcefile(NSString *fileName);
@end
