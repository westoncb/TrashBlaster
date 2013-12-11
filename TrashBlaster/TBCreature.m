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
#import "TBEvent.h"
#import "TBPlayer.h"
#import "TBGame.h"

@interface TBCreature()
@property BOOL startedMoving;
@property BOOL goingRight;

@property float lastBulletTime;
@end

@implementation TBCreature
@synthesize reloadTime = _reloadTime;
@synthesize power = _power;

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
        _glows = [NSMutableArray array];
        _skeletons = [NSMutableArray array];
    }
    
    return self;
}

- (void)increaseGlow
{
    if (_glows.count < 4) {
        TBSprite *glowSprite = [[TBSprite alloc] initWithFile:@"glow3.png"];
        TBEntity *glow = [[TBEntity alloc] initWithDrawable:glowSprite];
        [self addSubEntity:glow];
        glow.scale = GLKVector2Make(0, 0);
        glow.layer = 1;
        glow.color = GLKVector4Make(1, 0, 0, 1);
        glowSprite.additiveBlending = YES;

        [_glows addObject:glow];

        TBEvent *event = [[TBEvent alloc] initWithHandler:^(float progress) {
            glow.scale = GLKVector2Make(progress*progress, progress*progress);
            [self changeAttachmentPointForSubEntity:glow attachX:self.size.width/2 - glow.size.width/2*progress
                       attachY:self.size.height/2 - glow.size.height/2*progress];
        } completion:^{
            glow.scale = GLKVector2Make(1.0, 1.0);
            [self changeAttachmentPointForSubEntity:glow attachX:self.size.width/2 - glow.size.width/2
                                            attachY:self.size.height/2 - glow.size.height/2];
        } duration:0.6f repeat:NO];
        [event start];
    } else if (_skeletons.count < 4) {
        TBAnimationInfo animationInfo;
        animationInfo.frameWidth = 64;
        animationInfo.frameHeight = 64;
        animationInfo.frameCount = 9;
        animationInfo.frameLength = 50;
        animationInfo.loop = YES;
        
        TBAnimatedSprite *walkingSkeletonSprite = [[TBAnimatedSprite alloc] initWithFile:@"BODY_skeleton.png" animationInfo:animationInfo row:2];
        TBSprite *shootingSkeletonSprite = [[TBSprite alloc] initWithFile:@"BODY_skeleton.png" col:4 row:1];
        NSMutableDictionary *shirtMap = [[NSMutableDictionary alloc] init];
        [shirtMap setValue:walkingSkeletonSprite forKey:@"run"];
        [shirtMap setValue:walkingSkeletonSprite forKey:@"run_xf"];
        [shirtMap setValue:shootingSkeletonSprite forKey:@"shoot"];
        TBStateSprite *skeletonSprite = [[TBStateSprite alloc] initWithStateMap:shirtMap initialState:@"shoot"];
        
        TBStateSprite *creatureSprite = (TBStateSprite *)self.drawable;
        [creatureSprite linkSprite:skeletonSprite];
        
        [_skeletons addObject:skeletonSprite];
    }
}

- (void)endGlow
{
    for (TBEntity *glow in _glows) {
        [self removeSubEntity:glow];
    }
    
    for (TBStateSprite *skeleton in _skeletons) {
        TBStateSprite *creatureSprite = (TBStateSprite *)self.drawable;
        [creatureSprite unlinkSprite:skeleton];
    }
    
    [_glows removeAllObjects];
    [_skeletons removeAllObjects];
}

- (void)activateGun
{
    if (!_gun) {
        TBSprite *gunSprite = [[TBSprite alloc] initWithFile:@"gun.png"];
        _gun = [[TBEntity alloc] initWithDrawable:gunSprite];
        _gun.layer = 6;
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

- (void)updateWithTimeDelta:(float)delta {
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

    [self updateGunWithTimeDelta:delta];

    if (_deathBlock) {
        if (self.position.y + self.size.height > _deathBlock.position.y + _deathBlock.collisionyoff*2)
            self.position = GLKVector2Make(self.position.x, _deathBlock.position.y + _deathBlock.collisionyoff*2 - self.size.height);
        float distanceFromGround = _deathBlock.position.y - [self getGroundHeightBeneathPlayer];
        float yScale = (distanceFromGround/[self baseSize].height);
        float minYScale = 0.1;
        if (yScale < minYScale)
            yScale = minYScale;
        float xScale = 1.0f;
//        float xScale = 1.0f/(yScale);
//        if (xScale > 1.8f)
//            xScale = 1.8f;
        
        self.scale = GLKVector2Make(xScale, yScale);
        if (distanceFromGround < 1 || _deathBlock.velocity.y == 0) {
            self.alive = false;
        }
    }
    
    [super updateWithTimeDelta:delta];
}

- (void)updateGunWithTimeDelta:(float)delta
{
    self.lastBulletTime += delta;
    if(_canShoot && self.lastBulletTime > self.reloadTime && !_deathBlock) {
        self.lastBulletTime -= self.reloadTime;
        [self fireBullet];
    }
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
    if (column >= NUM_COLS)
        column = NUM_COLS - 1;
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
        self.position.y < nextBlock.position.y &&
        fabsf(self.velocity.x > 20)) {
        
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
        float distanceFromGround = block.position.y - [self getGroundHeightBeneathPlayer];
        if (block.velocity.y < -50 && !_deathBlock && [block shouldDamagePlayer] && distanceFromGround <= self.size.height)
            [self initiateDeathSequenceWithBlock:block];
    }
    
    if (self.type == NPC) {
        if (collider.type == BULLET) {
            TBBullet *bullet = (TBBullet *)collider;
            self.life -= bullet.damage;
            
            if (self.life <= 0) {
                if (self.type == NPC)
                {
                    [[TBGame instance] blockWasDestroyed];
                    [[TBWorld instance] createPointDisplayAtEntity:self];
                }
            }
        }
    }
}

- (void)initiateDeathSequenceWithBlock:(TBBlock *)block
{
    float distanceFromGround = block.position.y - [self getGroundHeightBeneathPlayer];
    
    if (distanceFromGround > self.size.height/2.0f) {
//        self.reloadTime = INT_MAX;
        _deathBlock = block;
//        _deathBlock.life = INT_MAX;
        self.velocity = GLKVector2Make(0, 0);
        self.acceleration = GLKVector2Make(0, 0);
        [self.destPoints removeAllObjects];
    } else {
        
    }
}

- (float)reloadTime
{
    return _reloadTime;
}

- (void)setReloadTime:(float)reloadTime
{
    _reloadTime = reloadTime;
}

- (int)power
{
    return _power;
}

- (void)setPower:(int)power
{
    _power = power;
}

- (void)fireBullet
{
    self.bulletSprite.yFlip = NO;
    TBBullet *bullet = [[TBBullet alloc] initWithDrawable:self.bulletSprite];
    bullet.damage = self.power;
    bullet.position = GLKVector2Make(self.position.x + self.size.width/2 - bullet.size.width/2 + self.xChange, self.position.y + self.size.height - 10 + self.yChange);
    
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
        float sizeOfGun = 25;
        float xShift = cosOfRotation*sizeOfGun;
        
        float sinOfRotation = sin(plainRotation);
        float yShift = sinOfRotation*sizeOfGun;
        
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
