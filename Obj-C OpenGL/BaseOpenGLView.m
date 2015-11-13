//
//  MainOpenGLView.m
//  Obj-C OpenGL
//


#import "BaseOpenGLView.h"
#import "sb6ktx.h"

@interface BaseOpenGLView()
@property (nonatomic) CVDisplayLinkRef displayLink;
@property (nonatomic) NSDate *startTime;
@end

@implementation BaseOpenGLView


- (void)awakeFromNib {
	NSOpenGLPixelFormatAttribute attrs[] =
	{
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, 24,
		// Must specify the 3.2 Core Profile to use OpenGL 3.2
		NSOpenGLPFAOpenGLProfile,
		NSOpenGLProfileVersion3_2Core,
		0
	};
	
	NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	
	if (!pf)
	{
		NSLog(@"No OpenGL pixel format");
	}
	
	NSOpenGLContext* context = [[NSOpenGLContext alloc] initWithFormat:pf shareContext:nil];
	
	// When we're using a CoreProfile context, crash if we call a legacy OpenGL function
	// This will make it much more obvious where and when such a function call is made so
	// that we can remove such calls.
	// Without this we'd simply get GL_INVALID_OPERATION error for calling legacy functions
	// but it would be more difficult to see where that function was called.
	CGLEnable([context CGLContextObj], kCGLCECrashOnRemovedFunctions);
	
	[self setPixelFormat:pf];
	
	[self setOpenGLContext:context];
}

- (void)drawRect:(NSRect)dirtyRect {
	NSRect viewRectPixels = [self convertRectToBacking:dirtyRect];
	info.windowWidth = (int)viewRectPixels.size.width;
	info.windowHeight = (int)viewRectPixels.size.height;
	[self drawView];
}

- (void)prepareOpenGL {
	[super prepareOpenGL];
	
	//init opengl
	[self initOpenGL];
	
	CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
	CVDisplayLinkSetOutputCallback(_displayLink, &MyDisplayLinkCallback, (__bridge void*) self);
	
	CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = [self.pixelFormat CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
	CVDisplayLinkStart(_displayLink);
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:self.window];
}

- (void)initOpenGL {
	[self.openGLContext makeCurrentContext];
	
	GLint swapInt = 1;
	[self.openGLContext setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
	
	NSLog(@"%s %s", glGetString(GL_RENDERER), glGetString(GL_VERSION));
	
	[self startUp];
	self.startTime = [NSDate date];
	double time = [[NSDate date] timeIntervalSinceDate:self.startTime];
	[self render:time];
}

- (void)startUp { }
- (void)shutDown { }
- (void)render:(double)currentTime { }
- (void)onResize:(int)width :(int)height { }

GLuint loadTextureFromSourcefile(NSString *fileName) {
	NSArray *extension = [fileName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
	NSString *path = @"";
	if ([extension.lastObject isEqualToString:fileName]) {
		// try to load glsl as the default extension
		path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"media/textures/%@", fileName]  ofType:@"ktx"];
	} else {
		fileName = [fileName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", extension.lastObject] withString:@""];
		path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"media/textures/%@", fileName] ofType:extension.lastObject];
	}
	return ktx::load(path.UTF8String);
}

const GLchar *loadShaderFromSourcefile(NSString *fileName) {
	NSArray *extension = [fileName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
	NSString *path = @"";
	if ([extension.lastObject isEqualToString:fileName]) {
		// try to load glsl as the default extension
		path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"glsl"];
	} else {
		fileName = [fileName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", extension.lastObject] withString:@""];
		path = [[NSBundle mainBundle] pathForResource:fileName ofType:extension.lastObject];
	}
	
	NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];	
	return [content UTF8String];
}

void logShader(GLuint shader) {
	GLint logLength;
	glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
	
	GLchar *utfString = new GLchar[logLength];
	if (logLength > 0) {
		glGetShaderInfoLog(shader, logLength, NULL, utfString);
		NSLog(@"Shader ERROR: %s", utfString);
	}
}

- (void) drawView
{
	[[self openGLContext] makeCurrentContext];
	
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main
	// thread. Add a mutex around to avoid the threads accessing the context
	// simultaneously when resizing
	CGLLockContext([[self openGLContext] CGLContextObj]);
	
	double time = [[NSDate date] timeIntervalSinceDate:self.startTime];
	[self render:time];
	
	CGLFlushDrawable([[self openGLContext] CGLContextObj]);
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}


- (void)reshape {
	[super reshape];
	CGLLockContext([self.openGLContext CGLContextObj]);
	NSRect viewRectPoints = self.bounds;
	NSRect viewRectPixels = [self convertRectToBacking:viewRectPoints];
	glViewport(0, 0, viewRectPixels.size.width, viewRectPixels.size.height);
	info.windowWidth = (int)viewRectPixels.size.width;
	info.windowHeight = (int)viewRectPixels.size.height;
	[self onResize:(int)viewRectPixels.size.width :(int)viewRectPixels.size.height];
	CGLUnlockContext([self.openGLContext CGLContextObj]);
}


- (void)windowWillClose:(NSNotification *)notification {
	CVDisplayLinkStop(self.displayLink);
	[self shutDown];
}

- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime
{
	// There is no autorelease pool when this method is called
	// because it will be called from a background thread.
	// It's important to create one or app can leak objects.
	@autoreleasepool {
		[self drawView];
	}
	return kCVReturnSuccess;
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink,
									  const CVTimeStamp* now,
									  const CVTimeStamp* outputTime,
									  CVOptionFlags flagsIn,
									  CVOptionFlags* flagsOut,
									  void* displayLinkContext)
{
	CVReturn result = [(__bridge BaseOpenGLView*)displayLinkContext getFrameForTime:outputTime];
	return result;
}

@end
