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

int blocksInColumns[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

@interface TBWorld()

@property (strong) NSMutableArray * entities;
@property (strong) NSMutableArray * colliders;
@property (strong) NSMutableArray * blocks;
@property (strong) TBSprite * bgSprite;
@property (strong) TBSprite * blockSprite;

@property const int WIDTH;
@property const int HEIGHT;
@property const int FLOOR_HEIGHT;

@property float timePassed;
@property float blockDelay;
@property float initialBlockVelocity;
@property const float BLOCK_ACCELERATION;
@property int blockCount;
@end

@implementation TBWorld
@synthesize entities;
@synthesize colliders;
@synthesize blocks;
@synthesize timePassed;
@synthesize blockDelay;

- (id)world {
    if((super.init)) {
        self.entities = [NSMutableArray array];
        self.colliders = [NSMutableArray array];
        self.blocks = [NSMutableArray array];
        self.blockDelay = 0.1f;
        self.BLOCK_ACCELERATION = -60;
        self.initialBlockVelocity = -100;
        self.WIDTH = 320;
        self.HEIGHT = 480;
        self.FLOOR_HEIGHT = 28;

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
    if(entity.type != BLOCK)
        [self.colliders addObject:entity];
    else
        [self.blocks addObject:entity];
}

- (void) updateBlockMachine:(float)delta {
    self.timePassed += delta;
    if(self.timePassed > self.blockDelay) {
        self.timePassed -= self.blockDelay;
        self.blockCount++;
        
        TBEntity *block = [self createBlock];
        [self addEntity:block];
        
        [self.entities sortedArrayUsingSelector:@selector(compare:)];
    }
}

- (TBEntity *) createBlock {
    TBEntity *block = [[TBEntity alloc] initWithSprite:self.blockSprite];
    int randX = arc4random_uniform(self.WIDTH);
    int colIndex = round(randX/32);
    int newX = colIndex*32;
    
    if(blocksInColumns[colIndex]*block.collisionsize.height < self.HEIGHT) {
        block.position = GLKVector2Make(newX, self.HEIGHT);
        block.velocity = GLKVector2Make(0, self.initialBlockVelocity);
        block.acceleration = GLKVector2Make(0, self.BLOCK_ACCELERATION);
        block.collisionxoff = 2;
        block.collisionyoff = 3;
        block.collisionsize = CGSizeMake(block.size.width-6, block.size.height-6);
        block.type = BLOCK;
    }
    return block;
}

- (void)update:(float)delta {
    [self updateBlockMachine:delta];
    
    for (TBEntity * entity in self.entities) {
        [entity update:delta];
    }
    [self checkForCollisions];
}

- (BOOL)checkForBlockCollisions {
    for (TBEntity * block in self.blocks) {
        int colIndex = block.position.x/block.size.width;
        int blocksInCol = blocksInColumns[colIndex];
        int collisionThreshold = blocksInCol*block.collisionsize.height + self.FLOOR_HEIGHT;
        
        if(block.position.y < collisionThreshold && fabsf(block.velocity.y) > 0) {
            block.acceleration = GLKVector2Make(0, 0);
            block.velocity = GLKVector2Make(0, 0);
            block.position = GLKVector2Make(block.position.x, collisionThreshold);
            blocksInColumns[colIndex]++;
        }
    }
}

- (void)checkForCollisions {
    [self checkForBlockCollisions];
    
    for (TBEntity * entity in self.colliders) {
        for (TBEntity * entity2 in self.colliders) {
            if(entity != entity2 && (entity.alive || entity2.alive)) {
                
                //prevent mid-air collisions of blocks! (Doing it another way would require a decent collision system)
                //if(entity.type == BLOCK && entity2.type == BLOCK) {
                  //  if(entity.position.x != entity2.position.x || !(fabsf(entity.yChange) < .1 || fabsf(entity2.yChange) < .1))
                    //    continue;
                //}
                
                BOOL collision = false;
                TBEntity * protruder = NULL;
                if([entity doCollisionCheck:entity2]) {
                    protruder = entity2;
                    collision = true;
                } else if([entity2 doCollisionCheck:entity]) {
                    protruder = entity;
                    collision = true;
                }
                if(collision) {
                    [entity handleCollision:entity2 wasTheProtruder:(entity == protruder)];
                    [entity2 handleCollision:entity wasTheProtruder:(entity2 == protruder)];
                }
            }
        }
    }
    
}

- (void)render {
    for (TBEntity * entity in self.entities) {
        [entity render];
    }
}
@end
