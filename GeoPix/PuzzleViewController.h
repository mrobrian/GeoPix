//
//  PuzzleViewController.h
//  GeoPix
//
//  Created by Brian Halderman on 5/24/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"
#import "FlickrAPI.h"
#import "FlickrAPIDelegate.h"

@interface PuzzleViewController : UIViewController <FlickrAPIDelegate>

@property (nonatomic) PUZZLE_TYPE type;
@property (nonatomic) NSInteger difficulty;
@property (nonatomic) NSInteger target;
@property (nonatomic) BOOL rotation;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) int radius;
@property (nonatomic, strong) NSString *searchBy;
@property (nonatomic, strong) NSString *locationId;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetLabel;
@property (weak, nonatomic) IBOutlet UILabel *movesLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIView *puzzleView;
@property (weak, nonatomic) IBOutlet UIImageView *fullImage;
@property (weak, nonatomic) IBOutlet UIView *gameOverView;
@property (weak, nonatomic) IBOutlet UILabel *gameOverLabel;
@property (weak, nonatomic) IBOutlet UIButton *gameOverButton;
@property (weak, nonatomic) IBOutlet UIImageView *leftMedal;
@property (weak, nonatomic) IBOutlet UIImageView *rightMedal;

- (IBAction)back:(id)sender;
- (IBAction)gameOverButton:(id)sender;

typedef NS_ENUM(int, GAME_OVER_TYPE) {
    GO_WON = 1,
    GO_MOVES,
    GO_TIME
};

@end
