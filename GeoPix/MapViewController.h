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
- (IBAction)hideLocationView:(id)sender;
- (IBAction)playPuzzle:(id)sender;

- (IBAction)goBack:(id)sender;

@end
