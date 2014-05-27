//
//  MapViewAnnotation.m
//  GeoPix
//
//  Created by Brian Halderman on 5/26/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import "MapViewAnnotation.h"

@implementation MapViewAnnotation

-(id)initWithLocation:(NSDictionary*)location {
    self = [super init];
    
    self.location = location;
    self.title = [location objectForKey:@"Name"];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[location objectForKey:@"Latitude"] doubleValue], [[location objectForKey:@"Longitude"] doubleValue]);
    
    [self setCoordinate:coordinate];
    
    return self;
}

@end
