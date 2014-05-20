//
//  CustomGameViewController.m
//  GeoPix
//
//  Created by Brian Halderman on 5/18/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import "CustomGameViewController.h"
#import "Constants.h"

@implementation CustomGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSInteger difficulty = [[NSUserDefaults standardUserDefaults] integerForKey:DIFFICULTY_KEY];
    self.difficulty.selectedSegmentIndex =  difficulty;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
