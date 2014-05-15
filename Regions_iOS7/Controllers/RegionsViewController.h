//
//  ViewController.h
//  Regions_iOS7
//
//  Created by Dean Woodward on 15/05/14.
//  Copyright (c) 2014 Dean Woodward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RegionsViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>{
}

@property (nonatomic, retain) IBOutlet MKMapView *regionsMapView;
@property (nonatomic, retain) IBOutlet UITableView *updatesTableView;
//@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, retain) NSMutableArray *updateEvents;
@property (nonatomic, retain) CLLocationManager *locationManager;

@end
