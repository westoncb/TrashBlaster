//
//  TBPlayer.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/18/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBPlayer.h"
#import "TBSprite.h"
#import "TBBullet.h"
#import "TBBlock.h"
#import "TBAnimatedSprite.h"
#import "TBBlockMachine.h"

@interface TBPlayer()
@property const float INITIAL_SPEED;
@property const float ACCELERATION;
@property const float DECELERATION;
@property BOOL startedMoving;
@property BOOL goingRight;

@property float lastBulletTime;
@property float reloadTime;
@end
@implementation TBPlayer

- (id)initWithStateSprite:(TBStateSprite *)stateSprite bulletSprite:(TBSprite *)bulletSprite {
    self = [super initWithDrawable:stateSprite];
    if (self) {
        self.destPoints = [NSMutableArray array];
        self.INITIAL_SPEED = 50;
        self.maxSpeed = 300;
        self.ACCELERATION = 6000;
        self.DECELERATION = 12000;
        self.reloadTime = 0.1f;
        self.lastBulletTime = 0;
        self.type = PLAYER;
        self.collisionxoff = 10;
        self.collisionsize = CGSizeMake(self.collisionsize.width - 20, self.collisionsize.height);
        self.position = GLKVector2Make(TBWorld.WIDTH/2 - self.size.width/2, TBWorld.FLOOR_HEIGHT);
        self.keepImageAfterDeath = true;
        _bulletSprite = bulletSprite;
        _stateSprite = stateSprite;
    }
    
    return self;
}

- (void)addDestPointWithDestX:(float)destX destY:(float)destY
{
    if (!_deathBlock) {
        TBPoint *point = [[TBPoint alloc] init:destX y:destY];
        [self.destPoints addObject:point];
    }
}

- (void)addToAcceleration:(GLKVector2)newAcceleration
{
    self.acceleration = GLKVector2Add(self.acceleration, newAcceleration);
}

- (void)addToVelocity:(GLKVector2)newVelocity
{
    self.velocity = GLKVector2Add(self.velocity, newVelocity);
}

- (void)update:(float)dt {
    if (self.destPoints.count > 0) {
        _destPoint = [self.destPoints objectAtIndex:0];
        int colIndex = [[TBWorld instance] xPositionToColumn:_destPoint.x];
        TBBlock *topBlock = [[TBWorld instance].blockMachine getTopSettledBlockAtColIndex:colIndex];
        
        float destX = colIndex*32;
        float destY = self.position.y; //(topBlock != nil) ? (topBlock.position.y + topBlock.size.height) : TBWorld.FLOOR_HEIGHT;
        
        self.acceleration = GLKVector2Make(0, GRAVITY_ACCELERATION); //gravity
        
        GLKVector2 point = GLKVector2Make(destX, destY);
        GLKVector2 offset = GLKVector2Subtract(point, self.position);
        GLKVector2 direction = GLKVector2Normalize(offset);
        
        if(!self.startedMoving) { //Begin motion toward the next point
            self.deceleration = GLKVector2Make(0, 0);
            [self addToVelocity:GLKVector2MultiplyScalar(direction, self.INITIAL_SPEED)];
            [self addToAcceleration:GLKVector2MultiplyScalar(direction, self.ACCELERATION)];
            self.startedMoving = true;
            if(direction.x > 0) {
                self.goingRight = true;
                [_stateSprite changeState:@"run"];
            }
            else {
                self.goingRight = false;
                [_stateSprite changeState:@"run_xf"];
            }
            
            _running = YES;
        } else if(self.startedMoving && ((direction.x < 0 && self.goingRight) || (direction.x > 0 && !self.goingRight))) { //Arrived: start stopping
            [self.destPoints removeObjectAtIndex:0];
            self.acceleration = GLKVector2Make(0, GRAVITY_ACCELERATION); //gravity
            
            //It seems like the reverse direction should be used here, but since we only reach this point if we have PASSED our
            //destination, we can use 'direction'
            self.deceleration = GLKVector2MultiplyScalar(direction, self.DECELERATION);
            self.startedMoving = false;
            [_stateSprite changeState:@"shoot"];
            _running = NO;
        }
    }

    self.lastBulletTime += dt;
    if(self.lastBulletTime > self.reloadTime) {
        self.lastBulletTime -= self.reloadTime;
        [self fireBullet];
    }

    if (_deathBlock) {
        float distanceFromGround = _deathBlock.position.y - [self getGroundHeightBeneathPlayer];
        float scale = (distanceFromGround/self.size.height);
        float minScale = 10.0f/self.size.height;
        if (scale < minScale)
            scale = minScale;
        self.scale = GLKVector2Make(self.scale.x, scale);
        if (distanceFromGround < 1 || _deathBlock.velocity.y == 0)
            self.alive = false;
    }
    
    [super update:dt];
}

- (void)jump
{
    _jumping = YES;
    [self addToVelocity:GLKVector2Make(0, 150)];
}

