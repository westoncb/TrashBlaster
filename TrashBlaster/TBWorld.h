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
static const int HEIGHT = 567;
static const int FLOOR_HEIGHT = 43;
static const int GRAVITY_ACCELERATION = -200;

@interface TBWorld : NSObject {
    TBAnimatedSprite *_runSprite;
    TBSprite *_shootSprite;
    TBEntity *_scoreEntity;
    TBEntity *_scoreTextEntity; //The text "Score: " displayed on the screen
    int _score;
    
    int _bezierSampleSize;
    NSMutableArray *_controlPoints;
    NSMutableArray *_bezierCurve;
}

@property TBBlockMachine * blockMachine;
+ (GLKBaseEffect*) effect;
+ (TBWorld *)instance;
+ (void)destroy;

- (void)addEntity:(TBEntity *)entity;
- (void)removeEntity:(TBEntity *)entity;
- (BOOL)update:(float)delta;
- (void)render;
- (void)movePlayerTo:(GLKVector2)dest;
- (int)xPositionToColumn:(float)xPosition;
- (void)addToScore:(int)amount;
- (void)handlePanWithPoint:(CGPoint)point;
- (void)handleFingerLiftedWithPoint:(CGPoint)point;
@end
