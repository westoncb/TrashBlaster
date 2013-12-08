//
//  TBPlayer.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/18/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBCreature.h"
#import "TBSprite.h"
#import "TBBullet.h"
#import "TBBlock.h"
#import "TBAnimatedSprite.h"
#import "TBBlockMachine.h"

@interface TBCreature()
@property BOOL startedMoving;
@property BOOL goingRight;

@property float lastBulletTime;
@end
@implementation TBCreature

- (id)initWithStateSprite:(TBStateSprite *)stateSprite bulletSprite:(TBSprite *)bulletSprite {
    self = [super initWithDrawable:stateSprite];
    if (self) {
        self.destPoints = [NSMutableArray array];
        self.INITIAL_SPEED = 50;
        self.maxSpeed = 300;
        self.ACCELERATION = 6000;
        self.DECELERATION = 12000;
        self.reloadTime = 0.05f;
        self.lastBulletTime = 0;
        self.type = PLAYER;
        self.collisionxoff = 26;
        self.collisionyoff = 4;
        self.collisionsize = CGSizeMake(self.collisionsize.width - 52, self.collisionsize.height - 8);
        self.position = GLKVector2Make(WIDTH/2 - self.size.width/2, FLOOR_HEIGHT - self.collisionyoff);
        self.keepImageAfterDeath = true;
        self.power = 5;
        _bulletSprite = bulletSprite;
        _stateSprite = stateSprite;
        _canShoot = NO;
        _circle = [NSMutableArray array];
    }
    
    return self;
}

- (void)activateGun
{
    if (!_gun) {
        TBSprite *gunSprite = [[TBSprite alloc] initWithFile:@"gun.png"];
        _gun = [[TBEntity alloc] initWithDrawable:gunSprite];
        [self addSubEntity:_gun attachX:(self.size.width/2 - _gun.size.width/2) attachY:40];
    }
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
        
        float destX = colIndex*32 - 16;
        float destY = self.position.y;
        
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
                [_stateSprite changeState:@"run_xf"];
            }
            else {
                self.goingRight = false;
                [_stateSprite changeState:@"run"];
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
    if(_canShoot && self.lastBulletTime > self.reloadTime) {
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
        if (distanceFromGround < 1 || _deathBlock.velocity.y == 0) {
            self.alive = false;
        }
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
    if (newPosition.y + self.collisionyoff < floorHeight) {
        self.velocity = GLKVector2Make(self.velocity.x, 0.0f);
        finalPosition = GLKVector2Make(newPosition.x, floorHeight - self.collisionyoff);
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
    
    GLKVector2 diff = GLKVector2Make(finalPosition.x - self.position.x, finalPosition.y - self.position.y);
    for (TBEntity *entity in _circle) {
        entity.position = GLKVector2Make(entity.position.x + diff.x, entity.position.y + diff.y);
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
    self.bulletSprite.yFlip = NO;
    TBBullet *bullet = [[TBBullet alloc] initWithDrawable:self.bulletSprite];
    bullet.damage = self.power;
    bullet.position = GLKVector2Make(self.position.x + self.size.width/2 - self.bulletSprite.size.width/2 + self.xChange, self.position.y + self.size.height - 10 + self.yChange);
    
    if (!_running && done) {
        bullet.velocity = GLKVector2Make(0, 300);
        bullet.rotation = 0.0f;
        _gun.rotation = 0.0f;
    }
    else {
        GLKVector2 bulletPath = GLKVector2Make(_destPoint.x - bullet.position.x, _destPoint.y - bullet.position.y);
        
        if ((self.goingRight && bulletPath.x < 0) || (!self.goingRight && bulletPath.x > 0) || !_running)
            bulletPath.x = 0;
        
        GLKVector2 bulletDirection = GLKVector2Normalize(bulletPath);
        
        bullet.velocity = GLKVector2MultiplyScalar(bulletDirection, 300.0f);
//        bullet.velocity = GLKVector2Subtract(bullet.velocity, self.velocity);
        
        float plainRotation = acos(bulletDirection.x);
        
        float positiveRotation = (plainRotation - M_PI/2);
        BOOL positive = bulletPath.y > 0;
        float negativeRotation = M_PI*2 - positiveRotation;
        
        _gun.rotation = positive ? positiveRotation : (negativeRotation + M_PI);
        
        if (bulletPath.y < 0) {
            plainRotation = M_PI*2 - plainRotation;
        }
        bullet.rotation = plainRotation - M_PI/2;
        
        float cosOfRotation = cos(plainRotation);
        float sizeOfBullet = 25;
        float xShift = cosOfRotation*sizeOfBullet;
        
        float sinOfRotation = sin(plainRotation);
        float yShift = sinOfRotation*sizeOfBullet;
        
        bullet.position = GLKVector2Make(bullet.position.x + xShift, bullet.position.y + yShift - 16);
    }
    
    bullet.collisionxoff = 0;
    bullet.collisionyoff = 0;
    bullet.collisionsize = CGSizeMake(7, 24);
    bullet.type = BULLET;
    [bullet.collidesWith addObject:[NSNumber numberWithInt:BLOCK]];
    [[TBWorld instance] addEntity:bullet];
}
BOOL done = false;

@end
