//
//  TBExplosion.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 9/14/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBEntity.h"

@interface TBExplosion : TBEntity {
    float _duration;
    float _timePassed;
}

- (id)initWithDrawable:(id<TBDrawable>)drawable duration:(float)duration;
@end
