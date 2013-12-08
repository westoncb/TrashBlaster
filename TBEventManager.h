//
//  TBEventManager.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/6/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBEvent.h"

@interface TBEventManager : NSObject {
    NSMutableArray *_events;
}

+ (TBEventManager *)instance;

- (void)addEvent:(TBEvent *)event;
- (void)updateWithTimeDelta:(float)delta;
@end
