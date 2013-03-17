#import "TBViewController.h"
#import "TBSprite.h"
#import "TBWorld.h"

@interface TBViewController ()
@property (strong, nonatomic) EAGLContext *context;
@property (strong) GLKBaseEffect * effect;
@property (strong) TBWorld * world;
@end

@implementation TBViewController
@synthesize context = _context;
@synthesize world = _world;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];

    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, 320, 0, 480, -1024, 1024);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    
    self.world = [[TBWorld alloc] world];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    [self.world render];
}

- (void)update {
    [self.world update:self.timeSinceLastUpdate];
}

@end