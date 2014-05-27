//
//  MapViewController.m
//  GeoPix
//
//  Created by Brian Halderman on 5/19/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import "MapViewController.h"
#import "MapViewAnnotation.h"
#import "Constants.h"
#import <iAd/iAd.h>

@interface MapViewController () {
    NSArray *locations;
    NSMutableArray *visibleLocations;
}

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.canDisplayBannerAds = YES;
    
    visibleLocations = [[NSUserDefaults standardUserDefaults] objectForKey:VISIBLE_LOCATIONS_KEY];
    if (visibleLocations == nil) {
        visibleLocations = [NSMutableArray arrayWithObject:@"SAN"];
        [[NSUserDefaults standardUserDefaults] setObject:visibleLocations forKey:VISIBLE_LOCATIONS_KEY];
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"US Cities" ofType:@"plist"];
    locations = [NSArray arrayWithContentsOfFile:path];
    
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *location in locations) {
        if ([visibleLocations containsObject:[location objectForKey:@"ID"]]) {
            MapViewAnnotation *annotation = [[MapViewAnnotation alloc] initWithLocation:location];
            [annotations addObject:annotation];
        }
    }
    [self.mapView addAnnotations:annotations];
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake([[locations[0] objectForKey:@"Latitude"] doubleValue], [[locations[0] objectForKey:@"Longitude"] doubleValue]);
    self.mapView.region = MKCoordinateRegionMake(self.mapView.centerCoordinate, MKCoordinateSpanMake(15, 15));
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView;
    
    annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"location_annotation"];
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"location_annotation"];
    }
    annotationView.canShowCallout = NO;
    annotationView.image = [UIImage imageNamed:@"NewLocation"];
    
    return annotationView;
}
//
//-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
//    
//}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    // Show information for selected location
    MapViewAnnotation *annotation = (MapViewAnnotation*)view.annotation;
    self.locationTitle.text = annotation.title;
    self.locationView.alpha = 0.0;
    self.locationView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.locationView.alpha = 1.0;
    }];
    [mapView deselectAnnotation:annotation animated:NO];
}

- (IBAction)hideLocationView:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.locationView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.locationView.hidden = YES;
    }];
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
