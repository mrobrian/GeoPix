//
//  CustomGameViewController.m
//  GeoPix
//
//  Created by Brian Halderman on 5/18/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import "CustomGameViewController.h"
#import "PuzzleViewController.h"
#import "Constants.h"
#import <iAd/iAd.h>

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CustomPuzzleSegue"]) {
        PuzzleViewController *pvc = segue.destinationViewController;
        pvc.difficulty = self.difficulty.selectedSegmentIndex;
        pvc.rotation = self.rotateSwitch.on;
        pvc.searchBy = self.tagText.text;
        
        pvc.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
    }
}

@end
