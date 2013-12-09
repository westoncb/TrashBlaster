//
//  TBWorld.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 3/17/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBWorld.h"
#import "TBCreature.h"
#import "TBNPC.h"
#import <stdlib.h>
#import "TBStateSprite.h"
#import "TBBlockMachine.h"
#import "TBBlock.h"
#import "TBStringSprite.h"
#import "TBEventManager.h"
#import "TBGame.h"
#import "TBPlayer.h"

static TBWorld *_world;

@interface TBWorld()
@property NSMutableArray * entities;
@property NSMutableArray * colliders;
@property NSMutableArray * blocks;
@property NSMutableArray * addEntityBuffer; //add to the buffer instead because something might want to add to 'entities' while we
                                            //are iterating that collection
@property NSMutableArray * removeEntityBuffer;

@property TBSprite * bgSprite;
@property TBPlayer * player;
@end

@implementation TBWorld

+ (TBWorld *)instance
{
    if (!_world)
        _world = [[TBWorld alloc] init];
    
    return _world;
}

+ (void)destroy
{
    _world = nil;
    [TBGame destroy];
}

- (id)init {
    self = super.init;
    
    return self;
}

- (void)start
{
    TBWorld.effect = [[GLKBaseEffect alloc] init];
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, TBWorld.WIDTH, 0, TBWorld.HEIGHT, -1024, 1024);
    TBWorld.effect.transform.projectionMatrix = projectionMatrix;
    
    self.entities = [NSMutableArray array];
    self.colliders = [NSMutableArray array];
    self.blocks = [NSMutableArray array];
    self.addEntityBuffer = [NSMutableArray array];
    self.removeEntityBuffer = [NSMutableArray array];
    
    _doTheBezier = NO;
    
    if (_doTheBezier) {
        
        int points = 3;
        int radius = 45;
        
        _controlPoints = [NSMutableArray arrayWithCapacity:points];
        _bezierSampleSize = 100;
        _bezierCurve = [NSMutableArray arrayWithCapacity:_bezierSampleSize];
        
        for (int i = 0; i < _bezierSampleSize; i++) {
            TBSprite *sprite = [[TBSprite alloc] initWithFile:@"player2stand.png"];
            TBEntity *entity = [[TBEntity alloc] initWithDrawable:sprite];
            
            [self addEntity:entity];
            [_bezierCurve addObject:entity];
        }
        
        for (int i = 0; i < points; i++) {
            TBSprite *sprite = [[TBSprite alloc] initWithFile:@"tinyexplosion.png"];
            TBEntity *entity = [[TBEntity alloc] initWithDrawable:sprite];
            
            float rotation = (M_PI*2/points)*i;
            
            entity.position = GLKVector2Make(TBWorld.WIDTH/2 + cosf(rotation)*radius,
                                             TBWorld.HEIGHT/2 + sinf(rotation)*radius);
            entity.type = CONTROL_POINT;
            
            [self addEntity:entity];
            [_controlPoints addObject:entity];
        }
    } else {
        self.bgSprite = [[TBSprite alloc] initWithFile:@"background2.png"];
        
        TBEntity *background = [[TBEntity alloc] initWithDrawable:self.bgSprite];
        background.layer = 0;
        background.size = CGSizeMake(TBWorld.WIDTH, TBWorld.HEIGHT);
        background.type = DECORATION;
        [self addEntity:background];
        
        [self createPlayer];
        
//        [self addCreature];
//        [self addCreature];
//        [self addCreature];
//        [self addCreature];
//        [self addCreature];
//        [self addCreature];
//        [self addCreature];
//        [self addCreature];
//        [self addCreature];
//        [self addCreature];
//        [self addCreature];
//        [self addCreature];
        
        TBStringSprite *scoreTextSprite = [[TBStringSprite alloc] initWithString:@"Score:"];
        _scoreTextEntity = [[TBEntity alloc] initWithDrawable:scoreTextSprite];
        _scoreTextEntity.position = GLKVector2Make(0, 0);
        _scoreTextEntity.scale = GLKVector2Make(1.3f, 1.3f);
        
        [self addEntity:_scoreTextEntity];
        
        self.blockMachine = [[TBBlockMachine alloc] init];
    }
}

