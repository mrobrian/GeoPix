//
//  FlickrAPI.m
//  GeoPixPuzzler
//
//  Created by Brian Halderman on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlickrAPI.h"

@implementation FlickrAPI

NSString *const FlickrAPIKey = @"8d7266b2199c0db3fb4486ab963429fd";
NSString *const FlickrAPIUrl = @"https://api.flickr.com/services/rest";
NSArray *FlickrAPIStandardParams;

BOOL isGettingPageCount = YES;

-(id)init {
	if (self = [super init]) {
		receivedData = [[NSMutableData alloc] init];
        FlickrAPIStandardParams = @[
                                    @"method=flickr.photos.search",
                                    [NSString stringWithFormat:@"api_key=%@", FlickrAPIKey],
                                    @"per_page=10",
                                    @"format=json",
                                    @"nojsoncallback=1",
                                    @"has_geo=1",
                                    @"extras=geo,o_dims,url_m",
                                    @"media=photos"
                                    ];
	}
	return self;
}

-(void)searchFlickrPhotos:(NSString *)text
{
	isGettingPageCount = YES;
	self.searchString = [NSString
                         stringWithFormat:@"%@?%@&tags=%@&page=%%i",
                         FlickrAPIUrl,
                         [FlickrAPIStandardParams componentsJoinedByString:@"&"],
                         text
                         ];
	[self searchFlickrPhotosOnPage:1];
}

-(void)searchFlickrPhotosByLocation:(CLLocation *)location withRadius:(int)radius {
	isGettingPageCount = YES;
	NSDate *date = [NSDate date];
	date = [date dateByAddingTimeInterval:-60 * 60 * 24 * 45];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyy-MM-dd+HH:mm:ss"];
	self.searchString = [NSString stringWithFormat:@"%@?%@&lat=%f&lon=%f&radius=%i&min_taken_date=%@&page=%%i",
						 FlickrAPIUrl,
                         [FlickrAPIStandardParams componentsJoinedByString:@"&"],
						 location.coordinate.latitude,
						 location.coordinate.longitude,
                         radius,
						 [formatter stringFromDate:date]
						 ];
	[self searchFlickrPhotosOnPage:1];
}

-(void)searchFlickrPhotosOnPage:(int)page
{
	NSString *urlString = [NSString stringWithFormat:self.searchString, page];
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
	[receivedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSDictionary *results = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingAllowFragments error:nil];
	if (isGettingPageCount) {
		int pages = [[[results objectForKey:@"photos"] objectForKey:@"pages"] intValue];
		if (pages == 0) {
			[self searchFlickrPhotos:@"London"];
			return;
		}
		if (pages > 400) {
			pages = 400;
		}
		int page = (arc4random() % pages) + 1;
		[self searchFlickrPhotosOnPage:page];
		isGettingPageCount = NO;
	} else {
		NSArray *photos = [[results objectForKey:@"photos"] objectForKey:@"photo"];
        NSDictionary *photo = [photos objectAtIndex:arc4random() % [photos count]];
		[self.delegate didFinishLoading:photo];
	}
}

@end
