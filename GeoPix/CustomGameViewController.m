//
//  CustomGameViewController.m
//  GeoPix
//
//  Created by Brian Halderman on 5/18/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import "CustomGameViewController.h"

@interface CustomGameViewController ()

@end

@implementation CustomGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
