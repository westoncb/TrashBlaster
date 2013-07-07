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

@class TBWorld;
@class TBBlock;

@interface TBPlayer : TBEntity {
    TBBlock *_deathBlock;
}

@property NSMutableArray * destPoints;
@property TBSprite * bulletSprite;
- (void)addDestPoint:(float)destx;
- (id)initWithSprite:(TBSprite *)sprite bulletSprite:(TBSprite *)bulletSprite world:(TBWorld *)world;
@end
