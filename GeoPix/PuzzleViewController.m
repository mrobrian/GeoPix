//
//  PuzzleViewController.m
//  GeoPix
//
//  Created by Brian Halderman on 5/24/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import "PuzzleViewController.h"
#import "NSMutableArray_Shuffling.h"

@interface PuzzleViewController () {
    FlickrAPI *flickr;
    UIImage *puzzleImage;
    NSTimer *time;
    NSDate *startTime;
    BOOL puzzleLoaded;
    NSInteger moves;
    NSInteger tilesX;
    NSInteger tilesY;
    NSMutableArray *tiles;
    NSMutableArray *correctRects;
}

@end

@implementation PuzzleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNeedsStatusBarAppearanceUpdate];
    puzzleLoaded = NO;
    moves = 0;
    
    tilesX = 2 * pow(2, self.difficulty);
    tilesY = (tilesX / 2) * 3;
    tiles = [NSMutableArray arrayWithCapacity:tilesX * tilesY];
    correctRects = [NSMutableArray arrayWithCapacity:tilesX * tilesY];
    
    flickr = [[FlickrAPI alloc] init];
    flickr.delegate = self;
}

-(void) incrementTimer {
    NSDate *nowTime = [NSDate date];
    NSTimeInterval elapsed = [nowTime timeIntervalSinceDate:startTime];
    NSUInteger seconds = (NSUInteger)round(elapsed);
    self.timerLabel.text = [NSString stringWithFormat:@"%02lu:%02lu", seconds / 60, seconds % 60];
}

-(void) updateMoves {
    self.movesLabel.text = [NSString stringWithFormat:@"%lu moves", moves];
}

-(void)viewWillDisappear:(BOOL)animated {
    // pause timer
    [time invalidate];
}

-(void)viewDidAppear:(BOOL)animated {
    // start/resume timer
    if (puzzleLoaded) {
        if (!startTime) {
            startTime = [NSDate date];
        }
        time = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(incrementTimer) userInfo:nil repeats:YES];
    } else {
        [flickr searchFlickrPhotos:self.searchBy];
    }
}

-(void)viewDidLayoutSubviews {
    // Puzzle is changing size, so adjust tiles
}

-(void)didFinishLoading:(NSDictionary *)info {
    puzzleImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[info objectForKey:@"url_l"]]]];
    self.fullImage.image = puzzleImage;
    [self createTilesFromImage:puzzleImage withHeight:[[info objectForKey:@"height_l"] integerValue] Width:[[info objectForKey:@"width_l"] integerValue]];
    self.puzzleView.hidden = NO;
    
    self.loadingLabel.hidden = YES;
    self.loadingSpinner.hidden = YES;
    puzzleLoaded = YES;
    
    [self updateMoves];

    if (self.isViewLoaded && self.view.window) {
        startTime = [NSDate date];
        time = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(incrementTimer) userInfo:nil repeats:YES];
    }
}

-(void)createTilesFromImage:(UIImage*)image withHeight:(NSInteger)height Width:(NSInteger)width {
    NSInteger imageTileHeight = height / tilesY;
    NSInteger imageTileWidth = width / tilesX;
    NSInteger tileHeight = self.puzzleView.frame.size.height / tilesY;
    NSInteger tileWidth = self.puzzleView.frame.size.width / tilesX;
    for (int i = 0; i < tilesX * tilesY; i++) {
        CGRect frame = CGRectMake((i % tilesX) * tileWidth, (i / tilesX) * tileHeight, tileWidth, tileHeight);
        [correctRects addObject:[NSValue valueWithCGRect:frame]];
        UIView *tile = [[UIView alloc] initWithFrame:frame];
        
        CGRect imageFrame = CGRectMake((i % tilesX) * imageTileWidth, (i / tilesX) * imageTileHeight, imageTileWidth, imageTileHeight);
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], imageFrame);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, tileWidth-2, tileHeight-2)];
        [imageView setImage:[UIImage imageWithCGImage:imageRef]];
        CGImageRelease(imageRef);
        [tile addSubview:imageView];
        
        [tiles addObject:tile];
    }
    [self shuffleTiles];
    for (int i = 0; i < tiles.count; i++) {
        [self.puzzleView addSubview:(UIView*)[tiles objectAtIndex:i]];
    }
}

-(void)shuffleTiles {
    NSMutableArray *shuffledRects = [NSMutableArray arrayWithArray:correctRects];
    [shuffledRects shuffle];
    for (int i = 0; i < tiles.count; i++) {
        [(UIView*)[tiles objectAtIndex:i] setFrame:[[shuffledRects objectAtIndex:i] CGRectValue]];
    }
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
