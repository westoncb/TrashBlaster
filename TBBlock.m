//
//  TBBlock.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 7/6/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBBlock.h"
#import "TBBullet.h"
#import "TBPlayer.h"
#import "TBExplosion.h"
#import "TBBlockMachine.h"
#import "TBStringSprite.h"

@implementation TBBlock
- (id)initWithSprite:(TBSprite *)sprite
{
    self = [super initWithDrawable:sprite];
    
    if (self) {
        self.collisionxoff = 2;
        self.collisionyoff = 3;
        self.collisionsize = CGSizeMake(self.size.width-6, self.size.height-6);
        self.position = GLKVector2Make(0, TBWorld.HEIGHT - (self.size.height-self.collisionyoff));
        self.type = BLOCK;
        self.life = 90;
        _resting = NO;
        _initialFall = YES;
        _pointValue = 10;
    }
    
    return self;
}

- (void)handleCollision:(TBEntity *)collider wasTheProtruder:(BOOL)retractSelf {
    [super handleCollision:collider wasTheProtruder:retractSelf];
    
    if (collider.type == BULLET) {
        self.velocity = GLKVector2Make(0, self.velocity.y + 2);
        if (self.velocity.y > 0)
            self.velocity = GLKVector2Make(0, 0);
        TBBullet *bullet = (TBBullet *)collider;
        self.life -= bullet.damage;
        [self createBulletHitEffectAtPoint:bullet.position];
        
    } else if (collider.type == PLAYER) {
        if (!_hitPlayer) {
            _hitPlayer = true;
            self.velocity = GLKVector2Make(self.velocity.x, self.velocity.y * 0.75f);
        }
    }
}

- (void)handleDeath
{
    [self createExplosionAtPoint:self.position];
    [self createPointDisplayAtPoint:self.position];
    
    TBBlockMachine *blockMachine = [TBWorld instance].blockMachine;
    int colIndex = [self getColumnIndex];
    [blockMachine alterColumnCount:colIndex adder:-1];
    
    TBBlock *topBlock = [blockMachine getTopBlockAtColIndex:colIndex];
    if (topBlock == self) {
        TBBlock *newTopBlock = _blockBelow != nil ? _blockBelow : blockMachine.dummyBlock;
        [blockMachine setTopBlockAtColIndex:colIndex block:newTopBlock];
    }

    TBBlock *tempBlockAbove = _blockAbove;
    [self removeBlockAbove];
    [tempBlockAbove setToFallingState];
    [tempBlockAbove setBlockBelow:_blockBelow];
    
    [[TBWorld instance] addToScore:_pointValue];
}

- (int)getColumnIndex
{
    return self.position.x/self.size.width;
}

- (void)createPointDisplayAtPoint:(GLKVector2)point
{
    TBStringSprite *stringSprite = [[TBStringSprite alloc] initWithString:[NSString stringWithFormat:@"%i", _pointValue]];
    TBEntity *stringEntity = [[TBEntity alloc] initWithDrawable:stringSprite];
    stringEntity.scale = GLKVector2Make(1.0f, 1.0f);
    stringEntity.position = GLKVector2Make(0, 0);
    stringEntity.position = point;
    stringEntity.velocity = self.velocity;
//    stringEntity.velocity = GLKVector2Add(stringEntity.velocity, GLKVector2Make(0, 200));
//    stringEntity.acceleration = GLKVector2Make(0, -250);
    [[TBWorld instance] addEntity:stringEntity];
}

- (void)createExplosionAtPoint:(GLKVector2)point
{
    TBAnimationInfo animInfo;
    animInfo.frameCount = 5;
    animInfo.frameWidth = 72;
    animInfo.frameHeight = 81;
    animInfo.frameLength = 75;
    animInfo.loop = NO;
    float animationLength = (animInfo.frameLength * animInfo.frameCount)/1000.0f;
    TBAnimatedSprite *sprite = [[TBAnimatedSprite alloc] initWithFile:@"bigexplosion.png" animationInfo:animInfo];
    TBExplosion *explosion = [[TBExplosion alloc] initWithDrawable:sprite duration:animationLength];
    explosion.position = point;
    explosion.velocity = GLKVector2MultiplyScalar(self.velocity, 0.75f);
    
    [[TBWorld instance] addEntity:explosion];
}


- (void)createBulletHitEffectAtPoint:(GLKVector2)point
{
    TBSprite *sprite = [[TBSprite alloc] initWithFile:@"tinyexplosion.png"];
    TBExplosion *explosion = [[TBExplosion alloc] initWithDrawable:sprite duration:0.2f];
    explosion.position = point;
    explosion.velocity = GLKVector2MultiplyScalar(self.velocity, 0.9f);
    
    [[TBWorld instance] addEntity:explosion];
}

- (void)setBlockAbove:(TBBlock *)block
{
    _blockAbove = block;
}

- (void)removeBlockAbove
{
    _blockAbove = nil;
}

- (void)setBlockBelow:(TBBlock *)block
{   
    _blockBelow = block;
}

- (TBBlock *)getBlockBelow
{
    return _blockBelow;
}

- (void)removeBlockBelow
{
    _blockBelow = nil;
}

- (void)setToFallingState
{
    [self setAcceleration:GLKVector2Make(0, BLOCK_ACCELERATION)];
    [self setVelocity:GLKVector2Make(0, INITIAL_BLOCK_VELOCITY)];
    
    if (_blockAbove) {
        [_blockAbove setToFallingState];
    }
    
    _resting = NO;
}

- (void)setToRestingState
{
    [self setAcceleration:GLKVector2Make(0, 0)];
    [self setVelocity:GLKVector2Make(0, 0)];
    _initialFall = NO;
    _resting = YES;
}

- (BOOL)shouldDamagePlayer
{
    return _initialFall; //If it's not the initial fall, we don't want to damage the player; this is for the case where
                         //the player is shooting up at some boxes stacked above him and they topple down, potentially
                         //before he has time to blast them.
}

@end
