//
//  ViewController.m
//  Regions_iOS7
//
//  Created by Dean Woodward on 15/05/14.
//  Copyright (c) 2014 Dean Woodward. All rights reserved.
//

#import "RegionsViewController.h"
#import "RegionAnnotation.h"
#import "RegionAnnotationView.h"
#import "GeoJsonParser.h"

#define REGION_RADIUS 50

@interface RegionsViewController ()

@end

@implementation RegionsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _updatesTableView.dataSource = self;
    
    // Create empty array to add region events to.
	self.updateEvents = [[NSMutableArray alloc] initWithCapacity:0];
	
	// Create location manager with filters set for battery efficiency.
	self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
	self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters; // kCLDistanceFilterNone  kCLLocationAccuracyNearestTenMeters  kCLLocationAccuracyHundredMeters
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// Start updating location changes.
	[self.locationManager startUpdatingLocation];
    
    _regionsMapView.delegate = self;
    _regionsMapView.showsUserLocation = YES;
}

- (void)viewDidAppear:(BOOL)animated {

	// Get all regions being monitored for this application ... monitored regions persist across app launches.
	NSArray *regions = [[self.locationManager monitoredRegions] allObjects];
    
    // If the location manager has no regions, read them in from the JSON file
    if([regions count] == 0){
        GeoJsonParser *parser = [GeoJsonParser sharedInstance];
        regions = [parser regionsWithJSONFile:@"Regions"];
    }
    
    // Add the regions to the map
    for (int i = 0; i < [regions count]; i++) {
        CLCircularRegion *region = [regions objectAtIndex:i];
        RegionAnnotation *annotation = [[RegionAnnotation alloc] initWithCLCircularRegion:region];
        [self.regionsMapView addAnnotation:annotation];
    }
    
    [self addPolyOverlay];
}

//------------------------------------------------------------------------------
// Add polygon overlay for test purposes.
//------------------------------------------------------------------------------
- (void) addPolyOverlay
{
    CLLocationCoordinate2D commuterLotCoords[5]={
        CLLocationCoordinate2DMake(-41.28610775408706, 174.77821612356817),
        CLLocationCoordinate2DMake(-41.28633751801452, 174.77896714209527),
        CLLocationCoordinate2DMake(-41.287837010094115, 174.7793480157743),
        CLLocationCoordinate2DMake(-41.28792568865442, 174.77855408190538),
        CLLocationCoordinate2DMake(-41.28610775408706, 174.77821612356817)
    };
    
    MKPolygon *commuterPoly1 = [MKPolygon polygonWithCoordinates:commuterLotCoords count:5];
    [self.regionsMapView addOverlay:commuterPoly1];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.updateEvents count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
	cell.textLabel.font = [UIFont systemFontOfSize:15.0];
	cell.textLabel.text = [self.updateEvents objectAtIndex:indexPath.row];
	cell.textLabel.numberOfLines = 4;
	
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if([annotation isKindOfClass:[RegionAnnotation class]]) {
    
		RegionAnnotation *currentAnnotation = (RegionAnnotation *)annotation;
		NSString *annotationIdentifier = [currentAnnotation title];
		RegionAnnotationView *regionView = (RegionAnnotationView *)[_regionsMapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
		
		if (!regionView) {
			regionView = [[RegionAnnotationView alloc] initWithAnnotation:annotation];
			regionView.map = _regionsMapView;
			
			// Create a button for the left callout accessory view of each annotation to remove the annotation and region being monitored.
			UIButton *removeRegionButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[removeRegionButton setFrame:CGRectMake(0., 0., 25., 25.)];
			[removeRegionButton setImage:[UIImage imageNamed:@"RemoveRegion"] forState:UIControlStateNormal];
			
			regionView.leftCalloutAccessoryView = removeRegionButton;
            
		} else {		
			regionView.annotation = annotation;
			regionView.theAnnotation = annotation;
		}
		
		// Update or add the overlay displaying the radius of the region around the annotation.
		[regionView updateRadiusOverlay];
		
		return regionView;		
	}	
	
	return nil;	
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {

    // Create the view for the Circle overlay.
	if([overlay isKindOfClass:[MKCircle class]]){
		MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
		circleView.strokeColor = [UIColor purpleColor];                                 // deprecated
		circleView.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.4];     // deprecated
        circleView.lineWidth = 1.0f;                                                    // deprecated
		
		return circleView;		
	}
    
    // Create the view for the Polygon overlay
    else if([overlay isKindOfClass:[MKPolygon class]]){
        MKPolygonView *polyView = [[MKPolygonView alloc] initWithOverlay:overlay];
        polyView.lineWidth = 1;
        polyView.strokeColor = [UIColor blueColor];
        polyView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        
        return polyView;
    }
	
	return nil;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	if([annotationView isKindOfClass:[RegionAnnotationView class]]) {
		RegionAnnotationView *regionView = (RegionAnnotationView *)annotationView;
		RegionAnnotation *regionAnnotation = (RegionAnnotation *)regionView.annotation;
		
		// If the annotation view is starting to be dragged, remove the overlay and stop monitoring the region.
		if (newState == MKAnnotationViewDragStateStarting) {		
			[regionView removeRadiusOverlay];
			
			[_locationManager stopMonitoringForRegion:regionAnnotation.region];
		}
		
		// Once the annotation view has been dragged and placed in a new location, update and add the overlay and begin monitoring the new region.
		if (oldState == MKAnnotationViewDragStateDragging && newState == MKAnnotationViewDragStateEnding) {
			[regionView updateRadiusOverlay];
			
			CLCircularRegion *newRegion = [[CLCircularRegion alloc] initWithCenter:regionAnnotation.coordinate radius:REGION_RADIUS identifier:[NSString stringWithFormat:@"%f, %f", regionAnnotation.coordinate.latitude, regionAnnotation.coordinate.longitude]];
			regionAnnotation.region = newRegion;
			
			[_locationManager startMonitoringForRegion:regionAnnotation.region];// desiredAccuracy:kCLLocationAccuracyBest];
		}		
	}	
}

//------------------------------------------------------------------------------
// User has tapped the delete button on the callout. Remove the annotation and
// stop monitoring the region.
//------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	RegionAnnotationView *regionView = (RegionAnnotationView *)view;
	RegionAnnotation *regionAnnotation = (RegionAnnotation *)regionView.annotation;
	
	// Stop monitoring the region, remove the radius overlay, and finally remove the annotation from the map.
	[_locationManager stopMonitoringForRegion:regionAnnotation.region];
	[regionView removeRadiusOverlay];
	[_regionsMapView removeAnnotation:regionAnnotation];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError: %@", error);
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);
	
	// Work around a bug in MapKit where user location is not initially zoomed to.
	if (oldLocation == nil) {
		// Zoom to the current user location.
		MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0);
		[_regionsMapView setRegion:userLocation animated:YES];
	}
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region  {
	NSString *event = [NSString stringWithFormat:@"didEnterRegion %@ at %@", region.identifier, [NSDate date]];
	
	[self updateWithEvent:event];
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
	NSString *event = [NSString stringWithFormat:@"didExitRegion %@ at %@", region.identifier, [NSDate date]];
	
	[self updateWithEvent:event];
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
	NSString *event = [NSString stringWithFormat:@"monitoringDidFailForRegion %@: %@", region.identifier, error];
	
	[self updateWithEvent:event];
}