- (void)createPlayer
{
    TBSprite *bulletSprite = [[TBSprite alloc] initWithFile:@"bullet.png"];
    TBAnimationInfo animationInfo;
    animationInfo.frameWidth = 64;
    animationInfo.frameHeight = 64;
    animationInfo.frameCount = 9;
    animationInfo.frameLength = 50;
    animationInfo.loop = YES;
    _runSprite  = [[TBAnimatedSprite alloc] initWithFile:@"baseplayer.png" animationInfo:animationInfo row:2];
    _shootSprite = [[TBSprite alloc] initWithFile:@"baseplayer.png" col:4 row:1];
    
    //shirt
    TBAnimatedSprite *walkingShirtSprite = [[TBAnimatedSprite alloc] initWithFile:@"TORSO_plate_armor_torso.png" animationInfo:animationInfo row:2];
    TBSprite *shootingShirtSprite = [[TBSprite alloc] initWithFile:@"TORSO_plate_armor_torso.png" col:4 row:1];
    NSMutableDictionary *shirtMap = [[NSMutableDictionary alloc] init];
    [shirtMap setValue:walkingShirtSprite forKey:@"run"];
    [shirtMap setValue:walkingShirtSprite forKey:@"run_xf"];
    [shirtMap setValue:shootingShirtSprite forKey:@"shoot"];
    TBStateSprite *shirtSprite = [[TBStateSprite alloc] initWithStateMap:shirtMap initialState:@"shoot"];
    
    //shoes
    TBAnimatedSprite *walkingShoesSprite = [[TBAnimatedSprite alloc] initWithFile:@"FEET_plate_armor_shoes.png" animationInfo:animationInfo row:2];
    TBSprite *shootingShoesSprite = [[TBSprite alloc] initWithFile:@"FEET_plate_armor_shoes.png" col:4 row:1];
    NSMutableDictionary *shoesMap = [[NSMutableDictionary alloc] init];
    [shoesMap setValue:walkingShoesSprite forKey:@"run"];
    [shoesMap setValue:walkingShoesSprite forKey:@"run_xf"];
    [shoesMap setValue:shootingShoesSprite forKey:@"shoot"];
    TBStateSprite *shoesSprite = [[TBStateSprite alloc] initWithStateMap:shoesMap initialState:@"shoot"];
    
    //helmet
    TBAnimatedSprite *walkingHelmetSprite = [[TBAnimatedSprite alloc] initWithFile:@"HEAD_plate_armor_helmet.png" animationInfo:animationInfo row:2];
    TBSprite *shootingHelmetSprite = [[TBSprite alloc] initWithFile:@"HEAD_plate_armor_helmet.png" col:4 row:1];
    NSMutableDictionary *helmetMap = [[NSMutableDictionary alloc] init];
    [helmetMap setValue:walkingHelmetSprite forKey:@"run"];
    [helmetMap setValue:walkingHelmetSprite forKey:@"run_xf"];
    [helmetMap setValue:shootingHelmetSprite forKey:@"shoot"];
    TBStateSprite *helmetSprite = [[TBStateSprite alloc] initWithStateMap:helmetMap initialState:@"shoot"];
    
    //gloves
    TBAnimatedSprite *walkingGlovesSprite = [[TBAnimatedSprite alloc] initWithFile:@"HANDS_plate_armor_gloves.png" animationInfo:animationInfo row:2];
    TBSprite *shootingGlovesSprite = [[TBSprite alloc] initWithFile:@"HANDS_plate_armor_gloves.png" col:4 row:1];
    NSMutableDictionary *glovesMap = [[NSMutableDictionary alloc] init];
    [glovesMap setValue:walkingGlovesSprite forKey:@"run"];
    [glovesMap setValue:walkingGlovesSprite forKey:@"run_xf"];
    [glovesMap setValue:shootingGlovesSprite forKey:@"shoot"];
    TBStateSprite *glovesSprite = [[TBStateSprite alloc] initWithStateMap:glovesMap initialState:@"shoot"];
    
    //pants
    TBAnimatedSprite *walkingPantsSprite = [[TBAnimatedSprite alloc] initWithFile:@"LEGS_plate_armor_pants.png" animationInfo:animationInfo row:2];
    TBSprite *shootingPantsSprite = [[TBSprite alloc] initWithFile:@"LEGS_plate_armor_pants.png" col:4 row:1];
    NSMutableDictionary *pantsMap = [[NSMutableDictionary alloc] init];
    [pantsMap setValue:walkingPantsSprite forKey:@"run"];
    [pantsMap setValue:walkingPantsSprite forKey:@"run_xf"];
    [pantsMap setValue:shootingPantsSprite forKey:@"shoot"];
    TBStateSprite *pantsSprite = [[TBStateSprite alloc] initWithStateMap:pantsMap initialState:@"shoot"];
    
    //arms
    TBAnimatedSprite *walkingArmsSprite = [[TBAnimatedSprite alloc] initWithFile:@"TORSO_plate_armor_arms_shoulders.png" animationInfo:animationInfo row:2];
    TBSprite *shootingArmsSprite = [[TBSprite alloc] initWithFile:@"TORSO_plate_armor_arms_shoulders.png" col:4 row:1];
    NSMutableDictionary *armsMap = [[NSMutableDictionary alloc] init];
    [armsMap setValue:walkingArmsSprite forKey:@"run"];
    [armsMap setValue:walkingArmsSprite forKey:@"run_xf"];
    [armsMap setValue:shootingArmsSprite forKey:@"shoot"];
    TBStateSprite *armsSprite = [[TBStateSprite alloc] initWithStateMap:armsMap initialState:@"shoot"];
    
    NSMutableDictionary *stateMap = [[NSMutableDictionary alloc] init];
    [stateMap setValue:_runSprite forKey:@"run"];
    [stateMap setValue:_runSprite forKey:@"run_xf"];
    [stateMap setValue:_shootSprite forKey:@"shoot"];
    TBStateSprite *playerSprite = [[TBStateSprite alloc] initWithStateMap:stateMap initialState:@"shoot"];
    [playerSprite linkSprite:shirtSprite];
    [playerSprite linkSprite:shoesSprite];
    [playerSprite linkSprite:helmetSprite];
    [playerSprite linkSprite:glovesSprite];
    [playerSprite linkSprite:pantsSprite];
    [playerSprite linkSprite:armsSprite];
    _player = [[TBPlayer alloc] initWithStateSprite:playerSprite bulletSprite:bulletSprite];
    [_player.collidesWith addObject:[NSNumber numberWithInt:BLOCK]];
    [_player activateGun];
    _player.canShoot = YES;
    _player.layer = 5;
    
    [self addEntity:_player];
}

