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
    BOOL _limitedDurationEffectInProgress;
}
@property NSString *imageFileName;

@property int maxParticles;
@property float lifetime;
@property float spawnRate;
@property float pStartScale;
@property float pEndScale;
@property GLKVector2 pPosition;
@property GLKVector2 pVelocity;
@property GLKVector2 pAcceleration;
@property GLKVector4 pStartColor;
@property GLKVector4 pEndColor;

@property float lifetimeVariation;
@property float spawnRateVariation;
@property float startScaleVariation;
@property float endScaleVariation;
@property GLKVector2 positionVariation;
@property GLKVector2 velocityVariation;
@property GLKVector2 accelerationVariation;
@property GLKVector4 startColorVariation;
@property GLKVector4 endColorVariation;

@property BOOL additiveBlending;
@property BOOL colororBlending;

- (void)setVariationWithLifetime:(float)lifetime spawnRate:(float)spawnRate position:(GLKVector2)position velocity:(GLKVector2)velocity acceleration:(GLKVector2)acceleration startScale:(float)startScale endScale:(float)endScale startColor:(GLKVector4)startColor endColor:(GLKVector4)endColor;
- (id)initWithParticleCount:(int)count lifetime:(float)lifetime spawnRate:(float)spawnRate position:(GLKVector2)position velocity:(GLKVector2)velocity acceleration:(GLKVector2)acceleration startScale:(float)startScale endScale:(float)endScale startColor:(GLKVector4)startColor endColor:(GLKVector4)endColor;
- (void)setBaseAttributes:(int)count lifetime:(float)lifetime spawnRate:(float)spawnRate position:(GLKVector2)position velocity:(GLKVector2)velocity acceleration:(GLKVector2)acceleration startScale:(float)startScale endScale:(float)endScale startColor:(GLKVector4)startColor endColor:(GLKVector4)endColor;
- (void)limitEffectLifetimeWithTime:(float)effectLifetime;

@end
