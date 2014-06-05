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
#import "PuzzleHelper.h"
#import "LocationHelper.h"
#import "LeaderboardTableViewCell.h"
#import <iAd/iAd.h>

@interface MapViewController () {
    NSMutableArray *annotations;
    NSString *locationId;
}

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.canDisplayBannerAds = YES;
    
    annotations = [NSMutableArray arrayWithCapacity:0];
    
    NSDictionary *focusedLocation = [LocationHelper locationWithId:@"SAN"];
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake([[focusedLocation objectForKey:@"Latitude"] doubleValue], [[focusedLocation objectForKey:@"Longitude"] doubleValue]);
    self.mapView.region = MKCoordinateRegionMake(self.mapView.centerCoordinate, MKCoordinateSpanMake(15, 15));
}

-(void)viewDidAppear:(BOOL)animated {
    [self updateAnnotations];
}

-(void)updateAnnotations {
    [self.mapView removeAnnotations:annotations];
    for (NSDictionary *location in [LocationHelper visibleLocations]) {
        MapViewAnnotation *annotation = [[MapViewAnnotation alloc] initWithLocation:location];
        [annotations addObject:annotation];
        NSArray *connections = [location objectForKey:@"Connections"];
        for (NSString *connectionId in connections) {
            if ([LocationHelper canShowLocation:connectionId]) {
                // TODO: Show connections overlay
            }
        }
    }
    [self.mapView addAnnotations:annotations];
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
    locationId = [annotation.location objectForKey:@"ID"];
    
    NSArray *puzzles = [annotation.location objectForKey:@"Puzzles"];
    [self updateTargetLabel:self.p1Target withPuzzle:puzzles[0] tag:1];
    [self updateTargetLabel:self.p2Target withPuzzle:puzzles[1] tag:2];
    [self updateTargetLabel:self.p3Target withPuzzle:puzzles[2] tag:3];
    [self updateTargetLabel:self.p4Target withPuzzle:puzzles[3] tag:4];
    self.p1View.backgroundColor = [self colorForScore:[PuzzleHelper scoreForLocation:locationId withNumber:1]
                                           withTarget:[[puzzles[0] objectForKey:@"Target"] integerValue]];
    self.p2View.backgroundColor = [self colorForScore:[PuzzleHelper scoreForLocation:locationId withNumber:2]
                                           withTarget:[[puzzles[1] objectForKey:@"Target"] integerValue]];
    self.p3View.backgroundColor = [self colorForScore:[PuzzleHelper scoreForLocation:locationId withNumber:3]
                                           withTarget:[[puzzles[2] objectForKey:@"Target"] integerValue]];
    self.p4View.backgroundColor = [self colorForScore:[PuzzleHelper scoreForLocation:locationId withNumber:4]
                                           withTarget:[[puzzles[3] objectForKey:@"Target"] integerValue]];
    [self.p1Leaderboard reloadData];
    [self.p2Leaderboard reloadData];
    [self.p3Leaderboard reloadData];
    [self.p4Leaderboard reloadData];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.locationView.alpha = 1.0;
    }];
}

-(UIColor*)colorForScore:(NSInteger)score withTarget:(NSInteger)target {
    UIColor *color;
    
    if (score == 0) {
        color = [UIColor lightGrayColor];
    } else {
        if (score <= target / 2) { // Gold (255, 215, 0)
            color = [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0];
        } else if (score <= (3 * target) / 4) { // Silver (192, 192, 192)
            color = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
        } else { // Bronze (205, 127, 50)
            color = [UIColor colorWithRed:0.8 green:0.5 blue:0.2 alpha:1.0];
        }
    }
    return color;
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
        pvc.locationId = locationId;
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
    self.locationView.hidden = YES;
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([PuzzleHelper scoreForLocation:locationId withNumber:tableView.tag % 400] > 0) {
        tableView.hidden = NO;
        return 1;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeaderboardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationLeaderboardCell"];
    cell.placeLabel.text = @"1. me";
    cell.scoreLabel.text = [NSString stringWithFormat:@"%lu", (long)[PuzzleHelper scoreForLocation:locationId withNumber:tableView.tag % 400]];
    
    return cell;
}

@end
