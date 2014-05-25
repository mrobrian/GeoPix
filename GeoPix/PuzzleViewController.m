//
//  PuzzleViewController.m
//  GeoPix
//
//  Created by Brian Halderman on 5/24/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import "PuzzleViewController.h"

@interface PuzzleViewController () {
    FlickrAPI *flickr;
    UIImage *puzzleImage;
    NSTimer *time;
    NSDate *startTime;
    BOOL puzzleLoaded;
}

@end

@implementation PuzzleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNeedsStatusBarAppearanceUpdate];
    self.canDisplayBannerAds = YES;
    puzzleLoaded = NO;
    
    flickr = [[FlickrAPI alloc] init];
    flickr.delegate = self;
    [flickr searchFlickrPhotos:self.searchBy];
}

-(void) incrementTimer {
    NSDate *nowTime = [NSDate date];
    NSTimeInterval elapsed = [nowTime timeIntervalSinceDate:startTime];
    NSUInteger seconds = (NSUInteger)round(elapsed);
    self.timerLabel.text = [NSString stringWithFormat:@"%02lu:%02lu", seconds / 60, seconds % 60];
}

-(void)viewWillDisappear:(BOOL)animated {
    // pause timer
    [time invalidate];
}

-(void)viewDidAppear:(BOOL)animated {
    // start/resume timer
    if (puzzleLoaded) {
        time = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(incrementTimer) userInfo:nil repeats:YES];
    }
}

-(void)didFinishLoading:(NSDictionary *)info {
    puzzleImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[info objectForKey:@"url_m"]]]];
    self.imageView.image = puzzleImage;
    self.imageView.hidden = NO;
    self.loadingLabel.hidden = YES;
    self.loadingSpinner.hidden = YES;
    startTime = [NSDate date];
    time = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(incrementTimer) userInfo:nil repeats:YES];
    puzzleLoaded = YES;
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
