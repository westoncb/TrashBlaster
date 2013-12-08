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

@interface TBSprite : NSObject <TBDrawable> {
    float _renderX;
    float _renderY;
    float _renderWidth;
    float _renderHeight;
}

@property BOOL xFlip;
@property BOOL yFlip;
@property CGSize size;
@property (assign) TexturedQuad quad;
@property (strong) GLKTextureInfo * textureInfo;

- (id)initWithFile:(NSString *)fileName;
- (id)initWithFile:(NSString *)fileName xStart:(float)xStart yStart:(float)yStart width:(float)width height:(float)height;
- (id)initWithFile:(NSString *)fileName col:(int)col row:(int)row;
- (void)renderWithModelMatrix:(GLKMatrix4)modelMatrix;
- (void)updateWithTimeDelta:(float)delta;
@end
