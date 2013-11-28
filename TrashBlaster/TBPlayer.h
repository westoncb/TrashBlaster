//
//  TBPlayer.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/18/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBEntity.h"
#import "TBSprite.h"
#import "TBStateSprite.h"
#import "TBPoint.h"

@class TBWorld;
@class TBBlock;

@interface TBPlayer : TBEntity {
    TBBlock *_deathBlock;
    TBStateSprite *_stateSprite;
    TBPoint *_destPoint;
    BOOL _running;
}

@property NSMutableArray * destPoints;
@property TBSprite * bulletSprite;
- (void)addDestPointWithDestX:(float)destX destY:(float)destY;
- (id)initWithStateSprite:(TBStateSprite *)stateSprite bulletSprite:(TBSprite *)bulletSprite;
@end
