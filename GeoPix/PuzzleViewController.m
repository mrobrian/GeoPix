//
//  PuzzleViewController.m
//  GeoPix
//
//  Created by Brian Halderman on 5/24/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import "PuzzleViewController.h"
#import "NSMutableArray_Shuffling.h"
#import "PuzzleHelper.h"
#import "LocationHelper.h"
#import <iAd/iAd.h>

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
    NSMutableArray *tileOrientations;
    GAME_OVER_TYPE gameOverReason;
}

@end

@implementation PuzzleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNeedsStatusBarAppearanceUpdate];
    self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyManual;
    
    flickr = [[FlickrAPI alloc] init];
    flickr.delegate = self;
}

-(void) loadPuzzle {
    puzzleLoaded = NO;
    moves = 0;
    selectedTile = -1;
    gameOverReason = 0;
    startTime = nil;
    
    self.puzzleView.hidden = YES;
    self.gameOverView.hidden = YES;
    self.loadingLabel.hidden = NO;
    self.loadingSpinner.hidden = NO;

    tilesX = 2 * pow(2, self.difficulty);
    tilesY = (tilesX / 2) * 3;
    tiles = [NSMutableArray arrayWithCapacity:tilesX * tilesY];
    correctRects = [NSMutableArray arrayWithCapacity:tilesX * tilesY];
    tileOrientations = [NSMutableArray arrayWithCapacity:tilesX * tilesY];
    
    if (CLLocationCoordinate2DIsValid(self.location) && !(self.location.latitude == 0 && self.location.longitude == 0)) {
        [flickr searchFlickrPhotosByLocation:self.location withRadius:self.radius];
    } else {
        [flickr searchFlickrPhotos:self.searchBy];
    }
}

-(void) incrementTimer {
    NSDate *nowTime = [NSDate date];
    NSTimeInterval elapsed = [nowTime timeIntervalSinceDate:startTime];
    NSUInteger seconds = (NSUInteger)round(elapsed);
    self.timerLabel.text = [NSString stringWithFormat:@"%02lu:%02lu", (long)(seconds / 60), (long)(seconds % 60)];
    if (self.type == TIMED && seconds >= self.target) {
        [time invalidate];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showGameOverView:) userInfo:[NSNumber numberWithInt:GO_TIME] repeats:NO];
    }
}

-(void) updateMoves {
    self.movesLabel.text = [NSString stringWithFormat:@"%lu moves", (long)moves];
    if (self.type == MOVES && moves >= self.target && self.fullImage.hidden) {
        [time invalidate];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showGameOverView:) userInfo:[NSNumber numberWithInt:GO_MOVES] repeats:NO];
    }
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
        [self loadPuzzle];
    }
}

-(void)didFinishLoading:(NSDictionary *)info {
    puzzleImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[info objectForKey:@"url_l"]]]];
    self.fullImage.image = puzzleImage;
    [self createTilesFromImage:puzzleImage withHeight:[[info objectForKey:@"height_l"] integerValue] Width:[[info objectForKey:@"width_l"] integerValue]];
    self.puzzleView.hidden = NO;
    
    self.loadingLabel.hidden = YES;
    self.loadingSpinner.hidden = YES;
    puzzleLoaded = YES;
    
    if (self.target != 0) {
        NSString *target;
        if (self.type == TIMED) {
            target = [NSString stringWithFormat:@"%02ld:%02ld", (long)(self.target / 60), (long)(self.target % 60)];
        } else {
            target = [NSString stringWithFormat:@"%lu moves", (long)self.target];
        }
        self.targetLabel.text = [NSString stringWithFormat:@"Target: %@", target];
    }
    
    [self updateMoves];

    if (self.isViewLoaded && self.view.window && !self.isPresentingFullScreenAd) {
        startTime = [NSDate date];
        time = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(incrementTimer) userInfo:nil repeats:YES];
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
        if (self.rotation) {
            NSInteger orientation = (arc4random() % 4);
            [tileOrientations addObject:[NSNumber numberWithInteger:orientation]];
            tile.transform = CGAffineTransformMakeRotation(0.5 * orientation * M_PI);
        } else {
            [tileOrientations addObject:[NSNumber numberWithInteger:0]];
        }
        tile.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tileTouchFrom:)];
        [tile addGestureRecognizer:tap];
        
        CGRect imageFrame = CGRectMake((i % tilesX) * imageTileWidth, (i / tilesX) * imageTileHeight, imageTileWidth, imageTileHeight);
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], imageFrame);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, tileWidth-2, tileHeight-2)];
        [imageView setImage:[UIImage imageWithCGImage:imageRef]];
        CGImageRelease(imageRef);
        imageView.tag = 100;
        [tile addSubview:imageView];

        [tiles addObject:tile];

        [self.puzzleView addSubview:(UIView*)[tiles objectAtIndex:i]];
    }
    // Make sure no more than 20% of the tiles are correct to begin with
    while ([self correctTilesCount] > (tilesX * tilesY) / 5) {
        [self shuffleTiles];
    }
    [self checkTilePositions];
    self.puzzleView.userInteractionEnabled = YES;
}

