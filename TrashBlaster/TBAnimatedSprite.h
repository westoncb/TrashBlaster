//
//  TBAnimatedSprite.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 9/11/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBDrawable.h"
#import "TBSprite.h"

typedef struct {
    int frameWidth;
    int frameHeight;
    int frameLength;
    int frameCount;
    BOOL loop;
} TBAnimationInfo;

@interface TBAnimatedSprite : NSObject <TBDrawable> {
    int _frameClock;
    CGSize _imageSize;
}

@property TBSprite *sprite;
@property TBAnimationInfo animationInfo;

- (id)initWithFile:(NSString *)fileName animationInfo:(TBAnimationInfo)animationInfo;
@end
