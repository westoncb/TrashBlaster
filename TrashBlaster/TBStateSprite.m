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
        _linkedSprites = [NSMutableArray array];
        [self changeState:initialState];
    }
    
    return self;
}

- (void)linkSprite:(TBStateSprite *)sprite
{
    [_linkedSprites addObject:sprite];
}

- (void)unlinkSprite:(TBStateSprite *)sprite
{
    [_linkedSprites removeObject:sprite];
}

- (void)changeState:(NSString *)state
{
    _activeSprite = [_stateMap objectForKey:state];
    _activeState = state;
    _activeSize = _activeSprite.size;
    
    [self updateActiveSprite];
    
    for (TBStateSprite *sprite in _linkedSprites) {
        [sprite changeState:state];
    }
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
    
    for (TBStateSprite *sprite in _linkedSprites) {
        [sprite updateActiveSprite];
    }
}

- (void)renderWithModelMatrix:(GLKMatrix4)modelMatrix
{
    [_activeSprite renderWithModelMatrix:modelMatrix];
    
    for (TBStateSprite *sprite in _linkedSprites) {
        [sprite renderWithModelMatrix:modelMatrix];
    }
}

- (void)updateWithTimeDelta:(float)delta
{
    [_activeSprite updateWithTimeDelta:delta];
    
    for (TBStateSprite *sprite in _linkedSprites) {
        [sprite updateWithTimeDelta:delta];
    }
}

- (void)setSize:(CGSize)size
{
    _activeSize = size;
    _sizeOverride = YES;
    [self updateActiveSprite];
    
    for (TBStateSprite *sprite in _linkedSprites) {
        [sprite setSize:size];
    }
}

- (void)setColor:(GLKVector4)color
{
    for (TBStateSprite *sprite in _linkedSprites) {
        [sprite setColor:color];
    }
}

- (GLKVector4)color
{
    return GLKVector4Make(1, 1, 1, 1);
}

- (CGSize)size
{
    return _activeSize;
}

- (void)setXFlip:(BOOL)xFlip
{
    _xFlip = xFlip;
    [self updateActiveSprite];
    
    for (TBStateSprite *sprite in _linkedSprites) {
        [sprite setXFlip:xFlip];
    }
}

- (BOOL)xFlip
{
    return _xFlip;
}

- (void)setYFlip:(BOOL)yFlip
{
    _yFlip = yFlip;
    [self updateActiveSprite];
    
    for (TBStateSprite *sprite in _linkedSprites) {
        [sprite setXFlip:yFlip];
    }
}

- (BOOL)yFlip
{
    return _yFlip;
}
@end
