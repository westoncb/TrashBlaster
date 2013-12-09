//
//  TBPlayer.m
//  TrashBlaster
//
//  Created by Weston Cannon Beecroft on 12/7/13.
//  Copyright (c) 2013 Weston Cannon Beecroft. All rights reserved.
//

#import "TBPlayer.h"
#import "TBGame.h"

@implementation TBPlayer

- (float)reloadTime
{
    TBGame *game = [TBGame instance];
    
    float multiplier = (game.bonusLevel < 7) ? game.bonusLevel : 6;
    
    return 0.20f - 0.025f*multiplier;
}

- (int)power
{
    int power = BASE_POWER;
    TBGame *game = [TBGame instance];
    if (game.bonusLevel > 6)
        power += game.bonusLevel - 6;
    
    return power;
}

@end
