//
//  MapViewController.h
//  GeoPix
//
//  Created by Brian Halderman on 5/19/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LocationView.h"

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet LocationView *locationView;
@property (weak, nonatomic) IBOutlet UILabel *locationTitle;
@property (weak, nonatomic) IBOutlet UILabel *p1Target;
@property (weak, nonatomic) IBOutlet UILabel *p2Target;
@property (weak, nonatomic) IBOutlet UILabel *p3Target;
@property (weak, nonatomic) IBOutlet UILabel *p4Target;
@property (weak, nonatomic) IBOutlet UIImageView *p1Medal;
@property (weak, nonatomic) IBOutlet UIImageView *p2Medal;
@property (weak, nonatomic) IBOutlet UIImageView *p3Medal;
@property (weak, nonatomic) IBOutlet UIImageView *p4Medal;
@property (weak, nonatomic) IBOutlet UIView *p1View;
@property (weak, nonatomic) IBOutlet UIView *p2View;
@property (weak, nonatomic) IBOutlet UIView *p3View;
@property (weak, nonatomic) IBOutlet UIView *p4View;
@property (weak, nonatomic) IBOutlet UILabel *energy;
@property (weak, nonatomic) IBOutlet UILabel *nextEnergy;
@property (weak, nonatomic) IBOutlet UILabel *p1Best;
@property (weak, nonatomic) IBOutlet UILabel *p2Best;
@property (weak, nonatomic) IBOutlet UILabel *p3Best;
@property (weak, nonatomic) IBOutlet UILabel *p4Best;

- (IBAction)hideLocationView:(id)sender;
- (IBAction)playPuzzle:(id)sender;
- (IBAction)goBack:(id)sender;

@end
