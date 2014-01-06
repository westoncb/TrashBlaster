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
@class TBPlayer;

static GLKBaseEffect *effect;
static const int WIDTH = 320;
static const int HEIGHT = 567;
static const int FLOOR_HEIGHT = 39;
static const int GRAVITY_ACCELERATION = -200;

@interface TBWorld : NSObject {
    TBAnimatedSprite *_runSprite;
    TBSprite *_shootSprite;
    TBEntity *_scoreEntity;
    TBEntity *_scoreTextEntity; //The text "Score: " displayed on the screen
    int _lastScore;
    int _frameIndex;
    TBEntity *_fpsEntity;
    NSMutableArray *_addEntityQueue;
    NSMutableArray *_entityPurgatory; //Entity has died, waiting for subentities to die before removal
    
    int _bezierSampleSize;
    NSMutableArray *_controlPoints;
    NSMutableArray *_bezierCurve;
}

@property BOOL doTheBezier;
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
- (void)handlePanWithPoint:(CGPoint)point;
- (void)handleFingerLiftedWithPoint:(CGPoint)point;
- (void)start;
- (void)setFramesPerSecond:(int)fps;
- (void)addCreature;
- (void)createPointDisplayAtEntity:(TBEntity *)entity;	
- (TBPlayer *)getPlayer;
@end
