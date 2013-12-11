//
//  TBDrawable.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 9/11/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@protocol TBDrawable <NSObject>
- (void)renderWithModelMatrix:(GLKMatrix4)modelMatrix;
- (void)updateWithTimeDelta:(float)delta;
- (void)setSize:(CGSize)size;
- (void)setColor:(GLKVector4)color;
- (GLKVector4)color;
- (CGSize)size;
- (void)setXFlip:(BOOL)xFlip;
- (void)setYFlip:(BOOL)yFlip;
- (BOOL)xFlip;
- (BOOL)yFlip;
@end
