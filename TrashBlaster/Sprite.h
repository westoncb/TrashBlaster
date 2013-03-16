//
//  Sprite.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/16/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Sprite : NSObject

@property (assign) GLKVector2 moveVelocity;
@property (assign) GLKVector2 position;
@property (assign) CGSize contentSize;

- (void)update:(float)dt;
- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect;
- (void)render;

@end
