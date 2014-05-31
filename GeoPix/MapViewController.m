//
//  MapViewController.m
//  GeoPix
//
//  Created by Brian Halderman on 5/19/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import "MapViewController.h"
#import "MapViewAnnotation.h"
#import "PuzzleViewController.h"
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
    annotationView.backgroundColor = [UIColor blackColor];
    annotationView.layer.cornerRadius = 12.0f;
    
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
    
    NSArray *puzzles = [annotation.location objectForKey:@"Puzzles"];
    [self updateTargetLabel:self.p1Target withPuzzle:puzzles[0] tag:1];
    [self updateTargetLabel:self.p2Target withPuzzle:puzzles[1] tag:2];
    [self updateTargetLabel:self.p3Target withPuzzle:puzzles[2] tag:3];
    [self updateTargetLabel:self.p4Target withPuzzle:puzzles[3] tag:4];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.locationView.alpha = 1.0;
    }];
}

-(void)updateTargetLabel:(UILabel*)label withPuzzle:(NSDictionary*)puzzle tag:(NSInteger)tag {
    NSString *target;
    NSInteger targetValue = [[puzzle objectForKey:@"Target"] intValue];
    if (tag % 2 == 0) {
        target = [NSString stringWithFormat:@"%02lu:%02lu", (long)(targetValue / 60), (long)(targetValue % 60)];
    } else {
        target = [NSString stringWithFormat:@"%lu moves", (long)targetValue];
    }
    label.text = [NSString stringWithFormat:@"Target: %@", target];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MapPlaySegue"]) {
        MapViewAnnotation *annotation = (MapViewAnnotation*)[sender objectForKey:@"annotation"];
        PuzzleViewController *pvc = (PuzzleViewController*)segue.destinationViewController;
        NSInteger tag = [[sender objectForKey:@"tag"] intValue] % 500;
        NSArray *puzzles = [annotation.location objectForKey:@"Puzzles"];
        NSDictionary *puzzle = puzzles[tag - 1];
        pvc.difficulty = [[puzzle objectForKey:@"Difficulty"] intValue];
        pvc.target = [[puzzle objectForKey:@"Target"] intValue];
        pvc.rotation = (tag > 2);
        pvc.location = annotation.coordinate;
        pvc.radius = [[annotation.location objectForKey:@"Radius"] intValue];
        pvc.type = tag % 2 == 0 ? TIMED : MOVES;
    }
    
}

- (IBAction)hideLocationView:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.locationView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.locationView.hidden = YES;
        [self.mapView deselectAnnotation:self.mapView.selectedAnnotations[0] animated:NO];
    }];
}

- (IBAction)playPuzzle:(id)sender {
    MapViewAnnotation *annotation = (MapViewAnnotation*)self.mapView.selectedAnnotations[0];
    [self performSegueWithIdentifier:@"MapPlaySegue" sender:@{ @"annotation": annotation, @"tag": [NSNumber numberWithInteger:((UIView*)sender).tag] }];
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:@"LocationLeaderboardCell"];
}

@end
