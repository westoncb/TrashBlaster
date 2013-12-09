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
        
        _bonusLevel++;
        _scoreMultiplier = _bonusLevel + 1;
    }
    
    _timeSinceLastScore = 0;
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
        [[[TBWorld instance] getPlayer] endGlow];
    }
}

- (int)getCurrentBlockValue
{
    return _scoreMultiplier * BASE_BLOCK_VALUE;
}
@end
