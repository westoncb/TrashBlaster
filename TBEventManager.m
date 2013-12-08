//
//  TBEventManager.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/6/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBEventManager.h"

static TBEventManager *_eventManager;

@implementation TBEventManager

+ (TBEventManager *)instance
{
    if (!_eventManager)
        _eventManager = [[TBEventManager alloc] init];
    
    return _eventManager;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _events = [NSMutableArray array];
    }
    
    return self;
}

- (void)addEvent:(TBEvent *)event
{
    [_events addObject:event];
}

- (void)updateWithTimeDelta:(float)delta
{
    NSMutableArray *finishedEvents = [NSMutableArray array];
    for (TBEvent *event in _events) {
        [event updateWithTimeDelta:delta];
        
        if ([event isComplete])
            [finishedEvents addObject:event];
    }
    
    for (TBEvent *event in finishedEvents) {
        [_events removeObject:event];
    }
}


@end
