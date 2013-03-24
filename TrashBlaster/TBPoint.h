//
//  TBPoint.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/18/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBPoint : NSObject
@property float x;
@property float y;

- (id)init:(float)x y:(float)y;
@end
