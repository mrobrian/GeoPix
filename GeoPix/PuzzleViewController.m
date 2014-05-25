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
    NSInteger selectedTile;
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
    selectedTile = -1;
    
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
        tile.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tileTouchFrom:)];
        [tile addGestureRecognizer:tap];
        
        CGRect imageFrame = CGRectMake((i % tilesX) * imageTileWidth, (i / tilesX) * imageTileHeight, imageTileWidth, imageTileHeight);
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], imageFrame);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, tileWidth-2, tileHeight-2)];
        [imageView setImage:[UIImage imageWithCGImage:imageRef]];
        CGImageRelease(imageRef);
        [tile addSubview:imageView];
        
        [tiles addObject:tile];

        [self.puzzleView addSubview:(UIView*)[tiles objectAtIndex:i]];
    }
    [self shuffleTiles];
    [self checkTilePositions];
}

-(void)tileTouchFrom:(UITapGestureRecognizer*)recognizer {
    NSInteger index = [tiles indexOfObject:recognizer.view];
    if (selectedTile != -1) {
        if (selectedTile == index) {
            if (self.rotation) {
                //TODO: spin the tile
            }
            recognizer.view.backgroundColor = nil;
        } else {
            // swap tiles
            UIView *fromTile = (UIView*)(tiles[selectedTile]);
            UIView *toTile = (UIView*)(tiles[index]);
            fromTile.backgroundColor = nil;
            self.puzzleView.userInteractionEnabled = NO;
            moves++;
            [self updateMoves];
            [UIView animateWithDuration:0.3 animations:^{
                fromTile.alpha = 0.0;
                toTile.alpha = 0.0;
            } completion:^(BOOL finished) {
                CGRect tmpRect = fromTile.frame;
                fromTile.frame = toTile.frame;
                toTile.frame = tmpRect;
                [UIView animateWithDuration:0.2 animations:^{
                    fromTile.alpha = 1.0;
                    toTile.alpha = 1.0;
                } completion:^(BOOL finished) {
                    [self checkTilePositions];
                    self.puzzleView.userInteractionEnabled = YES;
                }];
            }];
        }
        selectedTile = -1;
    } else {
        selectedTile = index;
        recognizer.view.backgroundColor = [UIColor yellowColor];
    }
}

-(void)shuffleTiles {
    NSMutableArray *shuffledRects = [NSMutableArray arrayWithArray:correctRects];
    [shuffledRects shuffle];
    for (int i = 0; i < tiles.count; i++) {
        [(UIView*)[tiles objectAtIndex:i] setFrame:[[shuffledRects objectAtIndex:i] CGRectValue]];
    }
}

-(void)checkTilePositions {
    NSInteger totalCorrect = 0;
    for (int i = 0; i < tiles.count; i++) {
        UIView *tile = tiles[i];
        CGRect correctRect = [correctRects[i] CGRectValue];
        if (correctRect.origin.x == tile.frame.origin.x && correctRect.origin.y == tile.frame.origin.y) {
            tile.backgroundColor = [UIColor colorWithRed:0.2 green:1.0 blue:0.4 alpha:1.0];
            totalCorrect++;
        } else {
            tile.backgroundColor = nil;
        }
    }
    if (totalCorrect == tilesX * tilesY) {
        // Win
        [time invalidate];
        self.puzzleView.userInteractionEnabled = NO;
        [self.puzzleView bringSubviewToFront:self.fullImage];
        self.fullImage.alpha = 0.0;
        self.fullImage.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{ self.fullImage.alpha = 1.0; }];
        if (self.type != CUSTOM) {
            //TODO: report elapsedTime and moves
//            NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:startTime];
        }
    }
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
