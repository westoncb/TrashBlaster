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
@property NSMutableArray * addEntityBuffer; //add to the buffer instead because something might want to add to 'entities' while we are
@property NSMutableArray * removeEntityBuffer;
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
        self.addEntityBuffer = [NSMutableArray array];
        self.removeEntityBuffer = [NSMutableArray array];
        
        self.bgSprite = [[TBSprite alloc] initWithFile:@"background.png"];
        
        TBEntity *background = [[TBEntity alloc] initWithSprite:self.bgSprite];
        background.type = DECORATION;
        [self addEntity:background];
        
        TBSprite *bulletSprite = [[TBSprite alloc] initWithFile:@"bullet.png"];
        TBSprite *playerSprite  = [[TBSprite alloc] initWithFile:@"player.png"];
        playerSprite.size = CGSizeMake(40, 80);
        _player = [[TBPlayer alloc] initWithSprite:playerSprite bulletSprite:bulletSprite world:self];
        [_player.collidesWith addObject:[NSNumber numberWithInt:BLOCK]];
        [self addEntity:_player];
    
        self.blockMachine = [[TBBlockMachine alloc] initWithWorld:self];
        
    }
    
    return self;
}

- (void)addEntity:(TBEntity *)entity {
    [self.addEntityBuffer addObject:entity];
    if(entity.type == BLOCK)
        [self.blocks addObject:entity];
    
    if (entity.type != DECORATION)
        [self.colliders addObject:entity];
    
    [self.entities sortedArrayUsingSelector:@selector(compare:)];
}

- (void)removeEntity:(TBEntity *)entity {
    if (!entity.keepImageAfterDeath)
        [self.removeEntityBuffer addObject:entity];
    if([self.colliders containsObject:entity])
        [self.colliders removeObject:entity];
    if([self.blocks containsObject:entity])
        [self.blocks removeObject:entity];

}

- (BOOL)update:(float)delta {
    [self.blockMachine update:delta];
    
    for (TBEntity * entity in self.entities) {
        
        if (entity.type == PLAYER && !entity.alive) {
            return YES;
        }
        
        [entity update:delta];
    }
    for (TBEntity * entity in self.addEntityBuffer) {
        [self.entities addObject:entity];
    }
    [self.addEntityBuffer removeAllObjects];
    
    for (TBEntity * entity in self.removeEntityBuffer) {
        [self.entities removeObject:entity];
    }
    [self.removeEntityBuffer removeAllObjects];
    
    [self removeDistantBullets];
    [self cleanupDeadEntities];
    [self checkForCollisions];
    
    return NO;
}

- (void)cleanupDeadEntities
{
    for (TBEntity *entity in self.entities) {
        if (!entity.alive)
            [self removeEntity:entity];
    }
}

- (void) removeDistantBullets {
    for (TBEntity * entity in self.entities) {
        if(entity.type == BULLET && entity.position.y > TBWorld.HEIGHT + 50)
            [self removeEntity:entity];
    }
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
    
    for (TBEntity * entity in self.colliders) {
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
                    if ([entity.collidesWith containsObject:[NSNumber numberWithInt:entity2.type]]) { //left off here
                        [entity handleCollision:entity2 wasTheProtruder:(entity == protruder)];
                    }
                    if ([entity2.collidesWith containsObject:[NSNumber numberWithInt:entity.type]]) {
                        [entity2 handleCollision:entity wasTheProtruder:(entity2 == protruder)];
                    }

                }
            }
        }
    }
    
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
    return HEIGHT;
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
