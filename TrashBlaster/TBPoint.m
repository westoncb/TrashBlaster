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

- (id)init:(float)xcoord ycoord:(float)ycoord {
    if([super init]) {
        self.x = xcoord;
        self.y = ycoord;
    }
    
    return self;
}
@end
