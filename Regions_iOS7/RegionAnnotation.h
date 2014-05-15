//
//  RegionAnnotation.h
//  Regions_iOS7
//
//  Created by Dean Woodward on 16/05/14.
//  Copyright (c) 2014 Dean Woodward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RegionAnnotation : NSObject <MKAnnotation>

@property (nonatomic, retain) CLCircularRegion *region;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) CLLocationDistance radius;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (id)initWithCLCircularRegion:(CLCircularRegion *)newRegion;

@end
