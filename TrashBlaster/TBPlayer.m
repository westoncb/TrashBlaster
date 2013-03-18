//
//  TBPlayer.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/18/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBPlayer.h"
#import "TBPoint.h"

@interface TBPlayer()
@property const float INITIAL_SPEED;
@property const float ACCELERATION;
@property const float DECELERATION;
@property BOOL startedMoving;
@property BOOL goingRight;
@end
@implementation TBPlayer
@synthesize destPoints;

- (id)initWithSprite:(TBSprite *)sprite {
    if ([super initWithSprite:sprite]) {
        self.destPoints = [NSMutableArray array];
        self.INITIAL_SPEED = 50;
        self.maxSpeed = 300;
        self.ACCELERATION = 6000;
        self.DECELERATION = 12000;
    }
    
    return self;
}

- (void)addDestPoint:(float)destx {
    TBPoint *point = [[TBPoint alloc] init:destx ycoord:0];
    [self.destPoints addObject:point];
}

- (void)update:(float)dt {
    if (self.destPoints.count > 0) {
        TBPoint *destPoint = [self.destPoints objectAtIndex:0];
        float destX = ((int)destPoint.x)/32*32;
        GLKVector2 point = GLKVector2Make(destX, self.position.y);
        GLKVector2 offset = GLKVector2Subtract(point, self.position);
        GLKVector2 direction = GLKVector2Normalize(offset);
        
        if(!self.startedMoving) { //Begin motion toward the next point
            self.deceleration = GLKVector2Make(0, 0);
            self.velocity = GLKVector2MultiplyScalar(direction, self.INITIAL_SPEED);
            self.acceleration = GLKVector2MultiplyScalar(direction, self.ACCELERATION);
            self.startedMoving = true;
            if(direction.x > 0)
                self.goingRight = true;
            else
                self.goingRight = false;
        } else if(self.startedMoving && ((direction.x < 0 && self.goingRight) || (direction.x > 0 && !self.goingRight))) { //Arrived: start stopping
            [self.destPoints removeObjectAtIndex:0];
            self.acceleration = GLKVector2Make(0, 0);
            
            //It seems like the reverse direction should be used here, but since we only reach this point if we have PASSED our
            //destination, we can use 'direction'
            self.deceleration = GLKVector2MultiplyScalar(direction, self.DECELERATION);
            self.startedMoving = false;
        }
    }
    
    [super update:dt];
}
@end
