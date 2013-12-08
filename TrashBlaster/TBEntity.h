//
//  TBEntity.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/17/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <Foundation/Foundation.h>
#import "TBDrawable.h"
#import "TBWorld.h"


@interface TBEntity : NSObject {
    NSMutableArray *_subEntities;
    NSMutableArray *_attachmentPoints;
}

@property TBEntity *parent;
@property GLKVector2 acceleration;
@property GLKVector2 deceleration;
@property GLKVector2 velocity;
@property GLKVector2 position;
@property GLKVector2 scale;
@property float rotation;
@property CGSize size;
@property float collisionxoff;
@property float collisionyoff;
@property CGSize collisionsize;
@property id<TBDrawable> drawable;
@property BOOL alive;
@property BOOL keepImageAfterDeath;
@property float xChange;
@property float yChange;
@property int type;
@property float maxSpeed;
@property (weak) TBWorld *world;
@property NSMutableArray *collidesWith;
@property int life;
@property BOOL dragging;
@property CGPoint touchPoint;

typedef enum {
    BLOCK,
    PLAYER,
    BULLET,
    DECORATION,
    NPC,
    CONTROL_POINT
} EntityType;

- (id)initWithDrawable:(id<TBDrawable>)drawable;
- (void)update:(float)dt;
- (void)render;
- (BOOL)doCollisionCheck:(TBEntity *)other;
- (void)handleCollision:(TBEntity *)collider wasTheProtruder:(BOOL)retractSelf;
- (void)addSubEntity:(TBEntity *)entity;
- (void)addSubEntity:(TBEntity *)entity attachX:(float)x attachY:(float)y;
//- (BOOL)doBoundsIntersect:(TBEntity *)first other:(TBEntity *)other;
- (void)updateMotion:(float)dt;
- (GLKVector2)vetNewPosition:(GLKVector2)newPosition;
@end
