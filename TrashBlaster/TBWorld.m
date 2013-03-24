//
//  TBWorld.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/17/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBWorld.h"
#import "TBSprite.h"
#import "TBPlayer.h"
#import <stdlib.h>
#import "TBBlockMachine.h"

@interface TBWorld()
@property NSMutableArray * entities;
@property NSMutableArray * colliders;
@property NSMutableArray * blocks;
@property NSMutableArray * entityBuffer; //add to the buffer instead because something might want to add to 'entities' while we are
                                         //iterating that collection
@property TBSprite * bgSprite;
@property TBPlayer * player;
@property TBBlockMachine * blockMachine;
@end

@implementation TBWorld

- (id)init {
    self = super.init;
    if(self) {
        TBWorld.effect = [[GLKBaseEffect alloc] init];
        GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, TBWorld.WIDTH, 0, TBWorld.HEIGHT, -1024, 1024);
        TBWorld.effect.transform.projectionMatrix = projectionMatrix;
        
        self.entities = [NSMutableArray array];
        self.colliders = [NSMutableArray array];
        self.blocks = [NSMutableArray array];
        self.entityBuffer = [NSMutableArray array];
        
        self.bgSprite = [[TBSprite alloc] initWithFile:@"background.png"];
        
        TBEntity *background = [[TBEntity alloc] initWithSprite:self.bgSprite];
        [self addEntity:background];
        
        TBSprite *bulletSprite = [[TBSprite alloc] initWithFile:@"bullet.png"];
        TBSprite *playerSprite  = [[TBSprite alloc] initWithFile:@"player.png"];
        _player = [[TBPlayer alloc] initWithSprite:playerSprite bulletSprite:bulletSprite world:self];
        [self addEntity:_player];
    
        self.blockMachine = [[TBBlockMachine alloc] initWithWorld:self];
        
    }
    
    return self;
}

- (void)addEntity:(TBEntity *)entity {
    [self.entityBuffer addObject:entity];
    if(entity.type != BLOCK && entity.type != PLAYER)
        [self.colliders addObject:entity];
    else
        [self.blocks addObject:entity];
    
    [self.entities sortedArrayUsingSelector:@selector(compare:)];
}

- (void)update:(float)delta {
    [self.blockMachine update:delta];
    
    for (TBEntity * entity in self.entities) {
        [entity update:delta];
    }
    for (TBEntity * entity in self.entityBuffer) {
        [self.entities addObject:entity];
    }
    [self.entityBuffer removeAllObjects];
    
    [self checkForCollisions];
}

- (void)checkForBlockCollisions {
    for (TBEntity * block in self.blocks) {
        if (block.type == PLAYER) {
            continue;
        }
        
        int colIndex = block.position.x/block.size.width;
        int blocksInCol = [self.blockMachine blocksInColumn:colIndex];
        int collisionThreshold = blocksInCol*block.collisionsize.height + TBWorld.FLOOR_HEIGHT - block.collisionyoff;
        
        if(block.position.y < collisionThreshold && fabsf(block.velocity.y) > 0) {
            block.acceleration = GLKVector2Make(0, 0);
            block.velocity = GLKVector2Make(0, 0);
            block.position = GLKVector2Make(block.position.x, collisionThreshold);
            [self.blockMachine alterColumnCount:colIndex adder:1];
        }
    }
}

- (void)movePlayerTo:(GLKVector2)dest {
    [self.player addDestPoint:dest.x];
}

- (void)checkForCollisions {
    [self checkForBlockCollisions];
    
    /*for (TBEntity * entity in self.colliders) {
        for (TBEntity * entity2 in self.colliders) {
            if(entity != entity2 && (entity.alive || entity2.alive)) {
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
    }*/
    
}

+ (GLKBaseEffect*)effect {
    return effect;
}

+ (void)setEffect:(GLKBaseEffect *)newEffect {
    effect = newEffect;
}

+ (int) WIDTH {
    return WIDTH;
}
+ (int) HEIGHT {
    return HEIGHt;
}
+ (int) FLOOR_HEIGHT {
    return FLOOR_HEIGHT;
}

- (void)render {
    for (TBEntity * entity in self.entities) {
        [entity render];
    }
}

@end