- (void)addCreature
{
    TBSprite *bulletSprite = [[TBSprite alloc] initWithFile:@"bullet.png"];
    TBAnimationInfo animationInfo;
    animationInfo.frameWidth = 64;
    animationInfo.frameHeight = 64;
    animationInfo.frameCount = 8;
    animationInfo.frameLength = 90;
    animationInfo.loop = YES;
    _runSprite  = [[TBAnimatedSprite alloc] initWithFile:@"player2.png" animationInfo:animationInfo];
    _shootSprite = [[TBSprite alloc] initWithFile:@"player2stand.png"];
    _runSprite.size = CGSizeMake(64, 64);
    _shootSprite.size = CGSizeMake(64, 64);
    NSMutableDictionary *stateMap = [[NSMutableDictionary alloc] init];
    [stateMap setValue:_runSprite forKey:@"run"];
    [stateMap setValue:_runSprite forKey:@"run_xf"];
    [stateMap setValue:_shootSprite forKey:@"shoot"];
    TBStateSprite *creatureSprite = [[TBStateSprite alloc] initWithStateMap:stateMap initialState:@"shoot"];
    TBCreature *creature = [[TBNPC alloc] initWithStateSprite:creatureSprite bulletSprite:bulletSprite];
    creature.INITIAL_SPEED = 25;
    creature.maxSpeed = 75;
    creature.ACCELERATION = 2000;
    creature.DECELERATION = 12000;
    creature.power = 100;
    creature.keepImageAfterDeath = NO;
    [creature.collidesWith addObject:[NSNumber numberWithInt:BLOCK]];
    creature.type = NPC;
    creature.canShoot = NO;
    creature.reloadTime = 0.1;
    [self addEntity:creature];
}

- (void)updateScoreDisplay
{
    TBGame *game = [TBGame instance];
    
    if ([game getScore] != _lastScore || !_scoreEntity) {
        if (_scoreEntity)
            [self removeEntity:_scoreEntity];
        
        TBStringSprite *scoreSprite = [[TBStringSprite alloc] initWithString:[NSString stringWithFormat:@"%i", [game getScore]]];
        _scoreEntity = [[TBEntity alloc] initWithDrawable:scoreSprite];
        _scoreEntity.scale = GLKVector2Make(1.3f, 1.3f);
        _scoreEntity.position = GLKVector2Make(_scoreTextEntity.size.width, 0);
        
        [self addEntity:_scoreEntity];
        
        _lastScore = [game getScore];
    }
}

