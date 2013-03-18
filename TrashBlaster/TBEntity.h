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
@property float xChange;
@property float yChange;
@property int type;

typedef enum {
    BLOCK,
    PLAYER,
    BULLET
} EntityType;

- (id)initWithSprite:(TBSprite *)sprite;
- (void)update:(float)dt;
- (void)render;
- (BOOL)doCollisionCheck:(TBEntity *)other;
- (void)handleCollision:(TBEntity *)collider wasTheProtruder:(BOOL)retractSelf ;
//- (BOOL)doBoundsIntersect:(TBEntity *)first other:(TBEntity *)other;
@end
