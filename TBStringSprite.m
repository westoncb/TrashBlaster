//
//  TBStringSprite.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/4/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBStringSprite.h"
#import "TBSprite.h"

@implementation TBStringSprite

-(id)initWithString:(NSString *)string
{
    self = [super init];
    
    if (self) {
        _characters = [NSMutableArray arrayWithCapacity:string.length];
        for (int i = 0; i < string.length; i++) {
            unichar curCharacter = [string characterAtIndex:i];
            [_characters addObject:[self createCharacterSpriteWithASCIICode:curCharacter]];
        }
    }
    
    return self;
}

- (TBSprite *)createCharacterSpriteWithASCIICode:(int)code
{
    int row = 15 - (code / CHARS_PER_ROW); //15 = number of rows - 1
    int col = code % CHARS_PER_ROW;
    float x = col * CHAR_WIDTH;
    float y = row * CHAR_HEIGHT;
    
    TBSprite *sprite = [[TBSprite alloc] initWithFile:@"bitmapfont.gif" xStart:x yStart:y width:CHAR_WIDTH height:CHAR_HEIGHT];
    sprite.size = CGSizeMake(CHAR_WIDTH, CHAR_HEIGHT);
    sprite.colorBlending = YES;
    
    return sprite;
}

- (void)updateWithTimeDelta:(float)delta
{
    
}

- (void)renderWithModelMatrix:(GLKMatrix4)modelMatrix
{
    for (TBSprite *sprite in _characters) {
        [sprite renderWithModelMatrix:modelMatrix];
        modelMatrix = GLKMatrix4Translate(modelMatrix, CHAR_WIDTH - 2, 0, 0);
    }
}

- (void)setSize:(CGSize)size
{
    for (TBSprite *sprite in _characters) {
        sprite.size = size;
    }
}

- (CGSize)size
{
    TBSprite *sprite = [_characters objectAtIndex:0];
    CGSize size = CGSizeMake(sprite.size.width*_characters.count, sprite.size.height);
    return size;
}

- (void)setColor:(GLKVector4)color
{
    for (TBSprite *sprite in _characters) {
        sprite.color = color;
    }
}

- (GLKVector4)color
{
    TBSprite *sprite = [_characters objectAtIndex:0];
    return sprite.color;
}

- (void)setXFlip:(BOOL)xFlip
{
    for (TBSprite *sprite in _characters) {
        sprite.xFlip = xFlip;
    }
}

- (BOOL)xFlip
{
    TBSprite *sprite = [_characters objectAtIndex:0];
    return sprite.xFlip;
}

- (void)setYFlip:(BOOL)yFlip
{
    for (TBSprite *sprite in _characters) {
        sprite.yFlip = yFlip;
    }
}

- (BOOL)yFlip
{
    TBSprite *sprite = [_characters objectAtIndex:0];
    return sprite.yFlip;
}

@end
