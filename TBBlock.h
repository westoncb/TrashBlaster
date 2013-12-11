//
//  TBBlock.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 7/6/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBEntity.h"
#import "TBSprite.h"
#import "TBBlock.h"

@interface TBBlock : TBEntity {
    BOOL _hitPlayer;
    BOOL _initialFall;
    TBBlock *_blockAbove;
    TBBlock *_blockBelow;
    float _initialLife;
}

@property int rowIndex;
@property BOOL resting;

- (id)initWithSprite:(TBSprite *)sprite;
- (int)getColumnIndex;
- (void)setBlockAbove:(TBBlock *)block;
- (void)removeBlockAbove;
- (void)setBlockBelow:(TBBlock *)block;
- (void)removeBlockBelow;
- (TBBlock *)getBlockBelow;
- (TBBlock *)getBlockAbove;
- (void)setToFallingState;
- (void)setToRestingState;
- (BOOL)shouldDamagePlayer;
@end
