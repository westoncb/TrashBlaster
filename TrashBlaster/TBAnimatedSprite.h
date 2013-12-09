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
    NSMutableArray *_linkedSprites;
}

@property TBSprite *sprite;
@property TBAnimationInfo animationInfo;
@property float xOffset;
@property float yOffset;
@property GLKVector4 color;

- (id)initWithFile:(NSString *)fileName animationInfo:(TBAnimationInfo)animationInfo;
- (id)initWithFile:(NSString *)fileName animationInfo:(TBAnimationInfo)animationInfo xOffset:(float)xOffset yOffset:(float)yOffset;
- (id)initWithFile:(NSString *)fileName animationInfo:(TBAnimationInfo)animationInfo row:(int)row;
- (void)linkSprite:(TBAnimatedSprite *)sprite;
- (void)unlinkSprite:(TBAnimatedSprite *)sprite;
@end
