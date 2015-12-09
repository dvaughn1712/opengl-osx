//
//  MainOpenGLView.h
//  Obj-C OpenGL
//


#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>
#import "object.h"
#import "vmath.h"

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
- (void)onKey:(int)key action:(int)action;

void logShader(GLuint shader);
GLuint loadTextureFromSourcefile(NSString *fileName);
const GLchar *loadShaderFromSourcefile(NSString *fileName);
const GLchar *loadShaderFromSourcefile(const char *fileName);
sb6::object loadObjectFromSourceFile(NSString *fileName);
@end
