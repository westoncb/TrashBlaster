#import "TBViewController.h"
#import "TBSprite.h"
#import "TBWorld.h"

@interface TBViewController ()
@property (strong, nonatomic) EAGLContext *context;
@property (strong) GLKBaseEffect * effect;
@property (strong) TBWorld * world;
@end

const float RESTART_DELAY = 1.0f;

@implementation TBViewController
@synthesize context = _context;
@synthesize world = _world;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    [EAGLContext setCurrentContext:self.context];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    firstTime = YES;
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = CGPointMake(touchLocation.x, 320 - touchLocation.y);
    
    GLKVector2 target = GLKVector2Make(touchLocation.x, touchLocation.y);
    
    [self.world movePlayerTo:target];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    if (self.world) {
        glClearColor(1, 1, 1, 1);
        glClear(GL_COLOR_BUFFER_BIT);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_BLEND);
        
        [self.world render];
    }
}

- (void)update {
    NSTimeInterval timeSinceLastUpdate = self.timeSinceLastUpdate;
    
    if (self.world) {
        BOOL reset = [self.world update:timeSinceLastUpdate];
        
        if (reset) {
            self.world = nil;
            restartTime = 0;
        }
    } else if (restartTime > RESTART_DELAY || firstTime) {
        self.world = [[TBWorld alloc] init];
        restartTime = 0;
        firstTime = NO;
    } else {
        restartTime += timeSinceLastUpdate;
    }
}

@end