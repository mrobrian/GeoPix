//
//  FlickrAPI.h
//  GeoPixPuzzler
//
//  Created by Brian Halderman on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "FlickrAPIDelegate.h"

@interface FlickrAPI : NSObject {
	NSMutableData *receivedData;
}

@property (nonatomic, retain) id <FlickrAPIDelegate> delegate;
@property (nonatomic, retain) NSString *searchString;

-(void)searchFlickrPhotos:(NSString *)text;
-(void)searchFlickrPhotosByLocation:(CLLocationCoordinate2D)location withRadius:(int)radius;
-(void)searchFlickrPhotosOnPage:(int)page;

@end
