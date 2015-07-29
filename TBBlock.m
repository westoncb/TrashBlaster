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
#import "TBParticleEmitter.h"

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
        _resting = YES;
        _initialFall = YES;
        self.layer = 8;
    }
    
    return self;
}

- (void)handleCollision:(TBEntity *)collider wasTheProtruder:(BOOL)retractSelf {
    [super handleCollision:collider wasTheProtruder:retractSelf];
    
    if (collider.type == BULLET) {
        self.velocity = GLKVector2Make(0, self.velocity.y + 2);
        if (self.velocity.y > -20)
            self.velocity = GLKVector2Make(0, -20);
        TBBullet *bullet = (TBBullet *)collider;
        
        self.life -= bullet.damage;
        
//        self.color = GLKVector4Make(1, (self.life/_initialLife), (self.life/_initialLife), 1.0f);
        [self createBulletHitEffectAtEntity:self];
    } else if (collider.type == PLAYER || collider.type == NPC) {
        if (!_hitPlayer) {
            _hitPlayer = true;
            self.velocity = GLKVector2Make(self.velocity.x, self.velocity.y * 0.75f);
        }
    }
}

- (void)updateWithTimeDelta:(float)delta
{
    [super updateWithTimeDelta:delta];
}

- (void)handleDeath
{
    [self createExplosionAtEntity:self];
    [[TBWorld instance] createPointDisplayAtEntity:self];
    
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
}

- (int)getColumnIndex
{
    return self.position.x/self.size.width;
}

- (void)createBulletHitEffectAtEntity:(TBEntity *)entity
{
    TBParticleEmitter *emmitter2 = [[TBParticleEmitter alloc] initWithParticleCount:10
                                                                           lifetime:0.3f
                                                                          spawnRate:0.001f
                                                                           position:GLKVector2Make(0, 0)
                                                                           velocity:GLKVector2Make(0, 0)
                                                                       acceleration:GLKVector2Make(0, 0)
                                                                         startScale:2 endScale:4 startColor:GLKVector4Make(0, 0, 0, 1) endColor:GLKVector4Make(1, 1, 1, 0)];
    [emmitter2 setVariationWithLifetime:0.08f
                              spawnRate:0.00
                               position:GLKVector2Make(25, 25)
                               velocity:GLKVector2Make(50, 50)
                           acceleration:GLKVector2Make(0, 0)
                             startScale:0.75f endScale:1 startColor:GLKVector4Make(0, 0, 0, 0) endColor:GLKVector4Make(0, 0, 0, 0)];
    
    [[TBWorld instance] addEntity:emmitter2];
    
    emmitter2.layer = 12;
    emmitter2.position = GLKVector2Make(entity.position.x + entity.size.width/2, entity.position.y + entity.size.height/2);
    emmitter2.velocity = entity.velocity;
    emmitter2.additiveBlending = NO;
    [emmitter2 limitEffectLifetimeWithTime:0.3f];
    
    //    TBSprite *sprite = [[TBSprite alloc] initWithFile:@"tinyexplosion.png"];
    //    TBExplosion *explosion = [[TBExplosion alloc] initWithDrawable:sprite duration:0.2f];
    //    explosion.layer = 11;
    //    GLKVector2 entityCenter = GLKVector2Make(entity.position.x + entity.size.width/2 - explosion.size.width/2,
    //                                             entity.position.y + entity.size.height/2 - explosion.size.height/2);
    //    float xVariation = arc4random_uniform(entity.size.width/2.0f);
    //    float yVariation = arc4random_uniform(entity.size.height/2.0f);
    //    xVariation -= entity.size.width/4.0f;
    //    yVariation -= entity.size.height/4.0f;
    //
    //    GLKVector2 position = GLKVector2Make(entityCenter.x + xVariation, entityCenter.y + yVariation);
    //    explosion.position = position;
    //    explosion.velocity = GLKVector2MultiplyScalar(entity.velocity, 0.9f);
    //    
    //    [self addEntity:explosion];
}

