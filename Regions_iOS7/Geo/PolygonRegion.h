//
//  PolygonRegion.h
//  Regions_iOS7
//
//  Created by Dean Woodward on 22/05/14.
//  Copyright (c) 2014 Dean Woodward. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface PolygonRegion : CLRegion

+ (PolygonRegion *)polygonWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;
+ (PolygonRegion *)polygonWithLocations:(NSArray *)locations;

@property (nonatomic, readonly) CLLocationCoordinate2D *coordinates;
@property (nonatomic, readonly) NSUInteger coordinateCount;
@property (nonatomic, assign, getter = isInside) BOOL inside;

- (id)initWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;
- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate;

// Deans method
//+ (PolygonRegion *)initPolygonRegionWithCoordinates:(NSArray *)coordinates identifier:(NSString *)identifier;

@end
