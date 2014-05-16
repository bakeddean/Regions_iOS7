//
//  RegionAnnotatonView.h
//  Regions_iOS7
//
//  Created by Dean Woodward on 16/05/14.
//  Copyright (c) 2014 Dean Woodward. All rights reserved.
//

#import <MapKit/MapKit.h>

@class RegionAnnotation;

@interface RegionAnnotationView : MKPinAnnotationView

@property (nonatomic, assign) MKMapView *map;
@property (nonatomic, assign) RegionAnnotation *theAnnotation;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation;
- (void)updateRadiusOverlay;
- (void)removeRadiusOverlay;

@end
