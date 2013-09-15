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

@implementation TBBlock
- (id)initWithSprite:(TBSprite *)sprite
{
    self = [super initWithDrawable:sprite];
    
    if (self) {
        self.life = 60;
    }
    
    return self;
}

- (void)handleCollision:(TBEntity *)collider wasTheProtruder:(BOOL)retractSelf {
    [super handleCollision:collider wasTheProtruder:retractSelf];
    
    if (collider.type == BULLET) {
        self.acceleration = GLKVector2Make(self.velocity.x, self.acceleration.y - 100);
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
@end
