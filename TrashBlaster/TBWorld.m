//
//  TBWorld.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/17/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBWorld.h"
#import "TBPlayer.h"
#import <stdlib.h>
#import "TBBlockMachine.h"
#import "TBStateSprite.h"

static TBWorld *_world;

@interface TBWorld()
@property NSMutableArray * entities;
@property NSMutableArray * colliders;
@property NSMutableArray * blocks;
@property NSMutableArray * addEntityBuffer; //add to the buffer instead because something might want to add to 'entities' while we
                                            //are iterating that collection
@property NSMutableArray * removeEntityBuffer;

@property TBSprite * bgSprite;
@property TBPlayer * player;
@property TBBlockMachine * blockMachine;
@end

@implementation TBWorld

+ (TBWorld *)instance
{
    if (!_world)
        _world = [[TBWorld alloc] init];
    
    return _world;
}

+ (void)destroy
{
    _world = nil;
}

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
        
        TBEntity *background = [[TBEntity alloc] initWithDrawable:self.bgSprite];
        background.type = DECORATION;
        [self addEntity:background];
        
        TBSprite *bulletSprite = [[TBSprite alloc] initWithFile:@"bullet.png"];
        TBAnimationInfo animationInfo;
        animationInfo.frameWidth = 40;
        animationInfo.frameHeight = 40;
        animationInfo.frameCount = 4;
        animationInfo.frameLength = 100;
        animationInfo.loop = YES;
        _runSprite  = [[TBAnimatedSprite alloc] initWithFile:@"playersheet.png" animationInfo:animationInfo];
        _shootSprite = [[TBSprite alloc] initWithFile:@"player.png"];
        _runSprite.size = CGSizeMake(60, 60);
        _shootSprite.size = CGSizeMake(40, 80);
        NSMutableDictionary *stateMap = [[NSMutableDictionary alloc] init];
        [stateMap setValue:_runSprite forKey:@"run"];
        [stateMap setValue:_runSprite forKey:@"run_xf"];
        [stateMap setValue:_shootSprite forKey:@"shoot"];
        TBStateSprite *playerSprite = [[TBStateSprite alloc] initWithStateMap:stateMap initialState:@"shoot"];
        _player = [[TBPlayer alloc] initWithStateSprite:playerSprite bulletSprite:bulletSprite];
        [_player.collidesWith addObject:[NSNumber numberWithInt:BLOCK]];
        [self addEntity:_player];
    
        self.blockMachine = [[TBBlockMachine alloc] init];
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
    [self.player addDestPointWithDestX:dest.x destY:dest.y];
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
        if (!entity.parent)
            [entity render];
    }
}

@end
