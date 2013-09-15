//
//  Sprite.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/16/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "TBDrawable.h"

typedef struct {
    CGPoint geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct {
    TexturedVertex bl;
    TexturedVertex br;
    TexturedVertex tl;
    TexturedVertex tr;
} TexturedQuad;

@interface TBSprite : NSObject <TBDrawable>

@property BOOL xFlip;
@property BOOL yFlip;
@property CGSize size;
@property (assign) TexturedQuad quad;
@property (strong) GLKTextureInfo * textureInfo;

- (id)initWithFile:(NSString *)fileName;
- (void)renderWithModelMatrix:(GLKMatrix4)modelMatrix;
- (void)updateWithTimeDelta:(float)delta;
@end
