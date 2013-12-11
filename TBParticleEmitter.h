//
//  TBParticleEmitter.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/10/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "TBDrawable.h"
#import "TBEntity.h"

@interface TBParticleEmitter : TBEntity {
    NSMutableArray *_particles;
    float _spawnTimePassed;
    float _nextSpawnTime;
}

@property int count;
@property float lifetime;
@property float spawnRate;
@property float pScale;
@property GLKVector2 pPosition;
@property GLKVector2 pVelocity;
@property GLKVector2 pAcceleration;
@property GLKVector4 pColor;

@property float lifetimeVariation;
@property float spawnRateVariation;
@property float scaleVariation;
@property GLKVector2 positionVariation;
@property GLKVector2 velocityVariation;
@property GLKVector2 accelerationVariation;
@property GLKVector4 colorVariation;

- (void)setVariationWithLifetime:(float)lifetime spawnRate:(float)spawnRate position:(GLKVector2)position velocity:(GLKVector2)velocity acceleration:(GLKVector2)acceleration scale:(float)scale color:(GLKVector4)color;
- (id)initWithParticleCount:(int)count lifetime:(float)lifetime spawnRate:(float)spawnRate position:(GLKVector2)position velocity:(GLKVector2)velocity acceleration:(GLKVector2)acceleration scale:(float)scale color:(GLKVector4)color;

@end
