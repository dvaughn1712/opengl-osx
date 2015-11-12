//
//  ViewController.m
//  Obj-C OpenGL
//


#import "ViewController.h"
#import "BaseOpenGLView.h"

@interface ViewController()
@property (weak) IBOutlet BaseOpenGLView *openGLView;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewWillAppear {
	[super viewWillAppear];
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}

@end
