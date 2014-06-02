//
//  LeaderboardTableViewCell.h
//  GeoPix
//
//  Created by Brian Halderman on 6/1/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeaderboardTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@end
