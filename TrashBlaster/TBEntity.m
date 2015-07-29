//
//  TBEntity.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/17/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBEntity.h"
#import "TBPoint.h"

@interface TBEntity()
@property float lastDelta;

@end

@implementation TBEntity
@synthesize parent = _parent;
@synthesize life = _life;
@synthesize size = _size;
@synthesize collisionsize = _collisionsize;
@synthesize collisionxoff = _collisionxoff;
@synthesize collisionyoff = _collisionyoff;

- (id)initWithDrawable:(id<TBDrawable>)drawable {
    self = [self init];
    if(self) {
        _drawable = drawable;
        self.size = CGSizeMake(drawable.size.width, drawable.size.height);
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _collidesWith = [NSMutableArray array];
        
        self.size = CGSizeMake(1, 1);
        self.collisionsize = CGSizeMake(_size.width, _size.height);
        self.acceleration = GLKVector2Make(0, 0);
        self.deceleration = GLKVector2Make(0, 0);
        self.velocity = GLKVector2Make(0, 0);
        self.position = GLKVector2Make(0, 0);
        self.scale = GLKVector2Make(1, 1);
        self.alive = true;
        self.maxSpeed = NSIntegerMax;
        self.type = DECORATION;
        _color = GLKVector4Make(1, 1, 1, 1);
        _subEntities = [NSMutableArray array];
        _attachmentPoints = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)updateWithTimeDelta:(float)delta
{    
    GLKVector2 velocityIncrement = GLKVector2MultiplyScalar(self.acceleration, delta);
    
    float newXVol = self.velocity.x + velocityIncrement.x;
    float newYVol = self.velocity.y + velocityIncrement.y;
    if (fabsf(newXVol) > self.maxSpeed) { //cap xspeed
        float xDirection = newXVol/fabsf(newXVol);
        velocityIncrement = GLKVector2Make((self.maxSpeed*xDirection) - self.velocity.x, velocityIncrement.y);
    }
    if (fabsf(newYVol) > self.maxSpeed) { //cap yspeed
        float yDirection = newYVol/fabsf(newYVol);
        velocityIncrement = GLKVector2Make(velocityIncrement.x, (self.maxSpeed*yDirection) - self.velocity.y);
    }
    self.velocity = GLKVector2Add(self.velocity, velocityIncrement);
    
    //It simplifies things to handle deceleration seperately, rather than just treating it as reverse acceleration
    GLKVector2 velocityDecrement = GLKVector2MultiplyScalar(self.deceleration, delta);
    newXVol = self.velocity.x + velocityDecrement.x;
    newYVol = self.velocity.y + velocityDecrement.y;
    if (fabsf(newXVol) > fabsf(self.velocity.x)) { //deceleration should never increase speed -- dampen to zero instead
        velocityDecrement = GLKVector2Make(-self.velocity.x, velocityDecrement.y); //this will make the x velocity zero
        self.deceleration = GLKVector2Make(0, self.deceleration.y);
    }
    if (fabsf(newYVol) > fabsf(self.velocity.y)) { //same for the y-axis
        velocityDecrement = GLKVector2Make(velocityDecrement.x, -self.velocity.y);
        self.deceleration = GLKVector2Make(self.deceleration.x, 0);
    }
    
    self.velocity = GLKVector2Add(self.velocity, velocityDecrement);
    
    [self updateMotion:delta];
    self.lastDelta = delta;
    [self.drawable updateWithTimeDelta:delta];
    
    for (TBEntity *entity in _subEntities) {
        [entity updateWithTimeDelta:delta];
    }
}

- (void)addSubEntity:(TBEntity *)entity
{
    [self addSubEntity:entity attachX:0 attachY:0];
}

- (void)addSubEntity:(TBEntity *)entity attachX:(float)x attachY:(float)y
{
    [entity setParent:self];
    [_subEntities addObject:entity];

    [self changeAttachmentPointForSubEntity:entity attachX:x attachY:y];
}

- (void)changeAttachmentPointForSubEntity:(TBEntity *)entity attachX:(float)x attachY:(float)y
{
    NSValue *valuePoint = [NSValue valueWithCGPoint:CGPointMake(x, y)];
    [_attachmentPoints setObject:valuePoint forKey:[entity key]];
}

- (void)removeSubEntity:(TBEntity *)entity
{
    entity.parent = nil;
    [_subEntities removeObject:entity];
    [_attachmentPoints removeObjectForKey:[entity key]];
}

- (void)updateMotion:(float)dt {
    GLKVector2 positionIncrement = GLKVector2MultiplyScalar(self.velocity, dt);
    GLKVector2 old = GLKVector2Make(self.position.x, self.position.y);
    GLKVector2 newPosition = GLKVector2Add(self.position, positionIncrement);
    self.position = [self vetNewPosition:newPosition];
    self.xChange = self.position.x - old.x;
    self.yChange = self.position.y - old.y;
}

- (GLKVector2)vetNewPosition:(GLKVector2)newPosition
{
    return newPosition;
}

- (void)render {
    [self renderWithStartingMatrix:GLKMatrix4Identity];
}

- (void)renderWithStartingMatrix:(GLKMatrix4)modelMatrix
{
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x - self.size.width/2.0f, self.position.y - self.size.height/2.0f, 0);
    modelMatrix = GLKMatrix4Scale(modelMatrix, self.scale.x, self.scale.y, 1.0f);
//    modelMatrix = GLKMatrix4Translate(modelMatrix, self.size.width/2*self.scale.x, self.size.height/2*self.scale.y, 0);
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.size.width/2, 0, 0);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, _rotation, 0, 0, 1);
    modelMatrix = GLKMatrix4Translate(modelMatrix, -self.size.width/2, 0, 0);
    
    for (int i = 0; i < _subEntities.count; i++) {
        TBEntity *entity = [_subEntities objectAtIndex:i];
        if (entity.layer < self.layer) {
            CGPoint attachPoint = [self getAttachmentPointForSubEntity:entity];
            
            modelMatrix = GLKMatrix4Translate(modelMatrix, attachPoint.x, attachPoint.y, 0);
            [entity renderWithStartingMatrix:modelMatrix];
            modelMatrix = GLKMatrix4Translate(modelMatrix, -attachPoint.x, -attachPoint.y, 0);
        }
    }
    
    GLKVector4 oldColor = [self.drawable color];
    [self.drawable setColor:self.color];
    [self.drawable renderWithModelMatrix:modelMatrix];
    [self.drawable setColor:oldColor];
    
    for (int i = 0; i < _subEntities.count; i++) {
        TBEntity *entity = [_subEntities objectAtIndex:i];
        if (entity.layer >= self.layer) {
            CGPoint attachPoint = [self getAttachmentPointForSubEntity:entity];
            
            modelMatrix = GLKMatrix4Translate(modelMatrix, attachPoint.x, attachPoint.y, 0);
            [entity renderWithStartingMatrix:modelMatrix];
            modelMatrix = GLKMatrix4Translate(modelMatrix, -attachPoint.x, -attachPoint.y, 0);
        }
    }
}

