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
#import "TBBlock.h"
#import "TBSprite.h"

@class TBWorld;

@interface TBBlockMachine ()
@property float timePassed;
@property float blockDelay;
@property float initialBlockVelocity;
@property const float BLOCK_ACCELERATION;
@property TBSprite * blockSprite;

@end

@implementation TBBlockMachine

- (id)init {
    self = [super init];
    if(self) {
        self.blockDelay = 1.0f;
        self.BLOCK_ACCELERATION = -100;
        self.initialBlockVelocity = -20;
        self.blockSprite = [[TBSprite alloc] initWithFile:@"block.png"];
    }
    
    return self;
}

- (void) update:(float)delta {
    self.timePassed += delta;
    if(self.timePassed > self.blockDelay) {
        self.timePassed -= self.blockDelay;
        
        TBEntity *block = [self createBlock];
        [[TBWorld instance] addEntity:block];
    }
}

- (TBEntity *) createBlock {
    TBBlock *block = [[TBBlock alloc] initWithSprite:self.blockSprite];
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
        [block.collidesWith addObject:[NSNumber numberWithInt:PLAYER]];
        [block.collidesWith addObject:[NSNumber numberWithInt:BULLET]];
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
