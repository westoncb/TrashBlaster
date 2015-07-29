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
@property TBSprite * blockSprite;

@end

@implementation TBBlockMachine

- (id)init {
    self = [super init];
    if(self) {
        self.blockDelay = 1.0f;
        self.blockSprite = [[TBSprite alloc] initWithFile:@"block2.png"];
        _dummyBlock = [[TBBlock alloc] initWithSprite:self.blockSprite];
        _dummyBlock.position = GLKVector2Make(0, INT_MAX);
        _topBlocks = [NSMutableArray arrayWithCapacity:NUM_COLS];
        for (int i = 0; i < NUM_COLS; i++) {
            [_topBlocks addObject:_dummyBlock];
        }
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
    float scale = COL_WIDTH/block.size.width;
    block.scale = GLKVector2Make(scale, scale);
    int randX = arc4random_uniform(WIDTH);
    int colIndex = round(randX/COL_WIDTH);
    int newX = colIndex*COL_WIDTH + block.size.width/2.0f;
    
    if(blocksInColumns[colIndex]*block.collisionsize.height < HEIGHT) {
        block.position = GLKVector2Make(newX, HEIGHT);
        block.rowIndex = blocksInColumns[colIndex];
        [block.collidesWith addObject:[NSNumber numberWithInt:PLAYER]];
        [block.collidesWith addObject:[NSNumber numberWithInt:BULLET]];
        [block setToFallingState];
        
        TBBlock *topBlock = [_topBlocks objectAtIndex:colIndex];
        [topBlock setBlockAbove:block];
        [block setBlockBelow:topBlock];
        [self setTopBlockAtColIndex:colIndex block:block];
    }
    
    return block;
}

- (void)setTopBlockAtColIndex:(int)colIndex block:(TBBlock *)block
{
    [_topBlocks setObject:block atIndexedSubscript:colIndex];
}

- (TBBlock *)getTopBlockAtColIndex:(int)colIndex
{
    if (colIndex >= NUM_COLS)
        colIndex = NUM_COLS - 1;
    if (colIndex < 0)
        colIndex = 0;
    
    return (TBBlock *)[_topBlocks objectAtIndex:colIndex];
}

- (TBBlock *)getTopSettledBlockAtColIndex:(int)colIndex
{
    TBBlock *candidate = [self getTopBlockAtColIndex:colIndex];
    while ((!candidate.resting || !candidate.alive) && candidate != self.dummyBlock) {
        if (candidate && !candidate.alive) {
            [_topBlocks setObject:self.dummyBlock atIndexedSubscript:colIndex];
            [[candidate getBlockAbove] setBlockBelow:self.dummyBlock];
        }
        
        candidate = [candidate getBlockBelow];
    }
    
    return candidate;
}

- (int)blocksInColumn:(int)col {
    return blocksInColumns[col];
}

- (void)alterColumnCount:(int)col adder:(int)adder {
    blocksInColumns[col] += adder;
}

@end
