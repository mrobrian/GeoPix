//
//  FlickrAPI.m
//  GeoPixPuzzler
//
//  Created by Brian Halderman on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlickrAPI.h"
#import "NSMutableArray_Shuffling.h"

@implementation FlickrAPI

NSString *const FlickrAPIKey = @"8d7266b2199c0db3fb4486ab963429fd";
NSString *const FlickrAPIUrl = @"https://api.flickr.com/services/rest";
NSArray *FlickrAPIStandardParams;

BOOL isGettingPageCount = YES;
int totalPages = 0;

-(id)init {
	if (self = [super init]) {
		receivedData = [[NSMutableData alloc] init];
        FlickrAPIStandardParams = @[
                                    @"method=flickr.photos.search",
                                    [NSString stringWithFormat:@"api_key=%@", FlickrAPIKey],
                                    @"per_page=20",
                                    @"format=json",
                                    @"nojsoncallback=1",
                                    @"has_geo=1",
                                    @"extras=geo,url_m,url_l",
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

-(void)searchFlickrPhotosByLocation:(CLLocationCoordinate2D)location withRadius:(int)radius {
	isGettingPageCount = YES;
	NSDate *date = [NSDate date];
	date = [date dateByAddingTimeInterval:-60 * 60 * 24 * 45];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyy-MM-dd+HH:mm:ss"];
	self.searchString = [NSString stringWithFormat:@"%@?%@&lat=%f&lon=%f&radius=%i&min_taken_date=%@&page=%%i",
						 FlickrAPIUrl,
                         [FlickrAPIStandardParams componentsJoinedByString:@"&"],
						 location.latitude,
						 location.longitude,
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
		totalPages = [[[results objectForKey:@"photos"] objectForKey:@"pages"] intValue];
		if (totalPages == 0) {
			[self searchFlickrPhotos:@"London"];
			return;
		}
		if (totalPages > 400) {
			totalPages = 400;
		}
		int page = (arc4random() % totalPages) + 1;
		[self searchFlickrPhotosOnPage:page];
		isGettingPageCount = NO;
	} else {
		NSMutableArray *photos = [NSMutableArray arrayWithArray:[[results objectForKey:@"photos"] objectForKey:@"photo"]];
        [photos shuffle];
        for (NSDictionary *photo in photos) {
            float height = [[photo objectForKey:@"height_l"] floatValue];
            float width = [[photo objectForKey:@"width_l"] floatValue];
            // Make sure the large image is at least the right size
            if (height && width && height == 1024 && width > 681 && width < 740) {
                [self.delegate didFinishLoading:photo];
                return;
            }
        }
        // Couldn't find an appropriately sized image, so try another page
		int page = (arc4random() % totalPages) + 1;
		[self searchFlickrPhotosOnPage:page];
	}
}

@end
