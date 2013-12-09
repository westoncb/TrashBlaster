//
//  TBStringSprite.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/4/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBDrawable.h"
#import "TBSprite.h"

static const int CHAR_WIDTH = 16;
static const int CHAR_HEIGHT = 16;
static const int CHARS_PER_ROW = 16;

@interface TBStringSprite : NSObject <TBDrawable> {
    NSMutableArray *_characters;
}

-(id)initWithString:(NSString *)string;
- (void)setColor:(GLKVector4)color;
- (GLKVector4)color;
- (void)setSize:(CGSize)size;
- (CGSize)size;
@end
