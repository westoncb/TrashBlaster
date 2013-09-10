//
//  TBWorld.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/17/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class TBEntity;

static GLKBaseEffect *effect;
static const int WIDTH = 320;
static const int HEIGHT = 480;
static const int FLOOR_HEIGHT = 31;

@interface TBWorld : NSObject
@property const int WIDTH;
@property const int HEIGHT;
@property const int FLOOR_HEIGHT;
+ (GLKBaseEffect*) effect;
+ (int) WIDTH;
+ (int) HEIGHT;
+ (int) FLOOR_HEIGHT;

- (id)init;
- (void)addEntity:(TBEntity *)entity;
- (void)removeEntity:(TBEntity *)entity;
- (BOOL)update:(float)delta;
- (void)render;
- (void)movePlayerTo:(GLKVector2)dest;
@end
