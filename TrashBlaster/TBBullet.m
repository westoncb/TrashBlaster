//
//  TBBullet.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 7/6/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBBullet.h"

@implementation TBBullet

- (id)initWithDrawable:(id<TBDrawable>)drawable
{
    self = [super initWithDrawable:drawable];

    if (self) {
        _damage = 10;
        self.layer = 10;
    }
    
    return self;
}

- (void)handleCollision:(TBEntity *)collider wasTheProtruder:(BOOL)retractSelf {
    [super handleCollision:collider wasTheProtruder:retractSelf];
    
    self.alive = false;
}

@end
