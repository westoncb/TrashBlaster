//
//  TBBlock.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 7/6/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBBlock.h"
#import "TBBullet.h"
#import "TBCreature.h"
#import "TBExplosion.h"
#import "TBBlockMachine.h"
#import "TBStringSprite.h"
#import "TBEvent.h"
#import "TBGame.h"

@implementation TBBlock
- (id)initWithSprite:(TBSprite *)sprite
{
    self = [super initWithDrawable:sprite];
    
    if (self) {
        self.collisionxoff = 2;
        self.collisionyoff = 6;
        self.collisionsize = CGSizeMake(self.size.width-6, self.size.height-6);
        self.position = GLKVector2Make(0, HEIGHT - (self.size.height-self.collisionyoff));
        self.type = BLOCK;
        _initialLife = 75;
        self.life = _initialLife;
        _resting = NO;
        _initialFall = YES;
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
//        TBSprite *sprite = (TBSprite *)self.drawable;
//        sprite.color = GLKVector4Make(1, (self.life/_initialLife), (self.life/_initialLife), 1.0f);
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
    
    [[TBGame instance] blockWasDestroyed];
    [[TBWorld instance] blockWasDestroyed];
}

- (int)getColumnIndex
{
    return self.position.x/self.size.width;
}

- (void)createPointDisplayAtPoint:(GLKVector2)point
{
    int pointValue = [[TBGame instance] getCurrentBlockValue];
    TBStringSprite *stringSprite = [[TBStringSprite alloc] initWithString:[NSString stringWithFormat:@"%i", pointValue]];
    TBEntity *stringEntity = [[TBEntity alloc] initWithDrawable:stringSprite];
    float bonusRatio = [TBGame instance].bonusLevel/((float)MAX_BONUS_LEVEL);
    if (bonusRatio > 1)
        bonusRatio = 1;
    
    float scale = 1 + bonusRatio;
    stringEntity.scale = GLKVector2Make(scale, scale);
    stringSprite.color = GLKVector4Make((1 - bonusRatio), 1, (1 - bonusRatio), 1);
    stringEntity.position = GLKVector2Make(point.x + self.size.width/2 - stringEntity.size.width/2, point.y + stringSprite.size.height/2);

    //Keep the string on screen
    if (stringEntity.position.x + stringEntity.size.width > WIDTH)
        stringEntity.position = GLKVector2Make(WIDTH - stringEntity.size.width, stringEntity.position.y);
    else if (stringEntity.position.x < 0)
        stringEntity.position = GLKVector2Make(0, stringEntity.position.y);
    
    stringEntity.velocity = self.velocity;
    
    //Shrink it down on the y-axis through time
    TBEvent *event = [[TBEvent alloc] initWithHandler:^(float progress) {
        stringEntity.scale = GLKVector2Make(scale, scale*(1 - progress*progress*progress));
    } completion:^{
        stringEntity.alive = NO;
    } duration:1.0f repeat:NO];
    [event start];
    
    //Popping effect
    stringEntity.velocity = GLKVector2Add(stringEntity.velocity, GLKVector2Make(0, 200));
    stringEntity.acceleration = GLKVector2Make(0, -250);
    
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
//    self.scale = GLKVector2Make(2, 2);
    
//    TBEvent *event = [[TBEvent alloc] initWithHandler:^(float progress) {
//        self.scale = GLKVector2Make(2.0, 2*(1 - progress*progress*progress));
//    } completion:^{
//        self.alive = NO;
//    } duration:0.35f repeat:NO];
//    [event start];
    
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
