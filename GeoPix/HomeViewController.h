//
//  HomeViewController.h
//  GeoPix
//
//  Created by Brian Halderman on 5/10/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrAPIDelegate.h"

@interface HomeViewController : UIViewController <FlickrAPIDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIImageView *fadeImage;

@end
