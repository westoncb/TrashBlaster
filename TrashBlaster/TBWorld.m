//
//  TBWorld.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/17/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBWorld.h"
#import "TBSprite.h"
#import <GLKit/GLKit.h>
#import <stdlib.h>

@interface TBWorld()
@property (strong) NSMutableArray * entities;
@property (strong) TBSprite * bgSprite;
@property (strong) TBSprite * blockSprite;

@property const int WIDTH;
@property const int HEIGHT;

@property float timePassed;
@property int blockDelay;
@property float initialBlockVelocity;
@property const float BLOCK_ACCELERATION;
@end

@implementation TBWorld
@synthesize entities;
@synthesize timePassed;
@synthesize blockDelay;

- (id)world {
    if((super.init)) {
        self.entities = [NSMutableArray array];
        self.blockDelay = 2.5f;
        self.BLOCK_ACCELERATION = -10;
        self.WIDTH = 320;
        self.HEIGHT = 480;
        
        GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
        
        GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, self.WIDTH, 0, self.HEIGHT, -1024, 1024);
        effect.transform.projectionMatrix = projectionMatrix;
        
        self.blockSprite = [[TBSprite alloc] initWithFile:@"block.png" effect:effect];
        self.bgSprite = [[TBSprite alloc] initWithFile:@"background.png" effect:effect];
        
        TBEntity *background = [[TBEntity alloc] initWithSprite:self.bgSprite];
        background.position = GLKVector2Make(0, 0);
        
        
        [self addEntity:background];
    }
    
    return self;
}

- (void)addEntity:(TBEntity *)entity {
    [self.entities addObject:entity];
}

- (void) updateBlockMachine:(float)delta {
    self.timePassed += delta;
    if(self.timePassed > self.blockDelay) {
        self.timePassed = 0;
        
        TBEntity *block = [self createBlock];
        [self addEntity:block];
        
        [self.entities sortedArrayUsingSelector:@selector(compare:)];
    }
}

- (TBEntity *) createBlock {
    TBEntity *block = [[TBEntity alloc] initWithSprite:self.blockSprite];
    block.position = GLKVector2Make(arc4random_uniform(self.WIDTH), self.HEIGHT);
    block.velocity = GLKVector2Make(0, self.initialBlockVelocity);
    block.acceleration = GLKVector2Make(0, self.BLOCK_ACCELERATION);
    return block;
}

- (void)update:(float)delta {
    [self updateBlockMachine:delta];
    
    for (TBEntity * entity in self.entities) {
        [entity update:delta];
    }
}

- (void)render {
    for (TBEntity * entity in self.entities) {
        [entity render];
    }
}
@end
