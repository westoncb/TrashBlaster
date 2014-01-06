//
//  TBParticleEmitter.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/10/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBParticleEmitter.h"
#import "TBSprite.h"
#import "TBParticle.h"
#import "TBEvent.h"

@implementation TBParticleEmitter

- (id)initWithParticleCount:(int)count lifetime:(float)lifetime spawnRate:(float)spawnRate position:(GLKVector2)position velocity:(GLKVector2)velocity acceleration:(GLKVector2)acceleration startScale:(float)startScale endScale:(float)endScale startColor:(GLKVector4)startColor endColor:(GLKVector4)endColor
{
//    TBSprite *emmitterSprite = [[TBSprite alloc] initWithFile:@"tinyexplosion.png"];
//    self = [super initWithDrawable:emmitterSprite];
    self = [super init];

    if (self) {
        self.type = PARTICLE_EFFECT;
        self.alive = YES;
        _spawnTimePassed = 10000;
        _additiveBlending = YES;
        _colororBlending = NO;
        _imageFileName = @"particle.png";
        
        _particles = [NSMutableArray array];
        
        [self setBaseAttributes:count lifetime:lifetime spawnRate:spawnRate position:position velocity:velocity acceleration:acceleration startScale:startScale endScale:endScale startColor:startColor endColor:endColor];
    }
    
    return self;
}

- (void)setBaseAttributes:(int)count lifetime:(float)lifetime spawnRate:(float)spawnRate position:(GLKVector2)position velocity:(GLKVector2)velocity acceleration:(GLKVector2)acceleration startScale:(float)startScale endScale:(float)endScale startColor:(GLKVector4)startColor endColor:(GLKVector4)endColor
{
    _maxParticles = count;
    _lifetime = lifetime;
    _spawnRate = spawnRate;
    _pStartScale = startScale;
    _pEndScale = endScale;
    _pPosition = position;
    _pVelocity = velocity;
    _pAcceleration = acceleration;
    _pStartColor = startColor;
    _pEndColor = endColor;
}

- (void)setVariationWithLifetime:(float)lifetime spawnRate:(float)spawnRate position:(GLKVector2)position velocity:(GLKVector2)velocity acceleration:(GLKVector2)acceleration startScale:(float)startScale endScale:(float)endScale startColor:(GLKVector4)startColor endColor:(GLKVector4)endColor
{
    _lifetimeVariation = lifetime;
    _spawnRateVariation = spawnRate;
    _startScaleVariation = startScale;
    _endScaleVariation = endScale;
    _positionVariation = position;
    _velocityVariation = velocity;
    _accelerationVariation = acceleration;
    _startColorVariation = startColor;
    _endColorVariation = endColor;
}

- (float)applyRandomVariationWithBase:(float)base variation:(float)variation
{
    variation *= 1000;
    float thisVariation = arc4random_uniform(variation*2);
    thisVariation -= variation;
    thisVariation /= 2000;
    
    return base + thisVariation;
}

- (GLKVector2)applyRandomVariationWithVectorBase:(GLKVector2)base variation:(GLKVector2)variation
{
    variation = GLKVector2MultiplyScalar(variation, 1000);
    float xVariation = arc4random_uniform(variation.x*2);
    float yVariation = arc4random_uniform(variation.y*2);
    xVariation -= variation.x;
    yVariation -= variation.y;
    
    xVariation /= 2000;
    yVariation /= 2000;
    
    return GLKVector2Make(base.x + xVariation, base.y + yVariation);
}

- (GLKVector4)applyRandomVariationWith4VectorBase:(GLKVector4)base variation:(GLKVector4)variation
{
    variation = GLKVector4MultiplyScalar(variation, 1000);
    float xVariation = arc4random_uniform(variation.x*2);
    float yVariation = arc4random_uniform(variation.y*2);
    float zVariation = arc4random_uniform(variation.z*2);
    float wVariation = arc4random_uniform(variation.w*2);
    xVariation -= variation.x;
    yVariation -= variation.y;
    zVariation -= variation.z;
    wVariation -= variation.w;
    
    xVariation /= 2000;
    yVariation /= 2000;
    zVariation /= 2000;
    wVariation /= 2000;
    
    return GLKVector4Make(base.x + xVariation, base.y + yVariation, base.z + zVariation, base.w + wVariation);
}

- (void)spawnParticle
{
    TBSprite *particleSprite = [[TBSprite alloc] initWithFile:_imageFileName];
    TBParticle *particle = [[TBParticle alloc] initWithDrawable:particleSprite];
    
    particle.type = PARTICLE;
    particle.layer = self.layer;
    particleSprite.additiveBlending = self.additiveBlending;
    particleSprite.colorBlending = self.colororBlending;
    
    particle.startScale = [self applyRandomVariationWithBase:_pStartScale variation:_startScaleVariation];
    particle.endScale = [self applyRandomVariationWithBase:_pEndScale variation:_endScaleVariation];
    
    GLKVector2 relativePosition = [self applyRandomVariationWithVectorBase:_pPosition variation:_positionVariation];
    particle.position = GLKVector2Make([self absolutePosition].x + relativePosition.x, [self absolutePosition].y + relativePosition.y);
    
    particle.velocity = [self applyRandomVariationWithVectorBase:_pVelocity variation:_velocityVariation];
    particle.acceleration = [self applyRandomVariationWithVectorBase:_pAcceleration variation:_accelerationVariation];
    
    particle.startColor = [self applyRandomVariationWith4VectorBase:_pStartColor variation:_startColorVariation];
    particle.endColor = [self applyRandomVariationWith4VectorBase:_pEndColor variation:_endColorVariation];
    
    particle.timeTillExpiration = [self applyRandomVariationWithBase:_lifetime variation:_lifetimeVariation];
    particle.totalLifeTime = particle.timeTillExpiration;
    
    [_particles addObject:particle];
    [[TBWorld instance] addEntity:particle];
}

- (void)updateWithTimeDelta:(float)delta
{
    [super updateWithTimeDelta:delta];
    
    _spawnTimePassed += delta;
    
    if (_spawnTimePassed > _nextSpawnTime) {
        if (_particles.count < _maxParticles) {
            _spawnTimePassed = 0;
            
            //This allows us to spawn particles at a rater greater than our framerate
            int iterations = 1;
            if (delta > _nextSpawnTime*2)
                iterations = (int)(_nextSpawnTime/delta);
            if (iterations < 1)
                iterations = 1;
            
            for (int i = 0; i < iterations; i++) {
                _nextSpawnTime = [self applyRandomVariationWithBase:_spawnRate variation:_spawnRateVariation];
                [self spawnParticle];
            }
        }
    }
    
    NSMutableArray *toRemove = [NSMutableArray array];
    for (TBParticle *particle in _particles) {
        if (!particle.alive) {
            [toRemove addObject:particle];
        }
    }
    
    for (TBParticle *particle in toRemove) {
        [_particles removeObject:particle];
    }
}

- (void)limitEffectLifetimeWithTime:(float)effectLifetime
{
    TBEvent *event = [[TBEvent alloc] initWithHandler:^(float progress) {
        _limitedDurationEffectInProgress = YES;
    } completion:^{
        self.alive = NO;
        _limitedDurationEffectInProgress = NO;
    } duration:effectLifetime repeat:NO];
    [event start];
}

- (void)handleDeath
{

}

- (BOOL)readyToDie
{
    return !_limitedDurationEffectInProgress;
}

@end
