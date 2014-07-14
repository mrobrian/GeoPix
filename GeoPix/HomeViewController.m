//
//  HomeViewController.m
//  GeoPix
//
//  Created by Brian Halderman on 5/10/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import "HomeViewController.h"
#import "FlickrAPI.h"
#import "GameKitHelper.h"
#import <GameKit/GameKit.h>
#import "Constants.h"

@interface HomeViewController () {
    NSMutableArray *backgroundImages;
    NSTimer *imageTimer;
    int currentBackgroundImage;
}
@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    backgroundImages = [NSMutableArray arrayWithCapacity:0];
    currentBackgroundImage = 0;
    [self loadBackgroundImage];
    //[GameKitHelper authenticateLocalPlayerWithViewController:self];
    id difficulty = [[NSUserDefaults standardUserDefaults] objectForKey:DIFFICULTY_KEY];
    if (difficulty == nil) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:DIFFICULTY_KEY];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadBackgroundImage {
    FlickrAPI *flickr = [[FlickrAPI alloc] init];
    flickr.delegate = self;
    [flickr searchFlickrPhotos:@"sky"];
}

-(void)showNextBackgroundImage {
    if (backgroundImages.count == 0) {
        return;
    }
    currentBackgroundImage++;
    if (currentBackgroundImage >= backgroundImages.count) {
        currentBackgroundImage = 0;
    }
    if (backgroundImages.count < 3) {
        [self loadBackgroundImage];
    }
    
    self.fadeImage.image = [backgroundImages objectAtIndex:currentBackgroundImage];
    self.fadeImage.hidden = NO;
    [UIImageView animateWithDuration:3.0 animations:^{
        self.fadeImage.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (finished) {
            self.mainImage.image = self.fadeImage.image;
        }
        self.fadeImage.hidden = YES;
        self.fadeImage.alpha = 0;
        self.fadeImage.image = nil;
    }];
}

// FlickrAPI
-(void)didFinishLoading:(NSDictionary *)info {
    [backgroundImages addObject:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[info objectForKey:@"url_m"]]]]];
    
    if (backgroundImages.count == 1) {
        [self showNextBackgroundImage];
        imageTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(showNextBackgroundImage) userInfo:nil repeats:YES];
    }
}

@end
