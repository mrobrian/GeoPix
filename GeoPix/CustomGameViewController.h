//
//  CustomGameViewController.h
//  GeoPix
//
//  Created by Brian Halderman on 5/18/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomGameViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tagText;
@property (weak, nonatomic) IBOutlet UISwitch *rotateSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *difficulty;
- (IBAction)goBack:(id)sender;

@end
