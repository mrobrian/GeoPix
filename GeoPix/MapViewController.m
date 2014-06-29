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
#import "EnergyHelper.h"
#import <iAd/iAd.h>

@interface MapViewController () {
    NSMutableArray *annotations;
    NSString *locationId;
    NSTimer *energyTimer;
}

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.canDisplayBannerAds = YES;
    
    annotations = [NSMutableArray arrayWithCapacity:0];
}

-(void)viewDidAppear:(BOOL)animated {
    [self updateAnnotations];
    
    NSDictionary *focusedLocation = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_KEY];
    if (focusedLocation == nil) {
        focusedLocation = [LocationHelper locationWithId:@"SAN"];
    }
    [self focusLocation:focusedLocation];
    
    energyTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateEnergy) userInfo:nil repeats:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [self updateEnergy];
}

-(void)viewWillDisappear:(BOOL)animated {
    [energyTimer invalidate];
}

-(void)updateEnergy {
    self.energy.text = [NSString stringWithFormat:@"Energy: %ld", (long)[EnergyHelper currentEnergy]];
    NSTimeInterval nextEnergy = [EnergyHelper nextEnergy];
    if (nextEnergy == -1) {
        self.nextEnergy.hidden = YES;
    } else {
        self.nextEnergy.hidden = NO;
        self.nextEnergy.text = [NSString stringWithFormat:@"Next: %02lu:%02lu", ((long)nextEnergy / 60), ((long)nextEnergy % 60)];
    }
}

-(void)focusLocation:(NSDictionary*)location {
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake([[location objectForKey:@"Latitude"] doubleValue],
                                                               [[location objectForKey:@"Longitude"] doubleValue]);
    self.mapView.region = MKCoordinateRegionMake(self.mapView.centerCoordinate, MKCoordinateSpanMake(15, 15));
    [[NSUserDefaults standardUserDefaults] setObject:location forKey:LAST_LOCATION_KEY];
}

