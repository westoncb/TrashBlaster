//
//  TBWorld.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/17/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "TBSprite.h"
#import "TBAnimatedSprite.h"

@class TBBlockMachine;
@class TBEntity;
@class TBBlock;

static GLKBaseEffect *effect;
static const int WIDTH = 320;
static const int HEIGHT = 480;
static const int FLOOR_HEIGHT = 31;
static const int GRAVITY_ACCELERATION = -200;

@interface TBWorld : NSObject {
    TBAnimatedSprite *_runSprite;
    TBSprite *_shootSprite;
    TBEntity *_scoreEntity;
    TBEntity *_scoreTextEntity; //The text "Score: " displayed on the screen
    int _score;
}

@property TBBlockMachine * blockMachine;
@property const int WIDTH;
@property const int HEIGHT;
@property const int FLOOR_HEIGHT;
+ (GLKBaseEffect*) effect;
+ (int) WIDTH;
+ (int) HEIGHT;
+ (int) FLOOR_HEIGHT;
+ (TBWorld *)instance;
+ (void)destroy;

- (void)addEntity:(TBEntity *)entity;
- (void)removeEntity:(TBEntity *)entity;
- (BOOL)update:(float)delta;
- (void)render;
- (void)movePlayerTo:(GLKVector2)dest;
- (int)xPositionToColumn:(float)xPosition;
- (void)addToScore:(int)amount;
@end
