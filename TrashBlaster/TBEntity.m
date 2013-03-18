//
//  TBEntity.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/17/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBEntity.h"
#import "TBPoint.h"

@interface TBEntity()
@property float lastDelta;
@property NSMutableArray *destPoints;
@end

@implementation TBEntity
@synthesize position = _position;
@synthesize size = _size;
@synthesize collisionxoff = _collisionxoff;
@synthesize collisionyoff = _collisionyoff;
@synthesize collisionsize = _collisionsize;
@synthesize velocity = _velocity;
@synthesize acceleration = _acceleration;
@synthesize sprite = _sprite;
@synthesize alive = _alive;
@synthesize lastDelta;
@synthesize xChange;
@synthesize yChange;
@synthesize type;
@synthesize destPoints;

- (id)initWithSprite:(TBSprite *)sprite {
    if(([super init])) {
        self.sprite = sprite;
        self.size = CGSizeMake(sprite.size.width, sprite.size.height);
        self.alive = true;
        self.destPoints = [NSMutableArray array];
    }
    
    return self;
}

- (void)update:(float)dt {
    if (self.destPoints.count > 0) {
        TBPoint *destPoint = [self.destPoints objectAtIndex:0];
        GLKVector2 point = GLKVector2Make(destPoint.x, self.position.y);
        GLKVector2 offset = GLKVector2Subtract(point, self.position);
        if(fabsf(offset.x) < 3) {
            [self.destPoints removeObjectAtIndex:0];
            self.velocity = GLKVector2Make(0, 0);
        } else {
            GLKVector2 normalizedOffset = GLKVector2Normalize(offset);
            self.velocity = GLKVector2MultiplyScalar(normalizedOffset, 100);
        }
    }
    
    GLKVector2 velocityIncrement = GLKVector2MultiplyScalar(self.acceleration, dt);
    self.velocity = GLKVector2Add(self.velocity, velocityIncrement);
    [self updateMotion:dt];
    self.lastDelta = dt;
}

- (void)updateMotion:(float)dt {
    GLKVector2 positionIncrement = GLKVector2MultiplyScalar(self.velocity, dt);
    GLKVector2 old = GLKVector2Make(self.position.x, self.position.y);
    self.position = GLKVector2Add(self.position, positionIncrement);
    self.xChange = self.position.x - old.x;
    self.yChange = self.position.y - old.y;
}

- (void)render {
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, 0);
    [self.sprite render:modelMatrix];
}

- (BOOL)doCollisionCheck:(TBEntity *)other {
    if([self doBoundsIntersect:self other:other]) {
        return TRUE;
    } else
        return FALSE;
}

- (void)addDestPoint:(float)destx {
    TBPoint *point = [[TBPoint alloc] init:destx y:0];
    [self.destPoints addObject:point];
}

- (void)handleCollision:(TBEntity *)collider wasTheProtruder:(BOOL)retractSelf {    
    if(retractSelf) {
        self.velocity = GLKVector2MultiplyScalar(self.velocity, -0.1f);
        do {
            [self updateMotion:lastDelta];
        } while ((fabsf(self.xChange) > .001f || fabsf(self.yChange)) > .001f && [collider doCollisionCheck:self]);
        
        
        self.velocity = GLKVector2Make(self.velocity.x, 0);
        self.acceleration = GLKVector2Make(self.acceleration.x, 0);
    }
    
    NSLog(@"collide");
}

- (float)collisionx1 {
    return self.position.x + self.collisionxoff;
}

- (float)collisionx2 {
    return self.position.x + self.collisionxoff + self.collisionsize.width;
}

- (float)collisiony1 {
    return self.position.y+self.size.height - self.collisionyoff;
}

- (float)collisiony2 {
    return self.position.y+self.size.height - self.collisionyoff - self.collisionsize.height;
}

- (BOOL)doBoundsIntersect:(TBEntity *)first other:(TBEntity *)second {
    if (([first collisionx1] <= [second collisionx1] && [first collisionx2] >= [second collisionx1] &&
        [first collisiony1] >= [second collisiony1] && [first collisiony2] <= [second collisiony1]) ||
        ([first collisionx1] <= [second collisionx2] && [first collisionx2] >= [second collisionx2] &&
         [first collisiony1] >= [second collisiony1] && [first collisiony2] <= [second collisiony1]) ||
        ([first collisionx1] <= [second collisionx1] && [first collisionx2] >= [second collisionx1] &&
         [first collisiony1] >= [second collisiony2] && [first collisiony2] <= [second collisiony2]) ||
        ([first collisionx1] <= [second collisionx2] && [first collisionx2] >= [second collisionx2] &&
         [first collisiony1] >= [second collisiony2] && [first collisiony2] <= [second collisiony2])) {
        return true;
    }
    return FALSE;
}

- (NSComparisonResult)compare:(TBEntity *)otherObject {
    return otherObject.position.y - self.position.y;
    
}
@end
