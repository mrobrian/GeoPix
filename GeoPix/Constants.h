//
//  Constants.h
//  GeoPix
//
//  Created by Brian Halderman on 5/19/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

extern NSString *DIFFICULTY_KEY;
extern NSString *VISIBLE_LOCATIONS_KEY;
extern NSString *SOLVED_PUZZLES_KEY;
extern NSString *LAST_LOCATION_KEY;

extern NSInteger MAX_ENERGY;
extern NSInteger ENERGY_INTERVAL;
extern NSString *ENERGY_TIMER_START_KEY;
extern NSString *CURRENT_ENERGY_KEY;

typedef NS_ENUM(int, PUZZLE_TYPE) {
    CUSTOM,
    TIMED,
    MOVES
};