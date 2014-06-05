//
//  LocationHelper.m
//  GeoPix
//
//  Created by Brian Halderman on 6/4/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import "LocationHelper.h"
#import "Constants.h"

@implementation LocationHelper

static NSMutableArray *visibleLocations;

+(void)loadData {
    if (visibleLocations == nil) {
        visibleLocations = [[NSUserDefaults standardUserDefaults] objectForKey:VISIBLE_LOCATIONS_KEY];
        if (visibleLocations == nil) {
            visibleLocations = [NSMutableArray arrayWithObject:@"SAN"];
            [[NSUserDefaults standardUserDefaults] setObject:visibleLocations forKey:VISIBLE_LOCATIONS_KEY];
        }
    }
}

+(void)saveData {
    [[NSUserDefaults standardUserDefaults] setObject:visibleLocations forKey:VISIBLE_LOCATIONS_KEY];
}

+(BOOL)canShowLocation:(NSString*)locationId {
    [LocationHelper loadData];
    return [visibleLocations containsObject:locationId];
}

@end