- (void)addEntity:(TBEntity *)entity
{
    [self.addEntityBuffer addObject:entity];
    if(entity.type == BLOCK)
        [self.blocks addObject:entity];
    
    if (entity.type != DECORATION)
        [self.colliders addObject:entity];
    
    [self.entities sortedArrayUsingSelector:@selector(compare:)];
}

- (void)removeEntity:(TBEntity *)entity {
    if (!entity.keepImageAfterDeath)
        [self.removeEntityBuffer addObject:entity];
    if([self.colliders containsObject:entity])
        [self.colliders removeObject:entity];
    if([self.blocks containsObject:entity])
        [self.blocks removeObject:entity];
}

- (BOOL)update:(float)delta {
    [self.blockMachine update:delta];
    [[TBEventManager instance] updateWithTimeDelta:delta];
    [[TBGame instance] updateWithTimeDelta:delta];
    
    for (TBEntity * entity in self.entities) {
        
        if (entity.type == PLAYER && !entity.alive) {
            return YES;
        }
        
        [entity update:delta];
    }
    for (TBEntity * entity in self.addEntityBuffer) {
        [self.entities addObject:entity];
    }
    [self.addEntityBuffer removeAllObjects];
    
    for (TBEntity * entity in self.removeEntityBuffer) {
        [self.entities removeObject:entity];
    }
    [self.removeEntityBuffer removeAllObjects];
    
    [self updateScoreDisplay];
    
    [self removeDistantBullets];
    [self cleanupDeadEntities];
    [self checkForCollisions];
    
    return NO;
}

- (void)render
{
    [self insertionSortOnLayer];
    
    for (TBEntity * entity in self.entities) {
        if (!entity.parent)
            [entity render];
    }
    
    if (_doTheBezier)
        [self renderBezierCurve];
}

- (void)insertionSortOnLayer
{
    if (self.entities.count == 0)
        return;
    
    for (int i = 0; i < self.entities.count-1; i++) {
        int firstIndex = i+1;
        TBEntity *first = [_entities objectAtIndex:firstIndex];
        
        for (int j = i; j > -1 ; j--) {
            TBEntity *second = [_entities objectAtIndex:j];
            if (first.layer < second.layer) {
                [_entities setObject:second atIndexedSubscript:firstIndex];
                [_entities setObject:first atIndexedSubscript:j];
                firstIndex = j;
            }
        }
    }
}

- (void)renderBezierCurve
{
    CGPoint controlPoints[_controlPoints.count];
    int j = 0;
    for (TBEntity *entity in _controlPoints) {
        CGPoint point = CGPointMake(entity.position.x, entity.position.y);
        controlPoints[j] = point;
        j++;
    }
    
    int samples = _bezierSampleSize;
    for (int i = 0; i < samples; i++) {
        float t = (1.0f/samples)*i;
        CGPoint point = [self findPointOnBezierCurveWithT:t controlPoints:controlPoints count:_controlPoints.count];
        TBEntity *entity = [_bezierCurve objectAtIndex:i];
        entity.position = GLKVector2Make(point.x, point.y);
    }
}

- (CGPoint)findPointOnBezierCurveWithT:(float)t controlPoints:(CGPoint[])controlPoints count:(int)count
{
    if (count == 1)
        return controlPoints[0];
    
    CGPoint nextControlPoints[count - 1];
    int controlPointIndex = 0;
    CGPoint last;
    
    for (int i = 0; i < count; i++) {
        CGPoint point = controlPoints[i];
        
        if (i > 0) {
            float xInterp = last.x + t*(point.x - last.x);
            float yInterp = last.y + t*(point.y - last.x);
            nextControlPoints[controlPointIndex] = CGPointMake(xInterp, yInterp);
            controlPointIndex++;
        }
        
        last = point;
    }
    
    return [self findPointOnBezierCurveWithT:t controlPoints:nextControlPoints count:(count-1)];
}

- (void)cleanupDeadEntities
{
    for (TBEntity *entity in self.entities) {
        if (!entity.alive) {
            [self removeEntity:entity];
        }
    }
}

