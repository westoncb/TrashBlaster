//
//  TBPoint.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/18/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBPoint.h"

@implementation TBPoint
@synthesize x;
@synthesize y;

- (id)init:(float)x y:(float)y {
    if([super init]) {
        self.x = x;
        self.y = y;
    }
    
    return self;
}
@end
