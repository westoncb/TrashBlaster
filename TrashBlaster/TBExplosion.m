//
//  TBExplosion.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 9/14/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBExplosion.h"

@implementation TBExplosion
- (id)initWithDrawable:(id<TBDrawable>)drawable duration:(float)duration
{
    self = [super initWithDrawable:drawable];
    
    if (self) {
        _duration = duration;
        super.type = DECORATION;
    }
    
    return self;
}

- (void)update:(float)dt {
    [super update:dt];
    
    _timePassed += dt;
    
    if (_timePassed > _duration) {
        self.alive = NO;
    }
}
@end