#pragma mark - RegionsViewController

//------------------------------------------------------------------------------
// This method swaps the visibility of the map view and the table of region
// events. The "add region" button in the navigation bar is also altered to only
// be enabled when the map is shown.
//------------------------------------------------------------------------------
- (IBAction)switchView {
	// Swap the hidden status of the map and table view so that the appropriate one is now showing.
	self.regionsMapView.hidden = !self.regionsMapView.hidden;
	self.updatesTableView.hidden = !self.updatesTableView.hidden;
	
	// Adjust the "add region" button to only be enabled when the map is shown.
	NSArray *navigationBarItems = [NSArray arrayWithArray:self.navigationController.navigationBar.items];
	UIBarButtonItem *addRegionButton = [[navigationBarItems objectAtIndex:0] rightBarButtonItem];
	addRegionButton.enabled = !addRegionButton.enabled;
	
	// Reload the table data and update the icon badge number when the table view is shown.
	if (!_updatesTableView.hidden) {
		[_updatesTableView reloadData];
	}
}

//------------------------------------------------------------------------------
// Create a new region - Add it to the map and start monitoring it.
//------------------------------------------------------------------------------
- (IBAction)addRegion {
if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        
		// Create a new region based on the center of the map view.
		CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(_regionsMapView.centerCoordinate.latitude, _regionsMapView.centerCoordinate.longitude);
		CLCircularRegion *newRegion = [[CLCircularRegion alloc] initWithCenter:coord
																	  radius:REGION_RADIUS
																  identifier:[NSString stringWithFormat:@"%f, %f", _regionsMapView.centerCoordinate.latitude, _regionsMapView.centerCoordinate.longitude]];
		
		// Create an annotation to show where the region is located on the map.
		RegionAnnotation *myRegionAnnotation = [[RegionAnnotation alloc] initWithCLCircularRegion:newRegion];
		myRegionAnnotation.coordinate = newRegion.center;
		myRegionAnnotation.radius = newRegion.radius;
		
		[_regionsMapView addAnnotation:myRegionAnnotation];
		
		// Start monitoring the newly created region.
		[_locationManager startMonitoringForRegion:newRegion];// desiredAccuracy:kCLLocationAccuracyBest];
		
	}
	else {
		NSLog(@"Region monitoring is not available.");
	}
}


//------------------------------------------------------------------------------
// This method adds the region event to the events array and updates the icon
// badge number.
//------------------------------------------------------------------------------
- (void)updateWithEvent:(NSString *)event {
	// Add region event to the updates array.
	[self.updateEvents insertObject:event atIndex:0];
	
	// Update the icon badge number.
	[UIApplication sharedApplication].applicationIconBadgeNumber++;
	
	if (!self.updatesTableView.hidden) {
		[self.updatesTableView reloadData];
	}
}

@end
