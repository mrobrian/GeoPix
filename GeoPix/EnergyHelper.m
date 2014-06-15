//
//  EnergyHelper.m
//  GeoPix
//
//  Created by Brian Halderman on 6/8/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import "EnergyHelper.h"
#import "Constants.h"

@implementation EnergyHelper

NSInteger _currentEnergy = -1;
NSDate *_timerStart;
NSTimer *_timer;

+(NSInteger)currentEnergy {
    if (_currentEnergy == -1) {
        id energy = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_ENERGY_KEY];
        if (energy == nil) {
            _currentEnergy = MAX_ENERGY;
        } else {
            _currentEnergy = [energy integerValue];
        }
        _timerStart = [[NSUserDefaults standardUserDefaults] objectForKey:ENERGY_TIMER_START_KEY];
        if (_timerStart) {
            while (_currentEnergy < MAX_ENERGY && [[NSDate dateWithTimeInterval:ENERGY_INTERVAL sinceDate:_timerStart] compare:[NSDate date]] == NSOrderedAscending) {
                _currentEnergy++;
                _timerStart = [NSDate dateWithTimeInterval:ENERGY_INTERVAL sinceDate:_timerStart];
            }
        }
        [EnergyHelper startTimer];
    }
    
    return _currentEnergy;
}

+(BOOL)hasEnergy {
    return [EnergyHelper currentEnergy] > 0;
}

+(void)saveEnergy {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_currentEnergy] forKey:CURRENT_ENERGY_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:_timerStart forKey:ENERGY_TIMER_START_KEY];
}

+(BOOL)useEnergy:(NSInteger)amount {
    if ([EnergyHelper currentEnergy] >= amount) {
        _currentEnergy -= amount;
        [EnergyHelper startTimer];
        return YES;
    } else {
        return NO;
    }
}

+(NSTimeInterval)nextEnergy {
    if (_timerStart == nil) {
        return -1;
    }
    return ENERGY_INTERVAL - [[NSDate date] timeIntervalSinceDate:_timerStart];
}

+(void)startTimer {
    if (_timer != nil) {
        return;
    }
    
    if ([EnergyHelper currentEnergy] < MAX_ENERGY) {
        if (_timerStart == nil) {
            _timerStart = [NSDate date];
        }
        _timer = [NSTimer timerWithTimeInterval:[EnergyHelper nextEnergy]
                                         target:self
                                       selector:@selector(incrementEnergy)
                                       userInfo:nil
                                        repeats:NO];
    } else {
        _timerStart = nil;
    }
    [EnergyHelper saveEnergy];
}

+(void)incrementEnergy {
    _currentEnergy++;
    _timer = nil;
    [EnergyHelper startTimer];
}

@end
