//
//  TBWorld.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/17/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBEntity.h"

@interface TBWorld : NSObject
- (id)world;
- (void)addEntity:(TBEntity *)entity;
- (void)update:(float)delta;
- (void)render;
- (void)movePlayerTo:(GLKVector2)dest;
@end
