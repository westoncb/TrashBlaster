//
//  TBParticleEmitter.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/10/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBParticleEmitter.h"
#import "TBSprite.h"
#import "TBEntity.h"

@implementation TBParticleEmitter

- (id)initWithParticleCount:(int)count lifetime:(float)lifetime spawnRate:(float)spawnRate position:(GLKVector2)position velocity:(GLKVector2)velocity acceleration:(GLKVector2)acceleration scale:(float)scale color:(GLKVector4)color
{
    self = [super init];
    
    if (self) {
        _count = count;
        _lifetime = lifetime;
        _spawnRate = spawnRate;
        _pScale = scale;
        _pPosition = position;
        _pVelocity = velocity;
        _pAcceleration = acceleration;
        _pColor = color;
        self.type = PARTICLE_EFFECT;
        self.alive = YES;
        _spawnTimePassed = 10000;
        
        _particles = [NSMutableArray array];
    }
    
    return self;
}

- (void)setVariationWithLifetime:(float)lifetime spawnRate:(float)spawnRate position:(GLKVector2)position velocity:(GLKVector2)velocity acceleration:(GLKVector2)acceleration scale:(float)scale color:(GLKVector4)color
{
    _lifetimeVariation = lifetime;
    _spawnRateVariation = spawnRate;
    _scaleVariation = scale;
    _positionVariation = position;
    _velocityVariation = velocity;
    _accelerationVariation = acceleration;
    _colorVariation = color;
}

- (float)applyRandomVariationWithBase:(float)base variation:(float)variation
{
    float thisVariation = arc4random_uniform(variation*2);
    thisVariation -= variation;
    
    return base + thisVariation;
}

- (GLKVector2)applyRandomVariationWithVectorBase:(GLKVector2)base variation:(GLKVector2)variation
{
    float xVariation = arc4random_uniform(variation.x*2);
    float yVariation = arc4random_uniform(variation.y*2);
    xVariation -= variation.x;
    yVariation -= variation.y;
    
    return GLKVector2Make(base.x + xVariation, base.y + yVariation);
}

- (GLKVector4)applyRandomVariationWith4VectorBase:(GLKVector4)base variation:(GLKVector4)variation
{
    float xVariation = arc4random_uniform(variation.x*2);
    float yVariation = arc4random_uniform(variation.y*2);
    float zVariation = arc4random_uniform(variation.z*2);
    float wVariation = arc4random_uniform(variation.w*2);
    xVariation -= variation.x;
    yVariation -= variation.y;
    zVariation -= variation.z;
    wVariation -= variation.w;
    
    return GLKVector4Make(base.x + xVariation, base.y + yVariation, base.z + zVariation, base.w + wVariation);
}

- (void)spawnParticle
{
    TBSprite *particleSprite = [[TBSprite alloc] initWithFile:@"particle.png"];
    TBEntity *particle = [[TBEntity alloc] initWithDrawable:particleSprite];
    particle.type = PARTICLE;
    particle.layer = self.layer;
    particleSprite.additiveBlending = NO;
    
    float scale = [self applyRandomVariationWithBase:_pScale variation:_scaleVariation];
    particle.scale = GLKVector2Make(scale, scale);
    GLKVector2 relativePosition = [self applyRandomVariationWithVectorBase:_pPosition variation:_positionVariation];
    particle.position = GLKVector2Make(self.position.x + relativePosition.x, self.position.y + relativePosition.y);
    particle.velocity = [self applyRandomVariationWithVectorBase:_pVelocity variation:_velocityVariation];
    particle.acceleration = [self applyRandomVariationWithVectorBase:_pAcceleration variation:_accelerationVariation];
    particle.color = [self applyRandomVariationWith4VectorBase:_pColor variation:_colorVariation];
    particle.timeTillExpiration = [self applyRandomVariationWithBase:_lifetime variation:_lifetimeVariation];
    
    [_particles addObject:particle];
    [[TBWorld instance] addEntity:particle];
}

- (void)updateWithTimeDelta:(float)delta
{
    [super updateWithTimeDelta:delta];
    
    _spawnTimePassed += delta;
    
    if (_spawnTimePassed > _nextSpawnTime) {
        _spawnTimePassed = 0;
        
        int count = 1;
        
        if (delta > _nextSpawnTime*2)
            count = (int)(_nextSpawnTime/delta);
        if (count < 1)
            count = 1;
        
        for (int i = 0; i < count; i++) {
            _nextSpawnTime = [self applyRandomVariationWithBase:_spawnRate variation:_spawnRateVariation];
            [self spawnParticle];
        }
    }
    
    NSMutableArray *toRemove = [NSMutableArray array];
    for (TBEntity *particle in _particles) {
        particle.timeTillExpiration -= delta;
        if (particle.timeTillExpiration <= 0) {
            particle.alive = NO;
            [toRemove addObject:particle];
        }
    }
    
    for (TBEntity *particle in toRemove) {
        [_particles removeObject:particle];
    }
}

- (void)handleDeath
{
    for (TBEntity *particle in _particles) {
        particle.alive = NO;
    }
}
@end
