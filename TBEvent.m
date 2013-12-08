//
//  TBEvent.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/6/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBEvent.h"
#import "TBEventManager.h"

@implementation TBEvent

- (id)initWithHandler:(TBEventUpdateHandler)handler completion:(TBEventCompletionHandler)completion duration:(float)duration repeat:(BOOL)repeat
{
    self = [super init];
    
    if (self) {
        _handler = handler;
        _completion = completion;
        _totalTime = duration;
        _repeat = repeat;
    }
    
    return self;
}

- (void)start
{
    [[TBEventManager instance] addEvent:self];
}

- (void)updateWithTimeDelta:(float)delta
{
    _elapsedTime += delta;
    
    float progress = _elapsedTime/_totalTime;
    
    if ([self isComplete])
        _completion();
    else
        _handler(progress);
}

- (BOOL)isComplete
{
    return _elapsedTime >= _totalTime;
}
@end
