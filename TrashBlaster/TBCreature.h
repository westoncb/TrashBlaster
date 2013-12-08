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

@interface TBCreature : TBEntity {
    TBBlock *_deathBlock;
    TBStateSprite *_stateSprite;
    TBPoint *_destPoint;
    BOOL _running;
    BOOL _jumping;
    TBEntity *_gun;
    NSMutableArray *_circle;
}

@property NSMutableArray * destPoints;
@property TBSprite * bulletSprite;
@property BOOL canShoot;
@property float reloadTime;
@property float INITIAL_SPEED;
@property float ACCELERATION;
@property float DECELERATION;
@property int power;

- (void)addDestPointWithDestX:(float)destX destY:(float)destY;
- (id)initWithStateSprite:(TBStateSprite *)stateSprite bulletSprite:(TBSprite *)bulletSprite;
- (void)activateGun;
@end
