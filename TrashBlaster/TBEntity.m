//
//  TBEntity.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/17/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBEntity.h"
@interface TBEntity()
@property float lastDelta;
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

- (id)initWithSprite:(TBSprite *)sprite {
    if(([super init])) {
        self.sprite = sprite;
        self.size = CGSizeMake(sprite.size.width, sprite.size.height);
        self.alive = true;
    }
    
    return self;
}

- (void)update:(float)dt {
    if(self.alive) {
        GLKVector2 velocityIncrement = GLKVector2MultiplyScalar(self.acceleration, dt);
        self.velocity = GLKVector2Add(self.velocity, velocityIncrement);
        [self updateMotion:dt];
        self.lastDelta = dt;
    }
}

- (void)updateMotion:(float)dt {
    self.position = GLKVector2Add(self.position, self.velocity);
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

- (void)handleCollision:(TBEntity *)collider wasTheProtruder:(BOOL)retractSelf {
    if(retractSelf) {
        self.alive = false;
        self.velocity = GLKVector2MultiplyScalar(self.velocity, -0.1f);
        do {
            [self updateMotion:lastDelta];
        } while([collider doCollisionCheck:self]);
    }
    self.velocity = GLKVector2Make(0, 0);
    NSLog(@"collision!");
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
