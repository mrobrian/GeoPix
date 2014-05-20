//
//  SettingsViewController.m
//  GeoPix
//
//  Created by Brian Halderman on 5/10/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import "SettingsViewController.h"
#import "Constants.h"

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.versionLabel.text = [NSString stringWithFormat:@"v%@", [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]];
    NSInteger difficulty = [[NSUserDefaults standardUserDefaults] integerForKey:DIFFICULTY_KEY];
    self.difficultySetting.selectedSegmentIndex =  difficulty;
}

- (IBAction)done:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:self.difficultySetting.selectedSegmentIndex forKey:DIFFICULTY_KEY];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
