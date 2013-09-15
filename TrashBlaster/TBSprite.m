//
//  Sprite.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/16/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//
#import "TBSprite.h"
#import "TBWorld.h"

@implementation TBSprite : NSObject
@synthesize size = _size;
@synthesize xFlip = _xFlip;
@synthesize yFlip = _yFlip;

- (id)initWithFile:(NSString *)fileName {
    if ((self = [super init])) {
        // 2
        NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES],
                                  GLKTextureLoaderOriginBottomLeft,
                                  nil];
        
        // 3
        NSError * error;
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        // 4
        self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
        if (self.textureInfo == nil) {
            NSLog(@"Error loading file: %@", [error localizedDescription]);
            return nil;
        }
        
        self.size = CGSizeMake(self.textureInfo.width, self.textureInfo.height);
    }
    return self;
}

- (void)createQuad {
    TexturedQuad newQuad;
    newQuad.bl.geometryVertex = CGPointMake(0, 0);
    newQuad.br.geometryVertex = CGPointMake(self.size.width+0.5f, 0);
    newQuad.tl.geometryVertex = CGPointMake(0, self.size.height+0.5f);
    newQuad.tr.geometryVertex = CGPointMake(self.size.width+0.5f, self.size.height+0.5f);
    
    newQuad.bl.textureVertex = CGPointMake(0, 0);
    newQuad.br.textureVertex = CGPointMake(1, 0);
    newQuad.tl.textureVertex = CGPointMake(0, 1);
    newQuad.tr.textureVertex = CGPointMake(1, 1);
    self.quad = newQuad;
}

- (void)setSize:(CGSize)size {
    _size = size;
    [self createQuad];
}

- (CGSize)size {
    return _size;
}

- (void)setXFlip:(BOOL)xFlip
{
    _xFlip = xFlip;
}

- (BOOL)xFlip
{
    return _xFlip;
}

- (void)setYFlip:(BOOL)yFlip
{
    _yFlip = yFlip;
}

- (BOOL)yFlip
{
    return _yFlip;
}

- (void)updateWithTimeDelta:(float)delta
{
    
}

- (void)renderWithModelMatrix:(GLKMatrix4)modelMatrix {
    TBWorld.effect.texture2d0.name = self.textureInfo.name;
    TBWorld.effect.texture2d0.enabled = YES;
    
    if (_xFlip) {
        modelMatrix = GLKMatrix4Scale(modelMatrix, -1, 1, 1.0f);
        modelMatrix = GLKMatrix4Translate(modelMatrix, -_size.width, 0, 0);
    }
    
    if (_yFlip) {
//        modelMatrix = GLKMatrix4Translate(modelMatrix, 0, -_size.height/2.0f, 0);
        modelMatrix = GLKMatrix4Scale(modelMatrix, 1, -1, 1.0f);
//        modelMatrix = GLKMatrix4Translate(modelMatrix, 0, _size.height/2.0f, 0);
    }
    
    
    TBWorld.effect.transform.modelviewMatrix = modelMatrix;
    
    [TBWorld.effect prepareToDraw];
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    long offset = (long)&_quad;
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
