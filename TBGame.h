//
//  TBGame.h
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/7/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import <Foundation/Foundation.h>

static const float BONUS_SCORE_OPPORTUNITY_DURATION = 1.5f;
static const int BASE_BLOCK_VALUE = 10;
static const int MAX_BONUS_LEVEL = 8;

@interface TBGame : NSObject {
    float _timeSinceLastScore;
    int _score;
    int _scoreMultiplier;
}

@property int bonusLevel;

+ (TBGame *)instance;
+ (void)destroy;
- (void)updateWithTimeDelta:(float)delta;
- (int)getScore;
- (void)blockWasDestroyed;
- (int)getCurrentBlockValue;
@end
