//
//  FlickrAPIDelegate.h
//  GeoPixPuzzler
//
//  Created by Brian Halderman on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlickrAPIDelegate

@required
-(void)didFinishLoading:(NSDictionary *)info;


@end
