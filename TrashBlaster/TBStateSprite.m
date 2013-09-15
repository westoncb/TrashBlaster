//
//  TBStateSprite.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 9/13/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBStateSprite.h"

@implementation TBStateSprite
- (id)initWithStateMap:(NSDictionary *)stateMap initialState:(NSString *)initialState
{
    self = [super init];
    
    if (self) {
        _stateMap = stateMap;
        [self changeState:initialState];
    }
    
    return self;
}

- (void)changeState:(NSString *)state
{
    _activeSprite = [_stateMap objectForKey:state];
    _activeState = state;
    _activeSize = _activeSprite.size;
    
    [self updateActiveSprite];
}

- (void)updateActiveSprite
{
    if ([_activeState hasSuffix:@"_xf"])
        [_activeSprite setXFlip:!_xFlip];
    else
        [_activeSprite setXFlip:_xFlip];
    
    if ([_activeState hasSuffix:@"_yf"])
        [_activeSprite setYFlip:!_yFlip];
    else
        [_activeSprite setYFlip:_yFlip];
    
    if (_sizeOverride)
        [_activeSprite setSize:_activeSize];
}

- (void)renderWithModelMatrix:(GLKMatrix4)modelMatrix
{
    [_activeSprite renderWithModelMatrix:modelMatrix];
}

- (void)updateWithTimeDelta:(float)delta
{
    [_activeSprite updateWithTimeDelta:delta];
}

- (void)setSize:(CGSize)size
{
    _activeSize = size;
    _sizeOverride = YES;
    [self updateActiveSprite];
}

- (CGSize)size
{
    return _activeSize;
}

- (void)setXFlip:(BOOL)xFlip
{
    _xFlip = xFlip;
    [self updateActiveSprite];
}

- (BOOL)xFlip
{
    return _xFlip;
}

- (void)setYFlip:(BOOL)yFlip
{
    _yFlip = yFlip;
    [self updateActiveSprite];
}

- (BOOL)yFlip
{
    return _yFlip;
}
@end
