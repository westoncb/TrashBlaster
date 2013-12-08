//
//  TBEvent.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/6/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TBEventUpdateHandler)(float progress);
typedef void (^TBEventCompletionHandler)();

@interface TBEvent : NSObject {
    TBEventUpdateHandler _handler;
    TBEventCompletionHandler _completion;
}

@property float totalTime;
@property float elapsedTime;
@property BOOL repeat;

- (id)initWithHandler:(TBEventUpdateHandler)handler completion:(TBEventCompletionHandler)completion duration:(float)duration repeat:(BOOL)repeat;
- (void)updateWithTimeDelta:(float)delta;
- (BOOL)isComplete;
- (void)start;
@end
