//
//  TBParticle.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/10/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBParticle.h"

@implementation TBParticle
- (void)updateWithTimeDelta:(float)delta
{
    [super updateWithTimeDelta:delta];
    
    self.timeTillExpiration -= delta;
    
    if (self.timeTillExpiration <= 0)
        self.alive = NO;
    else {
        [self interpolateScale];
        [self interpolateColor];
    }
}

- (void)interpolateColor
{
    float progress = (self.totalLifeTime - self.timeTillExpiration)/self.totalLifeTime;
    float red = (1 - progress)*self.startColor.x + self.endColor.x*progress;
    float green = (1 - progress)*self.startColor.y + self.endColor.y*progress;
    float blue = (1 - progress)*self.startColor.z + self.endColor.z*progress;
    float alpha = (1 - progress)*self.startColor.w + self.endColor.w*progress;
    
    self.color = GLKVector4Make(red, green, blue, alpha);
}

- (void)interpolateScale
{
    float progress = (self.totalLifeTime - self.timeTillExpiration)/self.totalLifeTime;
    float scale = (1 - progress)*self.startScale + self.endScale*progress;
    
    self.scale = GLKVector2Make(scale, scale);
}
@end