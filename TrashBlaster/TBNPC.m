//
//  TBNPC.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/4/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBNPC.h"

@implementation TBNPC

- (void)updateWithTimeDelta:(float)delta {
    _delay = 0.0f;
    
    [super updateWithTimeDelta:delta];
    
    if (self.destPoints.count == 0) {
        _delayedSoFar += delta;
    }
    
    if (_delayedSoFar > _delay) {
        _delayedSoFar = 0;
        int randX = arc4random_uniform(WIDTH);
        int randY = arc4random_uniform(100);
        
        [self addDestPointWithDestX:randX destY:randY];
    }
}

@end
