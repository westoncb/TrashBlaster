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

@end

@implementation TBEntity

- (id)initWithSprite:(TBSprite *)sprite {
    self = [super init];
    if(self) {
        _sprite = sprite;
        self.size = CGSizeMake(sprite.size.width, sprite.size.height);
        self.collisionsize = CGSizeMake(self.size.width, self.size.height);
        self.acceleration = GLKVector2Make(0, 0);
        self.deceleration = GLKVector2Make(0, 0);
        self.velocity = GLKVector2Make(0, 0);
        self.position = GLKVector2Make(0, 0);
        self.alive = true;
        self.maxSpeed = NSIntegerMax;
    }
    
    return self;
}

- (void)update:(float)dt {    
    GLKVector2 velocityIncrement = GLKVector2MultiplyScalar(self.acceleration, dt);
    
    float newXVol = self.velocity.x + velocityIncrement.x;
    float newYVol = self.velocity.y + velocityIncrement.y;
    if (fabsf(newXVol) > self.maxSpeed) { //cap xspeed
        float xDirection = newXVol/fabsf(newXVol);
        velocityIncrement = GLKVector2Make((self.maxSpeed*xDirection) - self.velocity.x, velocityIncrement.y);
    }
    if (fabsf(newYVol) > self.maxSpeed) { //cap yspeed
        float yDirection = newYVol/fabsf(newYVol);
        velocityIncrement = GLKVector2Make(velocityIncrement.x, (self.maxSpeed*yDirection) - self.velocity.y);
    }
    self.velocity = GLKVector2Add(self.velocity, velocityIncrement);
    
    //It simplifies things to handle deceleration seperately, rather than just treating it as reverse acceleration
    GLKVector2 velocityDecrement = GLKVector2MultiplyScalar(self.deceleration, dt);
    newXVol = self.velocity.x + velocityDecrement.x;
    newYVol = self.velocity.y + velocityDecrement.y;
    if (fabsf(newXVol) > fabsf(self.velocity.x)) { //deceleration should never increase speed -- dampen to zero instead
        velocityDecrement = GLKVector2Make(-self.velocity.x, velocityDecrement.y); //this will make the x velocity zero
        self.deceleration = GLKVector2Make(0, self.deceleration.y);
    }
    if (fabsf(newYVol) > fabsf(self.velocity.y)) { //same for the y-axis
        velocityDecrement = GLKVector2Make(velocityDecrement.x, -self.velocity.y);
        self.deceleration = GLKVector2Make(self.deceleration.x, 0);
    }
    
    self.velocity = GLKVector2Add(self.velocity, velocityDecrement);
    
    
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

- (void)handleCollision:(TBEntity *)collider wasTheProtruder:(BOOL)retractSelf {    
    if(retractSelf) {
        self.velocity = GLKVector2MultiplyScalar(self.velocity, -0.1f);
        do {
            [self updateMotion:_lastDelta];
        } while ((fabsf(self.xChange) > .001f || fabsf(self.yChange)) > .001f && [collider doCollisionCheck:self]);
        
        
        self.velocity = GLKVector2Make(self.velocity.x, 0);
        self.acceleration = GLKVector2Make(self.acceleration.x, 0);
    }
    
    //NSLog(@"collide");
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

- (NSString *)description {
    return [NSString stringWithFormat:@"entity width: %f, height: %f", self.size.width, self.size.height];
}
@end
