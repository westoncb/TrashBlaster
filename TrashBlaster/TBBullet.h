//
//  TBBullet.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 7/6/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBEntity.h"

@interface TBBullet : TBEntity {
    TBEntity *_glow;
}

@property int damage;

@end
