//
//  TBPoint.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/18/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBPoint.h"

@implementation TBPoint

- (id)init:(float)x y:(float)y {
    self = [super init];
    if(self) {
        _x = x;
        _y = y;
    }
    
    return self;
}
@end
