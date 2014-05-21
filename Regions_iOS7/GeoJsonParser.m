//
//  GeoJsonParser.m
//  Regions_iOS7
//
//  Created by Dean Woodward on 19/05/14.
//  Copyright (c) 2014 Dean Woodward. All rights reserved.
//

#import "GeoJsonParser.h"
#import <CoreLocation/CoreLocation.h>
#import "BPRegion.h"
#import "BPPolygon.h"

#define FILE_NAME @"Regions"
#define CIRCLE @"CLCircularRegion"
#define POLYGON @"Polygon"


@implementation GeoJsonParser

//------------------------------------------------------------------------------
// Return a singleton instance of class.
//------------------------------------------------------------------------------
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

//------------------------------------------------------------------------------
// Read the Region data from the given JSON file into an array.
//------------------------------------------------------------------------------
- (NSArray *)regionsWithJSONFile:(NSString *)fileName
{
    NSError *error = nil;
    NSMutableArray *regions = [NSMutableArray new];
    
    // Read the JSON file into a dictionary
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"geojson" inDirectory:@"GeoJSON"];
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath] options:kNilOptions error:&error];
    
    // Check error
    
    // Iterate through the JSON array and create the Regions
    NSArray *features = [root objectForKey:@"features"];
    NSMutableSet *polygons = [NSMutableSet new];
    
    [features enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    
        // Get the data we need for CLCircularRegions
        NSDictionary *geometry = [(NSDictionary *)obj objectForKey:@"geometry"];
        
        // Get the type of feature
        NSString *type = (NSString *)[geometry objectForKey:@"type"];
        
        if([type isEqualToString:CIRCLE]){
            NSArray *coordinates = [geometry objectForKey:@"coordinates"];
            double lat = [coordinates[1] doubleValue];
            double lon = [coordinates[0] doubleValue];
            double radius = [[geometry objectForKey:@"radius"] doubleValue];
            
            // Create a new CLCircularRegion and add it to the array
            CLLocationCoordinate2D center = {lat, lon};
            NSString *identifier = [NSString stringWithFormat:@"%f, %f", lat,lon];
            CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:center radius:radius identifier:identifier];
            
            [regions addObject:region];
        }
        
        else if([type isEqualToString:POLYGON]){
            NSArray *coordinates = [[geometry objectForKey:@"coordinates"] firstObject];
            NSMutableArray *locations = [[NSMutableArray alloc] init];
            
            // Iterate through the innermost array - of length 2 containing lat,lon
            for(NSArray *points in coordinates){
                CLLocation *loc = [[CLLocation alloc] initWithLatitude:[points[0] doubleValue] longitude:[points[1] doubleValue]];
                [locations addObject:loc];
            }
            
            // Create a polygon with our location array
            BPPolygon *polygon = [BPPolygon polygonWithLocations:locations];
            [polygons addObject:polygon];
        }
    }];
    
    // A BPRegion can be composed of many polygons, so create this after the iteration
    BPRegion *region = [BPRegion regionWithPolygons:polygons identifier:nil];
    [regions addObject:region];
    
    return regions;
}

@end
