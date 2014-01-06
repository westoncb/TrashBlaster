//
//  TBGame.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/7/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>

static const int BASE_BLOCK_VALUE = 10;
static const int MAX_BONUS_LEVEL = 9;
static const float MONSTER_SPAWN_DELAY = 5.0f;

@interface TBGame : NSObject {
    float _timeSinceLastScore;
    int _score;
    int _scoreMultiplier;
    int _blocksDestroyed;
    
    float _timeSinceLastMonsterSpawn;
    float _bonusScoreOpportunityDuration;
}

@property int bonusLevel;

+ (TBGame *)instance;
+ (void)destroy;
- (void)updateWithTimeDelta:(float)delta;
- (int)getScore;
- (void)blockWasDestroyed;
- (int)getCurrentBlockValue;
@end
