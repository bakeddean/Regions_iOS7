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
#import "PolygonRegion.h"

#define REGION_RADIUS 50
#define OVERLAY_COLOR [UIColor colorWithRed:200/255.0f green:20/255.0f blue:20/255.0f alpha:1.0]

@interface RegionsViewController ()

@property (nonatomic, strong) UITapGestureRecognizer *tapBehindGesture;
@property (nonatomic, strong, readonly) NSDateFormatter *dateFormatter;

@end

@implementation RegionsViewController{
    NSArray *regions;
}

@synthesize dateFormatter = _dateFormatter;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDefaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {

    // If we have no regions, read them in from the JSON file
    if([regions count] == 0){
        GeoJsonParser *parser = [GeoJsonParser sharedInstance];
        regions = [parser regionsWithJSONFile:@"data"];
    }
    
    // Add the regions to the map
    for (int i = 0; i < [regions count]; i++) {
        PolygonRegion *region = [regions objectAtIndex:i];
        MKPolygon *regionOverlay = [MKPolygon polygonWithCoordinates:region.coordinates count:region.coordinateCount];
        [self.regionsMapView addOverlay:regionOverlay];
    }
    
    // Set up the tap gesture recognizer for dismissing the settings form
    if(!_tapBehindGesture) {
        _tapBehindGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBehindDetected:)];
        [_tapBehindGesture setNumberOfTapsRequired:1];
        [_tapBehindGesture setCancelsTouchesInView:NO]; //So the user can still interact with controls in the modal view
    }
    [self.view.window addGestureRecognizer:_tapBehindGesture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[[NSNotificationCenter defaultCenter]removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

#pragma mark - Date Formatter

//------------------------------------------------------------------------------
// Set up a date formatter with local format and short date/time.
//------------------------------------------------------------------------------
- (NSDateFormatter *)dateFormatter
{
    if(!_dateFormatter){
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
        NSLocale *currentLocale = [NSLocale currentLocale];
        [_dateFormatter setLocale:currentLocale];
    }
    return _dateFormatter;
}

#pragma mark - Settings

//------------------------------------------------------------------------------
// Test if the user has tapped outside of the settings screen. If so dismiss
// the settings form.
//------------------------------------------------------------------------------
- (void)tapBehindDetected:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window

        // Convert tap location into the local view's coordinate system. If outside, dismiss the view.
        if (![self.presentedViewController.view pointInside:[self.presentedViewController.view convertPoint:location fromView:self.view.window] withEvent:nil])
        {   
            if(self.presentedViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

//------------------------------------------------------------------------------
// Handle settings changes. Update appplication accordingly.
//------------------------------------------------------------------------------
-(void) onDefaultsChanged:(NSNotification*)notification
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL showOverlays = [defaults boolForKey:@"Overlay_default"];
    if(!showOverlays){
        [_regionsMapView removeOverlays:[_regionsMapView overlays]];
    }
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
    NSString *event = [self.updateEvents objectAtIndex:indexPath.row];
	cell.textLabel.font = [UIFont systemFontOfSize:15.0];
	cell.textLabel.text = event;
	cell.textLabel.numberOfLines = 4;
    
    if([event rangeOfString:@"Entered"].location != NSNotFound)
        cell.imageView.image = [UIImage imageNamed:@"UpArrow"];
    else
        cell.imageView.image = [UIImage imageNamed:@"DownArrow"];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}

#pragma mark - MKMapViewDelegate

/*- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if([annotation isKindOfClass:[RegionAnnotation class]]) {
    
		RegionAnnotation *currentAnnotation = (RegionAnnotation *)annotation;
		NSString *annotationIdentifier = [currentAnnotation title];
		RegionAnnotationView *regionView = (RegionAnnotationView *)[_regionsMapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
		
		if (!regionView) {
            NSLog(@"Creating new region view");
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
		//[regionView updateRadiusOverlay];
        NSLog(@"Updating polygon overlay");
        [regionView updatePolygonOverlay];
		
		return regionView;		
	}	
	
	return nil;	
}*/

//------------------------------------------------------------------------------
// Return the overlay renderer to use when displaying the specified overlay
// object.
//------------------------------------------------------------------------------
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    // Create the renderer for the Polygon overlay
    if([overlay isKindOfClass:[MKPolygon class]]){
        MKPolygonRenderer *polyView = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)overlay];
        polyView.lineWidth = 1;
        polyView.strokeColor = OVERLAY_COLOR;
        polyView.fillColor = [OVERLAY_COLOR colorWithAlphaComponent:0.5];
        return polyView;
    }
	return nil;
}


