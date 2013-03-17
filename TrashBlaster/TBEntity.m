//
//  TBEntity.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/17/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBEntity.h"

@implementation TBEntity
@synthesize position = _position;
@synthesize size = _size;
@synthesize velocity = _velocity;
@synthesize acceleration = _acceleration;
@synthesize sprite = _sprite;

- (id)initWithSprite:(TBSprite *)sprite {
    if(([super init])) {
        self.sprite = sprite;
        self.size = CGSizeMake(sprite.size.width, sprite.size.height);
    }
    
    return self;
}

- (void)update:(float)dt {
    GLKVector2 velocityIncrement = GLKVector2MultiplyScalar(self.acceleration, dt);
    self.velocity = GLKVector2Add(self.velocity, velocityIncrement);
    //GLKVector2 curMove = GLKVector2MultiplyScalar(self.velocity, dt);
    self.position = GLKVector2Add(self.position, self.velocity);
}

- (void)render {
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, 0);
    [self.sprite render:modelMatrix];
}

- (NSComparisonResult)compare:(TBEntity *)otherObject {
    return otherObject.position.y - self.position.y;
    
}
@end
