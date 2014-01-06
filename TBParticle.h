//
//  TBParticle.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/10/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBEntity.h"

@interface TBParticle : TBEntity

@property float totalLifeTime;
@property float timeTillExpiration;
@property float startScale;
@property float endScale;
@property GLKVector4 startColor;
@property GLKVector4 endColor;

@end