- (BOOL)doCollisionCheck:(TBEntity *)other {
    if([self doBoundsIntersect:self other:other]) {
        return TRUE;
    } else
        return FALSE;
}

- (void)handleCollision:(TBEntity *)collider wasTheProtruder:(BOOL)retractSelf {
//    if(retractSelf) {
//        self.velocity = GLKVector2MultiplyScalar(self.velocity, -0.1f);
//        do {
//            [self updateMotion:_lastDelta];
//        } while ((fabsf(self.xChange) > .001f || fabsf(self.yChange)) > .001f && [collider doCollisionCheck:self]);
//        
//        self.velocity = GLKVector2Make(self.velocity.x, 0);
//        self.acceleration = GLKVector2Make(self.acceleration.x, 0);
//    }
}

- (float)collisionx1 {
    return self.position.x + self.collisionxoff - self.size.width/2.0f;
}

- (float)collisionx2 {
    return self.position.x + self.collisionxoff + self.collisionsize.width - self.size.width/2.0f;
}

- (float)collisiony1 {
    return self.position.y + self.size.height - self.collisionyoff - self.size.height/2.0f;
}

- (float)collisiony2 {
    return self.position.y + self.size.height - self.collisionyoff - self.collisionsize.height - self.size.height/2.0f;
}

