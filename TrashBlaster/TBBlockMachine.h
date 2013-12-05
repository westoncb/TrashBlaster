//
//  TBBlockMachine.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/23/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBWorld.h"

static const int NUM_COLS = 10;
static const int COL_WIDTH = 32;
static const float INITIAL_BLOCK_VELOCITY = -50;
static const float BLOCK_ACCELERATION = -20;

@interface TBBlockMachine : NSObject {
    int blocksInColumns[NUM_COLS];
    NSMutableArray *_topBlocks;
}

@property TBBlock *dummyBlock;

- (id)init;
- (void)update:(float)delta;
- (int)blocksInColumn:(int)col;
- (void)alterColumnCount:(int)col adder:(int)adder;
- (TBBlock *)getTopBlockAtColIndex:(int)colIndex;
- (void)setTopBlockAtColIndex:(int)colIndex block:(TBBlock *)block;
- (TBBlock *)getTopSettledBlockAtColIndex:(int)colIndex;
@end
