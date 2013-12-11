//
//  Sprite.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/16/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//
#import "TBSprite.h"
#import "TBWorld.h"

static NSMutableDictionary *_textureCache;

@implementation TBSprite : NSObject
@synthesize size = _size;
@synthesize xFlip = _xFlip;
@synthesize yFlip = _yFlip;
@synthesize color = _color;

- (id)initWithFile:(NSString *)fileName xStart:(float)xStart yStart:(float)yStart width:(float)width height:(float)height
{
    self = [super init];
    
    if(self) {
        _renderX = xStart;
        _renderY = yStart;
        _renderWidth = width;
        _renderHeight = height;
        
        [self loadTextureFromFileName:fileName];
        
        _color = GLKVector4Make(1, 1, 1, 1);
        _additiveBlending = NO;
        _colorBlending = NO;
        _size = CGSizeMake(width, height);
        [self createQuad];
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
        _color = GLKVector4Make(1, 1, 1, 1);
        _additiveBlending = NO;
        _colorBlending = NO;
        
        _size = CGSizeMake(self.textureInfo.width, self.textureInfo.height);
        [self createQuad];
    }
    return self;
}

- (void)loadTextureFromFileName:(NSString *)fileName
{
    if (!_textureCache)
        _textureCache = [NSMutableDictionary dictionary];
    
    //Use cached version if possible
    self.textureInfo = [_textureCache objectForKey:fileName];
    if (self.textureInfo)
        return;
    
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES],
                              GLKTextureLoaderOriginBottomLeft,
                              nil];
    
    
    NSError * error;
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if (self.textureInfo == nil) {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
    } else
        [_textureCache setObject:self.textureInfo forKey:fileName];
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
    
    newQuad.bl.colorVertex = self.color;
    newQuad.br.colorVertex = self.color;
    newQuad.tl.colorVertex = self.color;
    newQuad.tr.colorVertex = self.color;
    
    self.quad = newQuad;
}

- (void)setColor:(GLKVector4)color
{
    _color = color;
    [self createQuad];
}

- (GLKVector4)color
{
    return _color;
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
    
    if (self.additiveBlending)
        glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    else if (self.colorBlending)
        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
    else
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    TBWorld.effect.transform.modelviewMatrix = modelMatrix;
    
    [TBWorld.effect prepareToDraw];
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    
    long offset = (long)&_quad;
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, colorVertex)));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
