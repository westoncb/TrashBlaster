#import "ViewController.h"
#import "Sprite.h"

@interface ViewController ()
@property (strong, nonatomic) EAGLContext *context;
@property (strong) GLKBaseEffect * effect;
@property (strong) Sprite * background;
@property (strong) Sprite * block;
@property (strong) NSMutableArray * sprites;
@end

@implementation ViewController
@synthesize context = _context;
@synthesize background = _background;
@synthesize block = _block;
@synthesize sprites = _sprites;

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
    
    self.block = [[Sprite alloc] initWithFile:@"block.png" effect:self.effect];
    self.background = [[Sprite alloc] initWithFile:@"background.png" effect:self.effect];
    
    self.sprites = [NSMutableArray array];
    [self.sprites addObject:self.background];
    [self.sprites addObject:self.block];
    self.block.position = GLKVector2Make(self.block.contentSize.width/2, 160);
    self.block.moveVelocity = GLKVector2Make(50, 50);
    self.background.position = GLKVector2Make(0, 0);
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
    
    for (Sprite * sprite in self.sprites) {
        [sprite update:self.timeSinceLastUpdate];
    }
    
    for (Sprite * sprite in self.sprites) {
        [sprite render];
    }
}

- (void)update {
}

@end