- (void) removeDistantBullets {
    for (TBEntity * entity in self.entities) {
        if(entity.type == BULLET && (entity.position.y > TBWorld.HEIGHT + 50 || entity.position.y < 0 || entity.position.x < 0 || entity.position.x > TBWorld.WIDTH + 50))
            [self removeEntity:entity];
    }
}

- (int)xPositionToColumn:(float)xPosition
{
    return ((int)xPosition)/32;
}

- (void)checkForBlockCollisions {
    for (TBBlock * block in self.blocks) {
        if (block.type == PLAYER) {
            continue;
        }
        
        int colIndex = [block getColumnIndex];
        int collisionThreshold = TBWorld.FLOOR_HEIGHT - block.collisionyoff;
        
        TBBlock *blockBelow = [block getBlockBelow];
        if (blockBelow.resting && blockBelow != self.blockMachine.dummyBlock) {
            collisionThreshold = blockBelow.position.y + blockBelow.size.height - block.collisionyoff;
        }
        
        if(block.position.y < collisionThreshold && fabsf(block.velocity.y) > 0) {
            [block setToRestingState];

            block.position = GLKVector2Make(block.position.x, collisionThreshold);
            
            [self.blockMachine alterColumnCount:colIndex adder:1];
        }
    }
}

- (void)blockWasDestroyed
{
    
}

- (void)movePlayerTo:(GLKVector2)dest {
    [self.player addDestPointWithDestX:dest.x destY:dest.y];
}

- (void)checkForCollisions {
    [self checkForBlockCollisions];
    
    for (TBEntity * entity in self.colliders) {
        for (TBEntity * entity2 in self.colliders) {
            if(entity != entity2 && (entity.alive || entity2.alive)) {
                BOOL collision = false;
                TBEntity * protruder = NULL;
                if([entity doCollisionCheck:entity2]) {
                    protruder = entity2;
                    collision = true;
                } else if([entity2 doCollisionCheck:entity]) {
                    protruder = entity;
                    collision = true;
                }
                if(collision) {
                    if ([entity.collidesWith containsObject:[NSNumber numberWithInt:entity2.type]]) {
                        [entity handleCollision:entity2 wasTheProtruder:(entity == protruder)];
                    }
                    if ([entity2.collidesWith containsObject:[NSNumber numberWithInt:entity.type]]) {
                        [entity2 handleCollision:entity wasTheProtruder:(entity2 == protruder)];
                    }

                }
            }
        }
    }
    
}

- (void)handlePanWithPoint:(CGPoint)point
{
    point = CGPointMake(point.x, (TBWorld.HEIGHT) - point.y);
    for (TBEntity *entity in _entities) {
        if (entity.type == CONTROL_POINT) {
            float x1 = entity.position.x;
            float x2 = x1 + entity.size.width;
            float y1 = entity.position.y;
            float y2 = y1 + entity.size.height;
            
            if (x1 <= point.x && point.x <= x2 && y1 <= point.y && point.y <= y2) {
                if (!entity.dragging) {
                    entity.touchPoint = CGPointMake(point.x - entity.position.x, point.y - entity.position.y);
                    entity.dragging = YES;
                }
            }
            
            if (entity.dragging) {
                entity.position = GLKVector2Make(point.x - entity.touchPoint.x, point.y - entity.touchPoint.y);
            }
        }
    }
}

- (void)handleFingerLiftedWithPoint:(CGPoint)point
{
    for (TBEntity *entity in _entities) {
        if (entity.type == CONTROL_POINT) {
            entity.dragging = NO;
        }
    }
}

- (void)setFramesPerSecond:(int)fps
{
    if (_fpsEntity)
        [self removeEntity:_fpsEntity];
    
    TBStringSprite *fpsSprite = [[TBStringSprite alloc] initWithString:[NSString stringWithFormat:@"%i", fps]];
    _fpsEntity = [[TBEntity alloc] initWithDrawable:fpsSprite];
    _fpsEntity.position = GLKVector2Make(0, HEIGHT - _fpsEntity.size.height);
    
    [self addEntity:_fpsEntity];
}

+ (GLKBaseEffect*)effect {
    return effect;
}

+ (void)setEffect:(GLKBaseEffect *)newEffect {
    effect = newEffect;
}

+ (int) WIDTH {
    return WIDTH;
}
+ (int) HEIGHT {
    return HEIGHT;
}
+ (int) FLOOR_HEIGHT {
    return FLOOR_HEIGHT;
}

- (TBPlayer *)getPlayer
{
    return _player;
}

@end
