//
//  Sprite.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/16/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface TBSprite : NSObject

@property CGSize size;

- (id)initWithFile:(NSString *)fileName;
- (void)render:(GLKMatrix4)modelMatrix;

@end
