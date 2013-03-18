//
//  TBPlayer.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/18/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBEntity.h"
#import "TBSprite.h"

@interface TBPlayer : TBEntity
@property NSMutableArray *destPoints;

- (void)addDestPoint:(float)destx;
- (id)initWithSprite:(TBSprite *)sprite;
@end
