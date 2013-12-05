//
//  TBAnimatedSprite.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 9/11/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBAnimatedSprite.h"

@implementation TBAnimatedSprite
- (id)initWithFile:(NSString *)fileName animationInfo:(TBAnimationInfo)animationInfo
{
    self = [super init];
    
    if (self) {
        _sprite = [[TBSprite alloc] initWithFile:fileName];
        _imageSize = _sprite.size;
        _animationInfo = animationInfo;
        _sprite.size = CGSizeMake(_animationInfo.frameWidth, _animationInfo.frameHeight);
        
        _frameClock = 0;
    }
    
    return self;
}

- (void)updateWithTimeDelta:(float)delta
{
    int millis = (int)(delta*1000);
    _frameClock += millis;
    int absoluteFrameIndex = _frameClock / _animationInfo.frameLength;
    
    if (!_animationInfo.loop && (absoluteFrameIndex >= _animationInfo.frameCount - 1))
        return;
    
    int frameInCycle = (absoluteFrameIndex % _animationInfo.frameCount);
    int frameWidth = _animationInfo.frameWidth;
    int frameHeight = _animationInfo.frameHeight;
    
    int xStart = frameInCycle * frameWidth;
    int yStart = 0;
    int xFinish = xStart + frameWidth;
    int yFinish = yStart + frameHeight;
    
    float relXStart = xStart / _imageSize.width;
    float relXFinish = xFinish / _imageSize.width;
    float relYStart = yStart / _imageSize.height;
    float relYFinish = yFinish / _imageSize.height;
    
    TexturedQuad quad;
    quad.bl.geometryVertex = CGPointMake(0, 0);
    quad.br.geometryVertex = CGPointMake(self.size.width, 0);
    quad.tl.geometryVertex = CGPointMake(0, self.size.height);
    quad.tr.geometryVertex = CGPointMake(self.size.width, self.size.height);
    
    quad.bl.textureVertex = CGPointMake(relXStart, relYStart);
    quad.br.textureVertex = CGPointMake(relXFinish, relYStart);
    quad.tl.textureVertex = CGPointMake(relXStart, relYFinish);
    quad.tr.textureVertex = CGPointMake(relXFinish, relYFinish);
    
//    NSLog(@"xStart: %f, xFinish: %f, yStart: %f, yFinish: %f", xStart, xFinish, yStart, yFinish);
    
    _sprite.quad = quad;
}

- (void)renderWithModelMatrix:(GLKMatrix4)modelMatrix
{
    [_sprite renderWithModelMatrix:modelMatrix];
}

- (void)setSize:(CGSize)size
{
    _sprite.size = size;
}

- (CGSize)size
{
    return _sprite.size;
}

- (void)setXFlip:(BOOL)xFlip
{
    _sprite.xFlip = xFlip;
}

- (BOOL)xFlip
{
    return _sprite.xFlip;
}

- (void)setYFlip:(BOOL)yFlip
{
    _sprite.yFlip = yFlip;
}

- (BOOL)yFlip
{
    return _sprite.yFlip;
}

@end
