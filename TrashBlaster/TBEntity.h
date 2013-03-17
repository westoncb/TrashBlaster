//
//  TBEntity.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/17/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <Foundation/Foundation.h>
#import "TBSprite.h"

@interface TBEntity : NSObject
@property (assign) GLKVector2 acceleration;
@property (assign) GLKVector2 velocity;
@property (assign) GLKVector2 position;
@property (assign) CGSize size;
@property (strong) TBSprite *sprite;

- (id)initWithSprite:(TBSprite *)sprite;
- (void)update:(float)dt;
- (void)render;
@end