/*- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
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
			
			CLCircularRegion *newRegion = [[CLCircularRegion alloc] initWithCenter:regionAnnotation.coordinate radius:REGION_RADIUS
                                            identifier:[NSString stringWithFormat:@"%f, %f", regionAnnotation.coordinate.latitude, regionAnnotation.coordinate.longitude]];
			regionAnnotation.region = newRegion;
			
			[_locationManager startMonitoringForRegion:regionAnnotation.region];// desiredAccuracy:kCLLocationAccuracyBest];
		}		
	}	
}*/

//------------------------------------------------------------------------------
// User has tapped the delete button on the callout. Remove the annotation and
// stop monitoring the region.
//------------------------------------------------------------------------------
/*- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	RegionAnnotationView *regionView = (RegionAnnotationView *)view;
	RegionAnnotation *regionAnnotation = (RegionAnnotation *)regionView.annotation;
	
	// Stop monitoring the region, remove the radius overlay, and finally remove the annotation from the map.
	[_locationManager stopMonitoringForRegion:regionAnnotation.region];
	[regionView removeRadiusOverlay];
	[_regionsMapView removeAnnotation:regionAnnotation];
}*/


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError: %@", error);
}

//------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);
	
	// Work around a bug in MapKit where user location is not initially zoomed to.
	if (oldLocation == nil) {
		// Zoom to the current user location.
		MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0);
		[_regionsMapView setRegion:userLocation animated:YES];
	}
    
    // Check if current location is in a PolygonRegion
    // TODO - logic with reguard to overlapping polygons
    for(PolygonRegion *region in regions){
    
        // Entered region
        if(!region.isInside && [region containsCoordinate:newLocation.coordinate]){
        
            // Alert the user
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Boundary Crossing" message:@"Entered Monitored Region" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            //NSString *event = [NSString stringWithFormat:@"Did Enter Region %@ at %@", region.identifier, [NSDate date]];
            
            // Create event and update array/table
            NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
            NSString *event = [NSString stringWithFormat:@"Entered Monitored Region at %@", dateString];
            [self updateWithEvent:event];
            
            region.inside = YES;
            //break;
        }
        // Exited region
        else if(region.isInside && ![region containsCoordinate:newLocation.coordinate]){
        
            // Alert the user
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Boundary Crossing" message:@"Exited Monitored Region" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
            // Create event and update array/table
            NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
            NSString *event = [NSString stringWithFormat:@"Exited Monitored Region at %@", dateString];
            [self updateWithEvent:event];
            
            region.inside = NO;
            //break; // ?
        }
    }
}


/*- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region  {
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
}*/

#pragma mark - RegionsViewController

//------------------------------------------------------------------------------
// Swap the visibility of the map view and the table of region events.
//------------------------------------------------------------------------------
- (IBAction)switchView
{
	// Swap the hidden status of the map and table view so that the appropriate one is now showing.
	self.regionsMapView.hidden = !self.regionsMapView.hidden;
	self.updatesTableView.hidden = !self.updatesTableView.hidden;
		
	// Reload the table data and update the icon badge number when the table view is shown.
	if (!_updatesTableView.hidden) {
		[_updatesTableView reloadData];
	}
}

//------------------------------------------------------------------------------
// Create a new region - Add it to the map and start monitoring it.
//------------------------------------------------------------------------------
- (IBAction)settings {
    NSLog(@"Settings button pushed");
   // UIActionSheet *settingsActionSheet = [[UIActionSheet alloc]initWithTitle:<#(NSString *)#> delegate:<#(id<UIActionSheetDelegate>)#> cancelButtonTitle:<#(NSString *)#> destructiveButtonTitle:<#(NSString *)#> otherButtonTitles:<#(NSString *), ...#>, nil]
    
}

//------------------------------------------------------------------------------
// Add the region event to the events array and update the icon
// badge number. *** TODO - add local notifications ****
//------------------------------------------------------------------------------
- (void)updateWithEvent:(NSString *)event {
	// Add region event to the updates array.
	[self.updateEvents insertObject:event atIndex:0];
	
	// Update the icon badge number.
	[UIApplication sharedApplication].applicationIconBadgeNumber++;
    
    // Create a local notification for entry events
    if([event rangeOfString:@"Entered"].location != NSNotFound){
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date];
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.alertBody = @"Entered Region";
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
	
	if (!self.updatesTableView.hidden) {
		[self.updatesTableView reloadData];
	}
}

@end