-(void)updateAnnotations {
    [self.mapView removeAnnotations:annotations];

    for (NSDictionary *location in [LocationHelper visibleLocations]) {
        MapViewAnnotation *annotation = [[MapViewAnnotation alloc] initWithLocation:location];
        [annotations addObject:annotation];
        NSArray *connections = [location objectForKey:@"Connections"];
        for (NSString *connectionId in connections) {
            if ([LocationHelper canShowLocation:connectionId]) {
                CLLocationCoordinate2D *coordinates = malloc(sizeof(CLLocationCoordinate2D) * 2);
                coordinates[0] = [[MapViewAnnotation alloc] initWithLocation:[LocationHelper locationWithId:connectionId]].coordinate;
                coordinates[1] = annotation.coordinate;
                MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:2];
                free(coordinates);
                [self.mapView addOverlay:polyline];
            }
        }
    }
    [self.mapView addAnnotations:annotations];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView;
    NSString *locId = [((MapViewAnnotation*)annotation).location objectForKey:@"ID"];
    
    annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"location_annotation"];
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"location_annotation"];
    }
    annotationView.canShowCallout = NO;
    annotationView.backgroundColor = [UIColor blackColor];
    if ([PuzzleHelper solvedPuzzlesForLocation:locId] == 0) {
        annotationView.image = [UIImage imageNamed:@"NewLocation"];
        annotationView.layer.cornerRadius = 12.0f;
    } else {
        NSArray *puzzles = [((MapViewAnnotation*)annotation).location objectForKey:@"Puzzles"];

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(24, 24), NO, 2.0);
        [[PuzzleHelper medalForScore:[PuzzleHelper scoreForLocation:locId withNumber:1]
                         withTarget:[[puzzles[0] objectForKey:@"Target"] integerValue]]
         drawInRect:CGRectMake(0, 0, 12, 12)];
        [[PuzzleHelper medalForScore:[PuzzleHelper scoreForLocation:locId withNumber:2]
                          withTarget:[[puzzles[1] objectForKey:@"Target"] integerValue]]
         drawInRect:CGRectMake(12, 0, 12, 12)];
        [[PuzzleHelper medalForScore:[PuzzleHelper scoreForLocation:locId withNumber:3]
                          withTarget:[[puzzles[2] objectForKey:@"Target"] integerValue]]
         drawInRect:CGRectMake(0, 12, 12, 12)];
        [[PuzzleHelper medalForScore:[PuzzleHelper scoreForLocation:locId withNumber:4]
                          withTarget:[[puzzles[3] objectForKey:@"Target"] integerValue]]
         drawInRect:CGRectMake(12, 12, 12, 12)];
        annotationView.image = UIGraphicsGetImageFromCurrentImageContext();
        annotationView.layer.cornerRadius = 6.0f;
        UIGraphicsEndImageContext();
    }
    
    return annotationView;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *line = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    line.strokeColor = [UIColor blackColor];
    line.lineWidth = 1.0f;
    
    return line;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    // Show information for selected location
    MapViewAnnotation *annotation = (MapViewAnnotation*)view.annotation;
    self.locationTitle.text = annotation.title;
    self.locationView.alpha = 0.0;
    self.locationView.hidden = NO;
    locationId = [annotation.location objectForKey:@"ID"];
    [self focusLocation:annotation.location];
    
    NSArray *puzzles = [annotation.location objectForKey:@"Puzzles"];
    [self updateTargetLabel:self.p1Target withPuzzle:puzzles[0] tag:1];
    [self updateTargetLabel:self.p2Target withPuzzle:puzzles[1] tag:2];
    [self updateTargetLabel:self.p3Target withPuzzle:puzzles[2] tag:3];
    [self updateTargetLabel:self.p4Target withPuzzle:puzzles[3] tag:4];
    self.p1View.backgroundColor = [self backgroundColorForScore:[PuzzleHelper scoreForLocation:locationId withNumber:1]
                                                     withTarget:[[puzzles[0] objectForKey:@"Target"] integerValue]];
    self.p2View.backgroundColor = [self backgroundColorForScore:[PuzzleHelper scoreForLocation:locationId withNumber:2]
                                                     withTarget:[[puzzles[1] objectForKey:@"Target"] integerValue]];
    self.p3View.backgroundColor = [self backgroundColorForScore:[PuzzleHelper scoreForLocation:locationId withNumber:3]
                                                     withTarget:[[puzzles[2] objectForKey:@"Target"] integerValue]];
    self.p4View.backgroundColor = [self backgroundColorForScore:[PuzzleHelper scoreForLocation:locationId withNumber:4]
                                                     withTarget:[[puzzles[3] objectForKey:@"Target"] integerValue]];
    self.p1Medal.image = [PuzzleHelper medalForScore:[PuzzleHelper scoreForLocation:locationId withNumber:1]
                                  withTarget:[[puzzles[0] objectForKey:@"Target"] integerValue]];
    self.p2Medal.image = [PuzzleHelper medalForScore:[PuzzleHelper scoreForLocation:locationId withNumber:2]
                                  withTarget:[[puzzles[1] objectForKey:@"Target"] integerValue]];
    self.p3Medal.image = [PuzzleHelper medalForScore:[PuzzleHelper scoreForLocation:locationId withNumber:3]
                                  withTarget:[[puzzles[2] objectForKey:@"Target"] integerValue]];
    self.p4Medal.image = [PuzzleHelper medalForScore:[PuzzleHelper scoreForLocation:locationId withNumber:4]
                                  withTarget:[[puzzles[3] objectForKey:@"Target"] integerValue]];
    [self.p1Leaderboard reloadData];
    [self.p2Leaderboard reloadData];
    [self.p3Leaderboard reloadData];
    [self.p4Leaderboard reloadData];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.locationView.alpha = 1.0;
    }];
}

-(UIColor*)backgroundColorForScore:(NSInteger)score withTarget:(NSInteger)target {
    UIColor *color;
    
    if (score == 0) {
        color = [UIColor whiteColor];
    } else {
        if (score <= target / 2) { // Gold (255, 215, 0)
            color = [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:0.6];
        } else if (score <= (3 * target) / 4) { // Silver (192, 192, 192)
            color = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:0.6];
        } else { // Bronze (205, 127, 50)
            color = [UIColor colorWithRed:0.8 green:0.5 blue:0.2 alpha:0.6];
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
        [EnergyHelper useEnergy:1];
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
    if ([EnergyHelper hasEnergy]) {
        MapViewAnnotation *annotation = (MapViewAnnotation*)self.mapView.selectedAnnotations[0];
        [self performSegueWithIdentifier:@"MapPlaySegue" sender:@{ @"annotation": annotation, @"tag": [NSNumber numberWithInteger:((UIView*)sender).tag] }];
        self.locationView.hidden = YES;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Out of Energy" message:@"You have run out of Energy. Please wait for your energy to refill." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
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
