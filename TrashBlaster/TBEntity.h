//
//  TBEntity.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/17/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <Foundation/Foundation.h>
#import "TBSprite.h"

@interface TBEntity : NSObject
@property (assign) GLKVector2 acceleration;
@property (assign) GLKVector2 velocity;
@property (assign) GLKVector2 position;
@property (assign) CGSize size;
@property float collisionxoff;
@property float collisionyoff;
@property (assign) CGSize collisionsize;
@property (strong) TBSprite *sprite;
@property BOOL alive;

- (id)initWithSprite:(TBSprite *)sprite;
- (void)update:(float)dt;
- (void)render;
- (BOOL)doCollisionCheck:(TBEntity *)other;
- (void)handleCollision:(TBEntity *)collider;
//- (BOOL)doBoundsIntersect:(TBEntity *)first other:(TBEntity *)other;
@end