- (void)updateMotion:(float)dt
{
    if (!_deathBlock)
        [super updateMotion:dt];
}

- (float)getGroundHeightBeneathPlayer
{
    return [self getGroundHeightAtPoint:self.position.x + self.size.width/2.0f];
}

- (float)getGroundHeightAtPoint:(float)posX
{
    TBWorld *world = [TBWorld instance];
    TBBlockMachine *blockMachine = world.blockMachine;
    
    //Determine floor height
    int column = [world xPositionToColumn:posX];
    TBBlock *underBlock = [blockMachine getTopSettledBlockAtColIndex:column];
    //    NSLog(@"resting: %i", underBlock.resting);
    float floorHeight = underBlock.position.y + underBlock.size.height;
    
    if (underBlock == blockMachine.dummyBlock || !underBlock)
        floorHeight = FLOOR_HEIGHT;
    
    return floorHeight;
}

- (GLKVector2)vetNewPosition:(GLKVector2)newPosition
{
    TBWorld *world = [TBWorld instance];
    TBBlockMachine *blockMachine = world.blockMachine;
    
    float playerXCenter = newPosition.x + self.size.width/2.0f;
    int column = [world xPositionToColumn:playerXCenter];
    TBBlock *underBlock = [blockMachine getTopSettledBlockAtColIndex:column];
    float floorHeight = [self getGroundHeightAtPoint:playerXCenter];
    
    //Floor collision
    GLKVector2 finalPosition = newPosition;
    if (newPosition.y < floorHeight) {
        self.velocity = GLKVector2Make(self.velocity.x, 0.0f);
        finalPosition = GLKVector2Make(newPosition.x, floorHeight);
        _jumping = NO;
    }
    
    //Jump when encountering an obstacle
    float offset = _goingRight ? 10 : -10;
    GLKVector2 testPoint = GLKVector2Make(playerXCenter + offset, self.position.y);
    int nextColumn = [world xPositionToColumn:testPoint.x];
    
    TBBlock *nextBlock = [blockMachine getTopSettledBlockAtColIndex:nextColumn];
    if (nextBlock &&
        nextBlock != blockMachine.dummyBlock &&
        !_jumping &&
        nextBlock != underBlock &&
        self.position.y < nextBlock.position.y) {
        
        [self jump];
        
    }
    
    return finalPosition;
}

- (void)handleCollision:(TBEntity *)collider wasTheProtruder:(BOOL)retractSelf
{
    [super handleCollision:collider wasTheProtruder:retractSelf];
    
    if (collider.type == BLOCK) {
        TBBlock *block = (TBBlock *)collider;
        if (block.velocity.y < -50 && !_deathBlock && [block shouldDamagePlayer])
            [self initiateDeathSequenceWithBlock:block];
    }
}

- (void)initiateDeathSequenceWithBlock:(TBBlock *)block
{
    float distanceFromGround = block.position.y - [self getGroundHeightBeneathPlayer];
    
    if (distanceFromGround > self.size.height/2.0f) {
        self.reloadTime = INT_MAX;
        _deathBlock = block;
        _deathBlock.life = INT_MAX;
        self.velocity = GLKVector2Make(0, 0);
        self.acceleration = GLKVector2Make(0, 0);
        [self.destPoints removeAllObjects];
    } else {
        
    }
}

- (void)fireBullet {
    TBBullet *bullet = [[TBBullet alloc] initWithDrawable:self.bulletSprite];
    if (!_running) {
        bullet.position = GLKVector2Make(self.position.x + self.size.width/2 - self.bulletSprite.size.width/2, self.position.y + self.size.height);
        
        bullet.velocity = GLKVector2Make(0, 300);
        bullet.rotation = 0.0f;
    }
    else {
        float xAdder = -10.0f;
        if (self.goingRight) {
            xAdder = self.size.width + 20.0f;
        }
        bullet.position = GLKVector2Make(self.position.x + xAdder, self.position.y + self.size.height/2 - 12.0f);
        
        GLKVector2 bulletPath = GLKVector2Make(_destPoint.x - bullet.position.x, _destPoint.y - bullet.position.y);
        
        if ((self.goingRight && bulletPath.x < 0) || (!self.goingRight && bulletPath.x > 0) || !_running)
            bulletPath.x = 0;
        
        GLKVector2 bulletDirection = GLKVector2Normalize(bulletPath);
        
        bullet.velocity = GLKVector2MultiplyScalar(bulletDirection, 300.0f);
        
        float positiveRotation = (acos(bulletDirection.x) - M_PI/2);
        float negativeRoatation = M_PI*2 - positiveRotation;
        bullet.rotation = bulletPath.y > 0 ? positiveRotation : negativeRoatation;
    }
    bullet.collisionxoff = 0;
    bullet.collisionyoff = 0;
    bullet.collisionsize = CGSizeMake(7, 24);
    bullet.type = BULLET;
    [bullet.collidesWith addObject:[NSNumber numberWithInt:BLOCK]];
    [[TBWorld instance] addEntity:bullet];
}
@end
