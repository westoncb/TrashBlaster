//
//  TBStateSprite.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 9/13/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBDrawable.h"

@interface TBStateSprite : NSObject <TBDrawable> {
    id<TBDrawable> _activeSprite;
    NSString *_activeState;
    CGSize _activeSize;
    BOOL _sizeOverride;
    BOOL _xFlip;
    BOOL _yFlip;
    NSDictionary *_stateMap;
    NSMutableArray *_linkedSprites;
}

- (id)initWithStateMap:(NSDictionary *)stateMap initialState:(NSString *)initialState;
- (void)changeState:(NSString *)state;
- (void)linkSprite:(TBStateSprite *)sprite;
- (void)unlinkSprite:(TBStateSprite *)sprite;
@end