- (void)createExplosionAtEntity:(TBEntity *)entity
{
    TBParticleEmitter *emmitter = [[TBParticleEmitter alloc] initWithParticleCount:40
                                                                          lifetime:0.8f
                                                                         spawnRate:0.00001f
                                                                          position:GLKVector2Make(0, 0)
                                                                          velocity:GLKVector2Make(0, 0)
                                                                      acceleration:GLKVector2Make(0, 0)
                                                                        startScale:2.0f endScale:0.20f startColor:GLKVector4Make(1, 0, 0, 1) endColor:GLKVector4Make(0.9f, 0.7f, 0.2f, 1)];
    [emmitter setVariationWithLifetime:0.08f
                             spawnRate:0.00
                              position:GLKVector2Make(6, 6)
                              velocity:GLKVector2Make(150, 150)
                          acceleration:GLKVector2Make(0, 0)
                            startScale:0.08f endScale:0.08f startColor:GLKVector4Make(0, 0, 0, 0) endColor:GLKVector4Make(0, 0, 0, 0)];
    
    [[TBWorld instance] addEntity:emmitter];
    
    emmitter.layer = 12;
    emmitter.position = GLKVector2Make(entity.position.x + entity.size.width/2, entity.position.y + entity.size.height/2);
    emmitter.velocity = entity.velocity;
    emmitter.additiveBlending = YES;
    emmitter.colororBlending = YES;
    emmitter.imageFileName = @"sharpparticle.png";
    [emmitter limitEffectLifetimeWithTime:0.3f];
    
    GLKVector2 point = entity.position;
    TBAnimationInfo animInfo;
    animInfo.frameCount = 5;
    animInfo.frameWidth = 72;
    animInfo.frameHeight = 81;
    animInfo.frameLength = 75;
    animInfo.loop = NO;
    float animationLength = (animInfo.frameLength * animInfo.frameCount)/1000.0f;
    TBAnimatedSprite *sprite = [[TBAnimatedSprite alloc] initWithFile:@"bigexplosion.png" animationInfo:animInfo];
    TBExplosion *explosion = [[TBExplosion alloc] initWithDrawable:sprite duration:animationLength];
    explosion.scale = self.scale;
    explosion.position = GLKVector2Make(point.x + self.size.width/2 - explosion.size.width/2,
                                        point.y + self.size.height/2 - explosion.size.height/2);
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

- (GLKVector2)vetNewPosition:(GLKVector2)newPosition
{
//    float blockBelowTop = _blockBelow.position.y + _blockBelow.size.height - _blockBelow.collisionyoff;
//    TBBlockMachine *blockMachine = [TBWorld instance].blockMachine;
//    
//    if (_blockBelow && _blockBelow != blockMachine.dummyBlock &&  newPosition.y < blockBelowTop)
//        newPosition = GLKVector2Make(newPosition.x, blockBelowTop - _blockBelow.size.height);
    
    return newPosition;
}

- (void)setBlockAbove:(TBBlock *)block
{
    _blockAbove = block;
}

- (TBBlock *)getBlockAbove
{
    return _blockAbove;
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
    if (_resting) {
        [self setAcceleration:GLKVector2Make(0, BLOCK_ACCELERATION)];
        [self setVelocity:GLKVector2Make(0, INITIAL_BLOCK_VELOCITY)];
    }
    
    if (_blockAbove) {
        [_blockAbove setToFallingState];
    }
    
    _resting = NO;
}

- (void)createExplosionSmoke
{
    TBParticleEmitter *emmitter = [[TBParticleEmitter alloc] initWithParticleCount:20
                                                                          lifetime:0.5f
                                                                         spawnRate:0.0001f
                                                                          position:GLKVector2Make(-5, 0)
                                                                          velocity:GLKVector2Make(0, 20)
                                                                      acceleration:GLKVector2Make(0, 100)
                                                                             startScale:2 endScale:2 startColor:GLKVector4Make(1, 1, 1, 0.75f) endColor:GLKVector4Make(1, 1, 1, 0.75f)];
    [emmitter setVariationWithLifetime:0.1f
                             spawnRate:0.00
                              position:GLKVector2Make(25, 0)
                              velocity:GLKVector2Make(30, 0)
                          acceleration:GLKVector2Make(20, 30)
                                 startScale:0 endScale:0 startColor:GLKVector4Make(0, 0, 0, 0) endColor:GLKVector4Make(0, 0, 0, 0)];
    
    [[TBWorld instance] addEntity:emmitter];
    
    emmitter.layer = 12;
    emmitter.position = GLKVector2Make(self.position.x + self.size.width/2, self.position.y + self.size.height/2);
    emmitter.velocity = self.velocity;
    
    TBEvent *event = [[TBEvent alloc] initWithHandler:^(float progress) {
    } completion:^{
        emmitter.alive = NO;
    } duration:3 repeat:NO];
    [event start];
}

- (void)createSmokeEffect
{
    TBParticleEmitter *emmitter = [[TBParticleEmitter alloc] initWithParticleCount:15
                                                                          lifetime:0.65f
                                                                         spawnRate:0.0001f
                                                                          position:GLKVector2Make(0, -10)
                                                                          velocity:GLKVector2Make(0, -10)
                                                                      acceleration:GLKVector2Make(0, 100)
                                                                             startScale:2 endScale:2 startColor:GLKVector4Make(1, 1, 1, 1) endColor:GLKVector4Make(1, 1, 1, 0)];
    [emmitter setVariationWithLifetime:0.1f
                             spawnRate:0.00
                              position:GLKVector2Make(COL_WIDTH + COL_WIDTH*0.25f, 0)
                              velocity:GLKVector2Make(15, 0)
                          acceleration:GLKVector2Make(0, 30)
                                 startScale:1 endScale:1 startColor:GLKVector4Make(0, 0, 0, 0) endColor:GLKVector4Make(0, 0, 0, 0)];
    
    [[TBWorld instance] addEntity:emmitter];
    
    emmitter.layer = 12;
    emmitter.position = GLKVector2Make(self.position.x, self.position.y);
    emmitter.additiveBlending = NO;
    
    TBEvent *event = [[TBEvent alloc] initWithHandler:^(float progress) {
    } completion:^{
        emmitter.alive = NO;
    } duration:0.3f repeat:NO];
    [event start];
}

- (void)setToRestingState
{
    if (!_resting) {
        [self createSmokeEffect];
    }
    
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
