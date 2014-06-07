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
static NSArray *locations;
static NSMutableDictionary *locationHash;

+(void)loadData {
    if (visibleLocations == nil) {
        visibleLocations = [[NSUserDefaults standardUserDefaults] objectForKey:VISIBLE_LOCATIONS_KEY];
        if (visibleLocations == nil) {
            visibleLocations = [NSMutableArray arrayWithObject:@"SAN"];
            [[NSUserDefaults standardUserDefaults] setObject:visibleLocations forKey:VISIBLE_LOCATIONS_KEY];
        }
    }
    if (locations == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"US Cities" ofType:@"plist"];
        locations = [NSArray arrayWithContentsOfFile:path];
        locationHash = [NSMutableDictionary dictionaryWithCapacity:0];
        for (NSDictionary *location in locations) {
            [locationHash setObject:location forKey:[location objectForKey:@"ID"]];
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

+(NSArray*)visibleLocations {
    [LocationHelper loadData];
    NSMutableArray *visibleLocations = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *location in locations) {
        if ([LocationHelper canShowLocation:[location objectForKey:@"ID"]]) {
            [visibleLocations addObject:location];
        }
    }
    return visibleLocations;
}

+(NSDictionary*)locationWithId:(NSString*)locationId {
    [LocationHelper loadData];
    return [locationHash objectForKey:locationId];
}

+(void)unlockConnectionsForLocation:(NSString*)locationId {
    NSArray *connections = [[LocationHelper locationWithId:locationId] objectForKey:@"Connections"];
    for (NSString *connection in connections) {
        if (![visibleLocations containsObject:connection]) {
            [visibleLocations addObject:connection];
        }
    }
    [LocationHelper saveData];
}

@end
