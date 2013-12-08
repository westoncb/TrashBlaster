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

- (id)initWithFile:(NSString *)fileName xStart:(float)xStart yStart:(float)yStart width:(float)width height:(float)height
{
    self = [super init];
    if(self) {
        _renderX = xStart;
        _renderY = yStart;
        _renderWidth = width;
        _renderHeight = height;
        
        [self loadTextureFromFileName:fileName];
        
        self.size = CGSizeMake(width, height);
    }
    
    return self;
}

/*This is a convenience function for dealing with images of a particular format (64px by 64px cells, 9 cols and 4 rows)*/
- (id)initWithFile:(NSString *)fileName col:(int)col row:(int)row
{
    return [self initWithFile:fileName xStart:col*64 yStart:row*64 width:64 height:64];
}

- (id)initWithFile:(NSString *)fileName
{
    if ((self = [super init])) {

        [self loadTextureFromFileName:fileName];
        
        _renderX = 0;
        _renderY = 0;
        _renderWidth = self.textureInfo.width;
        _renderHeight = self.textureInfo.height;
        
        self.size = CGSizeMake(self.textureInfo.width, self.textureInfo.height);
    }
    return self;
}

- (void)loadTextureFromFileName:(NSString *)fileName
{
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES],
                              GLKTextureLoaderOriginBottomLeft,
                              nil];
    
    
    NSError * error;
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if (self.textureInfo == nil) {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
    }
}

- (void)createQuad {
    TexturedQuad newQuad;
    newQuad.bl.geometryVertex = CGPointMake(0, 0);
    newQuad.br.geometryVertex = CGPointMake(self.size.width, 0);
    newQuad.tl.geometryVertex = CGPointMake(0, self.size.height);
    newQuad.tr.geometryVertex = CGPointMake(self.size.width, self.size.height);
    
    float relX = _renderX / self.textureInfo.width;
    float relY = _renderY / self.textureInfo.height;
    float relWidth = _renderWidth / self.textureInfo.width;
    float relHeight = _renderHeight / self.textureInfo.height;
    
    newQuad.bl.textureVertex = CGPointMake(relX, relY);
    newQuad.br.textureVertex = CGPointMake(relX + relWidth, relY);
    newQuad.tl.textureVertex = CGPointMake(relX, relY + relHeight);
    newQuad.tr.textureVertex = CGPointMake(relX + relWidth, relY + relHeight);
    
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
        modelMatrix = GLKMatrix4Scale(modelMatrix, 1, -1, 1.0f);
    }
    
    TBWorld.effect.transform.modelviewMatrix = modelMatrix;
    
    [TBWorld.effect prepareToDraw];
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//    glEnableVertexAttribArray(GLKVertexAttribColor);
    
    long offset = (long)&_quad;
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