- (void)printCollisionBounds {
    NSLog(@"x1: %f, x2: %f, y1: %f, y2: %f", [self collisionx1], [self collisionx2], [self collisiony1], [self collisiony2]);
}

- (BOOL)doBoundsIntersect:(TBEntity *)first other:(TBEntity *)second {
    if (([first collisionx1] <= [second collisionx1] && [first collisionx2] >= [second collisionx1] &&
        [first collisiony1] >= [second collisiony1] && [first collisiony2] <= [second collisiony1]) ||
        ([first collisionx1] <= [second collisionx2] && [first collisionx2] >= [second collisionx2] &&
         [first collisiony1] >= [second collisiony1] && [first collisiony2] <= [second collisiony1]) ||
        ([first collisionx1] <= [second collisionx1] && [first collisionx2] >= [second collisionx1] &&
         [first collisiony1] >= [second collisiony2] && [first collisiony2] <= [second collisiony2]) ||
        ([first collisionx1] <= [second collisionx2] && [first collisionx2] >= [second collisionx2] &&
         [first collisiony1] >= [second collisiony2] && [first collisiony2] <= [second collisiony2])) {
        return true;
    }
    return FALSE;
}

- (NSComparisonResult)compare:(TBEntity *)otherObject {
    return otherObject.position.y - self.position.y;
}

//- (NSString *)description {
//    return [NSString stringWithFormat:@"layer: %i", self.layer];
//}

- (NSString *)key
{
    return [NSString stringWithFormat:@"%i", self.hash];
}

- (void)handleDeath
{

}

- (void)setSize:(CGSize)size
{   
    _size = size;
}

- (CGSize)size
{
    CGSize baseSize = [_drawable size];
    return CGSizeMake(self.scale.x*baseSize.width, self.scale.y*baseSize.height);
}

- (CGSize)baseSize
{
    return [_drawable size];
}

- (void)setCollisionsize:(CGSize)collisionsize
{
    _collisionsize = collisionsize;
}

- (CGSize)collisionsize
{
    return CGSizeMake(_collisionsize.width*self.scale.x, _collisionsize.height*self.scale.y);
}

- (float)collisionxoff
{
    return _collisionxoff*self.scale.x;
}

- (void)setCollisionxoff:(float)collisionxoff
{
    _collisionxoff = collisionxoff;
}

- (float)collisionyoff
{
    return _collisionyoff*self.scale.y;
}

- (void)setCollisionyoff:(float)collisionyoff
{
    _collisionyoff = collisionyoff;
}

- (void)setLife:(int)life {
    _life = life;
    
    if (_life <= 0) {
        self.alive = false;
    }
}

- (CGPoint)getAttachmentPointForSubEntity:(TBEntity *)entity
{
    NSValue *valuePoint = [_attachmentPoints objectForKey:[entity key]];
    CGPoint attachPoint = [valuePoint CGPointValue];
    
    return attachPoint;
}

- (GLKVector2)absolutePosition
{
    if (_parent) {
        GLKVector2 parentPosition = [_parent absolutePosition];
        CGPoint attachPoint = [_parent getAttachmentPointForSubEntity:self];
        GLKVector2 parentPlusChild = GLKVector2Add(parentPosition, self.position);
        
        return GLKVector2Make(parentPlusChild.x + attachPoint.x, parentPlusChild.y + attachPoint.y);
    }
    
    return self.position;
}

- (BOOL)readyToDie
{
    return YES;
}

- (int)life {
    return _life;
}

- (void)setParent:(TBEntity *)parent
{
    _parent = parent;
}

- (TBEntity *)parent
{
    return _parent;
}
@end