-(void)tileTouchFrom:(UITapGestureRecognizer*)recognizer {
    NSInteger index = [tiles indexOfObject:recognizer.view];
    if (selectedTile != -1) {
        if (selectedTile == index) {
            if (self.rotation) {
                UIView *tile = (UIView*)(tiles[selectedTile]);
                NSInteger orientation = [[tileOrientations objectAtIndex:index] integerValue];
                orientation++;
                if (orientation == 4) {
                    orientation = 0;
                }
                tileOrientations[index] = [NSNumber numberWithInteger:orientation];
                [UIView animateWithDuration:0.3 animations:^{
                    tile.transform = CGAffineTransformMakeRotation(0.5 * orientation * M_PI);
                } completion:^(BOOL finished) {
                    [self checkTilePositions];
                }];
            }
            recognizer.view.backgroundColor = nil;
        } else {
            // swap tiles
            UIView *fromTile = (UIView*)(tiles[selectedTile]);
            UIView *toTile = (UIView*)(tiles[index]);
            fromTile.backgroundColor = nil;
            self.puzzleView.userInteractionEnabled = NO;
            moves++;
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
                    [self updateMoves];
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

-(NSInteger)correctTilesCount {
    NSInteger totalCorrect = 0;
    for (int i = 0; i < tiles.count; i++) {
        UIView *tile = tiles[i];
        CGRect correctRect = [correctRects[i] CGRectValue];
        if ((int)correctRect.origin.x == (int)tile.frame.origin.x
            && (int)correctRect.origin.y == (int)tile.frame.origin.y
            && [tileOrientations[i] integerValue] == 0) {
            tile.backgroundColor = [UIColor colorWithRed:0.2 green:1.0 blue:0.4 alpha:1.0];
            totalCorrect++;
        } else {
            tile.backgroundColor = nil;
        }
    }
    return totalCorrect;
}

-(void)checkTilePositions {
    NSInteger totalCorrect = [self correctTilesCount];
    if (totalCorrect == tilesX * tilesY) {
        // Win
        [time invalidate];
        self.puzzleView.userInteractionEnabled = NO;
        [self.puzzleView bringSubviewToFront:self.fullImage];
        self.fullImage.alpha = 0.0;
        self.fullImage.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{ self.fullImage.alpha = 1.0; }];
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(showGameOverView:) userInfo:[NSNumber numberWithInt:GO_WON] repeats:NO];
        if (self.type != CUSTOM) {
            NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:startTime];
            NSInteger puzzleNumber = 1;
            if (self.type == TIMED) {
                puzzleNumber++;
            }
            if (self.rotation) {
                puzzleNumber += 2;
            }
            [PuzzleHelper solvedPuzzleForLocation:self.locationId withNumber:puzzleNumber time:elapsedTime moves:moves];
            [LocationHelper unlockConnectionsForLocation:self.locationId];
            //TODO: report elapsedTime and moves
        }
    }
}

-(void)showGameOverView:(NSTimer*)timer {
    self.puzzleView.userInteractionEnabled = NO;
    self.gameOverView.alpha = 0;
    self.gameOverView.hidden = NO;
    gameOverReason = [(NSNumber*)timer.userInfo intValue];
    switch (gameOverReason) {
        case GO_WON:
            self.gameOverLabel.text = @"You Win!";
            [self.gameOverButton setTitle:@"Ok" forState:UIControlStateNormal];
            break;
        case GO_MOVES:
            self.gameOverLabel.text = @"Out of Moves";
            [self.gameOverButton setTitle:@"Retry" forState:UIControlStateNormal];
            break;
        case GO_TIME:
            self.gameOverLabel.text = @"Out of Time";
            [self.gameOverButton setTitle:@"Retry" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.gameOverView.alpha = 1.0;
    }];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)gameOverButton:(id)sender {
    switch (gameOverReason) {
        case GO_WON:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case GO_TIME:
        case GO_MOVES:
        default:
            for (UIView *tile in tiles) {
                [tile removeFromSuperview];
            }
            [tiles removeAllObjects];
            [self loadPuzzle];
            [self requestInterstitialAdPresentation];
            break;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
