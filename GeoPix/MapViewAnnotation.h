//
//  MapViewAnnotation.h
//  GeoPix
//
//  Created by Brian Halderman on 5/26/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapViewAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSDictionary *location;

-(id)initWithLocation:(NSDictionary*)location;

@end
