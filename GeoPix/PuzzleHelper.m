//
//  PuzzleHelper.m
//  GeoPix
//
//  Created by Brian Halderman on 6/1/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import "PuzzleHelper.h"
#import "Constants.h"

@implementation PuzzleHelper

static NSMutableDictionary *solvedPuzzles; // location.ID: Dictionary of puzzle number: { time, moves }

+(void)loadData {
    if (solvedPuzzles == nil) {
        solvedPuzzles = [[NSUserDefaults standardUserDefaults] objectForKey:SOLVED_PUZZLES_KEY];
        if (solvedPuzzles == nil) {
            solvedPuzzles = [NSMutableDictionary dictionaryWithCapacity:0];
        }
    }
}

+(void)saveData {
    [[NSUserDefaults standardUserDefaults] setObject:solvedPuzzles forKey:SOLVED_PUZZLES_KEY];
}

+(NSInteger)solvedPuzzlesForLocation:(NSString*)locationId {
    [PuzzleHelper loadData];
    return [[((NSDictionary*)[solvedPuzzles objectForKey:locationId]) allKeys] count];
}

+(void)solvedPuzzleForLocation:(NSString*)locationId withNumber:(NSInteger)number time:(NSInteger)seconds moves:(NSInteger)moves {
    [PuzzleHelper loadData];
    NSMutableDictionary *location = [solvedPuzzles objectForKey:locationId];
    if (location == nil) {
        location = [NSMutableDictionary dictionaryWithCapacity:0];
        [solvedPuzzles setObject:location forKey:locationId];
    }
    NSMutableDictionary *puzzle = [location objectForKey:[NSString stringWithFormat:@"%lu", (long)number]];
    if (puzzle == nil) {
        puzzle = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:seconds], @"time",
                  [NSNumber numberWithInteger:moves], @"moves",
                  nil];
        [location setObject:puzzle forKey:[NSString stringWithFormat:@"%lu", (long)number]];
    } else {
        if (number % 2 == 0) { // TIMED
            if (seconds < [[puzzle objectForKey:@"time"] integerValue]) {
                [puzzle setObject:[NSNumber numberWithInteger:seconds] forKey:@"time"];
            }
        } else {
            if (moves < [[puzzle objectForKey:@"moves"] integerValue]) {
                [puzzle setObject:[NSNumber numberWithInteger:moves] forKey:@"moves"];
            }
        }
    }
    [PuzzleHelper saveData];
}

+(NSInteger)scoreForLocation:(NSString*)locationId withNumber:(NSInteger)number {
    [PuzzleHelper loadData];
    NSMutableDictionary *location = [solvedPuzzles objectForKey:locationId];
    if (location == nil) {
        return 0;
    }
    NSMutableDictionary *puzzle = [location objectForKey:[NSString stringWithFormat:@"%lu", (long)number]];
    if (puzzle == nil) {
        return 0;
    }
    if (number % 2 == 0) { // TIMED
        return [[puzzle objectForKey:@"time"] integerValue];
    } else {
        return [[puzzle objectForKey:@"moves"] integerValue];
    }
    
    return 0;
}

+(UIImage*)medalForScore:(NSInteger)score withTarget:(NSInteger)target {
    UIImage *image;
    
    if (score == 0) {
        image = [UIImage imageNamed:@"NewLocation"];
    } else {
        if (score <= target / 2) {
            image = [UIImage imageNamed:@"Gold Star"];
        } else if (score <= (3 * target) / 4) {
            image = [UIImage imageNamed:@"Silver Star"];
        } else {
            image = [UIImage imageNamed:@"Bronze Star"];
        }
    }
    
    return image;
}

@end
