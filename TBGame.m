//
//  TBGame.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/7/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBGame.h"
#import "TBWorld.h"
#import "TBPlayer.h"

static TBGame *_game;

@implementation TBGame

+ (TBGame *)instance
{
    if (!_game)
        _game = [[TBGame alloc] init];
    
    return _game;
}

+ (void)destroy
{
    _game = nil;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _scoreMultiplier = 1;
    }
    
    return self;
}

- (void)blockWasDestroyed
{
    _score += [self getCurrentBlockValue];
    
    if (_timeSinceLastScore < BONUS_SCORE_OPPORTUNITY_DURATION) {
        [[[TBWorld instance] getPlayer] increaseGlow];
        
        [self increaseBonusLevel];
        
        _scoreMultiplier = _bonusLevel + 1;
    }
    
    _timeSinceLastScore = 0;
}

- (void)increaseBonusLevel
{
    _bonusLevel++;
    
    if (_bonusLevel > MAX_BONUS_LEVEL) {
        _bonusLevel = MAX_BONUS_LEVEL;
    }
}

- (int)getScore
{
    return _score;
}

- (void)updateWithTimeDelta:(float)delta
{
    _timeSinceLastScore += delta;
    
    if (_timeSinceLastScore > BONUS_SCORE_OPPORTUNITY_DURATION) {
        _bonusLevel = 0;
        _scoreMultiplier = 1;
        _timeSinceLastMonsterSpawn = 0.0f;
        [[[TBWorld instance] getPlayer] endGlow];
    }
    
    if (_bonusLevel == MAX_BONUS_LEVEL) {
        _timeSinceLastMonsterSpawn += delta;
        if (_timeSinceLastMonsterSpawn > MONSTER_SPAWN_DELAY) {
            _timeSinceLastMonsterSpawn = 0.0f;
            [[TBWorld instance] addCreature];
        }
    }
}

- (int)getCurrentBlockValue
{
    return _scoreMultiplier * BASE_BLOCK_VALUE;
}
@end
