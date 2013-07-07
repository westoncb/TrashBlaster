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
#import "TBWorld.h"


@interface TBEntity : NSObject
@property GLKVector2 acceleration;
@property GLKVector2 deceleration;
@property GLKVector2 velocity;
@property GLKVector2 position;
@property GLKVector2 scale;
@property CGSize size;
@property float collisionxoff;
@property float collisionyoff;
@property CGSize collisionsize;
@property TBSprite *sprite;
@property BOOL alive;
@property BOOL keepImageAfterDeath;
@property float xChange;
@property float yChange;
@property int type;
@property float maxSpeed;
@property (weak) TBWorld *world;
@property NSMutableArray *collidesWith;
@property int life;

typedef enum {
    BLOCK,
    PLAYER,
    BULLET,
    DECORATION
} EntityType;

- (id)initWithSprite:(TBSprite *)sprite;
- (void)update:(float)dt;
- (void)render;
- (BOOL)doCollisionCheck:(TBEntity *)other;
- (void)handleCollision:(TBEntity *)collider wasTheProtruder:(BOOL)retractSelf;
//- (BOOL)doBoundsIntersect:(TBEntity *)first other:(TBEntity *)other;
@end
