//
//  TBBlockMachine.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/23/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBWorld.h"

@interface TBBlockMachine : NSObject {
    int blocksInColumns[10];
}

- (id)initWithWorld:(TBWorld*)world;
- (void)update:(float)delta;
- (int)blocksInColumn:(int)col;
- (void)alterColumnCount:(int)col adder:(int)adder;
@end
