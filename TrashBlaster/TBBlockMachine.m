//
//  TBBlockMachine.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/23/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBBlockMachine.h"
#import "TBEntity.h"
#import <GLKit/GLKit.h>

@class TBWorld;

@interface TBBlockMachine ()
@property float timePassed;
@property float blockDelay;
@property float initialBlockVelocity;
@property const float BLOCK_ACCELERATION;
@property (weak) TBWorld * world;
@property TBSprite * blockSprite;

@end

@implementation TBBlockMachine

- (id)initWithWorld:(TBWorld*)world {
    self = [super self];
    if(self) {
        _world = world;
        self.blockDelay = .3f;
        self.BLOCK_ACCELERATION = -400;
        self.initialBlockVelocity = -60;
        self.blockSprite = [[TBSprite alloc] initWithFile:@"block.png"];
    }
    
    return self;
}

- (void) update:(float)delta {
    self.timePassed += delta;
    if(self.timePassed > self.blockDelay) {
        self.timePassed -= self.blockDelay;
        
        TBEntity *block = [self createBlock];
        [self.world addEntity:block];
    }
}

- (TBEntity *) createBlock {
    TBEntity *block = [[TBEntity alloc] initWithSprite:self.blockSprite];
    int randX = arc4random_uniform(TBWorld.WIDTH);
    int colIndex = round(randX/32);
    int newX = colIndex*32;
    
    if(blocksInColumns[colIndex]*block.collisionsize.height < TBWorld.HEIGHT) {
        block.position = GLKVector2Make(newX, TBWorld.HEIGHT);
        block.velocity = GLKVector2Make(0, self.initialBlockVelocity);
        block.acceleration = GLKVector2Make(0, self.BLOCK_ACCELERATION);
        block.collisionxoff = 2;
        block.collisionyoff = 3;
        block.collisionsize = CGSizeMake(block.size.width-6, block.size.height-6);
        block.type = BLOCK;
    }
    return block;
}

- (int)blocksInColumn:(int)col {
    return blocksInColumns[col];
}

- (void)alterColumnCount:(int)col adder:(int)adder {
    blocksInColumns[col] += adder;
}

@end
