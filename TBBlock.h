//
//  TBBlock.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 7/6/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBEntity.h"
#import "TBSprite.h"

@interface TBBlock : TBEntity {
    BOOL _hitPlayer;
}

- (id)initWithSprite:(TBSprite *)sprite;
@end
