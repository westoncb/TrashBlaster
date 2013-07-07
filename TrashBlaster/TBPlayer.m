//
//  TBPlayer.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/18/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBPlayer.h"
#import "TBPoint.h"
#import "TBSprite.h"
#import "TBBullet.h"
#import "TBBlock.h"

@interface TBPlayer()
@property const float INITIAL_SPEED;
@property const float ACCELERATION;
@property const float DECELERATION;
@property BOOL startedMoving;
@property BOOL goingRight;
@property (weak) TBWorld *world;

@property float lastBulletTime;
@property float reloadTime;
@end
@implementation TBPlayer

- (id)initWithSprite:(TBSprite *)sprite bulletSprite:(TBSprite *)theBulletSprite world:(TBWorld *)world {
    self = [super initWithSprite:sprite];
    if (self) {
        self.destPoints = [NSMutableArray array];
        self.INITIAL_SPEED = 50;
        self.maxSpeed = 300;
        self.ACCELERATION = 6000;
        self.DECELERATION = 12000;
        self.reloadTime = 0.1f;
        self.lastBulletTime = 0;
        self.type = PLAYER;
        self.world = world;
        self.collisionxoff = 7;
        self.collisionsize = CGSizeMake(self.collisionsize.width - 14, self.collisionsize.height);
        self.position = GLKVector2Make(TBWorld.WIDTH/2 - self.size.width/2, TBWorld.FLOOR_HEIGHT);
        self.keepImageAfterDeath = true;
        _bulletSprite = theBulletSprite;
    }
    
    return self;
}

- (void)addDestPoint:(float)destx {
    if (!_deathBlock) {
        TBPoint *point = [[TBPoint alloc] init:destx y:0];
        [self.destPoints addObject:point];
    }
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
    
    self.lastBulletTime += dt;
    if(self.lastBulletTime > self.reloadTime) {
        self.lastBulletTime -= self.reloadTime;
        [self fireBullet];
    }
    
    if (_deathBlock) {
        float distanceFromGround = _deathBlock.position.y - TBWorld.FLOOR_HEIGHT;
        float scale = (distanceFromGround/self.size.height);
        float minScale = 10.0f/self.size.height;
        if (scale < minScale)
            scale = minScale;
        self.scale = GLKVector2Make(self.scale.x, scale);
        if (distanceFromGround < 1)
            self.alive = false;
    }
    
    [super update:dt];
}

- (void)handleCollision:(TBEntity *)collider wasTheProtruder:(BOOL)retractSelf {
    [super handleCollision:collider wasTheProtruder:retractSelf];
    
    if (collider.type == BLOCK) {
        TBBlock *block = (TBBlock *)collider;
        if (block.velocity.y < -50 && !_deathBlock)
            [self initiateDeathSequenceWithBlock:block];
    }
}

- (void)initiateDeathSequenceWithBlock:(TBBlock *)block
{
    float distanceFromGround = block.position.y - TBWorld.FLOOR_HEIGHT;
    
    if (distanceFromGround > self.size.height/2.0f) {
        self.reloadTime = INT_MAX;
        _deathBlock = block;
        self.velocity = GLKVector2Make(0, 0);
        self.acceleration = GLKVector2Make(0, 0);
        [self.destPoints removeAllObjects];
    } else {
        
    }
}

- (void)fireBullet {
    TBBullet *bullet = [[TBBullet alloc] initWithSprite:self.bulletSprite];
    bullet.position = GLKVector2Make(self.position.x + self.size.width/2 - self.bulletSprite.size.width/2, self.position.y + self.size.height);
    bullet.velocity = GLKVector2Make(self.velocity.x/2, 300);
    bullet.collisionxoff = 0;
    bullet.collisionyoff = 0;
    bullet.collisionsize = CGSizeMake(7, 24);
    bullet.type = BULLET;
    [bullet.collidesWith addObject:[NSNumber numberWithInt:BLOCK]];
    [self.world addEntity:bullet];
}
@end
