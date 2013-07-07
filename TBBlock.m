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

@implementation TBBlock
- (id)initWithSprite:(TBSprite *)sprite
{
    self = [super initWithSprite:sprite];
    
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
    } else if (collider.type == PLAYER) {
        if (!_hitPlayer) {
            _hitPlayer = true;
            self.velocity = GLKVector2Make(self.velocity.x, self.velocity.y * 0.75f);
        }
    }
}
@end
